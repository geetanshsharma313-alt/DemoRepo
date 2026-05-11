import { wire, api } from 'lwc';
import LightningModal from 'lightning/modal'
import { getObjectInfo } from 'lightning/uiObjectInfoApi'
import createCase from '@salesforce/apex/SCCaseController.createCase'
import ToastContainer from 'lightning/toastContainer';
import Toast from 'lightning/toast';
export default class ScCreateCaseModal extends LightningModal {

    showSpinner = true;
    @api caseObjName = 'Case';
    @api recordTypeName = 'Support';

    recordTypeId;

    @wire(getObjectInfo, { objectApiName: '$caseObjName' })
    objectInfo({ error, data }) {
        if (data) {
            const recordTypes = data.recordTypeInfos;
            const recordTypeInfo = Object.values(recordTypes).find(rt => rt.name === this.recordTypeName);
            if (recordTypeInfo) {
                this.recordTypeId = recordTypeInfo.recordTypeId;
                console.log('this.recordTypeId. ', this.recordTypeId)
            }
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    connectedCallback(){
        const toastContainer = ToastContainer.instance();
        toastContainer.maxToasts = 5;
        toastContainer.toastPosition = 'top-center';
    }

    handleLoad() {
        this.showSpinner = false;
    }

    handleSubmit(event) {


        event.preventDefault();
        const fields = event.detail.fields;

        this.showSpinner = true;

        createCase({ caseRecord: fields })
            .then(result => {

                if (result == 'success') {
                    console.log(result);
                    Toast.show({
                        label : 'Case Created',
                        message : 'Case Created Successfully!',
                        variant : 'success',
                        mode : 'dismissible'
                    }, this);
                    this.close('okay');
                } else {
                    Toast.show({
                        label : 'Error',
                        message : result,
                        variant : 'error',
                        mode : 'dismissible'
                    }, this);
                }
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                //show a toast message
                Toast.show({
                    label : 'Error',
                    message : 'Error Occurred',
                    variant : 'error',
                    mode : 'dismissible'
                }, this);
            });

    }

}