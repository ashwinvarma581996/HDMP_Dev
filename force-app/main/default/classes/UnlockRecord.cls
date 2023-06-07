public without sharing class UnlockRecord { 
    @InvocableMethod(label='Unlock Offer')
    public static List<Response> Unlock(List<ID> recIds) {
        List<Response> responseWrapper= new List<Response>();
        
        for (Id i:  recIds) { //Bulkify input - especially if used with Trigger,scheduled path 
            String recordId = recIds[0];
            
            Approval.UnlockResult unlockResult = Approval.unlock(recordId);
            
            //Create a Results object to hold the return values
            Response response = new Response();
            
            //add the return values to the Results object
            response.isSuccess = unlockResult.isSuccess();
            response.errors = packErrorString(unlockResult);
            
            responseWrapper.add(response);
            
        }
        return responseWrapper;
    
    }

    public static String packErrorString(Approval.UnlockResult unlockResult) {
        String errorString = '';
        for(Database.Error err : unlockResult.getErrors()) {
            errorString = errorString + (' The following error has occurred.');                   
            errorString = errorString + (' ' + err.getStatusCode() + ': ' + err.getMessage());
        }
        return errorString;

    }



    public class InvocableErrorException extends Exception{}


    public class Request {

      @InvocableVariable
      public String recordId;
      
    }
    
    public class Response {
     
       @invocableVariable
        public Boolean isSuccess; 
        
        @invocableVariable
        public String errors;
    }
    public class InvocableActionException extends Exception {}

}