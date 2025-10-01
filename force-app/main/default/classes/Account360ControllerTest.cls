/**
 * @description Test class for Account360Controller
 * Provides comprehensive test coverage for all controller methods
 * @author Augment Code
 * @version 1.0
 */
@isTest
public class Account360ControllerTest {
    
    /**
     * @description Test data setup method
     */
    @TestSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account 360',
            Type = 'Customer',
            Industry = 'Technology'
        );
        insert testAccount;
        
        // Create test Contacts
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 1; i <= 5; i++) {
            testContacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact ' + i,
                AccountId = testAccount.Id,
                Email = 'test.contact' + i + '@example.com',
                Phone = '555-000' + i,
                Title = 'Test Title ' + i
            ));
        }
        insert testContacts;
        
        // Create test Cases
        List<Case> testCases = new List<Case>();
        for (Integer i = 1; i <= 3; i++) {
            testCases.add(new Case(
                Subject = 'Test Case ' + i,
                AccountId = testAccount.Id,
                Status = i == 1 ? 'New' : 'In Progress',
                Priority = i == 1 ? 'High' : 'Medium',
                Origin = 'Web'
            ));
        }
        insert testCases;
        
        // Create test Opportunities
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for (Integer i = 1; i <= 4; i++) {
            testOpportunities.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                AccountId = testAccount.Id,
                StageName = i <= 2 ? 'Prospecting' : 'Closed Won',
                CloseDate = Date.today().addDays(30 * i),
                Amount = 10000 * i,
                Type = 'New Customer'
            ));
        }
        insert testOpportunities;
        
        // Create test Tasks
        List<Task> testTasks = new List<Task>();
        for (Integer i = 1; i <= 2; i++) {
            testTasks.add(new Task(
                Subject = 'Test Task ' + i,
                AccountId = testAccount.Id,
                Status = 'Not Started',
                Priority = 'Normal',
                ActivityDate = Date.today().addDays(i)
            ));
        }
        insert testTasks;
        
        // Create test Events
        List<Event> testEvents = new List<Event>();
        for (Integer i = 1; i <= 2; i++) {
            testEvents.add(new Event(
                Subject = 'Test Event ' + i,
                AccountId = testAccount.Id,
                StartDateTime = DateTime.now().addDays(i),
                EndDateTime = DateTime.now().addDays(i).addHours(1)
            ));
        }
        insert testEvents;
    }
    
    /**
     * @description Test getCases method with valid Account ID
     */
    @isTest
    static void testGetCases_ValidAccountId() {
        // Get test account
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 360' LIMIT 1];
        
        Test.startTest();
        List<Case> cases = Account360Controller.getCases(testAccount.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(3, cases.size(), 'Should return 3 cases');
        System.assertNotEquals(null, cases[0].CaseNumber, 'Case number should not be null');
        System.assertNotEquals(null, cases[0].Subject, 'Case subject should not be null');
        System.assertNotEquals(null, cases[0].Status, 'Case status should not be null');
    }
    
    /**
     * @description Test getCases method with null Account ID
     */
    @isTest
    static void testGetCases_NullAccountId() {
        Test.startTest();
        try {
            Account360Controller.getCases(null);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Account ID cannot be null'), 
                         'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getContacts method with valid Account ID
     */
    @isTest
    static void testGetContacts_ValidAccountId() {
        // Get test account
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 360' LIMIT 1];
        
        Test.startTest();
        List<Contact> contacts = Account360Controller.getContacts(testAccount.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(5, contacts.size(), 'Should return 5 contacts');
        System.assertNotEquals(null, contacts[0].Name, 'Contact name should not be null');
        System.assertNotEquals(null, contacts[0].Email, 'Contact email should not be null');
        
        // Verify ordering (should be by Name ASC)
        System.assert(contacts[0].Name <= contacts[1].Name, 'Contacts should be ordered by name');
    }
    
    /**
     * @description Test getContacts method with null Account ID
     */
    @isTest
    static void testGetContacts_NullAccountId() {
        Test.startTest();
        try {
            Account360Controller.getContacts(null);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Account ID cannot be null'), 
                         'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getOpportunities method with valid Account ID
     */
    @isTest
    static void testGetOpportunities_ValidAccountId() {
        // Get test account
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 360' LIMIT 1];
        
        Test.startTest();
        List<Opportunity> opportunities = Account360Controller.getOpportunities(testAccount.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(4, opportunities.size(), 'Should return 4 opportunities');
        System.assertNotEquals(null, opportunities[0].Name, 'Opportunity name should not be null');
        System.assertNotEquals(null, opportunities[0].StageName, 'Opportunity stage should not be null');
        System.assertNotEquals(null, opportunities[0].CloseDate, 'Opportunity close date should not be null');
    }
    
    /**
     * @description Test getOpportunities method with null Account ID
     */
    @isTest
    static void testGetOpportunities_NullAccountId() {
        Test.startTest();
        try {
            Account360Controller.getOpportunities(null);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Account ID cannot be null'), 
                         'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getAccountSummary method with valid Account ID
     */
    @isTest
    static void testGetAccountSummary_ValidAccountId() {
        // Get test account
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 360' LIMIT 1];
        
        Test.startTest();
        Map<String, Integer> summary = Account360Controller.getAccountSummary(testAccount.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(3, summary.get('casesCount'), 'Should return correct cases count');
        System.assertEquals(5, summary.get('contactsCount'), 'Should return correct contacts count');
        System.assertEquals(4, summary.get('opportunitiesCount'), 'Should return correct opportunities count');
        System.assertNotEquals(null, summary.get('openCasesCount'), 'Should return open cases count');
        System.assertNotEquals(null, summary.get('openOpportunitiesCount'), 'Should return open opportunities count');
    }
    
    /**
     * @description Test getAccountSummary method with null Account ID
     */
    @isTest
    static void testGetAccountSummary_NullAccountId() {
        Test.startTest();
        try {
            Account360Controller.getAccountSummary(null);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Account ID cannot be null'), 
                         'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getRecentActivities method with valid Account ID
     */
    @isTest
    static void testGetRecentActivities_ValidAccountId() {
        // Get test account
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 360' LIMIT 1];
        
        Test.startTest();
        List<SObject> activities = Account360Controller.getRecentActivities(testAccount.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(4, activities.size(), 'Should return 4 activities (2 tasks + 2 events)');
        
        // Verify we have both Tasks and Events
        Boolean hasTask = false;
        Boolean hasEvent = false;
        for (SObject activity : activities) {
            if (activity instanceof Task) {
                hasTask = true;
            } else if (activity instanceof Event) {
                hasEvent = true;
            }
        }
        System.assert(hasTask, 'Should include Task records');
        System.assert(hasEvent, 'Should include Event records');
    }
    
    /**
     * @description Test getRecentActivities method with null Account ID
     */
    @isTest
    static void testGetRecentActivities_NullAccountId() {
        Test.startTest();
        try {
            Account360Controller.getRecentActivities(null);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Account ID cannot be null'), 
                         'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test methods with non-existent Account ID
     */
    @isTest
    static void testMethods_NonExistentAccountId() {
        // Create a fake Account ID
        Id fakeAccountId = '001000000000000AAA';
        
        Test.startTest();
        
        // Test all methods with non-existent ID - should return empty lists
        List<Case> cases = Account360Controller.getCases(fakeAccountId);
        List<Contact> contacts = Account360Controller.getContacts(fakeAccountId);
        List<Opportunity> opportunities = Account360Controller.getOpportunities(fakeAccountId);
        Map<String, Integer> summary = Account360Controller.getAccountSummary(fakeAccountId);
        List<SObject> activities = Account360Controller.getRecentActivities(fakeAccountId);
        
        Test.stopTest();
        
        // Assertions - should return empty results, not errors
        System.assertEquals(0, cases.size(), 'Should return empty cases list');
        System.assertEquals(0, contacts.size(), 'Should return empty contacts list');
        System.assertEquals(0, opportunities.size(), 'Should return empty opportunities list');
        System.assertEquals(0, summary.get('casesCount'), 'Should return zero cases count');
        System.assertEquals(0, activities.size(), 'Should return empty activities list');
    }
    
    /**
     * @description Test bulk data handling (governor limits)
     */
    @isTest
    static void testBulkDataHandling() {
        // Create account with many related records to test limits
        Account bulkAccount = new Account(
            Name = 'Bulk Test Account',
            Type = 'Customer'
        );
        insert bulkAccount;
        
        // Create many contacts (but within test limits)
        List<Contact> bulkContacts = new List<Contact>();
        for (Integer i = 1; i <= 50; i++) {
            bulkContacts.add(new Contact(
                FirstName = 'Bulk',
                LastName = 'Contact ' + i,
                AccountId = bulkAccount.Id,
                Email = 'bulk.contact' + i + '@example.com'
            ));
        }
        insert bulkContacts;
        
        Test.startTest();
        List<Contact> retrievedContacts = Account360Controller.getContacts(bulkAccount.Id);
        Test.stopTest();
        
        // Should handle bulk data correctly
        System.assertEquals(50, retrievedContacts.size(), 'Should handle bulk contact retrieval');
    }
}
