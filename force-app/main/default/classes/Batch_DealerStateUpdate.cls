global class Batch_DealerStateUpdate implements Database.Batchable<sObject>,schedulable {
    //Lakshmi HDMP-19479 Batch process to update sales tax 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String accountType='Partner 1';
        // collect the list of dealers which do not have any sales tax jurisdiction assigned and update the values with dealers billing state
        String query = 'SELECT Id, Name,BillingState,Sales_Tax_Jurisdiction__c FROM Account WHERE recordtype.Name=:accountType AND BillingState!=null AND Sales_Tax_Jurisdiction__c = null'; 
        System.debug('Query ::' + query);
        return Database.getQueryLocator(query);
    }
    
    global Batch_DealerStateUpdate() {
    }

    global void execute(Database.BatchableContext BC, List<Account> accountList){
        List<Account> acntList = new List<Account>();
        for(Account  acntObj : accountList){
            acntObj.Sales_Tax_Jurisdiction__c = acntObj.BillingState;
            acntList.add(acntObj);
        }
        update acntList;
       }
   
    global void execute(SchedulableContext SC) {
        database.executebatch(new Batch_DealerStateUpdate());
    }
   
    global static void start(integer hour){
        string jobName = 'DealerStateUpdate';
        if (hour == 0) database.executebatch(new Batch_DealerStateUpdate());
    else {
        jobName = jobName += ' - ' + datetime.now().format();
        string cron = '0 0 ' + string.valueof(hour) + ' * * ?';
        system.schedule(jobName, cron, new Batch_DealerStateUpdate());
    }
    }
    global void finish(Database.BatchableContext BC){
    }
}