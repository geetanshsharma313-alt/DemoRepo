import { LightningElement, wire, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';

import getAccounts from '@salesforce/apex/AccountOpportunityController.getAccounts';
import getOpportunities from '@salesforce/apex/AccountOpportunityController.getOpportunities';
import linkOpportunities from '@salesforce/apex/AccountOpportunityController.linkOpportunities';

export default class AccountOpportunityLinker extends LightningElement {

    @track accounts = [];
    @track opportunities = [];

    selectedAccountId;
    selectedMappings = {}; // oppId → accountId

    accountSearch = '';
    oppSearch = '';

    // LOAD ACCOUNTS
    @wire(getAccounts, { searchKey: '$accountSearch' })
    wiredAccounts({ data }) {
        if (data) {
            this.accounts = data.map(acc => ({
                ...acc,
                opportunityCount: acc.Opportunities ? acc.Opportunities.length : 0,
                cssClass: 'card'
            }));
        }
    }

    // LOAD OPPORTUNITIES
    @wire(getOpportunities, { searchKey: '$oppSearch' })
    wiredOpps({ data }) {
        if (data) {
            this.opportunities = data.map(opp => ({
                ...opp,
                accountName: opp.Account ? opp.Account.Name : 'Not Linked',
                cssClass: 'card'
            }));
        }
    }

    handleAccountSearch(e) {
        this.accountSearch = e.target.value;
    }

    handleOppSearch(e) {
        this.oppSearch = e.target.value;
    }

    selectAccount(e) {
        this.selectedAccountId = e.currentTarget.dataset.id;

        this.accounts = this.accounts.map(acc => ({
            ...acc,
            cssClass: acc.Id === this.selectedAccountId ? 'card selected' : 'card'
        }));
    }

    selectOpportunity(e) {
        const oppId = e.currentTarget.dataset.id;
        if (!this.selectedAccountId) return;

        this.selectedMappings[oppId] = this.selectedAccountId;

        this.opportunities = this.opportunities.map(opp => {
            if (opp.Id === oppId) {
                return {
                    ...opp,
                    accountName: this.accounts.find(a => a.Id === this.selectedAccountId).Name
                };
            }
            return opp;
        });

        this.accounts = this.accounts.map(acc => {
            if (acc.Id === this.selectedAccountId) {
                return { ...acc, opportunityCount: acc.opportunityCount + 1 };
            }
            return acc;
        });
    }

    save() {
        linkOpportunities({ oppAccountMap: this.selectedMappings })
            .then(() => {
                this.selectedMappings = {};
            });
    }

    cancel() {
        window.location.reload();
    }

    // LDS CREATE
    createAccount() {
        createRecord({ apiName: 'Account' });
    }

    createOpportunity() {
        createRecord({ apiName: 'Opportunity' });
    }
}