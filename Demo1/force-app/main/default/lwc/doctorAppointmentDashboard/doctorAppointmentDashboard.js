import { LightningElement, track, wire } from 'lwc';
import getUpcomingAppointments from '@salesforce/apex/UpcomingDoctorAppointmentPortalClass.getUpcomingAppointments';
import updateAppointmentStatus from '@salesforce/apex/UpcomingDoctorAppointmentPortalClass.updateAppointmentStatus';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DoctorAppointmentDashboard extends LightningElement {

    @track appointments = [];
    @track filteredAppointments = [];
    @track isLoading = true;

    @track showModal = false;
    @track selectedAppointment;
    @track draftStatus;

    searchTerm = '';
    statusFilter = 'All';
    wireResult;

    statusOptions = [
        { label: 'All', value: 'All' },
        { label: 'Requested', value: 'Requested' },
        { label: 'Confirmed', value: 'Confirmed' },
        { label: 'Cancelled', value: 'Cancelled' }
    ];

    updateStatusOptions = [
        { label: 'Requested', value: 'Requested' },
        { label: 'Confirmed', value: 'Confirmed' },
        { label: 'Cancelled', value: 'Cancelled' }
    ];

    @wire(getUpcomingAppointments)
    wiredAppointments(result) {
        this.wireResult = result;
        if (result.data) {
            this.appointments = result.data;
            this.applyFilters();
        }
        this.isLoading = false;
    }

    applyFilters() {
        let data = [...this.appointments];

        if (this.searchTerm) {
            data = data.filter(a =>
                a.patientName.toLowerCase().includes(this.searchTerm) ||
                a.appointmentNumber.toLowerCase().includes(this.searchTerm)
            );
        }

        if (this.statusFilter !== 'All') {
            data = data.filter(a => a.status === this.statusFilter);
        }

        this.filteredAppointments = data;
    }

    handleSearchChange(e) {
        this.searchTerm = e.target.value.toLowerCase();
        this.applyFilters();
    }

    handleStatusFilterChange(e) {
        this.statusFilter = e.detail.value;
        this.applyFilters();
    }

    handleView(e) {
        const id = e.currentTarget.dataset.id;
        this.selectedAppointment = this.appointments.find(a => a.appointmentId === id);
        this.draftStatus = this.selectedAppointment.status;
        this.showModal = true;
    }

    handleStatusDraft(e) {
        const id = e.currentTarget.dataset.id;
        const value = e.detail.value;

        this.appointments = this.appointments.map(a =>
            a.appointmentId === id ? { ...a, status: value } : a
        );
        this.applyFilters();
    }

    handleModalStatusChange(e) {
        this.draftStatus = e.detail.value;
    }

    async handleSaveStatus() {
        try {
            this.isLoading = true;
            await updateAppointmentStatus({
                appointmentId: this.selectedAppointment.appointmentId,
                newStatus: this.draftStatus
            });
            this.showToast('Success', 'Status updated successfully', 'success');
            this.showModal = false;
            await refreshApex(this.wireResult);
        } finally {
            this.isLoading = false;
        }
    }

    closeModal() {
        this.showModal = false;
    }

    handleRefresh() {
        this.isLoading = true;
        refreshApex(this.wireResult).finally(() => this.isLoading = false);
    }

    get hasNoAppointments() {
        return !this.isLoading && this.filteredAppointments.length === 0;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}