import { LightningElement, wire, track } from 'lwc';
import getMyAppointments 
    from '@salesforce/apex/PatientCaseController.getMyAppointments';
import createCase 
    from '@salesforce/apex/PatientCaseController.createCase';
import LightningAlert from 'lightning/alert';
export default class PatientRaiseCase extends LightningElement {

    @track appointmentOptions = [];
    @track providerOptions = [];

    selectedAppointment;
    providerId;
    problemRelatedTo;
    subject;
    description;
    success = false;

    problemOptions = [
        { label: 'Support', value: 'Support' },
        { label: 'Billing Support', value: 'Billing Support' },
        { label: 'Medicine Support', value: 'Medicine Support' }
    ];

    @wire(getMyAppointments)
    wiredAppointments({ data }) {
        if (data) {
            this.appointmentOptions = data.map(app => ({
                label: `${app.Doctor__r.Name} - ${app.Appointment_Date__c}`,
                value: app.Id,
                providerId: app.Doctor__c
            }));
        }
    }

    handleAppointmentChange(event) {
        this.selectedAppointment = event.detail.value;

        const selected = this.appointmentOptions.find(
            opt => opt.value === this.selectedAppointment
        );

        this.providerOptions = [{
            label: selected.label.split('-')[0],
            value: selected.providerId
        }];

        this.providerId = selected.providerId;
    }

    handleProblemChange(e) {
        this.problemRelatedTo = e.detail.value;
    }
    handleSubjectChange(e) {
        this.subject = e.target.value;
    }
    handleDescriptionChange(e) {
        this.description = e.target.value;
    }

    handleSubmit() {
    createCase({
        problemRelatedTo: this.problemRelatedTo,
        subject: this.subject,
        description: this.description,
        appointmentId: this.selectedAppointment,
        providerId: this.providerId
    })
    .then(async () => {

        // ✅ EXPERIENCE-SAFE SUCCESS MESSAGE
        await LightningAlert.open({
            message: 'Case submitted successfully 🎉',
            theme: 'success',
            label: 'Success'
        });

        // ✅ Clear form after alert
        this.resetForm();
    })
    .catch(async err => {
        await LightningAlert.open({
            message: err.body?.message || 'Something went wrong',
            theme: 'error',
            label: 'Error'
        });
    });
}
    resetForm() {
    this.selectedAppointment = null;
    this.providerId = null;
    this.problemRelatedTo = null;
    this.subject = '';
    this.description = '';
    this.providerOptions = [];
    this.success = false;
}
}