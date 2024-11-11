/*
 * NextStepQueueable Class Description:
 * 
 * Implement the Queueable interface to process records asynchronously.
 * This example processes up to 10 accounts at a time.
 * It removes the Next Step from the accounts and related opportunities.
 *  
 * Benefits of using Queueable methods:
 * 
 * 1. Chaining Jobs: Allows for the chaining of jobs, meaning you can add another job to the queue from a running job.
 * 2. Stateful Execution: Supports stateful execution, which allows member variables to retain their values between job invocations.
 * 3. High Concurrency: Processes large sets of data without hitting governor limits.
 * 4. Flexibility: Useful for operations that need more flexibility in execution, especially when there's a possibility of chaining or performing related async operations.
 * 5. Enhanced Integration Capabilities: Useful for making asynchronous callouts to external systems, allowing for more extended processing times.
 * 
 * For more detailed information, refer to the official Salesforce documentation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_queueing_jobs.htm
 * 
 * Note: The class below contains placeholders for implementing a queueable job to update accounts and opportunities.
 */
public with sharing class NextStepQueueable implements Queueable {
    // Member variable to store the accounts
    private List<Account> accounts;

    // Constructor to accept the accounts
    public NextStepQueueable(List<Account> accounts) {
        this.accounts = accounts;
    }

    // Method to queue the job
    public static void enqueueJob() {
        // Get up to 10 accounts with Next Step populated
        List<Account> accountsToProcess = [SELECT Id, Next_Step__c FROM Account WHERE Next_Step__c != null LIMIT 10];

        // If there are any accounts, queue the job using System.enqueueJob
        if (!accountsToProcess.isEmpty()) {
            System.enqueueJob(new NextStepQueueable(accountsToProcess));
        }
    }

    // Execute method for the Queueable job
    public void execute(QueueableContext context) {
        // Remove the Next Step from accounts
        for (Account acc : accounts) {
            removeNextStep(acc);
        }

        // Update the accounts
        if (!accounts.isEmpty()) {
            update accounts;
        }

        // Get the opportunities related to the accounts
        List<Opportunity> relatedOpportunities = [
            SELECT Id, NextStep FROM Opportunity WHERE AccountId IN :accounts
        ];

        // Remove the Next Step from opportunities
        for (Opportunity opp : relatedOpportunities) {
            removeNextStep(opp);
        }

        // Update the opportunities
        if (!relatedOpportunities.isEmpty()) {
            update relatedOpportunities;
        }

        // Call the enqueueJob method to queue another job to process more records
        enqueueJob();
    }

    // Helper method to remove the Next Step from an opportunity
    private static void removeNextStep(Opportunity opp) {
        opp.NextStep = null;
    }

    // Helper method to remove the Next Step from an account
    private static void removeNextStep(Account acc) {
        acc.Next_Step__c = null;
    }
}