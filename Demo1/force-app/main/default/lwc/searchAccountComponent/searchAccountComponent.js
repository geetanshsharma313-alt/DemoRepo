import { LightningElement } from 'lwc';
import getAccounts from '@Salesforce/apex/SearchAccountController.searchAccount';
export default class SearchAccountComponent extends LightningElement {
    SearchKey = ' ';
    accounts = [];
    handleChange(event){
      this.SearchKey = event.target.value;
    }

    handleSave(){
        getAccounts({SearchKey = this.SearchKey})
    }
}