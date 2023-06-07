public class guestUserCleanupBatch implements Database.Batchable<sObject>, Database.Stateful{
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    DateTime dt = System.now();
    DateTime earlier = dt.addMinutes(-360);
    
     public Database.QueryLocator start(Database.BatchableContext bc) {
         system.debug('Time before'+earlier);
         if(Test.isRunningTest()){
        return Database.getQueryLocator(
            [SELECT ID, AccountId, Email, Name, CreatedDate, (SELECT ID, ContactId, IsActive, IsPortalEnabled FROM Users)  FROM Contact 
            Where Name LIKE '%Guest Contact%']
        );
         }
         else
         {
             return Database.getQueryLocator(
            [SELECT ID, AccountId, Email, Name, CreatedDate, (SELECT ID, ContactId, IsActive, IsPortalEnabled FROM Users)  FROM Contact 
            Where Name LIKE '%Guest Contact%' AND CreatedDate<=: earlier]
        );
         }
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope){
       system.debug('Contact list = '+scope.size());
        // process each batch of records
        List<User> users = new List<User>();
        for (Contact contact : scope) {
            for (User user : contact.users) {
                user.IsActive=False;
                user.IsPortalEnabled=False;
                users.add(user);
                // increment the instance member counter
                recordsProcessed = recordsProcessed + 1;
            }
        }
        if(users.size()>0)
        update users;        
        
    }
    public void finish(Database.BatchableContext bc){
       // Database.executeBatch(new guestUserCleanupBatch2(), 50);
        /*System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        EmailUtils.sendMessage(job, recordsProcessed);*/
    }

}