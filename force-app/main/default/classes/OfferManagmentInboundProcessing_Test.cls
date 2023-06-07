//****************************************************************************** 
// File Name:       OfferManagmentInboundProcessing_Test.cls
// Summary:        Used for Testing all the Inbound Feed related classes
// Created On:      03-13-2023
// Created By:      Rama Iyer
// Test Classes:    OfferManagmentInboundProcessing_Test.cls
// JIRA Story :     OMP-156,OMP-76,OMP-104,OMP-103
//*******************************************************************************
@isTest
private class OfferManagmentInboundProcessing_Test {
    
    @isTest
    private static void testInboundFeedRecordsNewRecords(){
              
               //Setup the Product Model Records
               
               List<Product_Model__c> prodmodelsinserted=OMTestDataFactory.createProductModelRecords(15);
        
               //List<Offer_Header__c> offHeader=OMTestDataFactory.createofferwithOfferId(10);
        
               List<STG_Offers__c> insertedstgoffers1=OMTestDataFactory.createStagingOfferHeader(5,30);
               
        	   //get no of records created - Should match the number of offers inserted and check the status of the updates
        	   //
        	  List<String> getOfferIds=new List<String>();
        
              for (STG_Offers__c stgoffer:insertedstgoffers1)
              {
                  getOfferIds.add(stgoffer.b2c_Offer_Id__c);
              }
              List<Offer_Header__c> offHeaders=[select Id from Offer_Header__c where Offer_Identifier__c in :getOfferIds] ;
        	  system.assertEquals(insertedstgoffers1.size(), offHeaders.size(), 'Not All Offers Successfully Inserted, Expected='+insertedstgoffers1.size()+'Actuals='+offHeaders.size());
        	   
        
    }
    @isTest
    private static void testInboundFeedRecordsUdpates(){
              
               //Setup the Product Model Records
               
               List<Product_Model__c> prodmodelsinserted=OMTestDataFactory.createProductModelRecords(15);
        
               List<Offer_Header__c> offHeader=OMTestDataFactory.createofferwithOfferId(10);
        
               List<STG_Offers__c> insertedstgoffers1=OMTestDataFactory.createStagingOfferHeader(1,10);
               
        	   //get no of records created - Should match the number of offers inserted and check the status of the updates
        	   //
        	  List<String> getOfferIds=new List<String>();
        
              for (STG_Offers__c stgoffer:insertedstgoffers1)
              {
                  getOfferIds.add(stgoffer.b2c_Offer_Id__c);
              }
              List<Offers__c> offVersions=[select Id from Offers__c where Offer_Identifier__c in :getOfferIds and Latest_Version__c=true] ;
        	  system.assertEquals(1, offVersions.size(), 'Expecting atleast 1 new Offer Version to be setup but 0 got setup');
              
        	   
        
    }   
    
}