import { createElement } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import AccountGlobalView from 'c/accountGlobalView';
import getCases from '@salesforce/apex/AccountGlobalController.getCases';
import getContacts from '@salesforce/apex/AccountGlobalController.getContacts';
import getOpportunities from '@salesforce/apex/AccountGlobalController.getOpportunities';
import getAccountSummary from '@salesforce/apex/AccountGlobalController.getAccountSummary';
import getRecentActivities from '@salesforce/apex/AccountGlobalController.getRecentActivities';
import exportData from '@salesforce/apex/AccountGlobalController.exportData';

// Mock the Apex methods
jest.mock(
    '@salesforce/apex/AccountGlobalController.getCases',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/AccountGlobalController.getContacts',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/AccountGlobalController.getOpportunities',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/AccountGlobalController.getAccountSummary',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/AccountGlobalController.getRecentActivities',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/AccountGlobalController.exportData',
    () => {
        return { default: jest.fn() };
    },
    { virtual: true }
);

// Mock lightning/uiRecordApi
jest.mock('lightning/uiRecordApi', () => {
    const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
    return {
        getRecord: createApexTestWireAdapter(jest.fn())
    };
}, { virtual: true });

// Mock lightning/platformShowToastEvent
jest.mock('lightning/platformShowToastEvent', () => {
    return {
        ShowToastEvent: jest.fn()
    };
}, { virtual: true });

// Mock lightning/navigation
jest.mock('lightning/navigation', () => {
    return {
        NavigationMixin: (Base) => {
            return class extends Base {
                [Symbol.for('NavigationMixin.Navigate')] = jest.fn();
            };
        }
    };
}, { virtual: true });

describe('c-account-global-view', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    // Mock data
    const mockAccountRecord = {
        fields: {
            Name: { value: 'Test Account' },
            Type: { value: 'Customer' },
            Industry: { value: 'Technology' },
            AnnualRevenue: { value: 1000000 }
        }
    };

    const mockCasesData = [
        {
            Id: '500xx0000000001',
            CaseNumber: '00001001',
            Subject: 'Test Case 1',
            Status: 'New',
            Priority: 'High',
            CreatedDate: '2024-01-01T00:00:00.000Z',
            OwnerName: 'Test Owner',
            StatusClass: 'status-open'
        }
    ];

    const mockContactsData = [
        {
            Id: '003xx0000000001',
            Name: 'Test Contact',
            Title: 'Manager',
            Email: 'test@example.com',
            Phone: '555-0001',
            Department: 'Sales',
            CreatedDate: '2024-01-01T00:00:00.000Z'
        }
    ];

    const mockOpportunitiesData = [
        {
            Id: '006xx0000000001',
            Name: 'Test Opportunity',
            StageName: 'Prospecting',
            Amount: 50000,
            CloseDate: '2024-12-31',
            Probability: 25,
            OwnerName: 'Test Owner',
            StageClass: 'stage-prospecting'
        }
    ];

    const mockAccountSummary = {
        totalRevenue: 150000,
        openCasesCount: 2,
        totalContacts: 5,
        pipelineValue: 100000
    };

    const mockRecentActivities = [
        {
            Id: '00Txx0000000001',
            Subject: 'Test Task',
            Description: 'Test task description',
            CreatedDate: '2024-01-01T00:00:00.000Z',
            Type: 'Task',
            IconName: 'utility:task'
        }
    ];

    it('renders component with default tab', () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        // Check if the component renders
        const card = element.shadowRoot.querySelector('.account-global-view');
        expect(card).toBeTruthy();

        // Check if the default tab is summary
        const tabset = element.shadowRoot.querySelector('lightning-tabset');
        expect(tabset).toBeTruthy();
        expect(tabset.activeTabValue).toBe('summary');
    });

    it('displays account information in header', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        // Emit mock data for account record
        getRecord.emit(mockAccountRecord);

        await Promise.resolve();

        // Check if account name is displayed
        const headerText = element.shadowRoot.querySelector('.slds-text-body_small');
        expect(headerText).toBeTruthy();
    });

    it('displays cases data correctly', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        // Emit mock cases data
        getCases.emit(mockCasesData);

        await Promise.resolve();

        // Check if cases tab label includes count
        const casesTab = element.shadowRoot.querySelector('lightning-tab[value="cases"]');
        expect(casesTab).toBeTruthy();
    });

    it('displays contacts data correctly', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        // Emit mock contacts data
        getContacts.emit(mockContactsData);

        await Promise.resolve();

        // Check if contacts tab exists
        const contactsTab = element.shadowRoot.querySelector('lightning-tab[value="contacts"]');
        expect(contactsTab).toBeTruthy();
    });

    it('displays opportunities data correctly', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        // Emit mock opportunities data
        getOpportunities.emit(mockOpportunitiesData);

        await Promise.resolve();

        // Check if opportunities tab exists
        const opportunitiesTab = element.shadowRoot.querySelector('lightning-tab[value="opportunities"]');
        expect(opportunitiesTab).toBeTruthy();
    });

    it('displays account summary metrics', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        // Emit mock summary data
        getAccountSummary.emit(mockAccountSummary);

        await Promise.resolve();

        // Check if metric cards are displayed
        const metricCards = element.shadowRoot.querySelectorAll('.metric-card');
        expect(metricCards.length).toBeGreaterThan(0);
    });

    it('displays recent activities', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        // Emit mock activities data
        getRecentActivities.emit(mockRecentActivities);

        await Promise.resolve();

        // Check if activities tab exists
        const activitiesTab = element.shadowRoot.querySelector('lightning-tab[value="activities"]');
        expect(activitiesTab).toBeTruthy();
    });

    it('handles tab change correctly', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        await Promise.resolve();

        // Simulate tab change
        const tabset = element.shadowRoot.querySelector('lightning-tabset');
        tabset.dispatchEvent(new CustomEvent('active', {
            detail: { value: 'cases' }
        }));

        await Promise.resolve();

        expect(element.activeTab).toBe('cases');
    });

    it('handles search input correctly', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        // Show filters first
        element.showFilters = true;

        await Promise.resolve();

        // Simulate search input
        const searchInput = element.shadowRoot.querySelector('lightning-input[type="search"]');
        expect(searchInput).toBeTruthy();

        searchInput.value = 'test search';
        searchInput.dispatchEvent(new CustomEvent('change', {
            detail: { value: 'test search' }
        }));

        await Promise.resolve();

        expect(element.searchTerm).toBe('test search');
    });

    it('handles refresh action correctly', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        await Promise.resolve();

        // Simulate refresh button click
        const refreshButton = element.shadowRoot.querySelector('lightning-button[label="Refresh"]');
        expect(refreshButton).toBeTruthy();

        refreshButton.click();

        await Promise.resolve();

        // Check if loading state is handled
        expect(element.isLoading).toBe(false);
    });

    it('handles quick action buttons correctly', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        await Promise.resolve();

        // Test new case button
        const newCaseButton = element.shadowRoot.querySelector('lightning-button[label="New Case"]');
        expect(newCaseButton).toBeTruthy();
        newCaseButton.click();
        // Navigation should be called (mocked)

        // Test new contact button
        const newContactButton = element.shadowRoot.querySelector('lightning-button[label="New Contact"]');
        expect(newContactButton).toBeTruthy();
        newContactButton.click();
        // Navigation should be called (mocked)

        // Test new opportunity button
        const newOpportunityButton = element.shadowRoot.querySelector('lightning-button[label="New Opportunity"]');
        expect(newOpportunityButton).toBeTruthy();
        newOpportunityButton.click();
        // Navigation should be called (mocked)
    });

    it('handles export functionality correctly', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        // Mock the export method
        exportData.mockResolvedValue('test,csv,data\n1,2,3');

        await Promise.resolve();

        // Simulate export button click
        const exportButton = element.shadowRoot.querySelector('lightning-button[label="Export"]');
        expect(exportButton).toBeTruthy();

        exportButton.dataset.object = 'Case';
        exportButton.click();

        await Promise.resolve();

        expect(exportData).toHaveBeenCalledWith({
            accountId: '001xx0000000001',
            objectType: 'Case'
        });
    });

    it('handles error states correctly', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        // Emit error for cases
        getCases.error();

        await Promise.resolve();

        // Check if error is handled
        expect(element.error).toBeTruthy();
    });

    it('toggles filters correctly', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        await Promise.resolve();

        // Initial state
        expect(element.showFilters).toBe(false);

        // Simulate filters button click
        const filtersButton = element.shadowRoot.querySelector('lightning-button[label="Filters"]');
        filtersButton.click();

        await Promise.resolve();

        expect(element.showFilters).toBe(true);
    });

    it('displays empty states correctly', async () => {
        const element = createElement('c-account-global-view', {
            is: AccountGlobalView
        });
        element.recordId = '001xx0000000001';
        document.body.appendChild(element);

        // Emit empty data
        getCases.emit([]);
        getContacts.emit([]);
        getOpportunities.emit([]);
        getRecentActivities.emit([]);

        await Promise.resolve();

        // Check if empty state illustrations are shown
        const illustrations = element.shadowRoot.querySelectorAll('.slds-illustration');
        expect(illustrations.length).toBeGreaterThan(0);
    });
});
