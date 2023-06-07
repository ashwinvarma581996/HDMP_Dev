/*******************************************************************************
Name: B2B_DataErrorLogger
Business Unit: HDM
Date: 06-04-2023
Developer: Vivek M
Description: Contains methods related to error logging when expected values are 0 in API and Product object
*******************************************************************************

*******************************************************************************/
public class B2B_DataErrorLogger {
    
     @AuraEnabled
    public static String logAPIDataError(String errorMessage,String messageType){
        String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
		Error__c errorRecord = createErrorRecord(true,'Data error from API',personAccountId,'B2B_DataErrorLogger','logDataError',errorMessage,messageType,true);
        return errorRecord.Id;
    }
    @AuraEnabled
    public static String logdbDataError(String errorMessage,String messageType){
        String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
		Error__c errorRecord = createErrorRecord(true,'Data error from SF DB',personAccountId,'B2B_DataErrorLogger','logdbDataError',errorMessage,messageType,true);
        return errorRecord.Id;
    }

    
    public static Error__c createErrorRecord(Boolean toInsert,String errorName,String personAccountId,String className,String methodName,String errorMessage, String errorType,Boolean notifySupport){
        try{
            Error__c errorRecord  =  new Error__c();
            errorRecord.Name  =  errorName;
            if(String.isNotBlank(personAccountId))
                errorRecord.Person_Account__c = personAccountId;
            errorRecord.ClassName__c  = className;
            errorRecord.Error_Message__c = errorMessage;
            errorRecord.Error_Type__c = errorType;
            errorRecord.Notify_Support__c = notifySupport;
            errorRecord.MethodName__c = methodName;
            errorRecord.Support_Notification_Date__c = system.now();
            if(toInsert)
            {
                insert errorRecord;
                return errorRecord;
            } else {
                return errorRecord;
            }
        }catch(Exception e) {
            System.debug(e.getMessage());
        }
        return null;
    }
}