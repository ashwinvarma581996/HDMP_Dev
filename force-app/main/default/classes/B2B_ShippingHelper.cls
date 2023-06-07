/*******************************************************************************
Name: B2B_ShippingHelper
Business Unit: HDM
Date: 28/04/2021
Developer: Radhey Shyam Gupta
Description: This class is used for Shipping charge calculation.
*******************************************************************************
MODIFICATIONS – V1 | 09/06/2022 | Sayalee | Added Header
MODIFICATIONS – V2 | 29/06/2022 | Soumya  | Added Header
MODIFICATIONS – V3 | 27/07/2022 | Soumya  | R2B related changes for Cart Updates and Multiple Shipping
MODIFICATIONS – V4 | 31/10/2022 | Soumya  | R2C2 related changes for Cart Updates and Multiple Shipping- HDMP-12228
*******************************************************************************/
public class B2B_ShippingHelper {
    @InvocableMethod(callout=true label='Get the delivery methods, silly' description='Runs a synchronous version of delivery method preparation' category='B2B Commerce')
    public static void syncDelivery(List<ID> cartIds) {
        if (cartIds == null || cartIds.size() != 1) {
            String errorMessage = 'A cart id must be included to B2BSyncDelivery';
            throw new CalloutException (errorMessage);
        }
        Id cartId = cartIds[0];
        String responsedetails=startCartProcessMegaSync(cartId,'','');
    }
    // starts here
    @AuraEnabled(cacheable=false)
    public static String startCartProcessMegaSync(Id cartId,String CustomerPostalCode,String cartType) {
        B2B_IntegrationWrapper response;
        try{
            String carrierName;
            Webcart wc=B2B_IntegrationUtility.getshippingdetails(cartId);
            if(wc != null){
                if(string.isNotEmpty(wc.DealerId__c)){
                    if(string.isNotEmpty(wc.DealerId__r.Preferred_Shipping_Carrier__c))
                        carrierName = wc.DealerId__r.Preferred_Shipping_Carrier__r.Name;
                    else
                        carrierName = B2B_IntegrationConstants.FEDEX_LABEL;
                    if(wc.Pickup_Dealer__c){
                        wc.ShippingAmount__c = B2B_IntegrationConstants.SHIPPING_AMOUNT_DEFAULT;
                        update wc;
                    }else if(carrierName.equalsIgnoreCase(B2B_IntegrationConstants.FEDEX_LABEL)){
                        response=getShippingChargesFromFedex(cartId,CustomerPostalCode,cartType,B2B_IntegrationConstants.FEDEX_LABEL);
                    }else if(carrierName.equalsIgnoreCase(B2B_IntegrationConstants.USPS_LABEL)){
                        response=getShippingChargesFromUSPS(cartId,CustomerPostalCode,cartType,B2B_IntegrationConstants.USPS_LABEL);
                    }else if(carrierName.equalsIgnoreCase(B2B_IntegrationConstants.UPS_LABEL)){
                        response=getShippingChargesFromUPS(cartId,CustomerPostalCode,cartType,B2B_IntegrationConstants.UPS_LABEL);
                    }
                }
                
            }
            
        }catch(Exception e){
            B2B_CheckoutUtility.createErrorRecord(B2B_IntegrationConstants.ERROR_MESSAGE_CHECKOUT, null, e.getTypeName() + B2B_IntegrationConstants.SHIPPING_STATEMENT + e.getMessage() + e.getLineNumber(), B2B_IntegrationConstants.ERROR_MESSAGE_DESCRIPTION,  B2B_IntegrationConstants.ERROR_MESSAGE_METHOD_NAME,cartId,true,true);
        }
        return JSON.serialize(response);
        
    }
    
    private static B2B_IntegrationWrapper getShippingChargesFromFedex(String cartId,String CustomerPostalCode,String cartType,String Carrier){
        B2B_IntegrationWrapper responseData;
        B2B_IntegrationWrapper responsedatawithdefault;
        String customerAddressStr,dealerAddressStr,shippingAmountResponse;
        Map<String,String> dealerAddress = New Map<String,String>();
        Map<String,String> customerAddress = New Map<String,String>();
        Webcart cart=B2B_IntegrationUtility.getcartdetails(cartId);
        if(cart!=Null){
            if(!cartType.equalsIgnoreCase(B2B_IntegrationConstants.TYPE_VALUE) && (String.isEmpty(CustomerPostalCode))){
                dealerAddress.put(B2B_IntegrationConstants.STATE,cart.DealerId__r.shippingState);
                dealerAddress.put(B2B_IntegrationConstants.POSTALCODE,cart.DealerId__r.shippingPostalCode);
                dealerAddress.put(B2B_IntegrationConstants.COUNTRY,B2B_IntegrationConstants.COUNTRY_VALUE );
                
                customerAddress.put(B2B_IntegrationConstants.STATE,cart.Customer_State__c);
                customerAddress.put(B2B_IntegrationConstants.POSTALCODE,cart.CustomerPostalCode__c);
                customerAddress.put(B2B_IntegrationConstants.COUNTRY,B2B_IntegrationConstants.COUNTRY_VALUE );
                dealerAddressStr = String.join(dealerAddress.values(),B2B_Constant.SHIPPING_SPLIT);
                customerAddressStr = String.join(customerAddress.values(),B2B_Constant.SHIPPING_SPLIT);
            }else{
                dealerAddressStr=cart.DealerId__r.shippingPostalCode.substring(B2B_IntegrationConstants.USPS_FIRST_INDEX,B2B_IntegrationConstants.USPS_LAST_iNDEX);
                customerAddressStr=CustomerPostalCode;
            }
            shippingAmountResponse=B2B_FedexShippingCalculation.fedexShippingChargeCalculation(cartId,dealerAddressStr,customerAddressStr,cartType);
            responseData = (B2B_IntegrationWrapper)JSON.deserialize(shippingAmountResponse, B2B_IntegrationWrapper.class);
            if(!cartType.equalsIgnoreCase(B2B_IntegrationConstants.TYPE_VALUE) && (String.isEmpty(CustomerPostalCode)))
                getdefaultspeedresponse(responsedata,cartId,Carrier);
            else
                setStandardCartData(responsedata,cartId,Carrier);
        }
        return responseData;
    }
    private static B2B_IntegrationWrapper getShippingChargesFromUSPS(String cartId,String CustomerPostalCode,String cartType,String Carrier){
        String customerAddressStr,dealerAddressStr,shippingAmountResponse;
        B2B_IntegrationWrapper responseData;
        Webcart cart=B2B_IntegrationUtility.getcartdetails(cartId);
        dealerAddressStr = cart.DealerId__r.shippingPostalCode.substring(B2B_IntegrationConstants.USPS_FIRST_INDEX,B2B_IntegrationConstants.USPS_LAST_iNDEX);
        if(cart!=Null){
            
            if(!cartType.equalsIgnoreCase(B2B_IntegrationConstants.TYPE_VALUE) && (String.isEmpty(CustomerPostalCode))){
                customerAddressStr =cart.CustomerPostalCode__c.substring(B2B_IntegrationConstants.USPS_FIRST_INDEX,B2B_IntegrationConstants.USPS_LAST_iNDEX);
            }else{
                customerAddressStr =CustomerPostalCode.substring(B2B_IntegrationConstants.USPS_FIRST_INDEX,B2B_IntegrationConstants.USPS_LAST_iNDEX);
            }
            shippingAmountResponse=B2B_USPSShippingCalculation.USPSShippingChargeCalculation(cartId,dealerAddressStr,customerAddressStr);
            responseData = (B2B_IntegrationWrapper)JSON.deserialize(shippingAmountResponse, B2B_IntegrationWrapper.class);
            if(!cartType.equalsIgnoreCase(B2B_IntegrationConstants.TYPE_VALUE) && (String.isEmpty(CustomerPostalCode)))
                getdefaultspeedresponse(responsedata,cartId,Carrier);
            else
                setStandardCartData(responsedata,cartId,Carrier);
        }
        return responseData;
    }
    private static B2B_IntegrationWrapper getShippingChargesFromUPS(String cartId,String CustomerPostalCode,String cartType,String Carrier){
        String customerAddressStr,dealerAddressStr,shippingAmountResponse;
        B2B_IntegrationWrapper responseData;
        Webcart cart=B2B_IntegrationUtility.getcartdetails(cartId);
        if(cart!=Null){
            if(!cartType.equalsIgnoreCase(B2B_IntegrationConstants.TYPE_VALUE) && (String.isEmpty(CustomerPostalCode))){
                Map<String,String> dealerAddress = New Map<String,String>();
                dealerAddress.put(B2B_IntegrationConstants.SHIPPINGSTREET,cart.DealerId__r.shippingStreet);
                dealerAddress.put(B2B_IntegrationConstants.CITY,cart.DealerId__r.shippingCity);
                dealerAddress.put(B2B_IntegrationConstants.STATE,cart.DealerId__r.shippingState);
                dealerAddress.put(B2B_IntegrationConstants.POSTALCODE,cart.DealerId__r.shippingPostalCode);
                dealerAddress.put(B2B_IntegrationConstants.COUNTRY,B2B_IntegrationConstants.COUNTRY_VALUE);
                Map<String,String> customerAddress = New Map<String,String>();
                customerAddress.put(B2B_IntegrationConstants.SHIPPINGSTREET,cart.CustomerStreet__c);
                customerAddress.put(B2B_IntegrationConstants.CITY,cart.CustomerCity__c);
                customerAddress.put(B2B_IntegrationConstants.STATE,cart.Customer_State__c);
                customerAddress.put(B2B_IntegrationConstants.POSTALCODE,cart.CustomerPostalCode__c);
                customerAddress.put(B2B_IntegrationConstants.COUNTRY,B2B_IntegrationConstants.COUNTRY_VALUE);
                dealerAddressStr = String.join(dealerAddress.values(),B2B_Constant.SHIPPING_SPLIT);
                customerAddressStr = String.join(customerAddress.values(),B2B_Constant.SHIPPING_SPLIT);
            }else{
                dealerAddressStr=cart.DealerId__r.shippingPostalCode.substring(B2B_IntegrationConstants.USPS_FIRST_INDEX,B2B_IntegrationConstants.USPS_LAST_iNDEX);
                customerAddressStr=CustomerPostalCode;
            }
            shippingAmountResponse=B2B_UPSShippingCalculation.UPSShippingChargeCalculation(cartId,dealerAddressStr,customerAddressStr,cartType);
            responseData = (B2B_IntegrationWrapper)JSON.deserialize(shippingAmountResponse,B2B_IntegrationWrapper.class);
            if(!cartType.equalsIgnoreCase(B2B_IntegrationConstants.TYPE_VALUE) && (String.isEmpty(CustomerPostalCode)))
                getdefaultspeedresponse(responsedata,cartId,Carrier);
            else
                setStandardCartData(responsedata,cartId,Carrier);
        }
        return responseData;
    }
    private static void getdefaultspeedresponse(B2B_IntegrationWrapper responsedata,Id CartId,String Carrier){
        String customerPreferredSpeed;
        Decimal amount; 
        Boolean flag=false;
        Map<String,Carrier_Speed__c> shippingSpeedsMap = B2B_IntegrationUtility.getShippingdata(Carrier,false);
        Map<String,Carrier_Speed__c> preferredShippingSpeedsMap = B2B_IntegrationUtility.getShippingdata(Carrier,true);
        String customerPreferredSpeedCategory=B2B_IntegrationUtility.getcustomerpreferredshippingspeed(UserInfo.getUserId());
        if(String.isNotBlank(customerPreferredSpeedCategory))
            customerPreferredSpeed= String.valueOf(preferredShippingSpeedsMap.get(customerPreferredSpeedCategory).Carrier_Speed_Name__c);
        else
            customerPreferredSpeed='';
        List<Webcart> carttoupdate=new List<Webcart>();
        Map<String,String> responsedetails=new Map<String,String>();
        Webcart cart =new Webcart(Id=CartId);
        
        if(!responsedata.serviceTypewithChargeMap.isEmpty() && responsedata != null && responsedata.isSuccess && responsedata.errorMessage==''){
            for(String shippingChargeKey : responsedata.serviceTypewithChargeMap.keyset()){
                responsedetails.put(shippingChargeKey,responsedata.serviceTypewithChargeMap.get(shippingChargeKey));
            }
            for(String SpeedPreference: shippingSpeedsMap.keySet()){
                if(responsedetails.containsKey(customerPreferredSpeed)){
                    amount = Decimal.valueof(responsedetails.get(customerPreferredSpeed));
                    cart.ShippingAmount__c=amount;
                    cart.Honda_Shipping_Speed__c = shippingSpeedsMap.get(SpeedPreference).Honda_Shipping_Speed__c;
                    responsedata.defaultspeed=customerPreferredSpeed;
                    break; 
                }else if(responsedetails.containsKey(SpeedPreference)){
                    amount = Decimal.valueof(responsedetails.get(SpeedPreference));
                    cart.ShippingAmount__c=amount;
                    cart.Honda_Shipping_Speed__c = shippingSpeedsMap.get(SpeedPreference).Honda_Shipping_Speed__c;
                    responsedata.defaultspeed=SpeedPreference;
                    break; 
                }
            }
            if(cart.ShippingAmount__c==Null){
                cart.ShippingAmount__c=B2B_IntegrationConstants.SHIPPING_AMOUNT_DEFAULT;
            }
        }else if(responsedata.responseCode == String.valueof(B2B_IntegrationConstants.STATUSCODE) && responsedata.errorMessage==''){
            cart.ShippingAmount__c = B2B_IntegrationConstants.SHIPPING_AMOUNT_DEFAULT;
            responsedata.errorMessage=B2B_IntegrationConstants.ERROR_MESSAGE_NO_HONDASHIPPING_SPEED;
        }else {
            cart.ShippingAmount__c = B2B_IntegrationConstants.SHIPPING_AMOUNT_DEFAULT;
        }
        cart.B2B_Shipping_Speed_Options__c=JSON.serialize(responsedata);
        carttoupdate.add(cart);
        if(!carttoupdate.isEmpty()){
          try{
                update carttoupdate;
            }catch(Exception e){
                B2B_CheckoutUtility.createErrorRecord(B2B_IntegrationConstants.ERROR_MESSAGE_CHECKOUT, null, B2B_IntegrationConstants.SHIPPING_EXCEPTION + e.getTypeName() + B2B_IntegrationConstants.SHIPPING_STATEMENT + e.getMessage(), B2B_IntegrationConstants.ERROR_MESSAGE_DESCRIPTION,  B2B_IntegrationConstants.ERROR_MESSAGE_METHOD_NAME,cartId,true,true);
            }  
        }
            
        
    }
    // Below method added as part of HDMP-12228
    private static void setStandardCartData(B2B_IntegrationWrapper responsedata,Id cartId,String carrier){
        String standardSpeed = B2B_IntegrationUtility.getStandardSpeed(carrier);
        if(cartId!=null && String.isNotEmpty(standardSpeed)){
            webcart carttoupdate = new webcart(Id=cartId);
        	if(responsedata.serviceTypewithChargeMap.containskey(standardSpeed) && responsedata.responseCode == String.valueof(B2B_IntegrationConstants.STATUSCODE))
                carttoupdate.ShippingAmount__c = Decimal.valueof(responsedata.serviceTypewithChargeMap.get(standardSpeed));
            else{
                carttoupdate.ShippingAmount__c = B2B_IntegrationConstants.SHIPPING_AMOUNT_DEFAULT;
                carttoupdate.Total_Shipping_Tax__c = B2B_IntegrationConstants.SHIPPING_AMOUNT_DEFAULT;
            }
            	    
            update carttoupdate;
        	
        }
    }
    
}// Ends here-- Soumya Sahoo -- R2 Story