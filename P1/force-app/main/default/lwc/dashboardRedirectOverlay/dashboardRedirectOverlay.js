import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class DashboardRedirectOverlay extends NavigationMixin(LightningElement) {
    handleClick() {
        // Navigate to Salesforce Home page
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }
}