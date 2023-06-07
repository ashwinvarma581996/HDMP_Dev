public without sharing class AccountSelector {




     // This method is used to retrieve the Account details.
     @AuraEnabled(cacheable=true)
     public static List<Account> getAccountList() {
         return [SELECT Id, phone, Name FROM Account where IsBuyer = true LIMIT 10];
     }
     
     @AuraEnabled
     public static void SetupExternalManagedAccount(string accountId) {
         DelegatedAccount degAcc = new DelegatedAccount ();
         User u = [select firstname,id, contactId, contact.account.name, contact.accountId from user where id = :UserInfo.getUserId() ];
         degAcc.TargetId = accountId;
         degAcc.ManagedById = UserInfo.getUserId();
         degAcc.Name = accountId+'-'+ u.FirstName;
         degAcc.AccessBuyFor = true;
         //degAcc.ManagedById = accountId;
         //
         try 
         {
            insert degAcc;
         } 
         catch(DmlException e)
          {
             System.debug('The following exception has occurred: ' + e.getMessage());
         }
         
     }
}