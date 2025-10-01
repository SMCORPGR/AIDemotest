import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

// Account fields
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import ACCOUNT_TYPE_FIELD from '@salesforce/schema/Account.Type';
import ACCOUNT_INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';

// Apex methods for related records
import getCases from '@salesforce/apex/Account360Controller.getCases';
import getContacts from '@salesforce/apex/Account360Controller.getContacts';
import getOpportunities from '@salesforce/apex/Account360Controller.getOpportunities';

const ACCOUNT_FIELDS = [ACCOUNT_NAME_FIELD, ACCOUNT_TYPE_FIELD, ACCOUNT_INDUSTRY_FIELD];

export default class Account360View extends LightningElement {
    @api recordId;
    @track activeTab = 'cases';
    @track isLoading = false;
    @track error;

    // Data containers
    @track casesData = [];
    @track contactsData = [];
    @track opportunitiesData = [];

    // Record counts
    @track casesCount = 0;
    @track contactsCount = 0;
    @track opportunitiesCount = 0;

    // Wire results for refresh capability
    _casesWireResult;
    _contactsWireResult;
    _opportunitiesWireResult;

    // Wire Account record
    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    account;

    // Wire Cases
    @wire(getCases, { accountId: '$recordId' })
    wiredCases(result) {
        this._casesWireResult = result;
        if (result.data) {
            this.casesData = result.data;
            this.casesCount = result.data.length;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.casesData = [];
            this.casesCount = 0;
        }
    }

    // Wire Contacts
    @wire(getContacts, { accountId: '$recordId' })
    wiredContacts(result) {
        this._contactsWireResult = result;
        if (result.data) {
            this.contactsData = result.data;
            this.contactsCount = result.data.length;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.contactsData = [];
            this.contactsCount = 0;
        }
    }

    // Wire Opportunities
    @wire(getOpportunities, { accountId: '$recordId' })
    wiredOpportunities(result) {
        this._opportunitiesWireResult = result;
        if (result.data) {
            this.opportunitiesData = result.data;
            this.opportunitiesCount = result.data.length;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.opportunitiesData = [];
            this.opportunitiesCount = 0;
        }
    }

    // Getters for account information
    get accountName() {
        return getFieldValue(this.account.data, ACCOUNT_NAME_FIELD);
    }

    get accountType() {
        return getFieldValue(this.account.data, ACCOUNT_TYPE_FIELD);
    }

    get accountIndustry() {
        return getFieldValue(this.account.data, ACCOUNT_INDUSTRY_FIELD);
    }

    // Tab labels with counts
    get casesTabLabel() {
        return `Cases (${this.casesCount})`;
    }

    get contactsTabLabel() {
        return `Contacts (${this.contactsCount})`;
    }

    get opportunitiesTabLabel() {
        return `Opportunities (${this.opportunitiesCount})`;
    }

    // Data availability checks
    get hasCases() {
        return this.casesData && this.casesData.length > 0;
    }

    get hasContacts() {
        return this.contactsData && this.contactsData.length > 0;
    }

    get hasOpportunities() {
        return this.opportunitiesData && this.opportunitiesData.length > 0;
    }

    // Tab visibility
    get showCases() {
        return this.activeTab === 'cases';
    }

    get showContacts() {
        return this.activeTab === 'contacts';
    }

    get showOpportunities() {
        return this.activeTab === 'opportunities';
    }

    // Event handlers
    handleTabChange(event) {
        this.activeTab = event.target.value;
    }

    async handleRefresh() {
        this.isLoading = true;
        try {
            await Promise.all([
                refreshApex(this._casesWireResult),
                refreshApex(this._contactsWireResult),
                refreshApex(this._opportunitiesWireResult)
            ]);
            this.showToast('Success', 'Data refreshed successfully', 'success');
        } catch (error) {
            this.showToast('Error', 'Failed to refresh data', 'error');
            this.error = error;
        } finally {
            this.isLoading = false;
        }
    }

    handleRecordClick(event) {
        const recordId = event.currentTarget.dataset.recordId;
        const recordType = event.currentTarget.dataset.recordType;
        
        // Navigate to record (would implement navigation in real scenario)
        this.showToast('Info', `Navigate to ${recordType}: ${recordId}`, 'info');
    }

    // Utility methods
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

    formatDate(dateString) {
        if (!dateString) return '';
        return new Date(dateString).toLocaleDateString();
    }

    formatCurrency(amount) {
        if (!amount) return '$0';
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(amount);
    }

    // Lifecycle hooks
    connectedCallback() {
        if (!this.recordId) {
            this.error = 'No Account record ID provided';
        }
    }

    disconnectedCallback() {
        // Cleanup if needed
    }

    renderedCallback() {
        // Post-render logic if needed
    }
}
