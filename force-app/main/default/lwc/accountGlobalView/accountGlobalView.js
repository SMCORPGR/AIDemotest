import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getCases from '@salesforce/apex/AccountGlobalController.getCases';
import getContacts from '@salesforce/apex/AccountGlobalController.getContacts';
import getOpportunities from '@salesforce/apex/AccountGlobalController.getOpportunities';
import getAccountSummary from '@salesforce/apex/AccountGlobalController.getAccountSummary';
import getRecentActivities from '@salesforce/apex/AccountGlobalController.getRecentActivities';
import exportData from '@salesforce/apex/AccountGlobalController.exportData';

// Account fields
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import ACCOUNT_TYPE_FIELD from '@salesforce/schema/Account.Type';
import ACCOUNT_INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
import ACCOUNT_ANNUAL_REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';

const ACCOUNT_FIELDS = [
    ACCOUNT_NAME_FIELD,
    ACCOUNT_TYPE_FIELD,
    ACCOUNT_INDUSTRY_FIELD,
    ACCOUNT_ANNUAL_REVENUE_FIELD
];

export default class AccountGlobalView extends NavigationMixin(LightningElement) {
    @api recordId;
    @track activeTab = 'summary';
    @track isLoading = false;
    @track error;
    @track searchTerm = '';
    @track sortField = '';
    @track sortDirection = 'asc';
    @track showFilters = false;
    @track filterCriteria = {};

    // Data properties
    @track accountSummary = {};
    @track casesData = [];
    @track contactsData = [];
    @track opportunitiesData = [];
    @track recentActivities = [];

    // Wired data for refresh capability
    wiredAccountResult;
    wiredCasesResult;
    wiredContactsResult;
    wiredOpportunitiesResult;
    wiredSummaryResult;
    wiredActivitiesResult;

    // Wire Account data
    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    wiredAccount(result) {
        this.wiredAccountResult = result;
        if (result.error) {
            this.handleError('Error loading account data', result.error);
        }
    }

    // Wire Account Summary
    @wire(getAccountSummary, { accountId: '$recordId' })
    wiredSummary(result) {
        this.wiredSummaryResult = result;
        if (result.data) {
            this.accountSummary = result.data;
        } else if (result.error) {
            this.handleError('Error loading account summary', result.error);
        }
    }

    // Wire Cases
    @wire(getCases, { 
        accountId: '$recordId', 
        searchTerm: '$searchTerm',
        sortField: '$sortField',
        sortDirection: '$sortDirection'
    })
    wiredCases(result) {
        this.wiredCasesResult = result;
        if (result.data) {
            this.casesData = result.data;
        } else if (result.error) {
            this.handleError('Error loading cases', result.error);
        }
    }

    // Wire Contacts
    @wire(getContacts, { 
        accountId: '$recordId',
        searchTerm: '$searchTerm',
        sortField: '$sortField',
        sortDirection: '$sortDirection'
    })
    wiredContacts(result) {
        this.wiredContactsResult = result;
        if (result.data) {
            this.contactsData = result.data;
        } else if (result.error) {
            this.handleError('Error loading contacts', result.error);
        }
    }

    // Wire Opportunities
    @wire(getOpportunities, { 
        accountId: '$recordId',
        searchTerm: '$searchTerm',
        sortField: '$sortField',
        sortDirection: '$sortDirection'
    })
    wiredOpportunities(result) {
        this.wiredOpportunitiesResult = result;
        if (result.data) {
            this.opportunitiesData = result.data;
        } else if (result.error) {
            this.handleError('Error loading opportunities', result.error);
        }
    }

    // Wire Recent Activities
    @wire(getRecentActivities, { accountId: '$recordId' })
    wiredActivities(result) {
        this.wiredActivitiesResult = result;
        if (result.data) {
            this.recentActivities = result.data;
        } else if (result.error) {
            this.handleError('Error loading recent activities', result.error);
        }
    }

    // Getters for account data
    get accountName() {
        return getFieldValue(this.wiredAccountResult.data, ACCOUNT_NAME_FIELD);
    }

    get accountType() {
        return getFieldValue(this.wiredAccountResult.data, ACCOUNT_TYPE_FIELD);
    }

    get accountIndustry() {
        return getFieldValue(this.wiredAccountResult.data, ACCOUNT_INDUSTRY_FIELD);
    }

    get accountRevenue() {
        const revenue = getFieldValue(this.wiredAccountResult.data, ACCOUNT_ANNUAL_REVENUE_FIELD);
        return revenue ? new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0
        }).format(revenue) : 'N/A';
    }

    // Tab counts with badges
    get casesTabLabel() {
        const count = this.casesData?.length || 0;
        return `Cases (${count})`;
    }

    get contactsTabLabel() {
        const count = this.contactsData?.length || 0;
        return `Contacts (${count})`;
    }

    get opportunitiesTabLabel() {
        const count = this.opportunitiesData?.length || 0;
        return `Opportunities (${count})`;
    }

    get activitiesTabLabel() {
        const count = this.recentActivities?.length || 0;
        return `Recent Activities (${count})`;
    }

    // Summary metrics
    get totalRevenue() {
        return this.accountSummary.totalRevenue || 0;
    }

    get openCasesCount() {
        return this.accountSummary.openCasesCount || 0;
    }

    get totalContacts() {
        return this.accountSummary.totalContacts || 0;
    }

    get pipelineValue() {
        return this.accountSummary.pipelineValue || 0;
    }

    // Event Handlers
    handleTabChange(event) {
        this.activeTab = event.target.value;
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
    }

    handleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortField = fieldName;
        this.sortDirection = sortDirection;
    }

    toggleFilters() {
        this.showFilters = !this.showFilters;
    }

    async handleRefresh() {
        this.isLoading = true;
        try {
            await Promise.all([
                refreshApex(this.wiredAccountResult),
                refreshApex(this.wiredSummaryResult),
                refreshApex(this.wiredCasesResult),
                refreshApex(this.wiredContactsResult),
                refreshApex(this.wiredOpportunitiesResult),
                refreshApex(this.wiredActivitiesResult)
            ]);
            this.showToast('Success', 'Data refreshed successfully', 'success');
        } catch (error) {
            this.handleError('Error refreshing data', error);
        } finally {
            this.isLoading = false;
        }
    }

    // Quick Actions
    handleNewCase() {
        this.navigateToNewRecord('Case', { AccountId: this.recordId });
    }

    handleNewContact() {
        this.navigateToNewRecord('Contact', { AccountId: this.recordId });
    }

    handleNewOpportunity() {
        this.navigateToNewRecord('Opportunity', { AccountId: this.recordId });
    }

    // Export functionality
    async handleExport(event) {
        const objectType = event.target.dataset.object;
        this.isLoading = true;
        try {
            const result = await exportData({ 
                accountId: this.recordId, 
                objectType: objectType 
            });
            this.downloadCSV(result, `${objectType}_export.csv`);
            this.showToast('Success', `${objectType} data exported successfully`, 'success');
        } catch (error) {
            this.handleError('Error exporting data', error);
        } finally {
            this.isLoading = false;
        }
    }

    // Navigation helper
    navigateToNewRecord(objectApiName, defaultFieldValues) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objectApiName,
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultFieldValues
            }
        });
    }

    // Utility methods
    downloadCSV(csvData, filename) {
        const element = document.createElement('a');
        element.setAttribute('href', 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvData));
        element.setAttribute('download', filename);
        element.style.display = 'none';
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);
    }

    handleError(title, error) {
        console.error(title, error);
        this.error = error;
        this.showToast('Error', title, 'error');
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    // Record navigation
    handleRecordNavigation(event) {
        const recordId = event.target.dataset.recordId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    // Column definitions for data tables
    get caseColumns() {
        return [
            {
                label: 'Case Number',
                fieldName: 'CaseNumber',
                type: 'text',
                sortable: true
            },
            {
                label: 'Subject',
                fieldName: 'Subject',
                type: 'text',
                sortable: true
            },
            {
                label: 'Status',
                fieldName: 'Status',
                type: 'text',
                sortable: true,
                cellAttributes: {
                    class: { fieldName: 'StatusClass' }
                }
            },
            {
                label: 'Priority',
                fieldName: 'Priority',
                type: 'text',
                sortable: true
            },
            {
                label: 'Created Date',
                fieldName: 'CreatedDate',
                type: 'date-local',
                sortable: true
            },
            {
                label: 'Owner',
                fieldName: 'OwnerName',
                type: 'text',
                sortable: true
            }
        ];
    }

    get contactColumns() {
        return [
            {
                label: 'Name',
                fieldName: 'Name',
                type: 'text',
                sortable: true
            },
            {
                label: 'Title',
                fieldName: 'Title',
                type: 'text',
                sortable: true
            },
            {
                label: 'Email',
                fieldName: 'Email',
                type: 'email',
                sortable: true
            },
            {
                label: 'Phone',
                fieldName: 'Phone',
                type: 'phone',
                sortable: true
            },
            {
                label: 'Department',
                fieldName: 'Department',
                type: 'text',
                sortable: true
            },
            {
                label: 'Created Date',
                fieldName: 'CreatedDate',
                type: 'date-local',
                sortable: true
            }
        ];
    }

    get opportunityColumns() {
        return [
            {
                label: 'Opportunity Name',
                fieldName: 'Name',
                type: 'text',
                sortable: true
            },
            {
                label: 'Stage',
                fieldName: 'StageName',
                type: 'text',
                sortable: true,
                cellAttributes: {
                    class: { fieldName: 'StageClass' }
                }
            },
            {
                label: 'Amount',
                fieldName: 'Amount',
                type: 'currency',
                sortable: true,
                typeAttributes: {
                    currencyCode: 'USD'
                }
            },
            {
                label: 'Close Date',
                fieldName: 'CloseDate',
                type: 'date-local',
                sortable: true
            },
            {
                label: 'Probability',
                fieldName: 'Probability',
                type: 'percent',
                sortable: true,
                typeAttributes: {
                    minimumFractionDigits: 0
                }
            },
            {
                label: 'Owner',
                fieldName: 'OwnerName',
                type: 'text',
                sortable: true
            }
        ];
    }
}
