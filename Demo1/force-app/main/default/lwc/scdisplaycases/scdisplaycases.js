import { LightningElement, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';

import ID_FIELD from '@salesforce/schema/Case.Id';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import IS_ESCALATED from '@salesforce/schema/Case.IsEscalated';

import ToastContainer from 'lightning/toastContainer';
import Toast from 'lightning/toast';

import CommentsModal from 'c/scCommentsModal';

export default class ScDisplayCases extends LightningElement {

    @api cases;

    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxToasts = 5;
        toastContainer.toastPosition = 'top-center';
    }

    async handleClick(event) {
        const action = event.currentTarget.name;
        const caseRec = event.currentTarget.value;

        switch (action) {
            case 'escalate':
                this.handleEscalate(caseRec);
                break;

            case 'reopen':
                this.handleReopen(caseRec);
                break;

            case 'comments':
                await this.openCommentsModal(caseRec);
                break;
        }
    }

    handleReopen(caseRec) {
        const fields = {
            [ID_FIELD.fieldApiName]: caseRec.Id,
            [STATUS_FIELD.fieldApiName]: 'New'
        };
        this.updateCase(fields);
    }

    handleEscalate(caseRec) {
        const fields = {
            [ID_FIELD.fieldApiName]: caseRec.Id,
            [IS_ESCALATED.fieldApiName]: true
        };
        this.updateCase(fields);
    }

    async openCommentsModal(caseRec) {
        const result = await CommentsModal.open({
            size: 'medium',
            content: caseRec
        });

        if (result === 'okay') {
            Toast.show({
                label: 'Success',
                message: 'Case Comment Posted Successfully',
                variant: 'success'
            }, this);

            this.raiseEvent(false, true);
        }
    }

    updateCase(fields) {
        this.raiseEvent(true, false);

        updateRecord({ fields })
            .then(() => {
                Toast.show({
                    label: 'Success',
                    message: 'Case updated successfully',
                    variant: 'success'
                }, this);

                this.raiseEvent(false, true);
            })
            .catch(error => {
                Toast.show({
                    label: 'Error',
                    message: error.body?.message || 'Unexpected error',
                    variant: 'error'
                }, this);

                this.raiseEvent(false, false);
            });
    }

    raiseEvent(spinner, refreshCases) {
        this.dispatchEvent(
            new CustomEvent('sccaseevent', {
                detail: { spinner, refreshCases }
            })
        );
    }
}