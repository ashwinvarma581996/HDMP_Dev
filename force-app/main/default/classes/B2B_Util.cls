/*************************************************************
Name: B2B_Util
Purpose: This class is to provide GUI,erro record creation , duration time of api.
Date : 28/04/2021
Created By : Radhey Shyam Gupta
Last Update Date: 22/05/2022
Last Update By: Soumya Sahoo(Error handling changes- JIRA- 8617)
*************************************************************/
public without sharing class B2B_Util{
    
    // This method will generate unique UI which is required in request header.
    public static String createGui() {
        String kHexChars = '0123456789abcdef';
        String returnValue = '';
        Integer nextByte = 0;
        
        for (Integer i=0; i<16; i++) {
            
            if (i==4 || i==6 || i==8 || i==10) 
                returnValue += '-';
            
            nextByte = (Math.round(Math.random() * 255)-128) & 255;
            
            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }
            
            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }
            
            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }
        
        return returnValue;
    }
    
    // This method is internally called from createGui()
    public static String getCharAtIndex(String str, Integer index) {
        if (str == null) return null;
        if (str.length() <= 0) return str; 
        if (index == str.length()) return null;  
        return str.substring(index, index+1);
    }
    
    public static Boolean isSalesforceID(String value){
        try{ //Added by shalini for issue HDMP-6372
            if(Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(value).matches()){
                return true;
            } else{
                return false;
            }
            // Id salesforceId = Id.valueOf(value); 
            // return true;
        }catch(Exception ex){
            return false;
        }
    }
    //Added by shalini soni HDMP-212 myDealers R2 Story
    public static Error__c createErrorRecord(String name, String errorMessage,Integer lineNumber, String className, String methodName){
        
        Error__c objError = new Error__c();
        objError.Name = name;
        objError.Line_Number__c = lineNumber;
        objError.ClassName__c = className;
        objError.Error_Message__c = errorMessage;
        objError.MethodName__c = methodName;
        return objError;
        
    }
    //HDMP-8617- Error handling -Below method utilize to create record in error object by recieving values from different methods
    public static Error__c createErrorRecord(Boolean toInsert,String errorName,String orderreturnId,String accountId,String personAccountId, String cartId,String className, String errorMessage, String errorType, String lineNumber,String methodName,Boolean notifySupport,String OrderId,String recordid,String stackTrace,Long duration,String severity,String requestPayload,String responsePayload){
        try{
            Error__c errorRecord  =  new Error__c();
            List<Error__c> errorRecToInsertList  =  new List<Error__c>();
            errorRecord.Name  =  errorName;
            if(String.isNotBlank(orderreturnId))
                errorRecord.Order_Transaction__c  =  orderreturnId;
            if(String.isNotBlank(accountId))
                errorRecord.Account__c  =  accountId;
            if(String.isNotBlank(personAccountId))
                errorRecord.Person_Account__c = personAccountId;
            if(String.isNotBlank(cartId))
                errorRecord.Cart__c	 = cartId;
            if(String.isNotBlank(OrderId))
                errorRecord.Order__c=OrderId;
            errorRecord.ClassName__c  = className;
            errorRecord.Duration__c  = duration;
            errorRecord.Error_Message__c = errorMessage;
            errorRecord.Error_Type__c = errorType;
            if(String.isNotBlank(lineNumber))
                errorRecord.Line_Number__c = Integer.valueOf(lineNumber);
            errorRecord.MethodName__c = methodName;
            errorRecord.Notify_Support__c = notifySupport;
            errorRecord.Support_Notification_Date__c = system.now();
            if(String.isNotBlank(orderId))
                errorRecord.Order__c = orderId;
            errorRecord.RecordId__c = recordid;
            errorRecord.Severity__c = Severity;
            errorRecord.StackTrace__c = stackTrace;
            errorRecord.Request_Payload__c = requestPayload;
            errorRecord.Response_Payload__c = responsePayload;
            errorRecToInsertList.add(errorRecord);
            if(!errorRecToInsertList.isEmpty() && toInsert)
            {
                insert errorRecToInsertList;
                return null;
            } else {
                return errorRecord;
            }
        }catch(Exception e) {
            System.debug(e.getMessage());
        }
        return null;
    }
    
    public static Long fetchCurrentTime(){
        Long beforeAPI = DateTime.now().getTime();
        return beforeAPI;
    }
    
    public static Long calInMilliSeconds(Long beforeApi, Long afterAPI){
        Long timeDuration =(afterAPI-beforeApi);
        return timeDuration;
    }
   //  //HDMP-8617- End of changes
    

    //for adobe analytics:isUserLoggedOut
    @AuraEnabled
    public static Boolean isUserLoggedOut(){
    try {
        String userId=UserInfo.getUserId();
        if(userId!=null || userId!=''){
            User loggedInUser = [SELECT Id,Name,Contact.Name FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
            String contactName = loggedInUser.Contact.Name;
            if(contactName.containsIgnoreCase('Guest Contact') ){
                return true;
            }
        }
        
        return false;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
   }
}