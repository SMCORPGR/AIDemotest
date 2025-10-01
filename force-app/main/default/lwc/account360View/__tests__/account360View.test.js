import { createElement } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import Account360View from 'c/account360View';

// Mock Apex methods
import getCases from '@salesforce/apex/Account360Controller.getCases';
import getContacts from '@salesforce/apex/Account360Controller.getContacts';
import getOpportunities from '@salesforce/apex/Account360Controller.getOpportunities';

// Mock data
const mockAccount = {
    Id: '0011234567890123',
    Name: 'Test Account',
    Type: 'Customer',
    Industry: 'Technology'
};

const mockCases = [
    {
        Id: '5001234567890123',
        CaseNumber: '00001001',
        Subject: 'Test Case 1',
        Status: 'New',
        Priority: 'High',
        CreatedDate: '2023-01-01T00:00:00.000Z'
    },
    {
        Id: '5001234567890124',
        CaseNumber: '00001002',
        Subject: 'Test Case 2',
        Status: 'In Progress',
        Priority: 'Medium',
        CreatedDate: '2023-01-02T00:00:00.000Z'
    }
];

const mockContacts = [
    {
        Id: '0031234567890123',
        Name: 'John Doe',
        Title: 'CEO',
        Email: 'john.doe@test.com',
        Phone: '555-1234'
    },
    {
        Id: '0031234567890124',
        Name: 'Jane Smith',
        Title: 'CTO',
        Email: 'jane.smith@test.com',
        Phone: '555-5678'
    }
];

const mockOpportunities = [
    {
        Id: '0061234567890123',
        Name: 'Test Opportunity 1',
        StageName: 'Prospecting',
        Amount: 100000,
        CloseDate: '2023-12-31'
    },
    {
        Id: '0061234567890124',
        Name: 'Test Opportunity 2',
        StageName: 'Closed Won',
        Amount: 250000,
        CloseDate: '2023-06-30'
    }
];

// Mock the Apex methods
jest.mock(
    '@salesforce/apex/Account360Controller.getCases',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/Account360Controller.getContacts',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/Account360Controller.getOpportunities',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

// Mock lightning/uiRecordApi
jest.mock('lightning/uiRecordApi', () => {
    const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
    return {
        getRecord: createApexTestWireAdapter(jest.fn()),
        getFieldValue: jest.fn()
    };
});

describe('c-account360-view', () => {
    afterEach(() => {
        // Clean up DOM after each test
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Clear all mocks
        jest.clearAllMocks();
    });

    // Helper function to create component
    function createComponent(recordId = '0011234567890123') {
        const element = createElement('c-account360-view', {
            is: Account360View
        });
        element.recordId = recordId;
        document.body.appendChild(element);
        return element;
    }

    describe('Component Rendering', () => {
        it('renders with correct title and icon', () => {
            const element = createComponent();

            const card = element.shadowRoot.querySelector('lightning-card');
            expect(card).toBeTruthy();
            expect(card.title).toBe('Account 360 View');
            expect(card.iconName).toBe('standard:account');
        });

        it('displays refresh button', () => {
            const element = createComponent();

            const refreshButton = element.shadowRoot.querySelector('lightning-button-icon[icon-name="utility:refresh"]');
            expect(refreshButton).toBeTruthy();
            expect(refreshButton.alternativeText).toBe('Refresh Data');
        });

        it('renders tabset with correct tabs', () => {
            const element = createComponent();

            const tabset = element.shadowRoot.querySelector('lightning-tabset');
            expect(tabset).toBeTruthy();

            const tabs = element.shadowRoot.querySelectorAll('lightning-tab');
            expect(tabs).toHaveLength(3);
            expect(tabs[0].value).toBe('cases');
            expect(tabs[1].value).toBe('contacts');
            expect(tabs[2].value).toBe('opportunities');
        });
    });

    describe('Data Loading and Display', () => {
        it('displays account information when data is loaded', async () => {
            const element = createComponent();

            // Mock getRecord wire
            getRecord.emit(mockAccount);

            await Promise.resolve();

            // Check if account header is displayed
            const accountHeader = element.shadowRoot.querySelector('.account-header');
            expect(accountHeader).toBeTruthy();
        });

        it('displays cases data correctly', async () => {
            const element = createComponent();

            // Emit mock data
            getCases.emit(mockCases);

            await Promise.resolve();

            // Check cases tab content
            const casesTable = element.shadowRoot.querySelector('lightning-tab[value="cases"] table');
            expect(casesTable).toBeTruthy();

            const caseRows = element.shadowRoot.querySelectorAll('lightning-tab[value="cases"] tbody tr');
            expect(caseRows).toHaveLength(2);
        });

        it('displays contacts data correctly', async () => {
            const element = createComponent();

            // Emit mock data
            getContacts.emit(mockContacts);

            await Promise.resolve();

            // Check contacts tab content
            const contactsTable = element.shadowRoot.querySelector('lightning-tab[value="contacts"] table');
            expect(contactsTable).toBeTruthy();

            const contactRows = element.shadowRoot.querySelectorAll('lightning-tab[value="contacts"] tbody tr');
            expect(contactRows).toHaveLength(2);
        });

        it('displays opportunities data correctly', async () => {
            const element = createComponent();

            // Emit mock data
            getOpportunities.emit(mockOpportunities);

            await Promise.resolve();

            // Check opportunities tab content
            const opportunitiesTable = element.shadowRoot.querySelector('lightning-tab[value="opportunities"] table');
            expect(opportunitiesTable).toBeTruthy();

            const opportunityRows = element.shadowRoot.querySelectorAll('lightning-tab[value="opportunities"] tbody tr');
            expect(opportunityRows).toHaveLength(2);
        });
    });

    describe('Tab Functionality', () => {
        it('switches tabs correctly', async () => {
            const element = createComponent();

            const tabset = element.shadowRoot.querySelector('lightning-tabset');
            
            // Simulate tab change to contacts
            tabset.dispatchEvent(new CustomEvent('active', {
                detail: { value: 'contacts' }
            }));

            await Promise.resolve();

            expect(element.activeTab).toBe('contacts');
        });

        it('displays correct tab labels with counts', async () => {
            const element = createComponent();

            // Emit mock data
            getCases.emit(mockCases);
            getContacts.emit(mockContacts);
            getOpportunities.emit(mockOpportunities);

            await Promise.resolve();

            const tabs = element.shadowRoot.querySelectorAll('lightning-tab');
            expect(tabs[0].label).toContain('Cases (2)');
            expect(tabs[1].label).toContain('Contacts (2)');
            expect(tabs[2].label).toContain('Opportunities (2)');
        });
    });

    describe('Error Handling', () => {
        it('displays error message when data loading fails', async () => {
            const element = createComponent();

            // Emit error
            const error = { body: { message: 'Test error message' } };
            getCases.error(error);

            await Promise.resolve();

            const errorMessage = element.shadowRoot.querySelector('.slds-alert_error');
            expect(errorMessage).toBeTruthy();
            expect(errorMessage.textContent).toContain('Test error message');
        });

        it('handles missing recordId gracefully', () => {
            const element = createComponent(null);

            expect(element.error).toBe('No Account record ID provided');
        });
    });

    describe('Empty States', () => {
        it('displays empty state for cases when no data', async () => {
            const element = createComponent();

            // Emit empty array
            getCases.emit([]);

            await Promise.resolve();

            const emptyState = element.shadowRoot.querySelector('lightning-tab[value="cases"] .slds-illustration');
            expect(emptyState).toBeTruthy();
            expect(emptyState.textContent).toContain('No Cases Found');
        });

        it('displays empty state for contacts when no data', async () => {
            const element = createComponent();

            // Emit empty array
            getContacts.emit([]);

            await Promise.resolve();

            const emptyState = element.shadowRoot.querySelector('lightning-tab[value="contacts"] .slds-illustration');
            expect(emptyState).toBeTruthy();
            expect(emptyState.textContent).toContain('No Contacts Found');
        });

        it('displays empty state for opportunities when no data', async () => {
            const element = createComponent();

            // Emit empty array
            getOpportunities.emit([]);

            await Promise.resolve();

            const emptyState = element.shadowRoot.querySelector('lightning-tab[value="opportunities"] .slds-illustration');
            expect(emptyState).toBeTruthy();
            expect(emptyState.textContent).toContain('No Opportunities Found');
        });
    });

    describe('User Interactions', () => {
        it('handles refresh button click', async () => {
            const element = createComponent();

            const refreshButton = element.shadowRoot.querySelector('lightning-button-icon[icon-name="utility:refresh"]');
            refreshButton.click();

            await Promise.resolve();

            // Verify loading state is set
            expect(element.isLoading).toBe(true);
        });

        it('handles record click events', async () => {
            const element = createComponent();

            // Mock showToast method
            element.showToast = jest.fn();

            // Emit mock data
            getCases.emit(mockCases);

            await Promise.resolve();

            // Click on a case link
            const caseLink = element.shadowRoot.querySelector('lightning-tab[value="cases"] a');
            caseLink.click();

            await Promise.resolve();

            expect(element.showToast).toHaveBeenCalledWith(
                'Info',
                expect.stringContaining('Navigate to Case'),
                'info'
            );
        });
    });

    describe('Accessibility', () => {
        it('has proper ARIA attributes', () => {
            const element = createComponent();

            const tables = element.shadowRoot.querySelectorAll('table');
            tables.forEach(table => {
                expect(table.className).toContain('slds-table');
            });

            const headers = element.shadowRoot.querySelectorAll('th');
            headers.forEach(header => {
                expect(header.getAttribute('scope')).toBe('col');
            });
        });

        it('has proper table structure for screen readers', async () => {
            const element = createComponent();

            getCases.emit(mockCases);

            await Promise.resolve();

            const table = element.shadowRoot.querySelector('lightning-tab[value="cases"] table');
            const thead = table.querySelector('thead');
            const tbody = table.querySelector('tbody');

            expect(thead).toBeTruthy();
            expect(tbody).toBeTruthy();

            const headerCells = thead.querySelectorAll('th');
            expect(headerCells.length).toBeGreaterThan(0);
        });
    });

    describe('Responsive Design', () => {
        it('applies responsive classes correctly', () => {
            const element = createComponent();

            const scrollableElements = element.shadowRoot.querySelectorAll('.slds-scrollable_y');
            scrollableElements.forEach(el => {
                expect(el.style.height).toBe('300px');
            });
        });
    });
});
