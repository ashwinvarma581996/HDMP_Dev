public class guestUserCleanupBatch2 implements Database.Batchable<sObject>{
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    DateTime dt = System.now();
    DateTime earlier = dt.addMinutes(-360);
    
     public Database.QueryLocator start(Database.BatchableContext bc) {
         system.debug('Time before'+earlier);
        return Database.getQueryLocator(
            [SELECT ID, Email, Name, CreatedDate FROM Contact 
            Where Name LIKE '%Guest Contact%' AND CreatedDate<=: earlier]
        );
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope){
       system.debug('Contact list = '+scope);
        // process each batch of records
   
        if(scope.size()>0) delete scope;
        
        
    }
    public void finish(Database.BatchableContext bc){
        /*
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        EmailUtils.sendMessage(job, recordsProcessed);*/
    }

}