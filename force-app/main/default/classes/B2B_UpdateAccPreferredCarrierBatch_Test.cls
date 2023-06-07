@isTest
private class B2B_UpdateAccPreferredCarrierBatch_Test{
    @isTest static void tesMethod1(){
        Carrier__c carrierObj = new Carrier__c(
            Name = 'FEDEX',
            Is_Active__c = true);
        insert carrierObj;
        Account accountObj = new Account(
            Name = 'Curry Honda',
            BillingStreet = '5525 Peachtree Industr',
            BillingCity = 'Chamblee',
            BillingState = 'GA',
            BillingPostalCode = '30341',
            BillingCountry = 'United States',
            ShippingStreet = '5525 Peachtree Blvd',
            ShippingCity = 'Chamblee',
            ShippingState = 'GA',
            ShippingPostalCode = '30341',
            ShippingCountry = 'United States',
            Phone = '7704512700',
            IsActive__c = true,
            Merchant_Id__c = 'x9n6kp46j5ctfff4',
            PoIId__c = '208878',
            State__c = 'US',
            Code__c = '****************************c147',
            DivisionCd__c = 'A',
            B2B_Preferred_Carrier__c = 'FEDEX',
            Return_Window__c = 30,
            Charge_Restocking_Fees__c = 'Yes',
            Restocking_Fees_Type__c = 'Percentage',
            Current_Dealer_Order_Seq_Number__c = 8,
            Restocking_Fees_Percentage__c = 15.75,
            Dealer_Type__c = 'Honda Auto',
            Participation_Code__c = 'DRM');
        insert accountObj;
		Test.startTest();
		B2B_UpdateAccPreferredCarrierBatch batch = new B2B_UpdateAccPreferredCarrierBatch();
		Database.executebatch(batch);
		Test.stopTest();
	}
}