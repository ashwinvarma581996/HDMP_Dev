/*******************************************************************************
Name: B2B_USPSShippingCalculation
Business Unit: HDM
Date: 28/04/21
Developer: Soumya Sahoo 
Description: This class is to provide Shipping charge calculation for USPS Carrier.
*******************************************************************************
MODIFICATIONS – V1 | Soumya Sahoo | Error handling changes- JIRA- 8617 
V2 | Sayalee Brahmankar | Added Header
V3 | Soumya Sahoo | Error handling changes- JIRA- 8924
V4 | Soumya Sahoo | R2B Stories- Multiple Shipping and cart updates stories
*******************************************************************************/
public class B2B_USPSShippingCalculation {
    public static String USPSShippingChargeCalculation(String CartId,String DealerPostalCode,String CustomerPostalCode){
        Integer packageCounter=B2B_IntegrationConstants.DEFAULT_VALUE,Counter=B2B_IntegrationConstants.DEFAULT_VALUE;
        String mailServiceName,param,speedName;
        Integer packageQuantity=B2B_IntegrationConstants.DEFAULT_VALUE;
        B2B_USPSShippingCalculation uspsObj=new B2B_USPSShippingCalculation();
        Map<String,String> speedmapping=new Map<String,String>();
        List<Carrier_Speed__c> carrierspeeds=B2B_IntegrationUtility.getCarrierSpeeds(B2B_IntegrationConstants.USPS_LABEL);
        for(Carrier_Speed__c availableSpeeds:carrierspeeds){
            speedmapping.put(availableSpeeds.Carrier_Speed_Name__c,'0');
        }
        Integer conversionrate=B2B_IntegrationConstants.CONVERSATIONRATE;
        Decimal rate;
        B2B_IntegrationWrapper responseWrapper =  New B2B_IntegrationWrapper();
        Map<String,Decimal> speedRate=new Map<String,Decimal>();
        try{
            
            param='RateV4&XML=';
            param +='<RateV4Request ';
            param +='USERID="'+Label.B2B_USPS_UserName+'">';
            param +='<Revision>'+B2B_IntegrationConstants.REVISION+'</Revision>';
            for(CartItem objCartItem : B2B_IntegrationUtility.getCartItemdetails(cartId)){
                if(objCartItem.Item_Package_quantity__c > 0)
                    packageQuantity = Integer.valueof(objCartItem.Quantity * objCartItem.Item_Package_quantity__c);
                else
                    packageQuantity = Integer.valueof(objCartItem.Quantity);
                for(integer i=0;i<packageQuantity;i++){
                    Decimal weight=objCartItem.Product2.Weight_lbs__c.setscale(2);
                    String weightinstring=String.valueOf(weight);
                    String weight_Ounces = weightinstring.substringAfter('.');
                    Decimal weight_in_ounces=Decimal.valueOf(weight_Ounces)/B2B_IntegrationConstants.CONSTANTVALUE;
                    Decimal weight_in_pounds=weight-weight_in_ounces;
                    param +='<Package ID="'+packageCounter+'">';
                    param +='<Service>'+B2B_IntegrationConstants.USPS_SERVICE+'</Service>';
                    param +='<ZipOrigination>'+DealerPostalCode+'</ZipOrigination>';
                    param +='<ZipDestination>'+CustomerPostalCode+'</ZipDestination>';
                    param +='<Pounds>'+weight_in_pounds+'</Pounds>';
                    param +='<Ounces>'+weight_in_ounces*conversionrate+'</Ounces>';
                    param +='<Container></Container>';
                    param +='<Width>'+Math.ceil(objCartItem.Product2.Width_in__c)+'</Width>';
                    param +='<Length>'+Math.ceil(objCartItem.Product2.Length_in__c)+'</Length>';
                    param +='<Height>'+Math.ceil(objCartItem.Product2.Height_in__c)+'</Height>';
                    param +='<Girth></Girth>';
                    param +='<Machinable>'+B2B_Constant.FALSE_FLAG+'</Machinable>';
                    param +='</Package>';
                    packageCounter=packageCounter+1;
                }
            }
            param +='</RateV4Request>';
            HttpRequest request = new HttpRequest();
            Http http = new Http();
            request = B2B_IntegrationCallout.uspsRequest(param);
            Long beforeAPI = B2B_Util.fetchCurrentTime();
            HTTPResponse response = http.send(request);
            responseWrapper.responseCode = String.valueOf(response.getStatusCode());
            if(response.getStatusCode()==B2B_IntegrationConstants.STATUSCODE)
            {	
                DOM.Document doc = response.getBodyDocument();
                Dom.XMLNode rootElement = doc.getRootElement(); 
                for (Dom.XMLNode childElement : rootElement.getChildElements()){
                    for(Dom.XMLNode detailElement : childElement.getChildElements()){
                        if(detailElement.getName()!= B2B_Constant.ERROR_LABEL){
                            for(Dom.XMLNode moredetailElement : detailElement.getChildElements()){
                                if(moredetailElement.getName()==B2B_IntegrationConstants.MAILSERVICE){
                                    if(moredetailElement.getText().contains('&lt;sup&gt;&#8482;&lt;/sup&gt;'))
                                        mailServiceName=moredetailElement.getText().replace('&lt;sup&gt;&#8482;&lt;/sup&gt;','');
                                    else
                                        mailServiceName=moredetailElement.getText().replace('&lt;sup&gt;&#174;&lt;/sup&gt;','');
                                    speedName=mailServiceName.trim();
                                }else if(moredetailElement.getName()==B2B_IntegrationConstants.RATE && speedName!=Null){
                                    rate=Decimal.valueOf(moredetailElement.getText());
                                }
                            }
                            if(speedName!=Null && rate!=0.0){
                                speedRate.put(speedName,rate);
                                speedName=Null;
                                rate=0.0;
                            }
                        }else{
                            for(Dom.XMLNode moredetailElement : detailElement.getChildElements()){
                                if(moredetailElement.getName() == B2B_IntegrationConstants.USPS_ERROR_NUMBER && moredetailElement.getText().trim() == B2B_IntegrationConstants.USPS_WRONGADDRESS_ERROR_CODE ){// This block will execute when address is invalid
                                    responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG;
                                    responseWrapper.responseCode = string.valueof(response.getStatusCode());
                                    responseWrapper.errorMessage=B2B_IntegrationConstants.ERROR_MESSAGE_ADDRESS_INVALID;
                                    break;
                                }
                            }
                        }
                    }
                    for(String filterSpeed:speedmapping.keyset()){
                        if(speedRate.containskey(filterSpeed)){
                            Decimal apirate=speedRate.get(filterSpeed)+ Decimal.valueOf(speedmapping.get(filterSpeed));
                            speedmapping.put(filterSpeed,string.valueof(apirate));
                        }else
                            speedmapping.remove(filterSpeed);
                    }
                    speedRate.clear();
                }
                responseWrapper.isSuccess = B2B_Constant.TRUE_FLAG;
                responseWrapper.serviceTypewithChargeMap= speedmapping;
            }else{// This block will excecute when API is down or throwing non 200 error code
                responseWrapper.errorMessage = B2B_IntegrationConstants.ERROR_MESSAGE_API_DOWN;
                responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG;
                responseWrapper.responseCode = string.valueof(response.getStatusCode());
                //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                Long afterAPI = B2B_Util.fetchCurrentTime();
                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);
                String severity;
                String errorType;
                Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                    severity= errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                    errorType=errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                }
                else{
                    severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                    errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                }
                Webcart cart=B2B_IntegrationUtility.getcartdetails(cartId);
                String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(cart.ownerId);
                Error__c errorRecord=B2B_Util.createErrorRecord(true,'','',cart.DealerId__c,personAccountId,cartId,'B2B_USPSShippingCalculation',String.valueOf(response.getStatusCode()),errorType,'','USPSShippingChargeCalculation',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                //HDMP-8617- End of changes
                responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG;
            }
            
        }catch(Exception Ex){
            responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG;
            responseWrapper.errorMessage = ex.getMessage() + B2B_IntegrationConstants.BlankVariable + ex.getLineNumber();
        }
        return JSON.serialize(responseWrapper); 
    }
    
}