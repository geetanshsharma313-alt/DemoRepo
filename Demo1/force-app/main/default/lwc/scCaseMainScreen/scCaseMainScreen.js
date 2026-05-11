import { LightningElement } from 'lwc';
import CaseCreateModal from 'c/scCreateCaseModal'
import getMyCases from '@salesforce/apex/SCCaseController.getMyCases'
export default class ScCaseMainScreen extends LightningElement {

    cases = [];
    showSpinner = true;

    connectedCallback() {
        this.getCaseRecords();
    }

    getCaseRecords() {
        this.showSpinner = true;
        getMyCases()
            .then(result => {
                if (result) {
                    this.cases = result;
                }
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    async handleClick(event) {
        let action = event.target.name;

        if (action == 'newcase') {
            const casemodalresult = await CaseCreateModal.open({
                size: 'medium'
            })
            if(casemodalresult == 'okay'){
                //Updated case details
                this.getCaseRecords();
            }
        }
       
    }

    handleEvent(event) {
        let spinner = event.detail.spinner;
        let refreshCases = event.detail.refreshCases;

        this.showSpinner = spinner;

        if (refreshCases) {
            //Updated case details
            this.getCaseRecords();
        }
    }

}