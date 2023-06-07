public without sharing class ownRadioNaviCodeController {
    public ownRadioNaviCodeController() {
        
    }
    
    //DOE-2375 
    @AuraEnabled
    public static string storeRadioOrNaviCode(String radioCode, String navCode,String vin,String ownershipId,boolean udateVin,string isSuccess,String radioserialNumber,String navserialNumber){
      //  system.debug('@@radioCode'+radioCode+'navCode'+ navCode+'vin'+vin+'ownershipId'+ownershipId+'udateVin'+ udateVin+'isSuccess'+ isSuccess);
        try{
        if(ownershipId != null ){
            Ownership__c record= [SELECT Id,Radio_Code__c,Navi_Code__c,Honda_Product__r.Product_Identifier__c  from Ownership__c where id=:ownershipId  ];
            if(!String.isBlank(radioserialNumber)){
                record.Radio_Code__c=radioCode;
            } 
            if(!String.isBlank(navserialNumber)){
                record.Navi_Code__c=navCode;
            }
            if(vin!= null && udateVin==true){
                record.Honda_Product__r.Product_Identifier__c=vin;
            }
            system.debug('@@@@@');
           // system.debug(radioCode != null && radioCode.trim() !='');
           // system.debug(navCode != null && navCode.trim() !='');
            update record;
            return record.id;
        }else{
            return 'there is no ownership Id';
        }   
      }catch(Exception e){
        System.debug('@@exception'+e);
     }
     return 'there is no ownership Id';
        
    }
    
    @AuraEnabled
    public static string createradioNaviRequest(String clientIpAddress,String radioCode, String navCode,string vin,string radioserialNumber,string navserialNumber,string email,string phone,string zipcode,string isSuccess,string response,boolean isRecurringerror,String radioNavId){
        list<Radio_Navi_Request__c> radioNaviReqList =new list<Radio_Navi_Request__c>();
        DateTime dt=System.now().addHours(-1);
        if(isRecurringerror && isSuccess != 'Success'){
        radioNaviReqList = [SELECT Id,LastUpdatedDate__c,Radio_Serial_Number__c,Navi_Serial_Number__c,Radio_Authorization_Code__c,
                                                            Navi_Authorization_Code__c,Phone_Number__c,Customer_XML__c,Zip_Code__c
                                                            FROM Radio_Navi_Request__c 
                                                            WHERE id=:radioNavId AND LastUpdatedDate__c >=:dt LIMIT 1];
        }
        
        if(radioNaviReqList.size()>0){
            radioNaviReqList[0].LastUpdatedDate__c = system.now();
            if(!String.isBlank(navserialNumber)){
            radioNaviReqList[0].Navi_Serial_Number__c = navserialNumber;
            radioNaviReqList[0].Navi_Authorization_Code__c = navCode;
            }
            if(!String.isBlank(radioserialNumber)){
            radioNaviReqList[0].Radio_Serial_Number__c = radioserialNumber;
            radioNaviReqList[0].Radio_Authorization_Code__c = radioCode;
            }
            radioNaviReqList[0].Phone_Number__c= phone;
            radioNaviReqList[0].Zip_Code__c= zipcode;
            //radioNaviReqList[0].Client_IP_Address__c =clientIpAddress;
            radioNaviReqList[0].Request_Result_Code__c =isSuccess;
         //   radioNaviReqList[0].Customer_XML__c = response;
         if(isSuccess=='FVIN' || isSuccess == 'FVINS'){
              radioNaviReqList[0].VIN_Service_Response__c = response;
          }
            radioNaviReqList[0].Product_Identifier__c = vin;
            radioNaviReqList[0].Email_Address__c = email;
            if(UserInfo.getUserType() != 'Guest' && !Test.isRunningTest()){
            radioNaviReqList[0].Client_IP_Address__c=Auth.SessionManagement.getCurrentSession().get('SourceIp');
            }
            if(isSuccess=='Not Found'||isSuccess=='Success'|| isSuccess=='Validation Error'|| isSuccess=='Unavailable'|| isSuccess=='Runtime Error'){
                if(isSuccess=='Success'){
                    radioNaviReqList[0].Request_Result_Code__c ='SUC';
                    }else{
                    radioNaviReqList[0].Request_Result_Code__c ='INCPT';
                    }
            }
            update radioNaviReqList[0];
            return radioNaviReqList[0].Id;
        }else{
            Radio_Navi_Request__c radioNav = new Radio_Navi_Request__c();
            radioNav.LastUpdatedDate__c = system.now();
            radioNav.Radio_Authorization_Code__c = radioCode;
            radioNav.Navi_Authorization_Code__c = navCode;
            radioNav.Email_Address__c = email;
            radioNav.Product_Identifier__c = vin;
            radioNav.Radio_Serial_Number__c = radioserialNumber;
            radioNav.Navi_Serial_Number__c = navserialNumber;
            radioNav.Phone_Number__c= phone;
            radioNav.Zip_Code__c = zipcode;
            radioNav.Zip_Code__c = zipcode;
            radioNav.Request_Result_Code__c =isSuccess;
            if(UserInfo.getUserType() != 'Guest' && !Test.isRunningTest()){
            radioNav.Client_IP_Address__c=Auth.SessionManagement.getCurrentSession().get('SourceIp');
            }
            //radioNav.Client_IP_Address__c =clientIpAddress;
           // radioNav.Customer_XML__c = response;
           if(isSuccess=='FVIN' || isSuccess == 'FVINS'){
             radioNav.VIN_Service_Response__c = response;
           }
            if(isSuccess=='Not Found'||isSuccess=='Success'|| isSuccess=='Validation Error'|| isSuccess=='Unavailable'|| isSuccess=='Runtime Error'){
                if(isSuccess=='Success'){
                radioNav.Request_Result_Code__c ='SUC';
                }else{
                radioNav.Request_Result_Code__c ='INCPT';
                }
            }
            
            insert radioNav;
            return radioNav.id;
        }    
                 
    }
    @AuraEnabled
    public static string createradioNaviRequestFailure(string vin,string radioserialNumber,string navserialNumber,string email,string radioNavRequest,string isSuccess,string phone,string zipcode,string response,string returncode){
       if(isSuccess !='Success') {
            Radio_Navi_Request_Failure__c radioNaviRequestFailure = new Radio_Navi_Request_Failure__c();
            list<Radio_Navi_Request__c> radioNaviReqList = [SELECT id,Request_Result_Code__c,Radio_Serial_Number__c,Navi_Serial_Number__c,Radio_Authorization_Code__c,Navi_Authorization_Code__c FROM Radio_Navi_Request__c where Id =: radioNavRequest];
            if(radioNaviReqList.size()>0){
                list<Radio_Navi_Request_Failure__c> radioNaviReqFailList = [SELECT id FROM Radio_Navi_Request_Failure__c where Radio_Navi_Request_Id__c =:radioNavRequest];
                radioNaviRequestFailure.Attempt_Number__c = radioNaviReqFailList.size()+1;
                radioNaviRequestFailure.Alternate_Identifier__c = radioNavRequest+radioNaviRequestFailure.Attempt_Number__c+returncode;
                if(radioNaviReqList[0].Request_Result_Code__c == 'FVIN'){
                radioNaviRequestFailure.Authorization_Code_Failure_Type_Code__c ='VIN';
                }else if(radioNaviReqList[0].Request_Result_Code__c == 'FVINS'){
                    radioNaviRequestFailure.Authorization_Code_Failure_Type_Code__c ='VINSV';  
                }
                if(radioNaviReqList[0].Request_Result_Code__c == 'INCPT'){
                if(!String.isBlank(radioNaviReqList[0].Navi_Serial_Number__c) && String.isBlank(radioNaviReqList[0].Navi_Authorization_Code__c)){
                    radioNaviRequestFailure.Authorization_Code_Failure_Type_Code__c ='SRLN';
                    }
                if(!String.isBlank(radioNaviReqList[0].Radio_Serial_Number__c) && String.isBlank(radioNaviReqList[0].Radio_Authorization_Code__c)){
                        radioNaviRequestFailure.Authorization_Code_Failure_Type_Code__c ='SRLR';  
                    }
                }
            }
            
            radioNaviRequestFailure.Email_Address__c = email;
            radioNaviRequestFailure.Radio_Serial_Number__c = radioserialNumber;
            radioNaviRequestFailure.Navi_Serial_Number__c = navserialNumber;
            radioNaviRequestFailure.Product_Identifier__c = vin;
            //
            radioNaviRequestFailure.Radio_Navi_Request_Id__c = radioNavRequest; 
            radioNaviRequestFailure.Phone_Number__c = phone;
            radioNaviRequestFailure.Zip_Code__c = zipcode;
            radioNaviRequestFailure.CreatedDate__c = system.now();
          //  radioNaviRequestFailure.Customer_XML__c = response;
                
            insert radioNaviRequestFailure;
       }
        return isSuccess;
    }
    
    @AuraEnabled(cacheable=true) //Map<String,String>.SourceIp
    public static String getExternalIp() {
        //return Auth.SessionManagement.getCurrentSession().get('SourceIp');
        return [SELECT Id, SourceIp FROM AuthSession WHERE UsersId = :UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1].SourceIp;
    } 
}