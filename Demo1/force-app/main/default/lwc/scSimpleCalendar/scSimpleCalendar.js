import { LightningElement, track } from 'lwc';
import getCurrentUserContactId from '@salesforce/apex/DoctorAppointmentController.getCurrentUserContactId';
import getSpecialities from '@salesforce/apex/DoctorAppointmentController.getSpecialities';
import getDoctorsBySpeciality from '@salesforce/apex/DoctorAppointmentController.getDoctorsBySpeciality';
import getAvailableSlots from '@salesforce/apex/DoctorAppointmentController.getAvailableSlots';
import bookAppointment from '@salesforce/apex/DoctorAppointmentController.bookAppointment';
import getUpcomingAppointments from '@salesforce/apex/DoctorAppointmentController.getUpcomingAppointments';
import LightningAlert from 'lightning/alert';

export default class DoctorAppointmentBooking extends LightningElement {

    @track specialities = [];
    @track doctors = [];
    @track availableSlots = [];
    @track upcomingAppointments = [];

    selectedSpeciality;
    selectedDoctorId;
    selectedDoctorName;

    appointmentDate;
    selectedTime;
    selectedTimeDisplay;
    symptoms = '';

    patientContactId;

    currentStep = 1;
    isLoading = true;
    isSuccess = false;
    showTimeSlots = false;
    errorMessage;

    minDate;
    maxDate;

    connectedCallback() {
        this.setDateLimits();
        this.loadUser();
        this.loadSpecialities();
        this.loadUpcomingAppointments();
    }

    setDateLimits() {
        const today = new Date();
        this.minDate = today.toISOString().split('T')[0];

        const max = new Date();
        max.setDate(max.getDate() + 30);
        this.maxDate = max.toISOString().split('T')[0];
    }

    loadUser() {
        getCurrentUserContactId()
            .then(id => {
                this.patientContactId = id;
            })
            .catch(() => {
                this.patientContactId = null;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    loadSpecialities() {
        getSpecialities()
            .then(data => {
                this.specialities = data.map(v => ({
                    label: v,
                    value: v
                }));
            })
            .catch(() => {
                this.errorMessage = 'Unable to load specialities.';
            });
    }

    handleSpecialityChange(event) {
        this.selectedSpeciality = event.detail.value;
        this.selectedDoctorId = null;
        this.selectedDoctorName = null;
        this.doctors = [];

        getDoctorsBySpeciality({ speciality: this.selectedSpeciality })
            .then(data => {
                this.doctors = data.map(d => ({
                    ...d,
                    cssClass: 'doctor-card'
                }));
            });
    }

    get isStep1() { return this.currentStep === 1; }
    get isStep2() { return this.currentStep === 2; }
    get isStep3() { return this.currentStep === 3; }

    get isStep1Disabled() {
        return !(this.selectedSpeciality && this.selectedDoctorId);
    }

    get isStep2Disabled() {
        return !(this.appointmentDate && this.selectedTime);
    }

    handleDoctorSelect(event) {
        const id = event.currentTarget.dataset.id;
        this.selectedDoctorId = id;

        this.doctors = this.doctors.map(d => ({
            ...d,
            cssClass: d.Id === id ? 'doctor-card selected' : 'doctor-card'
        }));

        this.selectedDoctorName = this.doctors.find(d => d.Id === id)?.Name;
    }

    goToStep2() { this.currentStep = 2; }
    goBackToStep1() { this.currentStep = 1; }
    goToStep3() { this.currentStep = 3; }
    goBackToStep2() { this.currentStep = 2; }

    handleDateChange(event) {
        this.appointmentDate = event.target.value;
        this.selectedTime = null;
        this.selectedTimeDisplay = null;
        this.showTimeSlots = false;
        this.loadSlots();
    }

    /* ----------------- NEW HELPERS ----------------- */

    isToday(dateStr) {
        const today = new Date();
        const selected = new Date(dateStr);

        return (
            today.getFullYear() === selected.getFullYear() &&
            today.getMonth() === selected.getMonth() &&
            today.getDate() === selected.getDate()
        );
    }

    convertToDateTime(timeStr, dateStr) {
        let [time, meridian] = timeStr.split(' ');
        let [hour, minute] = time.split(':').map(Number);

        if (meridian === 'PM' && hour !== 12) hour += 12;
        if (meridian === 'AM' && hour === 12) hour = 0;

        const date = new Date(dateStr);
        date.setHours(hour, minute, 0, 0);

        return date;
    }

    /* ----------------- UPDATED LOGIC ----------------- */

    loadSlots() {
        getAvailableSlots({
            doctorId: this.selectedDoctorId,
            appointmentDate: this.appointmentDate
        }).then(data => {

            const now = new Date();
            const isTodaySelected = this.isToday(this.appointmentDate);

            this.availableSlots = data.map(s => {

                const slotDateTime = this.convertToDateTime(s.displayTime, this.appointmentDate);

                let isPastTime = false;

                if (isTodaySelected) {
                    isPastTime = slotDateTime <= now; // change to < if you want to allow current slot
                }

                return {
                    ...s,
                    cssClass: 'time-slot',
                    disabled: !s.isAvailable || isPastTime,
                    time24: this.convertTo24Hour(s.displayTime)
                };
            });

            this.showTimeSlots = true;
        });
    }

    convertTo24Hour(timeStr) {
        let [time, meridian] = timeStr.split(' ');
        let [hour, minute] = time.split(':').map(Number);

        if (meridian === 'PM' && hour !== 12) hour += 12;
        if (meridian === 'AM' && hour === 12) hour = 0;

        return `${hour.toString().padStart(2, '0')}:${minute
            .toString()
            .padStart(2, '0')}`;
    }

    handleTimeSlotSelect(event) {
        const index = event.currentTarget.dataset.index;
        const slot = this.availableSlots[index];

        if (slot.disabled) return; // 🔥 prevent click

        this.selectedTime = slot.time24;
        this.selectedTimeDisplay = slot.displayTime;

        this.availableSlots = this.availableSlots.map((s, i) => ({
            ...s,
            cssClass: i === Number(index)
                ? 'time-slot selected'
                : 'time-slot'
        }));
    }

    handleSymptomsChange(event) {
        this.symptoms = event.target.value;
    }

    async handleConfirmBooking() {
        try {
            await bookAppointment({
                patientContactId: this.patientContactId,
                doctorId: this.selectedDoctorId,
                appointmentDate: this.appointmentDate,
                startTime: this.selectedTime,
                symptoms: this.symptoms,
                notes: null
            });

            await LightningAlert.open({
                message: 'Appointment booked successfully',
                theme: 'success',
                label: 'Success'
            });

            this.resetForm();
            this.loadUpcomingAppointments();

        } catch (err) {
            await LightningAlert.open({
                message: err.body?.message || 'Booking failed',
                theme: 'error',
                label: 'Error'
            });
        }
    }

    loadUpcomingAppointments() {
        getUpcomingAppointments()
            .then(data => {
                this.upcomingAppointments = data;
            });
    }

    resetForm() {
        this.currentStep = 1;
        this.isSuccess = false;

        this.selectedSpeciality = null;
        this.selectedDoctorId = null;
        this.selectedDoctorName = null;

        this.appointmentDate = null;
        this.selectedTime = null;
        this.selectedTimeDisplay = null;
        this.symptoms = '';

        this.doctors = [];
        this.availableSlots = [];
        this.showTimeSlots = false;

        this.errorMessage = null;
    }
}