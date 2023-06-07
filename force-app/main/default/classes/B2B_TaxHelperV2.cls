/*******************************************************************************
Name: B2B_TaxHelperV2
Business Unit: HDM
Date: 28/04/2021
Developer: Radhey Shyam Gupta
Description: This class is to provide Tax from Vertex API.
Test ClassName- B2B_TaxHelperV2Test, B2B_VertexTaxCalculationCalloutMock(Mock Class)
*******************************************************************************
MODIFICATIONS – Date | Dev Name 	| Method | User Story
22/05/2022 | Soumya Sahoo |  Error handling changes- JIRA- 8617
*******************************************************************************/

public class B2B_TaxHelperV2 {
    
    private static string taxErrorMessage;
    
    public class FlowOutput{
        @InvocableVariable public String taxErrorMessage;
        public FlowOutput(String taxErrorMessage) {this.taxErrorMessage = taxErrorMessage;}
    }
    
    // This invocable method only expects one ID
    @InvocableMethod(callout=true label='TAX MAN COMETH' description='Runs a synchronous version of taxes' category='B2B Commerce')
    public static FlowOutput[] syncTax(List<ID> cartIds) {
        // Validate the input
        if (cartIds == null || cartIds.size() != 1) {
            String errorMessage = B2B_IntegrationConstants.ERRORMESSAGE_TAX; // Get wording from doc!!!
            integrationStatusFailedWithCartValidationOutputError(B2B_Constant.FAILURE_LABEL,errorMessage,B2B_IntegrationConstants.SOME_JOB,'');
            throw new CalloutException (errorMessage);
        }
        
        // Extract cart id and start processing
        Id cartId = cartIds[0];
        String taxresponse=startCartProcessMegaSync(cartId,B2B_IntegrationConstants.BlankVariable,B2B_IntegrationConstants.BlankVariable,B2B_IntegrationConstants.BlankVariable);
    	FlowOutput[] results = new List<FlowOutput>();
        results.add(new FlowOutput(taxErrorMessage));
        return results;
    }
    
    @AuraEnabled(cacheable=false)	
    public static String startCartProcessMegaSync(Id cartId,String CustomerPostalCode,String ShippingCharges,String cartType) {
        String integStatus = B2B_IntegrationConstants.BlankVariable,finalresponse=B2B_IntegrationConstants.NULLVARIABLE;
        try {
            B2B_VertexTaxCalculationIntegration.ResponseDataWrapper taxResponse = getTaxRatesAndAmountsFromVertex(cartId,ShippingCharges,CustomerPostalCode,cartType);
            WebCart cart = new WebCart(id = cartId);
            if(taxResponse.isSuccess){
                cart.Total_Tax__c = Decimal.valueof(taxResponse.totalTaxAmount) ;//Changes done to store values on cart page - HDMP-12353
                cart.Total_Shipping_Tax__c = taxResponse.shippingTaxAmount;//Added by Soumya for 8705, Changes done to store values on cart page - HDMP-12353
                cart.Total_Installation_Tax__c = taxResponse.installationTaxAmount;//Added to update tax against Total Installation Charges-8705, Changes done to store values on cart page - HDMP-12353
                integStatus = B2B_Constant.SUCCESS;
            }
            else{
                cart.Total_Tax__c = B2B_IntegrationConstants.SHIPPING_AMOUNT_DEFAULT;
                String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                Error__c errorRecord=B2B_Util.createErrorRecord(true,'','','',personAccountId,cartId,'B2B_TaxHelperV2','','','','startCartProcessMegaSync',false,'','','',0,'','','Response:'+ finalresponse);
                
            }
            finalresponse = JSON.serialize(taxResponse);
            taxErrorMessage = taxResponse.errorMessage;
            update cart;
        } catch(Exception e) {
            integStatus = B2B_Constant.FAILURE_LABEL;
            B2B_CheckoutUtility.createErrorRecord(B2B_IntegrationConstants.TAX_ERROR_MESSAGE_CHECKOUT, B2B_IntegrationConstants.NULLVARIABLE, B2B_IntegrationConstants.SHIPPING_EXCEPTION + e.getTypeName() +B2B_IntegrationConstants.SHIPPING_STATEMENT+ e.getMessage(), B2B_IntegrationConstants.ERROR_MESSAGE_DESCRIPTION, B2B_IntegrationConstants.ERROR_MESSAGE_METHOD_NAME,cartId,B2B_Constant.TRUE_FLAG,B2B_Constant.TRUE_FLAG);
            integrationStatusFailedWithCartValidationOutputError(integStatus,B2B_IntegrationConstants.SHIPPING_EXCEPTION + e.getTypeName() + B2B_IntegrationConstants.SHIPPING_STATEMENT + e.getMessage(),B2B_IntegrationConstants.JOB_INFO,cartId);
        }
        return finalresponse;
    }
    
    //Starts here
    @AuraEnabled
    public static B2B_VertexTaxCalculationIntegration.ResponseDataWrapper getTaxRatesAndAmountsFromVertex(String cartId,String ShippingCharges,String CustomerPostalCode,String cartType){//, String customerAdd) {
        String InstallationCharges;
        Map<String,String> dealerAddress = New Map<String,String>();
        Map<String,String> customerAddress = New Map<String,String>();
        WebCart cart = B2B_IntegrationUtility.getcartdetails(cartId);
        if(String.isBlank(ShippingCharges)){
            if(cart.ShippingAmount__c > B2B_IntegrationConstants.DEFAULT_VALUE)
                ShippingCharges = String.valueOf(cart.ShippingAmount__c);  
            else
                ShippingCharges=B2B_IntegrationConstants.NULLVARIABLE;
        }else{
            ShippingCharges = ShippingCharges; 
        }
        if(cart.Total_Installation_Charge__c > B2B_IntegrationConstants.DEFAULT_VALUE)
            installationCharges=String.valueOf(cart.Total_Installation_Charge__c);
        else
            installationCharges=B2B_IntegrationConstants.NULLVARIABLE;
        if(!cartType.equalsIgnoreCase(B2B_IntegrationConstants.TYPE_VALUE)){
            dealerAddress.put(B2B_IntegrationConstants.STREETADDRESS,cart.DealerId__r.shippingStreet);
            dealerAddress.put(B2B_IntegrationConstants.CITY,cart.DealerId__r.shippingCity);
            dealerAddress.put(B2B_IntegrationConstants.STATE,cart.DealerId__r.shippingState);
            dealerAddress.put(B2B_IntegrationConstants.POSTALCODE,cart.DealerId__r.shippingPostalCode);
            customerAddress.put(B2B_IntegrationConstants.STREETADDRESS,cart.CustomerStreet__c);
            customerAddress.put(B2B_IntegrationConstants.CITY,cart.CustomerCity__c);
            customerAddress.put(B2B_IntegrationConstants.STATE,cart.Customer_State__c);
            customerAddress.put(B2B_IntegrationConstants.POSTALCODE,cart.CustomerPostalCode__c);
        }else{
            dealerAddress.put(B2B_IntegrationConstants.POSTALCODE,cart.DealerId__r.shippingPostalCode);
            customerAddress.put(B2B_IntegrationConstants.POSTALCODE,CustomerPostalCode);
        }
        B2B_VertexTaxCalculationIntegration.ResponseDataWrapper responseData = B2B_VertexTaxCalculationIntegration.calculateTaxQuotation(cartId,dealerAddress,customerAddress,cart.DealerId__r.POIID__c,ShippingCharges,installationCharges,B2B_IntegrationConstants.QUOTATION,cartType);
        return responseData;
    }
    //Ends here--- Soumya Sahoo-- R2 Story
    
    @testvisible
    private static void integrationStatusFailedWithCartValidationOutputError(string integrationStatus, String errorMessage, string jobInfo, Id cartId) {
        CartValidationOutput cartValidationError = new CartValidationOutput(
            CartId = cartId,
            Level = B2B_Constant.ERROR_LABEL,
            Message = errorMessage.left(255),
            Name = (String)cartId + ':' + System.now(),
            RelatedEntityId = cartId,
            Type = B2B_IntegrationConstants.TAXES
        );
        insert(cartValidationError);
    }  
}