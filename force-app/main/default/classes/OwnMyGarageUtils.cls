public class OwnMyGarageUtils implements Queueable{
     
     Public Error__c objError;
     public OwnMyGarageUtils(String name, String errorMessage,Integer lineNumber, String className, String methodName,String errorType,String requestPayload,String responsePayload,String statusCode){
        
         try{
        objError = new Error__c();
        objError.Name = name;
        objError.Line_Number__c = lineNumber;
        objError.ClassName__c = className;
        objError.Error_Message__c = errorMessage;
        objError.MethodName__c = methodName;
        objError.Error_Type__c = errorType;
        objError.Request_Payload__c = requestPayload;
        objError.Response_Payload__c = responsePayload;
        objError.Status__c = statusCode;
        objError.UserInfo__c = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : 'Guest';
      //  insert objError;
         }catch(Exception e){
             system.debug('@@Exception'+e);
         }
        
    }

    public void execute(QueueableContext context) {
        database.insert(objError,false);
    }

}