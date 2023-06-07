/**************************************************************************************
@File Name      : B2B_LoggedInUserAddressCheck  
@Description    : This class is to store the customer address
@Created By		: SAILAKSHMAN KANUKOLLU
@Business Unit  : HDM
@Created Date   : 12/15/2021
@API Version    : 54.0
@TEST Code      : B2B_LoggedInUserAddressCheckTest
*****************************************************************************************
MODIFICATIONS – Date        | Dev Name         | Method                     | User Story 
                            |                  |                            | 
*****************************************************************************************/ 
public without sharing class  B2B_LoggedInUserAddressCheck {
    @AuraEnabled
    public static List<My_Address_Book__c> loggedInuser(){
        List<User> loggedInUser = new List<User>();
        loggedInUser = [SELECT Id,Name,Contact.Name,ContactId,Contact.Account.Name,Contact.Account.BillingPostalCode FROM User WHERE Id=:userinfo.getUserId()];
        if(loggedInUser.size() > 0){
            String contactName = loggedInUser[0].contact.Name;
            Id contactId = loggedInUser[0].contactId;
            List<My_Address_Book__c> addressBookList =[SELECT Id,Name,Address__c,City__c,Phone__c,Notes__c,State__c,Country__c,Zip__c FROM My_Address_Book__c WHERE Person_Address_Account__r.PersonContactId =:contactId and isPreferred__c=true ORDER BY createdDate DESC];
            if(!contactName.containsIgnoreCase('Guest Contact') && addressBookList.size() > 0 ){
                return addressBookList;
            }
        }
        return (new List<My_Address_Book__c>());
    }

    @AuraEnabled
    public static List<My_Address_Book__c> loggedInuserAddressList(){
        List<User> loggedInUser = new List<User>();
        loggedInUser = [SELECT Id,ContactId FROM User WHERE Id=:userinfo.getUserId()];
        if(loggedInUser.size() > 0){
            Id contactId = loggedInUser[0].contactId;
            //commented by shalini soni on 11-05-2022 for HDMP-8707
            List<My_Address_Book__c> addressBookList =[SELECT Id,Name,NickName__c, isPreferred__c,Address__c,Address_Type__c ,City__c,Phone__c,Notes__c,State__c,Country__c,Zip__c FROM My_Address_Book__c WHERE Person_Address_Account__r.PersonContactId =:contactId Order By Name Asc];//,Email__c
            Set<My_Address_Book__c> addressBookSet = new Set<My_Address_Book__c>();
            List<My_Address_Book__c> addressBookList1 = new List<My_Address_Book__c>();
            List<My_Address_Book__c> addressBookList2 = new List<My_Address_Book__c>();
            if(addressBookList.size() > 0){
                for(My_Address_Book__c addr: addressBookList){
                    addressBookList1.add(addr);
                    if(addr.isPreferred__c){
                        addressBookList1.add(0, addr);
                    }
                }
                addressBookSet.addAll(addressBookList1); // To remove duplicate records
                addressBookList2.addAll(addressBookSet); // To return final list of records
                return addressBookList2;
            }
        }
        return (new List<My_Address_Book__c>());
    }

    @AuraEnabled
    public static Map<String, String> loggedInuserAllAddressList(){
        List<User> loggedInUser = new List<User>();
        Map<String, String> wrapdata = new Map<String, String>();
        wrapdata.put('My_Account_Address',JSON.serialize(new List<Account>()));
        loggedInUser = [SELECT Contact.AccountId FROM User WHERE Id=:userinfo.getUserId()];
        if(loggedInUser.size() > 0){
            if(loggedInUser[0].Contact.AccountId != NULL){
                Id accountId = loggedInUser[0].Contact.AccountId;
                Account acc = [SELECT Id, Name, PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry FROM Account Where Id =: accountId];
                wrapdata.put('My_Account_Address',JSON.serialize(new List<Account>{acc}));
            }
        }
        wrapdata.put('My_Address_Book_Address',JSON.serialize(loggedInuserAddressList()));
        return wrapdata;
    }
    @AuraEnabled
    public static List<My_Address_Book__c> deleteAddressBook(string addressId){
        try{
            My_Address_Book__c deleteRecord = [SELECT Id,isPreferred__c FROM My_Address_Book__c WHERE Id =:addressId];
            List<BT_Payment_Method__c> paymentList = new List<BT_Payment_Method__c>();
            Boolean isRecordDelete;
            Integer count = 0;
            
            for (BT_Payment_Method__c paymentObj : paymentList) {
                isRecordDelete = B2B_BrainTreeUtils.deleteBTVaultPaymentMethod(paymentObj.Payment_Method_Token__c);
                    count = isRecordDelete == true ? count + 1 : count ;
            }

            if (!paymentList.isEmpty() && paymentList.size() == count) {
                DELETE paymentList;
                DELETE deleteRecord;
            }else if (paymentList.isEmpty()) {
                DELETE deleteRecord;
            }else{
                return (new List<My_Address_Book__c>());
            }
            List<My_Address_Book__c> updatedRecords = loggedInuserAddressList();
            return updatedRecords;
        }catch(Exception ex){
            System.debug('Error '+ex.getMessage()+ ' At '+ex.getLineNumber());
            return (new List<My_Address_Book__c>());
        }
    }

    @AuraEnabled
    public static ResponseWrapper updateAddressBook(String addressRecordToUpdate){
        Boolean foundDuplicate;
        Boolean foundName;
        My_Address_Book__c addressBookRecord = (My_Address_Book__c) JSON.deserialize(addressRecordToUpdate, My_Address_Book__c.class);
        String conactId = [SELECT Id,ContactId  FROM User WHERE Id=:userinfo.getUserId() Limit 1]?.ContactId;
        
        List<My_Address_Book__c> lstOfNames = [Select id,Name,Address__c,City__c,Zip__c,Phone__c,State__c,Country__c, Notes__c from My_Address_Book__c where Id != : addressBookRecord.Id AND Person_Address_Account__r.PersonContactId =: conactId AND (Name =: addressBookRecord.Name.trim() AND Address__c =: addressBookRecord.Address__c.trim() AND City__c =: addressBookRecord.City__c.trim()  AND State__c =: addressBookRecord.State__c.trim() AND Zip__c =: addressBookRecord.Zip__c.trim() AND Phone__c =: addressBookRecord.Phone__c.trim())];
        
        Boolean found = addressBookRecord.isPreferred__c == true ? true : false;
        
        //Added by Sayalee as a bug 7227 
        try{
            if(lstOfNames.size() == 1){
                foundDuplicate = true;
            }
            else {
                if(found == true){
                    changeAllAddressisPreferred();
                }
                foundDuplicate = false;
                addressBookRecord.Country__c = 'United States';
                update addressBookRecord;
            }
            //end
            ResponseWrapper objResponseWrapper = new ResponseWrapper();
            objResponseWrapper.error = false;
            objResponseWrapper.errorMessage = '';
            if(foundDuplicate == true)
            {
                objResponseWrapper.errorWhenDuplicateName ='Duplicate record not allowed';
            }
            else if(foundDuplicate == false)
            {
                objResponseWrapper.errorWhenDuplicateName ='Continue inserting record';
            } 
            objResponseWrapper.addressList = loggedInuserAddressList();
            return objResponseWrapper;
        }catch (Exception e) {
            ResponseWrapper objResponseWrapper = new ResponseWrapper();
            objResponseWrapper.error = true;
            objResponseWrapper.errorMessage = e.getMessage() +' At ' +e.getLineNumber();
            objResponseWrapper.addressList = new List<My_Address_Book__c>();
            return objResponseWrapper;
        }
    }

    @AuraEnabled
    public static List<Map<String, String>> getStateAddressBook(){
        return B2BGuestUserController.getStateCodes();
    }
    
    @AuraEnabled
    public static ResponseWrapper createAddressRecord(String addressRecord){
        try{
            Boolean foundDuplicate;
            My_Address_Book__c objAddressRecord = (My_Address_Book__c) JSON.deserialize(addressRecord, My_Address_Book__c.class);
            String conactId = [SELECT Id,ContactId  FROM User WHERE Id=:userinfo.getUserId() Limit 1]?.ContactId;
            Account objAccountId = [Select Id,PersonContactId from Account where PersonContactId=:conactId];
           
            List<My_Address_Book__c> lstOfNames = [Select id,Name,Address__c,City__c,State__c,Country__c,Zip__c,Phone__c, Notes__c from My_Address_Book__c where Person_Address_Account__r.PersonContactId =: conactId AND (Name =: objAddressRecord.Name.trim() AND Address__c =: objAddressRecord.Address__c.trim() AND City__c =: objAddressRecord.City__c.trim() AND State__c =: objAddressRecord.State__c.trim()  AND Zip__c =: objAddressRecord.Zip__c.trim() AND Phone__c =: objAddressRecord.Phone__c.trim())];
           
            Boolean found = objAddressRecord.isPreferred__c == true ? true : false;
            if(objAccountId != null){
                objAddressRecord.Person_Address_Account__c = objAccountId.Id;
            }
            //Added by Sayalee as a bug 7227
            if(lstOfNames.size() > 0){
                foundDuplicate = true;
            }
            else {
                if(found == true){
                    changeAllAddressisPreferred();
                }
                foundDuplicate = false;
                List<My_Address_Book__c> addressBookList =[SELECT Id,Name,NickName__c, isPreferred__c,Address__c,City__c,Phone__c,Notes__c,State__c,Country__c,Zip__c FROM My_Address_Book__c WHERE Person_Address_Account__r.PersonContactId =:conactId ];
                objAddressRecord.Country__c = 'United States';
                insert objAddressRecord;
            }
            //end
            ResponseWrapper objResponseWrapper = new ResponseWrapper();
            objResponseWrapper.currentRecord = objAddressRecord;
            objResponseWrapper.error = false;
            objResponseWrapper.errorMessage = '';
            if(foundDuplicate == true)
            {
                objResponseWrapper.errorWhenDuplicateName ='Duplicate record not allowed';
            }
            else if(foundDuplicate == false)
            {
                objResponseWrapper.errorWhenDuplicateName ='Continue inserting record';
            }
            objResponseWrapper.addressList = loggedInuserAddressList();
            return objResponseWrapper;         
        }
        catch (Exception e) {
            ResponseWrapper objResponseWrapper = new ResponseWrapper();
            objResponseWrapper.error = true;
            objResponseWrapper.errorMessage = e.getMessage() +' At ' +e.getLineNumber();
            objResponseWrapper.addressList = new List<My_Address_Book__c>();
            return objResponseWrapper;
        }
    }
    
    private static void changeAllAddressisPreferred(){
        Boolean isPreferred = false;
        List<My_Address_Book__c> allAddressListToUpdate = new  List<My_Address_Book__c>();
        
        String conactId = [SELECT Id,ContactId  FROM User WHERE Id=:userinfo.getUserId() Limit 1]?.ContactId;
        List<My_Address_Book__c> allAddressList =[SELECT Id, isPreferred__c FROM My_Address_Book__c WHERE Person_Address_Account__r.PersonContactId =:conactId];
        
        for(My_Address_Book__c objAdd : allAddressList){
            if(objAdd.isPreferred__c == true){
                isPreferred = true;
                break;
            }
        }
        if(isPreferred == true){
            for(My_Address_Book__c objAdd : allAddressList){
                if(objAdd.isPreferred__c == true){
                    objAdd.isPreferred__c = false;
                    allAddressListToUpdate.add(objAdd);
                }
            }
            update allAddressListToUpdate;
        }
    }
    
    @AuraEnabled
    public static Boolean markAsPrefferedDirectly(String addressId)
    {
        try{
            List<My_Address_Book__c> allAddressListToUpdate = new  List<My_Address_Book__c>();
            String conactId = [SELECT Id,ContactId  FROM User WHERE Id=:userinfo.getUserId() Limit 1]?.ContactId;
            List<My_Address_Book__c> allAddressList =[SELECT Id, isPreferred__c FROM My_Address_Book__c WHERE Person_Address_Account__r.PersonContactId =:conactId];
            for(My_Address_Book__c objAdd : allAddressList){
                if(objAdd.Id == addressId ){
                    objAdd.isPreferred__c = true;
                }
                else
                {
                    objAdd.isPreferred__c = false;
                }
            }
            if(allAddressList.size() > 0)
            {
                update allAddressList;
                return true;
            }
            return false;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //updated by Ravi Prasad as part of HDMP-HDMP-16282	
    @AuraEnabled
    public static My_Address_Book__c getEditAddressInfo(String editAddressId)
    {
        List<My_Address_Book__c> editAddressList = [SELECT Id, Address__c, City__c, State__c, Country__c, Zip__c FROM My_Address_Book__c WHERE Id =: editAddressId Limit 1];
        if(!editAddressList.isEmpty()){
            return editAddressList[0];
        } else {
            return new My_Address_Book__c(); 
        }
    }
    
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class ResponseWrapper{
        @AuraEnabled
        public Boolean error{get;set;}
        @AuraEnabled
        public My_Address_Book__c currentRecord{get;set;}
        @AuraEnabled
        public String errorMessage{get;set;}
        @AuraEnabled
        public List<My_Address_Book__c> addressList{get;set;}
        @AuraEnabled
        public String errorWhenDuplicateName{get;set;}
        
    }
}