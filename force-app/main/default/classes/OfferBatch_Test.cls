//****************************************************************************** 
// File Name:       OfferBatch_Test.cls
// Summary:         This is test class for Offer Batch
// Created On:      10-04-2023
// Created By:      Manohar
// Test Classes:   
// Data I/O:        
// Honda Jira Story: 
//*******************************************************************************
@isTest
public class OfferBatch_Test {
    public static Offers__c offerRecord;
    @testSetup
    public static void createTestData() {
        map<string,Id> mapOfferRecType = GetOfferRecordTypesUtility.getofferRectypeIds();
        map<string,Id> mapOfferHeaderRecType = GetOfferRecordTypesUtility.getofferHeadRectypeIds();
        Custom_Offer_Attribute__c  attr = new Custom_Offer_Attribute__c ();
        attr.Offer_Attribute_Code__c ='cashback';
        attr.Offer_Attribute_Name__c='Cash Back Offer';
        attr.Description__c ='$4000 Cash back program';
        attr.brand__c='A';
        attr.Offer_Status_Code_for_Publishing__c='P';
        attr.Alternate_Custom_Offer_Attribute_ID__c='cashback~P~A';
        insert attr;
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
       offerRec.end_Date__c = system.today();
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
       offerRec.Custom_Offer_Attributes__c ='cashback';
       offerRec.Term_Max_1__c=99;
       offerRec.Term_Max_2__c=89;
       offerRec.Term_Max_3__c=79;
       offerRec.Term_Max_4__c=69;
       offerRec.Term_Max_5__c=59;
       offerRec.Term_Max_6__c=49;
       offerRec.Term_Min_1__c=12;
       offerRec.Term_Min_2__c=15;
       offerRec.Term_Min_3__c=18;
       offerRec.Term_Min_4__c=21;
       offerRec.Term_Min_5__c=24;
       offerRec.Term_Min_6__c=28; 
     
       offerRec.APR_2__c=10;
       offerRec.APR_3__c=20;
       offerRec.APR_4__c=30;
       offerRec.APR_5__c=40;
       offerRec.APR_6__c=50;
       insert offerRec;

       Offer_Eligible_Models__c model = new Offer_Eligible_Models__c();
       model.Year__c =pm.Model_Year__c;
       model.Trim__c = pm.Trim__c;
       model.Model__c = pm.Model_Name__c;
       model.Featured_Offer__c = true;
       model.Offer__c = offerRec.Id;
       insert model;
   
    }

     static testMethod void testActiveOffer(){
        string name ='CPO STD FINANCE OFF HEADER'+ system.today();
        List<offers__c> lstOffers = [select id,name,status__c,recordtypeid from offers__c where start_Date__c=today];
        lstOffers[0].Status__c='Approved';
        update lstOffers;
        Test.setMock(HttpCalloutMock.class, new EshoppyOutboundRequestMock());
        Test.startTest();
        Database.executeBatch(new OfferBatch(),200);
        Test.stopTest();
    }
    static testMethod void testExpiredOffer(){
        string name ='CPO STD FINANCE OFF HEADER'+ system.today();
        List<offers__c> lstOffers = [select id,name,status__c,recordtypeid from offers__c where start_Date__c=today];
        lstOffers[0].end_Date__c=System.today();
        update lstOffers;
        Test.setMock(HttpCalloutMock.class, new EshoppyOutboundRequestMock());
        Test.startTest();
        Database.executeBatch(new OfferBatch(),200);  
        Test.stopTest();
    }
}