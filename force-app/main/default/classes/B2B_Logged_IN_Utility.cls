public class B2B_Logged_IN_Utility {
    
    public static RecordType getRecordType(){
        RecordType recordTypeId=[SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account' Limit 1];
    return recordTypeId;
    }
    
    public static String getPersoncontactId(Account personAccount){
        string PersonContactId;
        Account personConId = [Select PersonContactId From Account where Id = :personAccount.Id];
        if(personConId!=Null)
            PersonContactId=personConId.PersonContactId;
        return PersonContactId;
    }
    
    public static Account getPersonAccountId(String federationIdentifier){
        String contactId;
        Account acc;
        User userContactId=[select contactId from User where FederationIdentifier = :federationIdentifier];
        if(userContactId!=Null)
            acc=[select Id from Account where PersonContactId = :userContactId.contactId];
        return acc;
    }
    public static Profile getProfileDetails(){
        return [Select Name,id from Profile where name =: B2B_Constant.PROFILENAME Limit 1];
    }
    
    public static User getUserId(String federationIdentifier){
        return  [SELECT id from user WHERE federationIdentifier =: federationIdentifier Limit 1];
    }
    
    public static User getUserdetails(String userid){
       return [select id,federationIdentifier,contactid from user where id=:userid Limit 1];
    }
    
    public static Account getPersonAccountDetails(String personContactid){
        return [Select id From Account where PersonContactId = :personContactid Limit 1];
    }
    public static String getMigratedBuyerGroupID(){
        string BuyerGroupId;
        B2B_DreamShop_users__mdt buyerGroupdata=[select id,B2B_Buyer_GroupId__c from B2B_DreamShop_users__mdt where B2B_Is_Active__c=true and B2B_User_Type__c ='Migrated' Limit 1];
        if(buyerGroupdata!=Null)
        BuyerGroupId=buyerGroupdata.B2B_Buyer_GroupId__c;
        return BuyerGroupId;
    }
        public static String getBuyerGroupID(){
        string BuyerGroupId;
        B2B_DreamShop_users__mdt buyerGroupdata=[select id,B2B_Buyer_GroupId__c from B2B_DreamShop_users__mdt where B2B_Is_Active__c=true and B2B_User_Type__c ='Logged In' Limit 1];
        if(buyerGroupdata!=Null)
        BuyerGroupId=buyerGroupdata.B2B_Buyer_GroupId__c;
        return BuyerGroupId;
    }
}