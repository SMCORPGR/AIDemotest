/**
 * @description Controller class for Account360View Lightning Web Component
 * Provides methods to retrieve related records for Account 360 view
 * @author Augment Code
 * @version 1.0
 */
public with sharing class Account360Controller {
    
    /**
     * @description Retrieves Cases related to the specified Account
     * @param accountId The ID of the Account
     * @return List of Cases with essential fields
     */
    @AuraEnabled(cacheable=true)
    public static List<Case> getCases(Id accountId) {
        try {
            if (accountId == null) {
                throw new IllegalArgumentException('Account ID cannot be null');
            }
            
            return [
                SELECT Id, CaseNumber, Subject, Status, Priority, CreatedDate, 
                       LastModifiedDate, Owner.Name, Type, Origin
                FROM Case 
                WHERE AccountId = :accountId 
                ORDER BY CreatedDate DESC 
                LIMIT 100
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving Cases: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves Contacts related to the specified Account
     * @param accountId The ID of the Account
     * @return List of Contacts with essential fields
     */
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Id accountId) {
        try {
            if (accountId == null) {
                throw new IllegalArgumentException('Account ID cannot be null');
            }
            
            return [
                SELECT Id, Name, Title, Email, Phone, MobilePhone, 
                       Department, LastModifiedDate, CreatedDate
                FROM Contact 
                WHERE AccountId = :accountId 
                ORDER BY Name ASC 
                LIMIT 100
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving Contacts: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves Opportunities related to the specified Account
     * @param accountId The ID of the Account
     * @return List of Opportunities with essential fields
     */
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(Id accountId) {
        try {
            if (accountId == null) {
                throw new IllegalArgumentException('Account ID cannot be null');
            }
            
            return [
                SELECT Id, Name, StageName, Amount, CloseDate, Probability, 
                       Type, LeadSource, Owner.Name, CreatedDate, LastModifiedDate
                FROM Opportunity 
                WHERE AccountId = :accountId 
                ORDER BY CloseDate DESC 
                LIMIT 100
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving Opportunities: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves summary statistics for Account related records
     * @param accountId The ID of the Account
     * @return Map containing count statistics
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getAccountSummary(Id accountId) {
        try {
            if (accountId == null) {
                throw new IllegalArgumentException('Account ID cannot be null');
            }
            
            Map<String, Integer> summary = new Map<String, Integer>();
            
            // Get Cases count
            Integer casesCount = [SELECT COUNT() FROM Case WHERE AccountId = :accountId];
            summary.put('casesCount', casesCount);
            
            // Get Contacts count
            Integer contactsCount = [SELECT COUNT() FROM Contact WHERE AccountId = :accountId];
            summary.put('contactsCount', contactsCount);
            
            // Get Opportunities count
            Integer opportunitiesCount = [SELECT COUNT() FROM Opportunity WHERE AccountId = :accountId];
            summary.put('opportunitiesCount', opportunitiesCount);
            
            // Get Open Cases count
            Integer openCasesCount = [SELECT COUNT() FROM Case WHERE AccountId = :accountId AND IsClosed = false];
            summary.put('openCasesCount', openCasesCount);
            
            // Get Open Opportunities count
            Integer openOpportunitiesCount = [SELECT COUNT() FROM Opportunity WHERE AccountId = :accountId AND IsClosed = false];
            summary.put('openOpportunitiesCount', openOpportunitiesCount);
            
            return summary;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving Account summary: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves recent activities for the Account
     * @param accountId The ID of the Account
     * @return List of recent activities (Tasks and Events)
     */
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecentActivities(Id accountId) {
        try {
            if (accountId == null) {
                throw new IllegalArgumentException('Account ID cannot be null');
            }
            
            List<SObject> activities = new List<SObject>();
            
            // Get recent Tasks
            List<Task> tasks = [
                SELECT Id, Subject, Status, Priority, ActivityDate, 
                       CreatedDate, Owner.Name, Type
                FROM Task 
                WHERE AccountId = :accountId 
                ORDER BY CreatedDate DESC 
                LIMIT 25
            ];
            activities.addAll(tasks);
            
            // Get recent Events
            List<Event> events = [
                SELECT Id, Subject, StartDateTime, EndDateTime, 
                       CreatedDate, Owner.Name, Type
                FROM Event 
                WHERE AccountId = :accountId 
                ORDER BY CreatedDate DESC 
                LIMIT 25
            ];
            activities.addAll(events);
            
            return activities;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving recent activities: ' + e.getMessage());
        }
    }
    
    /**
     * @description Custom exception class for illegal arguments
     */
    public class IllegalArgumentException extends Exception {}
}
