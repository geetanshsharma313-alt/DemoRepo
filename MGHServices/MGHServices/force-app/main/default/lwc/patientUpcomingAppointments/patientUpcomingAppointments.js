import { LightningElement, track } from 'lwc';
import getUpcomingAppointments from
    '@salesforce/apex/DoctorAppointmentController.getUpcomingAppointments';

export default class PatientUpcomingAppointments extends LightningElement {

    @track appointments = [];
    isLoading = true;
    errorMessage;

    connectedCallback() {
        this.loadAppointments();
    }

    loadAppointments() {
        this.isLoading = true;
        this.errorMessage = null;

        getUpcomingAppointments()
            .then(data => {
                this.appointments = data.map(a => ({
                    id: a.Id,
                    doctorName: a.Doctor__r?.Name,
                    speciality: a.Doctor__r?.Speciality__c,
                    date: a.Appointment_Date__c,
                    time: this.formatTime(a.Start_Time__c),
                    status: a.Appointment_Status__c
                }));
            })
            .catch(error => {
                console.error(error);
                this.errorMessage = 'Unable to load appointments.';
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    formatTime(timeVal) {
        if (!timeVal) return '';
        const ms = Number(timeVal);
        const date = new Date(ms);
        return date.toLocaleTimeString([], {
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    get hasAppointments() {
        return this.appointments.length > 0;
    }
}