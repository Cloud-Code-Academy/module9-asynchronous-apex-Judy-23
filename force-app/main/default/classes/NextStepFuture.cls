/*
 * NextStepFuture Class Description:
 *
 * Question 1: Create a future method that updates all account and opportunities next step to 'Meeting in the future'
 * Question 2: Create a method that inserts a big deal opportunity and updates the user role name to 'CRO'
 *
 * Benefits of using future methods:
 *
 * 1. Asynchronous Processing: Allows long-running operations to be handled in the background, freeing up resources.
 * 2. Governor Limit Management: Asynchronous methods have a separate set of limits, providing more flexibility.
 * 3. User Experience Enhancement: Improves responsiveness in user interfaces by offloading processes to the background.
 * 4. Mixed DML Operations Handling: Helps overcome Mixed DML errors by allowing updates on setup and non-setup objects.
 * 5. Enhanced Integration Capabilities: Useful for making callouts to external systems without blocking the user interaction.
 *
 * For more detailed information, refer to the official Salesforce documentation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_invoking_future_methods.htm
 *
 * Note: The class below contains placeholders for implementing a future method to update accounts and opportunities.
 *       The accompanying test class 'AsynchronousTest' should also be updated to test this method.
 */
public with sharing class NextStepFuture {

    /* 
     * Question 1
     * Update/Uncomment the template code to create a method
     * Create a future method that updates all account and opportunities next step to 'Meeting in the future'
     * Account Next Step field is a custom field
     * Opportunity Next Step field is a standard field
     * Update the corresponding test class AsynchronousTest and test method nextStepFuture_testUpdateAllNextStep to cover test this method
     */
    //[public | private ] [static] data_type method_name (input parameters) {
    //  The body of the method
    //}

    /*
    * Question 2
    * Update/Uncomment the template code to create a method
    * Create a method that inserts a big deal opportunity and updates the user role name to 'CRO'
    * Update the corresponding test class AsynchronousTest and test method nextStepFuture_testCreateDealAndUpdateRole to cover test this method
    */
    //Mix DML Error happens when you try to perform DML operations on setup and non-setup objects in a single transaction.
    @future
    public static void updateAllNextStep(Set<Id> accountIds, Set<Id> oppIds) {
        List<Account> accountsToUpdate = [SELECT Id FROM Account WHERE Id IN :accountIds];
        for (Account acc : accountsToUpdate) {
            acc.Next_Step__c = 'Meeting in the future';
        }
        update accountsToUpdate;

        List<Opportunity> oppsToUpdate = [SELECT Id FROM Opportunity WHERE Id IN :oppIds];
        for (Opportunity opp : oppsToUpdate) {
            opp.NextStep = 'Meeting in the future';
        }
        update oppsToUpdate;
    }

    // Enqueues a Queueable job to insert the "Big Deal" and update roles
    public static void createDealAndUpdateRole() {
        System.enqueueJob(new InsertBigDealQueueable());
    }

    // Queueable class to insert Opportunity and update user roles
    public class InsertBigDealQueueable implements Queueable {
        public void execute(QueueableContext context) {
            Opportunity bigDeal = new Opportunity(
                Name = 'Big Deal', 
                Amount = 1000000, 
                StageName = 'Closed Won', 
                CloseDate = Date.today()
            );
            insert bigDeal;

            updateUserRoleName();
        }
    }

    // Helper method to update or create the "CRO" user role
    private static void updateUserRoleName() {
        List<UserRole> roles = [SELECT Id, Name FROM UserRole WHERE Name = 'CRO' LIMIT 1];

        UserRole role;
        if (roles.isEmpty()) {
            role = new UserRole(
                Name = 'CRO', 
                portalType = 'None', 
                CaseAccessForAccountOwner = 'Edit'
            );
        } else {
            role = roles[0];
            role.Name = 'CRO'; // Ensure name is correctly set
        }
        upsert role;
    }
}