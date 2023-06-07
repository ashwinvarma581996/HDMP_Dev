public with sharing class GetRecordLockStatus {
    
    @InvocableMethod(label='Check if Offer Locked')
    public static List<Response> GetStatus(List<ID> recIds) {
        String recordId = recIds[0];
        Boolean lockStatus = Approval.isLocked(recordId);
        
        //Create a Results object to hold the return values
        Response response = new Response();
        
        //add the return values to the Results object
        response.locked = lockStatus;
        
        List<Response> responseWrapper= new List<Response>();
        responseWrapper.add(response);
        return responseWrapper;
        
    }
    public class InvocableErrorException extends Exception{}
    public class Request {
        
        @InvocableVariable
        public String recordId;
        
        
    }
    
    public class Response {
        
        @invocableVariable
        public Boolean locked; 
        
        
    }
    public class InvocableActionException extends Exception {}
    
}