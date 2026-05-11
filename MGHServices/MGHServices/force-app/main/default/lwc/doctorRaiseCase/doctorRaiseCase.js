import { LightningElement, track, wire } from 'lwc';
import getDoctorAppointments from '@salesforce/apex/PatientCaseController.getDoctorAppointments';
import createProviderCase from '@salesforce/apex/PatientCaseController.createProviderCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DoctorRaiseCase extends LightningElement {

    problemRelatedTo;
    appointmentId;
    subject;
    description;

    appointmentOptions = [];

    problemOptions = [
    { label: 'Support', value: 'Support' },
    { label: 'Billing Support', value: 'Billing Support' },
    { label: 'Medicine Support', value: 'Medicine Support' }
];

    @wire(getDoctorAppointments)
    wiredAppointments({ data }) {
        if (data) {
            this.appointmentOptions = data.map(item => {
                return {
                    label: item.Patient__r.Name + ' - ' + item.Appointment_Date__c,
                    value: item.Id
                };
            });
        }
    }

    handleProblemChange(event) {
        this.problemRelatedTo = event.detail.value;
    }

    handleAppointmentChange(event) {
        this.appointmentId = event.detail.value;
    }

    handleSubject(event) {
        this.subject = event.target.value;
    }

    handleDescription(event) {
        this.description = event.target.value;
    }

    createCase() {

        createProviderCase({
            problemRelatedTo: this.problemRelatedTo,
            subject: this.subject,
            description: this.description,
            appointmentId: this.appointmentId
        })
        .then(result => {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Case created successfully',
                    variant: 'success'
                })
            );

        })
        .catch(error => {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );

        });

    }
}