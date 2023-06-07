/**
* @File Name          : B2B_MyPaymentsController
* @Description        : Apex class is created to handle my payments for logged-in user only.
* @Created By         : Soumya,Vipul
* @Date               : 29/08/2022
* @Last Modified By   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0       02/02/2022               Farazuddin            Initial Version
**/
public without sharing class B2B_MyPaymentsController {
    static String currentUserId = UserInfo.getUserId();
    static String currentUserFName = UserInfo.getFirstName();
    public static String BASE_URL = 'callout:HondaBraintreeGraphQL';
    
    public static Final String BRAINTREE_VERSION = '2019-01-01';
    public static Final String CONTENT_TYPE = 'application/json';
    public static boolean callClientTokenAPI = true;
    public static String CUSTOMER_SF_ID;
    static List<BT_Customer_Details__c> customerDetailList = [SELECT Id, BT_CustomerId__c, Customer__c, Customer__r.ContactId FROM BT_Customer_Details__c WHERE Customer__c =: currentUserId LIMIT 1];
    public static Map<String, Object> DATA_UPDATES;
    //Retrieves a Client Token from BrainTree for the Hosted Form
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> hostedFormSetup() {
        DATA_UPDATES = new Map<String, Object>();
        String username = UserInfo.getName();
        Map<String, Object> returnData = new Map<String, Object>{'success' => false, 'error' => null};
            returnData.put('paymentTypes', getPaymentTypes());
        String clientToken = B2B_CreditCardController.requestClientToken();
        returnData.put('success', true);
        returnData.put('token', clientToken);
        returnData.put('isLoggedInUser',true);
        return returnData;
    }
    //Returns a list of Payment Types available on the page
    private static List<Map<String, String>> getPaymentTypes() {
        List<Map<String, String>> paymentTypes = new List<Map<String, String>>();
        //TODO - make this more dynamic once more payment types start being supported
        paymentTypes.add(new Map<String, String>{'label' => 'Credit Card', 'value' => 'CC'});
        return paymentTypes;
    } 
    @AuraEnabled
    public static void updateExpiredCardList(){
        try {
            if(!currentUserFName.containsIgnoreCase('Guest')){
                BT_Payment_Method__c defaultToUpdate = new BT_Payment_Method__c();
                    List<BT_Payment_Method__c> defaultPaymentMethodList = [select id,Default_Payment_Method__c, CC_Expiration_Month__c,CC_Expiration_Year__c from BT_Payment_Method__c where BT_Customer_Details__c =: customerDetailList[0].Id
                                                                           and Default_Payment_Method__c = true];
               for(BT_Payment_Method__c defaultlist : defaultPaymentMethodList){
                        if(defaultlist.CC_Expiration_Year__c < System.today().year())
                            defaultlist.Default_Payment_Method__c = false;
                        else if(defaultlist.CC_Expiration_Year__c == System.today().year() && defaultlist.CC_Expiration_Month__c < System.today().month())
                            defaultlist.Default_Payment_Method__c = false;
                    }
                    if(!defaultPaymentMethodList.isEmpty())
                        update defaultPaymentMethodList;
            }
            //return 'No record found';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string getAddMyPayments(){
        try {
            if(!currentUserFName.containsIgnoreCase('Guest')){
                System.debug('User : '+ currentUserId +' and '+ UserInfo.getName());
                
                Map<String, Object> returnData = new Map<String, Object>();  
                if(callClientTokenAPI == true){
                    B2B_CreditCardController.MERCHANT_ID = 'DreamShop';                       
                    String clientToken = B2B_CreditCardController.requestClientToken();
                    returnData.put('clientToken',clientToken);
                    
                    List<Map<String, String>> stateList = B2BGuestUserController.getStateCodes();
                    returnData.put('states',stateList);
                }                     
                return JSON.serialize(returnData);
            }
            return 'No record found';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string getSavedAddresses(){
        try {
            if ( string.isNotEmpty(currentUserId)) {
                String personAccID = B2B_Fetch_PersonAccount.getPersonAccount(currentUserId);
                List<My_Address_Book__c> addressBookList = [SELECT Id, Name, Address__c, City__c, State__c, Country__c, Zip__c, Phone__c, Notes__c, NickName__c, isPreferred__c, Email__c,
                                                            Address_Line_2__c FROM My_Address_Book__c WHERE Person_Address_Account__c =: personAccID order by isPreferred__c desc];
                
                if(!addressBookList.isEmpty()){
                    return JSON.serialize(addressBookList); 
                }
                return 'No record found1';
            }
            return 'No record found2';  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
	@AuraEnabled
    public static string getAllMyPayments(){
        try {
            if(!currentUserFName.containsIgnoreCase('Guest')){
                System.debug('User : '+ currentUserId +' and '+ UserInfo.getName());
                //List<BT_Customer_Details__c> customerDetailLst = [SELECT Id FROM BT_Customer_Details__c WHERE Customer__c =: currentUserId LIMIT 1];
                if(!customerDetailList.isEmpty()){
                    //My_Address_Book__r.Address_Type__c, My_Address_Book__r.Email__c, 
                    //My_Address_Book__r.isPreferred__c, My_Address_Book__r.NickName__c, My_Address_Book__r.Notes__c, 
                       // My_Address_Book__r.Phone__c, My_Address_Book__r.Zip__c, My_Address_Book__r.State__c, My_Address_Book__r.City__c, 
                       // My_Address_Book__r.Address__c, My_Address_Book__r.Name,My_Address_Book__c
                    List<BT_Payment_Method__c> paymentMethodList = [SELECT Id, Billing_Customer_Name__c,Cardholder_Name__c,Default_Payment_Method__c, Credit_Card_Number__c,
                                                                    Type__c, BT_Customer_Details__c, Payment_Method_Token__c,Billing_Street__c, Billing_State__c,Billing_PostalCode__c,Billing_Country__c,Billing_City__c,Billing_Phone__c,
                                                                    Customer__c,Customer__r.email, Name,CC_Expiration_Year__c,CC_Expiration_Month__c,Billing_Street_Line2__c FROM BT_Payment_Method__c
                                                                    WHERE Is_In_My_Payment__c = true and Is_Vaulted__c =true and BT_Customer_Details__c =: customerDetailList[0].Id order by Default_Payment_Method__c desc,CC_Expiration_Year__c desc, CC_Expiration_Month__c desc];
                    if(!paymentMethodList.isEmpty()){
                        Map<String, Object> returnData = new Map<String, Object>();  
                        if(callClientTokenAPI == true){
                            B2B_CreditCardController.MERCHANT_ID = 'DreamShop';                       
                            String clientToken = B2B_CreditCardController.requestClientToken();
                            returnData.put('clientToken',clientToken);
                            
                            List<Map<String, String>> stateList = B2BGuestUserController.getStateCodes();
                            returnData.put('states',stateList);
                        }                     
                        returnData.put('paymentMethodList',paymentMethodList);
                        return JSON.serialize(returnData);
                    }
                    return 'No record found';
                }
                return 'No record found';
            }
            return 'No record found';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string getAllMyPaymentsNew(){
        try {
            if(!currentUserFName.containsIgnoreCase('Guest')){
                if(!customerDetailList.isEmpty()){
                    List<BT_Payment_Method__c> paymentMethodList = [SELECT Id,Billing_Customer_Name__c, Cardholder_Name__c,Default_Payment_Method__c, Credit_Card_Number__c,
                                                                    Type__c, BT_Customer_Details__c, Payment_Method_Token__c,Billing_Street__c,Billing_State__c,Billing_PostalCode__c,Billing_Country__c,Billing_City__c,Billing_Phone__c, 
                                                                    Customer__c, Name,CC_Expiration_Year__c,CC_Expiration_Month__c,Billing_Street_Line2__c FROM BT_Payment_Method__c 
                                                                    WHERE Is_In_My_Payment__c = true and Is_Vaulted__c =true and  BT_Customer_Details__c =: customerDetailList[0].Id order by Default_Payment_Method__c desc,CC_Expiration_Year__c desc, CC_Expiration_Month__c desc];
                    if(!paymentMethodList.isEmpty()){
                        Map<String, Object> returnData = new Map<String, Object>();  
                        if(callClientTokenAPI == true){
                            B2B_CreditCardController.MERCHANT_ID = 'DreamShop';                       
                            String clientToken = B2B_CreditCardController.requestClientToken();
                            returnData.put('clientToken',clientToken);
                            List<Map<String, String>> stateList = B2BGuestUserController.getStateCodes();
                            returnData.put('states',stateList);
                        }                     
                        returnData.put('paymentMethodList',paymentMethodList);
                        return JSON.serialize(returnData);
                    }else{
                        Map<String, Object> returnData = new Map<String, Object>(); 
                        String clientToken = B2B_CreditCardController.requestClientToken();
                        returnData.put('clientToken',clientToken);
                        List<Map<String, String>> stateList = B2BGuestUserController.getStateCodes();
                        returnData.put('states',stateList);
                        return JSON.serialize(returnData);
                    }
                }else{
                    Map<String, Object> returnData = new Map<String, Object>(); 
                    String clientToken = B2B_CreditCardController.requestClientToken();
                    returnData.put('clientToken',clientToken);
                    List<Map<String, String>> stateList = B2BGuestUserController.getStateCodes();
                    returnData.put('states',stateList);
                    return JSON.serialize(returnData);
                }
                
            }
            return 'No record found';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Map<String, String>> getStateAddressBook(){
        return B2BGuestUserController.getStateCodes();
    }
    @AuraEnabled
    public static string deletePaymentRecord(String paymentId){
        try {
            Boolean duplicate = false;
            String currentAddress;
            List<BT_Payment_Method__c> remainingPaymentList = new List<BT_Payment_Method__c>();
            B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();
            B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponseMethod = new B2B_BrainTreeTransactionResponse();
            B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponseDelete = new B2B_BrainTreeTransactionResponse();
            if (String.isNotBlank(paymentId)) {
                List<BT_Payment_Method__c> paymentList = [SELECT Id,Customer__c,Billing_Customer_Name__c,Billing_Street__c,Billing_City__c,Billing_State__c,Billing_PostalCode__c,Billing_Country__c,Payment_Method_Token__c,Default_Payment_Method__c,BT_Customer_Details__r.BT_Customer_Legecy_Id__c FROM BT_Payment_Method__c WHERE Id =: paymentId];
                if(!paymentList.isEmpty()){
                    currentAddress= (paymentList[0].Billing_Customer_Name__c + paymentList[0].Billing_Street__c + paymentList[0].Billing_City__c +paymentList[0].Billing_State__c + paymentList[0].Billing_PostalCode__c + paymentList[0].Billing_Country__c).toLowercase();
                    remainingPaymentList = [SELECT Id,Billing_Customer_Name__c,Billing_Street__c,Billing_City__c,Billing_State__c,Billing_PostalCode__c,Billing_Country__c,Payment_Method_Token__c,Default_Payment_Method__c,BT_Customer_Details__r.BT_Customer_Legecy_Id__c FROM BT_Payment_Method__c WHERE Id !=: paymentId and Customer__c =: paymentList[0].Customer__c ];
                }
                for(BT_Payment_Method__c rempaylist:remainingPaymentList){
                    String duplicateAddress = (rempaylist.Billing_Customer_Name__c + rempaylist.Billing_Street__c + rempaylist.Billing_City__c +rempaylist.Billing_State__c + rempaylist.Billing_PostalCode__c + rempaylist.Billing_Country__c).toLowercase();
                    if(currentAddress == duplicateAddress){
                        duplicate = true;
                        break;
                    }

                }
                Boolean isRecordDelete = false;
                if (!paymentList.isEmpty()){
                    List<Order> existingOrder =[select id from Order where Payment_Method_Token__c=:paymentList[0].Payment_Method_Token__c and BT_Transaction_Status__c = 'Authorized'];
                    if(existingOrder.isEmpty()){

                        B2B_BrainTreeTransactionResponse objPaymentFindResponse = B2B_BrainTreeIntegration.braintreePaymentMethodFind(paymentList[0].Payment_Method_Token__c);
                        if(objPaymentFindResponse.status == 200){   
                            String legacyId = paymentList[0].BT_Customer_Details__r.BT_Customer_Legecy_Id__c;
                            String billingAddressId = objPaymentFindResponse.billingAddressId;
                            objBrainTreeTransactionResponseMethod = B2B_BrainTreeIntegration.braintreePaymentMethodDelete(paymentList[0].Payment_Method_Token__c);
                            if(String.isNotEmpty(paymentList[0].BT_Customer_Details__r.BT_Customer_Legecy_Id__c) && duplicate != true){
                                objBrainTreeTransactionResponseDelete = B2B_BrainTreeIntegration.braintreeAddressDelete(legacyId, billingAddressId);
                }
                        }
                    }else{
                        BT_Payment_Method__c updatePaymentMethod = new BT_Payment_Method__c();
                        updatePaymentMethod.id = paymentId;
                        updatePaymentMethod.Is_In_My_Payment__c=false;
                        if(updatePaymentMethod!=null)
                            update updatePaymentMethod;
                            String updatedRecords = getAllMyPaymentsNew();
                            return updatedRecords;
                    }
                    	//isRecordDelete = B2B_BrainTreeUtils.deleteBTVaultPaymentMethod(paymentList[0].Payment_Method_Token__c);
                        
                }
                if(objBrainTreeTransactionResponseMethod.status == 200 || objBrainTreeTransactionResponseDelete.status == 200){
                isRecordDelete = true;
                }
                
                if (!paymentList.isEmpty() && isRecordDelete) {
                    system.debug('Deleted Final : '+ paymentList +isRecordDelete );
                    DELETE paymentList;
                    /*if (defaultPaymentMethod) {
                        List<BT_Payment_Method__c> payments = [SELECT Id FROM BT_Payment_Method__c WHERE BT_Customer_Details__c =: customerDetailList[0].Id];
                        if (!payments.isEmpty()){
                            markPreferredSingleRecord(payments[0].Id);
                        }
                    }*/
                    
                    callClientTokenAPI = false;
                    String updatedRecords = getAllMyPaymentsNew();
                    return updatedRecords;
                }
                return 'Delete Failed';
            }
            return 'Delete Failed';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string markPreferredSingleRecord(String paymentId){
        try {
            if (String.isNotBlank(paymentId)) {
                List<BT_Payment_Method__c> paymentList =[SELECT Id, Default_Payment_Method__c FROM BT_Payment_Method__c WHERE 
                                                         BT_Customer_Details__c =: customerDetailList[0].Id];
                if (!paymentList.isEmpty()) {
                    for(BT_Payment_Method__c paymentMethodObj : paymentList){
                        if(paymentMethodObj.Id == paymentId){
                            paymentMethodObj.Default_Payment_Method__c = true;
                        }else{
                            paymentMethodObj.Default_Payment_Method__c = false;
                        }
                    }
                    update paymentList;
                    callClientTokenAPI = false;
                    String updatedRecords = getAllMyPaymentsNew();
                    return updatedRecords;
                }
                return 'No record found';
            }
            return 'No record found';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string getAllMyAddresses(String addressId){
        try {
            if (String.isNotBlank(addressId) && !customerDetailList.isEmpty()) {
                List<My_Address_Book__c> addressBookList = [SELECT Id, Name, Address__c, City__c, State__c, Country__c, Zip__c, Phone__c, Notes__c, NickName__c, isPreferred__c, Email__c
                                                             FROM My_Address_Book__c WHERE Person_Address_Account__r.PersonContactId =: customerDetailList[0].Customer__r.ContactId 
                                                            AND Id !=: addressId];
                
                if(!addressBookList.isEmpty()){
                    return JSON.serialize(addressBookList);
                }
                return 'No record found1';
            }
            return 'No record found2';  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string updatePaymentAndAddress(String payload, String objPaymentStr, String replacedAddressId){
        try {           
            BT_Payment_Method__c  objPaymentMethod = (BT_Payment_Method__c) JSON.deserialize(objPaymentStr, BT_Payment_Method__c.class);           
            Map<String, Object> mapPayload = (Map<String, Object>)JSON.deserializeUntyped(payload);
            Map<String, Object> returnData = new Map<String, Object>();
            if(mapPayload.containsKey('nonce') && objPaymentMethod != null && objPaymentMethod.getPopulatedFieldsAsMap().size() > 1){
                //call the payment update SDK API
                B2B_BrainTreeTransactionResponse updateResponse = B2B_BrainTreeIntegration.braintreePaymentMethodUpdate(objPaymentMethod.Payment_Method_Token__c, String.valueOf(mapPayload.get('nonce')));
                system.debug('updateResponse'+updateResponse.status);
                if(updateResponse.status == 200){
                    system.debug('updateResponse'+updateResponse);
                    // mark it as default payment method if the flag is true
                    if(objPaymentMethod.Default_Payment_Method__c == true){
                        markPreferredSingleRecord(objPaymentMethod.Id);
                    }
                    
                    // update the expiration date on payment method
                    if(mapPayload.containsKey('details')){                       
                        Map<String, Object> mapDetails = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mapPayload.get('details')));
                        //Integer month = Integer.valueOf(mapDetails.get('expirationMonth'));
                        //Integer year = Integer.valueOf(mapDetails.get('expirationYear'));
                        objPaymentMethod.CC_Expiration_Month__c = Integer.valueOf(mapDetails.get('expirationMonth'));
                		objPaymentMethod.CC_Expiration_Year__c = Integer.valueOf(mapDetails.get('expirationYear'));
                        //objPaymentMethod.CC_Expiration_Date__c = Date.newInstance(year, month, 10);
                    }
                    
                    update objPaymentMethod;
                    
                    callClientTokenAPI = false;
                    String updatedRecords = getAllMyPaymentsNew();
                    return updatedRecords;
                }else if(updateResponse.errorMessage != null){
                    returnData.put('errorMessage',updateResponse.errorMessage);
  
                    return JSON.serialize(returnData);
                }  
            }     		
            
        } catch (Exception e) {
            System.debug('line : '+ e.getLineNumber() + ' message : '+e.getMessage());
            System.debug('stacktrace : '+ e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return 'update failed';
    }
    
    // Below lines of code added by Vipul for My Address save
    public static My_Address_Book__c createAddressRecord(Map<String, Object> customerData) {        
        My_Address_Book__c objAddressBook = new My_Address_Book__c();
        //objAddressBook.Address_Type__c = 'Billing Address';                       
        objAddressBook.Person_Address_Account__c = [SELECT Contact.accountId FROM User WHERE Id =: UserInfo.getUserId()].Contact.accountId;
        //Set the necessary Email fields
        if(customerData.containsKey('email')) {                
            objAddressBook.Email__c = String.valueOf(customerData.get('email'));
        }
        
        //Set the necessary Address 1 and 2 fields
        if(customerData.containsKey('address1')) {
            objAddressBook.Address__c = String.valueOf(customerData.get('address1'));
        }
            
        //Set the necessary City field
        if(customerData.containsKey('city')) {
            objAddressBook.City__c = String.valueOf(customerData.get('city'));
        }
        
        //Set the necessary State field
        if(customerData.containsKey('state')) {
            objAddressBook.State__c = String.valueOf(customerData.get('state'));
        }
        //Set the necessary country field
        if(customerData.containsKey('countryName')) {
            objAddressBook.Country__c = String.valueOf(customerData.get('countryName'));
        }
        //Set the necessary Zip Code field
        if(customerData.containsKey('zipCode')) {
            objAddressBook.Zip__c = String.valueOf(customerData.get('zipCode'));               
        }            
        
        //Set the necessary Customer Name field
        if(customerData.containsKey('name')) {
            if(!String.isBlank(String.valueOf(customerData.get('name')))) {
                objAddressBook.Name = String.valueOf(customerData.get('name'));
            }
        }
        
        //Set the necessary Phone fields
        if(customerData.containsKey('phone')) {
            if(!String.isBlank(String.valueOf(customerData.get('phone')))) {
                objAddressBook.Phone__c = String.valueOf(customerData.get('phone'));                   
            }
        }
        
        insert objAddressBook;
        return objAddressBook;
    }
    // Below lines of code added by Soumya for My Payment-  Add Payment  story
    @AuraEnabled
    public static Object processAddPayment(String nonce, Map<String, Object> customerData,String paymentType,Boolean ispreferred,Boolean isNewAddr ) {
        String customerId;
        String paymentToken;
        String fullAddress;
        String customerVaultId;
            List<User> emailIdlst = [select id,email from User where id=: UserInfo.getUserId() LIMIT 1];
        	if(!emailIdlst.isEmpty())
                customerData.put('email',emailIdlst[0].email);
        Map<String, Object> vaultPaymentData = new Map<String, Object>();
        String customerrecordId;
        //B2B_CreditCardController.DATA_UPDATES = new Map<String, Object>();
        Map<String,Object> Data_To_Insert=new map<String,Object>();
        Map<String, Object> returnData = new Map<String, Object>{'success' => false, 'error' => null};
        List<BT_Customer_Details__c> lstCustomers = [SELECT Id, BT_CustomerId__c 
                                                         FROM BT_Customer_Details__c 
                                                         WHERE Customer__c =: UserInfo.getUserId() LIMIT 1];
            if(!lstCustomers.isEmpty()){
                customerVaultId = lstCustomers[0].BT_CustomerId__c;	
            }else if(customerData != null){
                //customerId = B2B_CreditCardController.createCustomer(customerData);
                Data_To_Insert = createCustomer(customerData);
                customerVaultId = Data_To_Insert.containsKey('customerIdInsert') ? String.valueOf(Data_To_Insert.get('customerIdInsert')) : null;
            }else
                returnData.put('customerId','');
        if(string.isNotEmpty(customerVaultId)){
            vaultPaymentData= B2B_CreditCardController.vaultPaymentMethod(nonce,customerVaultId);
        
        }
        customerrecordId = createCustomerDetailsRecord(Data_To_Insert);
        List<BT_Payment_Method__c> upsertPayments = new List<BT_Payment_Method__c>();
        
        String uniqueNumber=vaultPaymentData.containsKey('uniqueNumberIdentifier') ? String.valueOf(vaultPaymentData.get('uniqueNumberIdentifier')) : null;
        List<BT_Payment_Method__c> lstPayments = [SELECT Id,Is_In_My_Payment__c,Is_Vaulted__c, Payment_Method_Token__c, BT_Customer_Details__c, Unique_Number_Identifier__c
                                                  FROM BT_Payment_Method__c 
                                                  WHERE Is_In_My_Payment__c = true AND Unique_Number_Identifier__c =: uniqueNumber AND BT_Customer_Details__c =: customerrecordId];
        if(!lstPayments.isEmpty()){
            paymentToken = lstPayments[0].Payment_Method_Token__c;
            //if(String.isNotEmpty(paymentToken) && lstPayments[0].Is_In_My_Payment__c!=True)
                //toAddPayment=true;
        }
        if(vaultPaymentData != null && vaultPaymentData.containsKey('id')){
            if(String.isEmpty(paymentToken)){
                if(ispreferred){
                    List<BT_Payment_Method__c> lstPaymentstoUpdate = [SELECT Id, Default_Payment_Method__c 
                                                                      FROM BT_Payment_Method__c 
                                                                      WHERE BT_Customer_Details__c=: customerrecordId AND Default_Payment_Method__c = true];
                    
                    for(BT_Payment_Method__c lstPaymentmethod:lstPaymentstoUpdate){
                        lstPaymentmethod.Default_Payment_Method__c = false;
                        upsertPayments.add(lstPaymentmethod);
                    }
                    
                }
                
                BT_Payment_Method__c paymentMethodData = new BT_Payment_Method__c();
                paymentMethodData.Customer__c = UserInfo.getUserId();
                paymentMethodData.Cardholder_Name__c = String.valueof(vaultPaymentData.get('cardholderName'));
                paymentMethodData.Billing_Customer_Name__c = String.valueof(customerData.get('name'));
                paymentMethodData.BT_Customer_Details__c = customerrecordId;
                paymentMethodData.Credit_Card_Number__c =  vaultPaymentData.containsKey('last4') ? String.valueOf(vaultPaymentData.get('last4')) : null;
                paymentMethodData.Payment_Method_Token__c = String.valueof(vaultPaymentData.get('id'));
                if(vaultPaymentData.containsKey('brandCode')){
                    String brandCode = String.valueOf(vaultPaymentData.get('brandCode'));
                    if(brandCode.containsIgnoreCase('VISA')){
                        paymentMethodData.Type__c = 'Credit Card - Visa';
                    }else if(brandCode.containsIgnoreCase('DISCOVER')){
                        paymentMethodData.Type__c =  'Credit Card - Discover';
                    }else if(brandCode.containsIgnoreCase('AMERICAN_EXPRESS')){
                        paymentMethodData.Type__c = 'Credit Card - Amex';
                    }else if(brandCode.containsIgnoreCase('MASTERCARD')){
                        paymentMethodData.Type__c = 'Credit Card - Mastercard';
                    }
                }
                paymentMethodData.Unique_Number_Identifier__c = vaultPaymentData.containsKey('uniqueNumberIdentifier') ? String.valueOf(vaultPaymentData.get('uniqueNumberIdentifier')) : null;
                paymentMethodData.CC_Expiration_Month__c = Integer.valueof(vaultPaymentData.get('expirationMonth'));
                paymentMethodData.CC_Expiration_Year__c = Integer.valueof(vaultPaymentData.get('expirationYear'));
                paymentMethodData.Default_Payment_Method__c=ispreferred;
                paymentMethodData.Payment_Gateway__c = 'Braintree';
                paymentMethodData.Billing_Country__c = 'United States';
                paymentMethodData.AK_Payment_Method__c = 'Braintree' + customerrecordId + String.valueof(vaultPaymentData.get('id'));
                paymentMethodData.Is_In_My_Payment__c = true;
                paymentMethodData.Is_Vaulted__c=true;
                if(customerData.containsKey('city'))
                    paymentMethodData.Billing_City__c = String.valueof(customerData.get('city'));
                if(customerData.containsKey('address1'))
                 	paymentMethodData.Billing_Street__c = String.valueof(customerData.get('address1'));
                if(customerData.containsKey('state'))
                    paymentMethodData.Billing_State__c = String.valueof(customerData.get('state'));
                if(customerData.containsKey('zipCode'))
                    paymentMethodData.Billing_PostalCode__c = String.valueof(customerData.get('zipCode'));
                if(customerData.containsKey('countryName'))
                    paymentMethodData.Billing_Country__c = String.valueof(customerData.get('countryName'));
                if(customerData.containsKey('phone'))
                    paymentMethodData.Billing_Phone__c = String.valueof(customerData.get('phone'));
                
                upsertPayments.add(paymentMethodData);
                returnData.put('success', true);
            }else {
                returnData.put('errorReason', 'Duplicate Card');
                B2B_BrainTreeUtils.deleteBTVaultPaymentMethod(String.valueOf(vaultPaymentData.get('id')));
            } 
            
            
            if(upsertPayments.size()>0){
                upsert upsertPayments;
                if(isNewAddr){
                    My_Address_Book__c objAddress = createAddressRecord(customerData);
                }
            }
        }else{
                if(vaultPaymentData.containsKey('gatewayRejectionReason')){
                    returnData.put('errorReason', vaultPaymentData.get('gatewayRejectionReason'));
                }else if(vaultPaymentData.containsKey('CCTypeError')){
                    returnData.put('errorReason', vaultPaymentData.get('CCTypeError'));
                }else {                       
                    returnData.put('errorReason', 'An error occurred while processing the Payment.');
                }
            }
        
        
        
        return returnData;
    } 
    // To Create Customer in BrainTree
    public static Map<String,Object> createCustomer(Map<String, Object> customerData){
        Map<String,Object> returnparsedata=new Map<String,object>();
        //Map<String,Object> DATA_UPDATES=new Map<String,object>();
        if(customerData == null) {
            return null;
        }
        //Store the Customer Data for the future method
        //DATA_UPDATES.put('customerData', customerData);
        try {
            HttpRequest req = createBaseRequest('POST');
            Map<String, Object> graphQl = new Map<String, Object>();
            //Create base Query and Variables structure
            graphQl.put('query', 'mutation createCustomer($input: CreateCustomerInput) { createCustomer(input: $input) { customer { id legacyId} } }');
            graphQl.put('variables', new Map<String, Object>());
            
            Map<String, String> fieldsMap = new Map<String, String>();
            
            //Add Name
            if(customerData.containsKey('name')) {
                if(!String.isBlank(String.valueOf(customerData.get('name')))) {
                    String fullName = String.valueOf(customerData.get('name'));
                    List<String> nameParts = fullName.split(' ');
                    fieldsMap.put('firstName', nameParts[0]);
                    nameParts.remove(0);
                    fieldsMap.put('lastName', String.join(nameParts, ' '));
                }
            }

            //Add Email
            if(customerData.containsKey('email')) {
                if(!String.isBlank(String.valueOf(customerData.get('email')))) {
                    fieldsMap.put('email', String.valueOf(customerData.get('email')));
                }
            }
            
            //Add Phone Number
            if(customerData.containsKey('phone')) {
                if(!String.isBlank(String.valueOf(customerData.get('phone')))) {
                    fieldsMap.put('phoneNumber', String.valueOf(customerData.get('phone')));
                }
            }

            //input > customer > firstName, lastName, email, phoneNumber
            Map<String, Object> customerMap = new Map<String, Object>{'customer' => fieldsMap};
            ((Map<String, Object>)graphQl.get('variables')).put('input', customerMap);
                    
            req.setBody(JSON.serialize(graphQl));

            Http http = new Http();
            Long beforeAPI = DateTime.now().getTime(); // Added By Ravi Prasad
            HttpResponse res = http.send(req);
            if(res.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
                returnparsedata = parseCreateCustomerResponse(res.getBody());
                system.debug('Soumya returnparsedata'+returnparsedata);
                return returnparsedata;
            }else{
                Long afterAPI = DateTime.now().getTime();
                Long durationTime = afterAPI - beforeAPI;
                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                    
                String severity;
                String errorType;
                Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                        if(errorRecords.containskey(String.valueOf(res.getStatusCode()))){
                            severity= errorRecords.get(String.valueOf(res.getStatusCode())).severity__c;
                            errorType=errorRecords.get(String.valueOf(res.getStatusCode())).error_Type__c;
                        }
                        else{
                            severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                            errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                        }
                Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', '', '', '', 'B2B_MyPaymentController', String.valueOf(res.getStatusCode()), errorType, '', 'createCustomer', true, '', '', '', durationTime, severity, 'Request:'+req.getBody(), 'Response:'+res.getBody());
                //HDMP-8617:ends
                return returnparsedata;
            }
            
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        return returnparsedata;
    }
    //Parse Braintree request
    private static Map<String,Object> parseCreateCustomerResponse(String resBody) {
        Map<String, Object> resData = (Map<String, Object>)JSON.deserializeUntyped(resBody);
        Map<String,Object> DATA_UPDATES = new Map<String,Object>();
        
        // data > createClientToken > clientToken > {token}
        if(resData != null && resData.containsKey('data')) {
            Map<String, Object> initialData = (Map<String, Object>)resData.get('data');
            
            if(initialData != null && initialData.containsKey('createCustomer')) {
                Map<String, Object> createCustomerData = (Map<String, Object>)initialData.get('createCustomer');
                
                if(createCustomerData != null && createCustomerData.containsKey('customer')) {
                    Map<String, Object> customerData = (Map<String, Object>)createCustomerData.get('customer');
                    system.debug('Soumya customerData'+customerData);
                    if(customerData != null && customerData.containsKey('legacyId')) { 
                        DATA_UPDATES.put('legacyId',customerData.get('legacyId'));                     
                    }
                    if(customerData != null && customerData.containsKey('id')) {
                        DATA_UPDATES.put('customerIdInsert',customerData.get('id')); 
                        //return DATA_UPDATES;
                    }
                }
            }
        }
        return DATA_UPDATES;
    }
    //Creates a Customer Details record including the Customer ID---  Used as Part of My Payment
    public static String createCustomerDetailsRecord(Map<String, Object> dataToUpdate) {
        String CUSTOMER_ID;
        try {
            BT_Customer_Details__c customerDetails = new BT_Customer_Details__c();
            customerDetails.Customer__c = UserInfo.getUserId();
            customerDetails.AK1_PG_Customer_ext__c = UserInfo.getUserId() + 'Braintree';
            if(customerDetailList.isEmpty()){
                customerDetails.BT_CustomerId__c = String.valueOf(dataToUpdate.get('customerIdInsert'));
                customerDetails.Payment_Gateway__c = 'Braintree';
                customerDetails.AK2_PG_Customer_ext__c = String.valueOf(dataToUpdate.get('customerIdInsert')) + 'Braintree';
                if(dataToUpdate.containsKey('legacyId')){
                    customerDetails.BT_Customer_Legecy_Id__c = String.valueOf(dataToUpdate.get('legacyId'));
                }
                insert customerDetails;
                CUSTOMER_ID = customerDetails.Id;
            }else{
                CUSTOMER_ID= customerDetailList[0].id;
            }
            
            
            
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        return CUSTOMER_ID;
    }
    // --- End of Methods that parse GraphQL Responses --- 
    public static HttpRequest createBaseRequest(String method) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL);
        req.setMethod(method);
        
        req.setHeader('Content-Type', CONTENT_TYPE);
        req.setHeader('Braintree-Version', BRAINTREE_VERSION);
        
        return req;
    }
}