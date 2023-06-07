/*******************************************************************************
Name: B2B_ShippingHelperV2
    Business Unit: HDM
	Date: 28/04/2021
	Developer: Radhey Shyam Gupta
	Description: This class is used for Shipping charge calculation.
	*******************************************************************************
	MODIFICATIONS – V1 | 09/06/2022 | Sayalee | Added Header
	*******************************************************************************/
    public class B2B_ShippingHelperV2 {
        @InvocableMethod(callout=true label='Get the delivery methods, silly' description='Runs a synchronous version of delivery method preparation' category='B2B Commerce')
        public static void syncDelivery(List<ID> cartIds) {
            // Validate the input
            if (cartIds == null || cartIds.size() != 1) {
                String errorMessage = 'A cart id must be included to B2BSyncDelivery';
                integrationStatusFailedWithCartValidationOutputError('Fail',errorMessage,'somejob','');
                throw new CalloutException (errorMessage);
            }
            
            // Extract cart id and start processing
            Id cartId = cartIds[0];
            startCartProcessMegaSync(cartId);
        }
        
        public static void startCartProcessMegaSync(Id cartId) {
            String integStatus = '';
            try{
                Webcart wc=[SELECT Id,Pickup_Dealer__c from Webcart where Id=:cartId];
                if(wc!=null && wc.Pickup_Dealer__c){
                    wc.ShippingAmount__c = 0.00;
                    update wc;
                }
                else{
                    B2B_FedexShippingCalculation.ResponseDataWrapper response=getShippingChargesFromFedex(cartId);
                    system.debug('response from api'+ response);
                    WebCart cart = new WebCart(id = cartId);
                    integStatus = 'SUCCESS';
                    if(response != null && response.isSuccess){
                        system.debug('map----' + response.serviceTypewithChargeMap);
                        for(String shippingChargeKey : response.serviceTypewithChargeMap.keyset()){
                            Decimal amount = Decimal.valueof(response.serviceTypewithChargeMap.get(shippingChargeKey)) ;
                            if(shippingChargeKey == 'FEDEX_GROUND'){
                                cart.ShippingAmount__c = amount;
                                break;
                            }
                            else if(cart.ShippingAmount__c == null){
                                cart.ShippingAmount__c = amount ;
                            }
                            else if(amount < cart.ShippingAmount__c){
                                cart.ShippingAmount__c = amount ;
                            }
                        }
                        cart.Shipping_Amount_Error_Message__c = ' ';
                        
                    }
                    else{
                        //cart.DisableShipToMe__c=true;
                        System.debug('else block'+response.responseCode);
                        if(response.responseCode == '500')
                        {
                            System.debug('500  block');
                            cart.Shipping_Amount_Error_Message__c='Dynamic backend host not specified';
                            cart.ShippingAmount__c = 0.00;
                            
                            
                        }
                        else
                        {
                            cart.Shipping_Amount_Error_Message__c = response?.errorMessage;
                            cart.ShippingAmount__c = 0.00;
                            
                            
                            
                        }
                        
                    }
                    
                    update cart; // updating cart
                }
            }catch(Exception e){
                
                integStatus = 'FAILED';
                // Creating error log record
                B2B_CheckoutUtility.createErrorRecord('Shhipping cost calculation error', null, 'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(), 'B2B_ShippingHelperV2', 'startCartProcessAsync',cartId,true,true);
                integrationStatusFailedWithCartValidationOutputError(integStatus,'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),'jobInfo',cartId);
            }
            
        }
        
        private static B2B_FedexShippingCalculation.ResponseDataWrapper getShippingChargesFromFedex(String cartId){
            WebCart cart = [SELECT Id,DealerId__c,DealerId__r.shippingStreet,DealerId__r.shippingCity,
                            DealerId__r.shippingPostalCode,DealerId__r.shippingState,
                            DealerId__r.Name,DealerId__r.POIID__c,
                            CustomerStreet__c,Customer_State__c,CustomerCity__c,CustomerCountry__c,
                            CustomerPostalCode__c
                            FROM WEbCart
                            WHERE Id=:cartId];
            Map<String,String> dealerAddress = New Map<String,String>();
            dealerAddress.put('mainDivision',cart.DealerId__r.shippingState);
            dealerAddress.put('postalCode',cart.DealerId__r.shippingPostalCode);
            dealerAddress.put('country','US');
            
            String dealerAddressStr = String.join(dealerAddress.values(),',');
            
            Map<String,String> customerAddress = New Map<String,String>();
            customerAddress.put('mainDivision',cart.Customer_State__c);
            customerAddress.put('postalCode',cart.CustomerPostalCode__c);
            customerAddress.put('country','US');
            B2B_FedexShippingCalculation.ResponseDataWrapper responseData;
            String customerAddressStr = String.join(customerAddress.values(),',');
            
            system.debug('dealerAddressStr====' + dealerAddressStr);
            system.debug('customerAddressStr====' + customerAddressStr);
            if(dealerAddressStr != customerAddressStr){
                String shippingAmountResponse = B2B_FedexShippingCalculation.fedexShippingChargeCalculation(cartId,dealerAddressStr,customerAddressStr);
                responseData = (B2B_FedexShippingCalculation.ResponseDataWrapper)JSON.deserialize(shippingAmountResponse, B2B_FedexShippingCalculation.ResponseDataWrapper.class);
            }
            else{
                return null;
            }
            
            return responseData;
        }
        
        @testvisible
        private static void integrationStatusFailedWithCartValidationOutputError(string integrationStatus, String errorMessage, string jobInfo, Id cartId) {
            
            CartValidationOutput cartValidationError = new CartValidationOutput(
                //BackgroundOperationId = jobInfo.jobId,
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String)cartId + ':' + System.now(),
                RelatedEntityId = cartId,
                Type = 'Shipping'
            );
            insert(cartValidationError);
            
        }
        
        
    }