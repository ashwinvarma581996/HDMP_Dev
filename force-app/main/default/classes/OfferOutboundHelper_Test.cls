//****************************************************************************** 
// File Name:       OfferOutboundHelper_Test.cls
// Summary:         This is test class for Offer Outbound Helper
// Created On:      10-04-2023
// Created By:      Manohar
// Test Classes:   
// Data I/O:        
// Honda Jira Story: 
//*******************************************************************************
@isTest
public  class OfferOutboundHelper_Test {

    @testSetup
    public static void createTestData() {
        map<string,Id> mapOfferRecType = GetOfferRecordTypesUtility.getofferRectypeIds();
        map<string,Id> mapOfferHeaderRecType = GetOfferRecordTypesUtility.getofferHeadRectypeIds();
        Product_Model__c pm = new Product_Model__c(Model_Name__c='MODEL1',
                            Model_Year__c='2023',
                            Product_Model_Id__c='MODID-1',
                            Trim__c='Test Trim');
        insert pm;
        Boilerplate__c bp=new Boilerplate__c();
        bp.Name  = 'test';
        bp.Brand__c = 'A';
        bp.Legal_Disclaimer__c='Disclaimer';
        bp.Short_Description__c='Short Desc';
        bp.Terms_Conditions__c='Terms and Conditions';
        bp.Offer_Title__c ='title';
        insert bp;
        Offer_Header__c header = new Offer_Header__c();
        header.Brand__c= 'A';
        header.Name ='CPO STD FINANCE OFF HEADER'+ system.today();
        header.Descriptive__c ='Description';
        header.AHFC_Sales_Program_ID__c='12345';
        header.AHM_Sales_Program_ID__c ='56789';
        header.RecordTypeId = mapOfferHeaderRecType.get('CPO_Standard_Finance');
        insert header;

       Offers__c offerRec = new offers__c();      
       offerRec.Brand__c= 'A'; 
       offerRec.start_Date__c = system.today();
       offerRec.end_Date__c = system.today()+7;
       offerRec.Priority__c='1';
       offerRec.Credit_Tier__c ='1';    
       offerRec.Term_Min_1__c=12;
       offerRec.Term_Max_1__c=24;
       offerRec.RecordTypeId = mapOfferRecType.get('CPO_Standard_Finance');
       offerRec.Sample_Model_Description__c ='Sample Description';
       offerRec.Sample_Termmonths__c=24;
       offerRec.Sample_APR__c=2;
       offerRec.Boilerplate__c=bp.Id;  
       offerRec.Detailed_Description__c = bp.Detailed_Description__c;
       offerRec.Short_Description__c=bp.Short_Description__c;
       offerRec.Terms_and_Conditions__c=bp.Terms_Conditions__c;
       offerRec.Offer_Title__c=bp.Offer_Title__c;
       offerRec.Status__c ='WIP';
       insert offerRec;

       Offer_Eligible_Models__c model = new Offer_Eligible_Models__c();
       model.Year__c =pm.Model_Year__c;
       model.Trim__c = pm.Trim__c;
       model.Model__c = pm.Model_Name__c;
       model.Featured_Offer__c = true;
       model.Offer__c = offerRec.Id;
       insert model;
    }
    static testMethod void testStandardSpecialoffers(){
        offers__c offerRec = [select id,name, recordTypeId,Sample_Monthly_Payment__c from offers__c where start_Date__c = today];
       // List<Offer_Eligible_Models__c> lstOEM = [select id,name, Featured_Offer__c,Include_Sample_Payment__c from Offer_Eligible_Models__c where Offer__c=: offerRec.Id];
        test.startTest();
        Map<String,OM_Integration_Setting__mdt> mapSettings = OfferOutboundHelper.getAllIntegrationSettings();
        OfferOutboundHelper.getOfferDetailsForStandardSpecial(offerRec.Id);
        OfferOutboundHelper.getOfferDetailsForSpecial(offerRec.Id);
        OfferOutboundHelper.getHeaderValue(mapSettings.get(OfferMgmtConstants.STANDARDSPECIALS_INTEGRATION).HeaderValue__c);        
        OfferOutboundHelper.getSpecialCategory('A',offerRec.recordTypeId);
        OfferOutboundHelper.getSpecialCategory('B',offerRec.recordTypeId);
        OfferOutboundHelper.getSpecialCategory('M',offerRec.recordTypeId);
        map<string,List<Offer_Eligible_Models__c>> mapModels= OfferOutboundHelper.getElgibleModelsByOfferForStandardSpecial(offerRec.Id);
        OfferOutboundHelper.getIncludeSamplePayment(offerRec,mapModels.get(offerRec.Id)[0]);
        OfferOutboundHelper.getLowestFeaturedModel(mapModels.get(offerRec.Id));
        mapModels= OfferOutboundHelper.getElgibleModelsByOfferForSpecial(offerRec.Id);        
        test.stopTest(); 
    }
   
}