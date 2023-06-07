/*******************************************************************************
Name: B2B_UPSShippingCalculation
Business Unit: HDM
Date: 28/04/21
Developer: Soumya Sahoo 
Description: This class is to provide Shipping charge calculation for UPS Carrier.
*******************************************************************************
MODIFICATIONS – V1 | Soumya Sahoo | Error handling changes- JIRA- 8617 
				V2 | Sayalee Brahmankar | Added Header
				V3 | Soumya Sahoo | Error handling changes- JIRA- 8924
				V4 | Soumya Sahoo | R2B Stories- Multiple Shipping and cart updates stories
*******************************************************************************/
public class B2B_UPSShippingCalculation {
    public static String UPSShippingChargeCalculation(String cartId, String dealerAddress, String customerAddress,String cartType){
        B2B_IntegrationWrapper responseWrapper =  New B2B_IntegrationWrapper();
        String reqBody,ShipperDetails,DealerDetails,CustomerDetails,PackageDetails,PackageItems;
        Integer packageCounter=B2B_IntegrationConstants.DEFAULT_VALUE;
        Integer packageQuantity=B2B_IntegrationConstants.DEFAULT_VALUE;
        List<String> dealerAddressList = New List<String>();
        List<String> customerAddressList = New List<String>();
        Map<String,Carrier_Speed__c> shippingSpeedsMap = B2B_IntegrationUtility.getShippingdata(B2B_IntegrationConstants.UPS_LABEL,false);
        Map<String,String> hondaResponseData=new Map<String,String>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        try{
            if(!String.IsEmpty(dealerAddress) && (!cartType.equalsIgnoreCase(B2B_IntegrationConstants.TYPE_VALUE))){
                dealerAddressList = dealerAddress.split(B2B_Constant.SHIPPING_SPLIT);
            }
            if(!String.IsEmpty(customerAddress) && (!cartType.equalsIgnoreCase(B2B_IntegrationConstants.TYPE_VALUE))){
                customerAddressList = customerAddress.split(B2B_Constant.SHIPPING_SPLIT);
            }
            if((dealerAddressList.size() < 4 || customerAddressList.size() < 4) && (!cartType.equalsIgnoreCase(B2B_IntegrationConstants.TYPE_VALUE))){
                responseWrapper.errorMessage = B2B_IntegrationConstants.ERROR_CORRECT_ADDRESS;
                responseWrapper.isSuccess = false; 
            }else{
                if(cartType!= B2B_IntegrationConstants.TYPE_VALUE){
                    ShipperDetails='"Shipper": {"Name":"","ShipperNumber":"","Address": {"AddressLine": "'+dealerAddressList[0]+'","City":"'+dealerAddressList[1]+'","StateProvinceCode": "'+dealerAddressList[2]+'","PostalCode": "'+dealerAddressList[3]+'","CountryCode": "'+dealerAddressList[4]+'"}},';
                    CustomerDetails='"ShipTo": {"Name":"","Address": {"AddressLine": "'+customerAddressList[0]+'","City": "'+customerAddressList[1]+'","StateProvinceCode": "'+customerAddressList[2]+'","PostalCode": "'+customerAddressList[3]+'","CountryCode": "'+customerAddressList[4]+'"}},';
                    DealerDetails='"ShipFrom": {"Name":"","Address": {"AddressLine": "'+dealerAddressList[0]+'","City": "'+dealerAddressList[1]+'","StateProvinceCode": "'+dealerAddressList[2]+'","PostalCode": "'+dealerAddressList[3]+'","CountryCode": "'+dealerAddressList[4]+'"}},';
                }else{
                    ShipperDetails='"Shipper": {"Name":"","ShipperNumber":"","Address": {"PostalCode": "'+dealerAddress+'","CountryCode": "US"}},';
                    CustomerDetails='"ShipTo": {"Name":"","Address": {"PostalCode": "'+customerAddress+'","CountryCode": "US"}},';
                    DealerDetails='"ShipFrom": {"Name":"","Address": {"PostalCode": "'+dealerAddress+'","CountryCode": "US"}},';
                }
                PackageItems='"Package":[';
                for(CartItem objCartItem : B2B_IntegrationUtility.getCartItemdetails(cartId)){
                    if(objCartItem.Item_Package_quantity__c > 0)
                        packageQuantity = Integer.valueof(objCartItem.Quantity * objCartItem.Item_Package_quantity__c);
                    else
                    	packageQuantity = Integer.valueof(objCartItem.Quantity);
                    for(Integer i=0;i < packageQuantity;i++){
                        PackageItems+='{"PackagingType": {"Code": "02","Description": "Package"},"Dimensions": {"UnitOfMeasurement": {"Code": "IN"},';
                        PackageItems+='"Length": "'+Math.ceil(objCartItem.Product2.Length_in__c)+'",';
                        PackageItems+='"Width": "'+Math.ceil(objCartItem.Product2.Width_in__c)+'",';
                        PackageItems+='"Height": "'+Math.ceil(objCartItem.Product2.Height_in__c)+'"';
                        PackageItems+='},"PackageWeight": {"UnitOfMeasurement": {"Code": "LBS"},';
                        PackageItems+='"Weight": "'+objCartItem.Product2.Weight_lbs__c+'"';
                        PackageItems+='}},';
                        packageCounter=packageCounter+1;
                    }
                }
                String finalPackageItems=PackageItems.removeEnd(B2B_Constant.SHIPPING_SPLIT);
                PackageDetails=finalPackageItems+']';
                reqBody='{"RateRequest": {"Shipment": {'+ShipperDetails+CustomerDetails+DealerDetails+PackageDetails+'}}}';
                request = B2B_IntegrationCallout.upsRequest(reqBody);
                Long beforeAPI = B2B_Util.fetchCurrentTime();
                HTTPResponse response = http.send(request);
                if(response.getStatusCode()==B2B_IntegrationConstants.STATUSCODE){
                    Map<String,Object> UPSDecoderResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody()); 
                    Map<String,Object> UPSRateResponse = (Map<String,Object>) UPSDecoderResponse.get(B2B_IntegrationConstants.RATERESPONSE);
                    String UPSRatedResponseserialize = JSON.serialize(UPSRateResponse);
                    Map<String,Object> UPSRatedResponsedeseriliaze = (Map<String,Object>)JSON.deserializeUntyped(UPSRatedResponseserialize);
                    Map<String,Object> UPSresponse = (Map<String,Object>)UPSRatedResponsedeseriliaze.get(B2B_IntegrationConstants.RESPONSE);
                    Map<String,Object> UPSresponsestatus = (Map<String,Object>)UPSresponse.get(B2B_IntegrationConstants.RESPONSESTATUS);
                    String statusflag = (String)UPSresponsestatus.get(B2B_IntegrationConstants.DESCRIPTION);
                    
                    if(statusflag.equalsIgnoreCase(B2B_IntegrationConstants.SUCCESS)){
                        List<Object> RatedShipmentList=(List<Object>)JSON.deserializeUntyped(JSON.serialize(UPSRatedResponsedeseriliaze.get(B2B_IntegrationConstants.RATEDSHIPMENT)));
                        Map<Integer,Object> RateShippmentMappedData=new Map<Integer,Object>();
                        Map<String,String> serviceTypewithChargeMapdata=new Map<String,String>();
                        Integer i=0;
                        for(Object RatedShipmentdata: RatedShipmentList){
                            RateShippmentMappedData.put(i,RatedShipmentdata);
                            i++;
                        }
                        for(Integer RateShippmentKey:RateShippmentMappedData.keySet()){
                            Map<String,Object> RateShippmentrecords=(Map<String,Object>)RateShippmentMappedData.get(RateShippmentKey);
                            Map<String,Object> RateShippmentTotalcharges=(Map<String,Object>)RateShippmentrecords.get(B2B_IntegrationConstants.TOTALCHARGES);
                            Map<String,Object> RateShippmentService=(Map<String,Object>)RateShippmentrecords.get(B2B_IntegrationConstants.SERVICE);
                            serviceTypewithChargeMapdata.put((String)RateShippmentService.get(B2B_IntegrationConstants.CODE),(String)RateShippmentTotalcharges.get(B2B_IntegrationConstants.MONETARYVALUE));
                            
                        }
                        // Below line of code to filter honda specific speed
                        for(string availableSpeed:shippingSpeedsMap.keySet()){
                            if(serviceTypewithChargeMapdata.containskey(availableSpeed))
                                hondaResponseData.put(availableSpeed,serviceTypewithChargeMapdata.get(availableSpeed));
                        }
                        // End of changes
                        responseWrapper.serviceTypewithChargeMap= hondaResponseData;
                        responseWrapper.errorMessage=B2B_IntegrationConstants.BlankVariable;
                        responseWrapper.isSuccess = B2B_Constant.TRUE_FLAG;
                        responseWrapper.responseCode= String.valueOf(response.getStatusCode());
                    }else
                        responseWrapper.errorMessage=statusflag;
                }else if(response.getStatusCode()==400){ // This condition will execute when user put invalid zipcode
                    responseWrapper.errorMessage=B2B_IntegrationConstants.ERROR_MESSAGE_ADDRESS_INVALID;
                    responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG;
                    responseWrapper.responseCode = string.valueof(response.getStatusCode());
                }else { // This condition will execute when API is down or <>200,400 status code
                    responseWrapper.errorMessage = B2B_IntegrationConstants.ERROR_MESSAGE_API_DOWN;
                    responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG;
                    responseWrapper.responseCode = string.valueof(response.getStatusCode());
                    //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                    Long afterAPI = B2B_Util.fetchCurrentTime();
                    Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);
                    Webcart cart=B2B_IntegrationUtility.getcartdetails(cartId);
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
                    String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(cart.ownerId);
                    Error__c errorRecord=B2B_Util.createErrorRecord(true,'','',cart.DealerId__c,personAccountId,cartId,'B2B_UPSShippingCalculation',String.valueOf(response.getStatusCode()),errorType,'','UPSShippingChargeCalculation',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                    //HDMP-8617- End of changes
                    responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG;
                }
                
            }
        }catch(Exception Ex){
            responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG;
            responseWrapper.errorMessage = ex.getMessage() + ' ' + ex.getLineNumber();
        }
        return JSON.serialize(responseWrapper);
    }
    
}