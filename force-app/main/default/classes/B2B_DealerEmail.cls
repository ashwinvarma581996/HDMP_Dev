public with sharing class B2B_DealerEmail {
    public class FlowInputs {
        @InvocableVariable(label='Order ID' description='ID for the Current Order') 
        public String orderId;
        
        @InvocableVariable(label='Order Summary ID' description='ID for the current Order Summary') 
        public String orderSummaryId;
    }
    @InvocableMethod(label='OrderConfirmationEmailToDealers' description='Flow Step to send email to dealers')
    public static void inserDealerEmailBasedOnOrderId(List<FlowInputs> flowInp){
        FlowInputs req = flowInp[0];
        String orderId= req.orderId;
        String orderSummaryId= req.orderSummaryId;  
        processData(orderId,orderSummaryId);
        
    }
    @future(callout=true)
    public static void processData(String orderId, String orderSummaryId){
        String cc='';
        List<string> ccAddress = new List<string>();
        Order o=[select id,Name,Account.PoIId__c, Account.Name,Updated_Shipping__c from Order where id=:orderId]; 
        List<Dealer_Email__c> de=[select id,Name,Email__c from Dealer_Email__c  where Order__c =:orderId];
        set<string> existingEMail=new set<string>();
        for(Dealer_Email__c d:de){
            existingEMail.add(d.Email__c); 
        }
        String poiId='';
        String poiType='';
        List<Dealer_Email__c> lstDealerEmails = new List<Dealer_Email__c>();
        B2B_BrainTreeUtils.DealerServiceResponse objDealerResponse = New B2B_BrainTreeUtils.DealerServiceResponse();
        if(o.Account.Name.contains('Honda')){
            poiId=o.Account.PoIId__c;
            poiType='A'; 
        }else {
            poiId=o.Account.PoIId__c;
            poiType='B'; 
        }  
        Long beforeAPI = B2B_Util.fetchCurrentTime();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String guId = B2B_Util.createGui();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('hondaHeaderType.messageId',guId);           
        request.setHeader('accept','application/json');
        request.setMethod('GET');
        String endPointUrl = 'callout:B2B_Dealer_Credential';
        endPointUrl += Label.B2B_Dealer_Locator_URL;
        endPointUrl += '&POIId='+poiId+'&Country=US&POIType='+poiType+'&SearchRadius=20&NumberOfPOIs=1&ShowAllAttributes=False&ShowAllProperties=False&ShowAllDepartments=False&DepartmentCdCSV=PA&ShowPOIMetadata=False&Output=Json';            
        request.setEndPoint(endPointUrl);
        system.debug('endPointUrl'+endPointUrl);
        // Getting response from Econfig Server.
        HTTPResponse response = http.send(request);
        String responseBody = response.getBody();
        system.debug('responseBody' +responseBody);
        List<Map<String, Object>> myMaps = new List<Map<String, Object>>();
        Map<String, Object> poiResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> mapResponse_level1 = (Map<String, Object>) poiResponse.get('POIResponse');
        if(!mapResponse_level1.containsKey('ResultCount') || (mapResponse_level1.containsKey('ResultCount') && (String)mapResponse_level1.get('ResultCount') == '0' )){
            Map<String, Object> mapResponse_level2 = (Map<String, Object>) mapResponse_level1.get('Error');
            String errorResponse = (String)mapResponse_level2.get('Description');
            objDealerResponse.isError = true;                
        }else if(mapResponse_level1.containsKey('ResultCount') && (String)mapResponse_level1.get('ResultCount') != '0'){
            Map<String, Object> mapPois = (Map<String, Object>)mapResponse_level1.get('POIs');
            List<Object> poiList = (List<Object>)mapPois.get('POI');
            if(!poiList.isEmpty()) {
                String emails = '';
                Map<String, Object> poiData = (Map<String, Object>)poiList[0];                      
                Map<String, Object> departments = (Map<String, Object>)poiData.get('Departments');
                List<Object> departmentList = (List<Object>)departments.get('Department');               
                Map<String, Object> departmentData = (Map<String, Object>)departmentList[0]; 
                if(departmentData.containsKey('Contact')){
                    List<Object> contactList = (List<Object>)departmentData.get('Contact');                                  
                    for(Object conDetail : contactList){
                        Map<String, object> mapContactDetails = (Map<String, Object>)conDetail;
                        emails += String.valueOf(mapContactDetails.get('Email')) + ';';                                              
                    }
                }
                objDealerResponse.isError = false;
                objDealerResponse.dealerEmails = emails;
            }else {
                objDealerResponse.isError = true;
            }                          
        } 
        System.debug('@@Test'+objDealerResponse.dealerEmails);
        if(objDealerResponse.isError == false && String.isNotEmpty(objDealerResponse.dealerEmails)){
            List<String> lstEmails = objDealerResponse.dealerEmails.split(';');             
            for(String email : lstEmails){
                ccAddress.add(email);
                cc=cc+email;
                /*  if(!existingEMail.contains(email)){
Dealer_Email__c objDealerEmail = new Dealer_Email__c();
objDealerEmail.Email__c = email;
objDealerEmail.Order__c = o.Id;
objDealerEmail.isPaymentReprocess__c = true;
objDealerEmail.IsShipToHome__c = (o.Updated_Shipping__c != null && o.Updated_Shipping__c > 0) ? true : false;
lstDealerEmails.add(objDealerEmail);
}*/
            }
        }
        /*  if(!lstDealerEmails.isEmpty()){
upsert lstDealerEmails;
}*/
        OrderSummary os=[select id,OwnerId,Billing_Email_Address_User_Email__c from OrderSummary where Id=:orderSummaryId];
        EmailTemplate et=[SELECT Id,Subject,Description,
                          HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName ='SF_POC_Confirmation_with_Items' LIMIT 1];
        List<OrgWideEmailAddress>  oEA=[SELECT Id, Address, DisplayName, IsAllowAllProfiles, Purpose FROM OrgWideEmailAddress where DisplayName='Dreamshop Orders' LIMIT 1];       
        List<String> toAddress = new List<String>();
        toAddress.add(os.Billing_Email_Address_User_Email__c);//relace with os.Billing_Email_Address_User_Email__c
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(et.Id);
        if(!oEA.isEmpty()){
            mail.setOrgWideEmailAddressId(oEA[0].Id);
        }
        if(Label.Environment == 'production'){
            if(!ccAddress.isEmpty()){
                mail.setccAddresses(ccAddress); 
            }
            mail.setBccAddresses(new String[]{Label.OrderConfirmationBCCEmail});
        }else{
            mail.setccAddresses( new List<String>{Label.OrderConfirmationCCEmail});  
        }  
        mail.setToAddresses(toAddress);
        mail.setTargetObjectId(os.OwnerId);
        mail.setWhatId(os.Id);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setTreatTargetObjectAsRecipient(false) ;    
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        Messaging.SendEmailResult [] r =Messaging.sendEmail(allmsg,false);
    }
    
}