import { LightningElement , wire} from 'lwc';
import getReportAccounts from '@salesforce/apex/CustomReportController.getAccounts';

export default class CustomReport extends LightningElement {
    data = [];
    error = ' ';

    columns = [
        {label : 'Account Name ' , fieldName :'accountName'},
        {label : 'Account Rating ' , fieldName :'accountRating'},
        {label : 'Contact Name ' , fieldName :'contactName'},
        {label : 'Opportunity Amount ' , fieldName :'opportunityAmount'}
       
    ]

    @wire(getReportAccounts)
      wireData({data , error}){
        if(data){
            this.data = data ;
        }
        else if(error){
             this.error = error ;
        }
      
    }
    

}