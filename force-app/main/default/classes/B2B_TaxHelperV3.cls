public class B2B_TaxHelperV3 {

    // This invocable method only expects one ID
    @InvocableMethod(callout=true label='TAX MAN COMETH' description='Runs a synchronous version of taxes' category='B2B Commerce')
    public static void syncTax(List<ID> cartIds) {
        // Validate the input
        if (cartIds == null || cartIds.size() != 1) {
            String errorMessage = 'A cart id must be included to B2BSyncTax'; // Get wording from doc!!!
            integrationStatusFailedWithCartValidationOutputError('FAIL',errorMessage, 'SOMEJOB','');
            throw new CalloutException (errorMessage);
        }

        // Extract cart id and start processing
        Id cartId = cartIds[0];
        startCartProcessMegaSync(cartId);
    }
	 @AuraEnabled
    public static void startCartProcessMegaSync(Id cartId) {
        String integStatus = '';
        try {

            B2B_VertexTaxCalculationIntegration.ResponseDataWrapper taxResponse = getTaxRatesAndAmountsFromVertex(cartId,'','','');
            WebCart cart = new WebCart(id = cartId);
            if(taxResponse.isSuccess){
                cart.Total_Tax__c = Decimal.valueof(taxResponse.totalTaxAmount) ;
                integStatus = 'SUCCESS';
                cart.Tax_Amount_Error_Message__c='';

            }
            else{
                cart.Total_Tax__c = 0.00;
                cart.Tax_Amount_Error_Message__c = taxResponse?.errorMessage;

                // Creating error log record
                B2B_CheckoutUtility.createErrorRecord('Tax calculation error', null, taxResponse.errorMessage, 'B2BTaxSample', 'startCartProcessAsync',cartId,true,true);


            }
            update cart;
        } catch(Exception e) {
            // sending mail
            //B2B_CheckoutUtility.sendEmail('Vertex error','Taxt Sample An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage());
            integStatus = 'FAILED';
            // Creating error log record
            // B2B_CheckoutUtility.createErrorRecord('Tax calculation error', null, e.getMessage(), 'B2BTaxSample', 'startCartProcessAsync',null,true);
            B2B_CheckoutUtility.createErrorRecord('Tax cost calculation error', null, 'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(), 'B2BDeliverySample', 'startCartProcessAsync',cartId,true,true);
            integrationStatusFailedWithCartValidationOutputError(integStatus,'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),'jobInfo',cartId);
        }
    }
	//Below method is called from LWC for estimated Tax charges on Cart Page-- Added By Soumya as part of R2
	@AuraEnabled(cacheable=false)	
    public static string CartTaxCharges(String cartId,String CustomerPostalCode,String ShippingCharges) 
       		{ 
                String finalresponse;
			try{
                
                B2B_VertexTaxCalculationIntegration.ResponseDataWrapper taxResponse = getTaxRatesAndAmountsFromVertex(cartId,ShippingCharges,CustomerPostalCode,'Cart');
            		if(taxResponse != null && taxResponse.isSuccess){
                    	 finalresponse=JSON.serialize(taxResponse);
                        system.debug('String finalresponse'+ finalresponse);
                        
                    }
                else
                {
                    
                                    
                B2B_CheckoutUtility.createErrorRecord('Tax calculation error', null, taxResponse.errorMessage, 'B2BTaxSample', 'CartTaxCharges',cartId,true,true);
				finalresponse=Null;
                    
                }
              } catch(Exception e) {
            
            
            
				B2B_CheckoutUtility.createErrorRecord('Tax cost calculation error', null, 'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(), 'B2BDeliverySample', 'startCartProcessAsync',cartId,true,true);
				
				finalresponse=Null;
			}  
              system.debug('String finalresponse'+ finalresponse);
                return finalresponse;  	
			}

    @AuraEnabled
    public static B2B_VertexTaxCalculationIntegration.ResponseDataWrapper getTaxRatesAndAmountsFromVertex(String cartId,String ShippingCharges,String CustomerPostalCode,String Type){//, String customerAdd) {
        
        String InstallationCharges;
        Map<String,String> dealerAddress = New Map<String,String>();
        Map<String,String> CustomerAddress = New Map<String,String>();
        
        WebCart cart = [SELECT Id,DealerId__c,DealerId__r.shippingStreet,DealerId__r.shippingCity,
                DealerId__r.shippingPostalCode,DealerId__r.shippingState,
                DealerId__r.Name,DealerId__r.POIID__c,ShippingAmount__c,Total_Installation_Charge__c,
                CustomerStreet__c,Customer_State__c,CustomerCity__c,CustomerCountry__c,
                CustomerPostalCode__c
        FROM WEbCart
        WHERE Id=:cartId];
        if(String.isBlank(ShippingCharges))
            ShippingCharges = String.valueOf(cart.ShippingAmount__c);
        
        if(cart.Total_Installation_Charge__c>0)
            			InstallationCharges=String.valueOf(cart.Total_Installation_Charge__c);
            	else
                		InstallationCharges=Null;
       	if(Type!='Cart'){
        	
        	dealerAddress.put('streetAddress',cart.DealerId__r.shippingStreet);
        	dealerAddress.put('city',cart.DealerId__r.shippingCity);
        	dealerAddress.put('mainDivision',cart.DealerId__r.shippingState);
        	dealerAddress.put('postalCode',cart.DealerId__r.shippingPostalCode);

       	 	
        	CustomerAddress.put('streetAddress',cart.CustomerStreet__c);
        	CustomerAddress.put('city',cart.CustomerCity__c);
        	CustomerAddress.put('mainDivision',cart.Customer_State__c);
        	CustomerAddress.put('postalCode',cart.CustomerPostalCode__c);
       }else{
            dealerAddress.put('postalCode',cart.DealerId__r.shippingPostalCode);
            CustomerAddress.put('postalCode',CustomerPostalCode);
        }
        	B2B_VertexTaxCalculationIntegration.ResponseDataWrapper responseData = B2B_VertexTaxCalculationIntegration.calculateTaxQuotation(cartId,dealerAddress,CustomerAddress,cart.DealerId__r.POIID__c,ShippingCharges,InstallationCharges, 'quotation',Type);
            return responseData;
    }

	@testvisible
    private Map<String, TaxDataFromExternalService> getTaxRatesAndAmountsFromExternalService (
            Map<String, Decimal> cartItemTotalAmountBySKU, String state, String country) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Integer SuccessfulHttpRequest = 200;
        String encodedState = (state == null) ? '' : EncodingUtil.urlEncode(state, 'UTF-8').replace('+', '%20');
        String encodedCountry = (country == null) ? '' : EncodingUtil.urlEncode(country, 'UTF-8').replace('+', '%20');

        Map<String, Decimal> encodedCartItemTotalAmountBySKU = new Map<String, Decimal>();
        for(String sku: cartItemTotalAmountBySKU.keySet()) {
            encodedCartItemTotalAmountBySKU.put(EncodingUtil.urlEncode(sku, 'UTF-8'), cartItemTotalAmountBySKU.get(sku));
        }

        // To access the service below, you may need to add endpoint = https://b2b-commerce-test.herokuapp.com in Setup | Security | Remote site settings.
        String requestURL = 'https://b2b-commerce-test.herokuapp.com/get-tax-rates?state=' + encodedState
                + '&country=' + encodedCountry
                + '&amountsBySKU=' + JSON.serialize(encodedCartItemTotalAmountBySKU);
        request.setEndpoint(requestURL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == SuccessfulHttpRequest) {
            Map<String, Object> resultsFromExternalServiceBySKU = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, TaxDataFromExternalService> taxDataFromExternalServiceBySKU = new Map<String, TaxDataFromExternalService>();
            for (String sku : resultsFromExternalServiceBySKU.keySet()) {
                Map<String, Object> rateAndAmountFromExternalService = (Map<String, Object>) resultsFromExternalServiceBySKU.get(sku);
                taxDataFromExternalServiceBySKU.put(sku, new TaxDataFromExternalService(
                        (Decimal)rateAndAmountFromExternalService.get('taxRate'),
                        (Decimal)rateAndAmountFromExternalService.get('taxAmount'),
                        (String)rateAndAmountFromExternalService.get('taxName')
                ));
            }
            return taxDataFromExternalServiceBySKU;
        }
        else {
            throw new CalloutException ('There was a problem with the request. Error: ' + response.getStatusCode());
        }
    }

    // Structure to store the tax data retrieved from external service
    // This simplifies our ability to access it when storing it in Salesforce's CartTax entity
    @testvisible
    Class TaxDataFromExternalService {
        private Decimal rate;
        private Decimal amount;
        private String taxName;

        public TaxDataFromExternalService () {
            rate = 0.0;
            amount = 0.0;
            taxName = '';
        }

        public TaxDataFromExternalService (Decimal someRate, Decimal someAmount, String someTaxName) {
            rate = someRate;
            amount = someAmount;
            taxName = someTaxName;
        }

        public Decimal getRate() {
            return rate;
        }

        public Decimal getAmount() {
            return amount;
        }

        public String getTaxName() {
            return taxName;
        }
    }
	@testvisible
    private static void integrationStatusFailedWithCartValidationOutputError(string integrationStatus, String errorMessage, string jobInfo, Id cartId) {
        //integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
        CartValidationOutput cartValidationError = new CartValidationOutput(
                //BackgroundOperationId = jobInfo.jobId,
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String)cartId + ':' + System.now(),
                RelatedEntityId = cartId,
                Type = 'Taxes'
        );
        insert(cartValidationError);
        //return integrationStatus;
    }

}