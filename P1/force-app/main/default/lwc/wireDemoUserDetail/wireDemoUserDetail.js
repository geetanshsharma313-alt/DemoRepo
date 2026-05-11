import { LightningElement, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
const fields = [NAME_FIELD, EMAIL_FIELD, PHONE_FIELD];

export default class WireDemoUserDetail extends LightningElement {
    userId = Id;
    //005gL00000BD6CXQA1
    userDeatils;
    @wire(getRecord, { recordId: '$userId', fields })
    wiredUser({ data, error }) {
        if (data) {
            this.userDeatils = data.fields;
        }
        if (error) {
            console.error(error);
        }
    }

}