public class B2B_CheckoutUtility {
    
    //Method to send email 
    //
    // More parameters are needed to reflect the details of the error
    // the error record
    // the error log
    // the cart or the order
    // 
    /*public static void sendEmail(String bodyStr, String subjectStr){
        if(String.isNotBlank(subjectStr) && String.isNotBlank(bodyStr)){
            List<String> liststringEmail = new List<String>();
            if(String.isNotBlank(Label.checkoutEmailAddresses)){
                liststringEmail = Label.checkoutEmailAddresses.split(',');
            }
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            if(liststringEmail.size() > 0){
                message.setToAddresses(liststringEmail);
            }
            message.subject = subjectStr;
            message.plainTextBody = bodyStr; 
            message.SaveAsActivity = false;
            
            List < Messaging.SingleEmailMessage > messages = new List < Messaging.SingleEmailMessage > {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
        
          
    }*/
    
    //method to create Error record
    /*public static Error__c createErrorRecord(String name, String orderId , String errorMessage, String className, String methodName, String cartId, Boolean isInsert){
        Error__c objError = new Error__c();
        if(String.isNotBlank(name)){
            objError.Name = name;
        }
        if(String.isNotBlank(orderId)){
            objError.Order__c = orderId;
        }
        if(String.isNotBlank(className)){
            objError.ClassName__c = className;
        }
        if(String.isNotBlank(errorMessage)){
            objError.Error_Message__c = errorMessage; // only 255 character will be consider.
        }
        if(String.isNotBlank(methodName)){
            objError.MethodName__c = methodName;
        }
        if(String.isNotBlank(orderId)){
            objError.RecordId__c = orderId;  
        }
        if(String.isNotBlank(cartId)){
            objError.Cart__c = cartId; 
        }
        
        if(isInsert){
            insert objError;
        }
        return objError;
        
    }*/
    
    //method to create Error record
    public static Error__c createErrorRecord(String name, String orderId , String errorMessage, String className, String methodName, String cartId,Boolean notifySupport, Boolean isInsert){
        Error__c objError = new Error__c();
        if(String.isNotBlank(name)){
            objError.Name = name;
        }
        if(String.isNotBlank(orderId)){
            objError.Order__c = orderId;
        }
        if(String.isNotBlank(className)){
            objError.ClassName__c = className;
        }
        if(String.isNotBlank(errorMessage)){
            objError.Error_Message__c = errorMessage; // only 255 character will be consider.
        }
        if(String.isNotBlank(methodName)){
            objError.MethodName__c = methodName;
        }
        if(String.isNotBlank(orderId)){
            objError.RecordId__c = orderId;  
        }
        if(String.isNotBlank(cartId)){
            objError.Cart__c = cartId; 
        }
        
        if(notifySupport){
            objError.Notify_Support__c = true; 
        }
        
        if(isInsert){
            insert objError;
        }
        return objError;
        
    }
    
}