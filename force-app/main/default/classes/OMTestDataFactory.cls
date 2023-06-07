//****************************************************************************** 
// File Name:       OMTestDataFactory.cls
// Summary:         Apex Class for Test Data Factory for Offer Management Project
// Created On:      03-12-2023
// Created By:      Rama Iyer
// Test Classes:    Not Required as this is annotated with Test itself
// JIRA Story :     OMP-156,OMP-76,OMP-104,OMP-103
//===============================================================================
@isTest
public class OMTestDataFactory {
    
    public static List<Product_Model__c>  createProductModelRecords(Integer noOfModelRecords){
        List<Product_Model__c> prodmodelst=new List<Product_Model__c>();
        for(Integer i=0;i<noOfModelRecords;i++)
        {
            prodmodelst.add(new Product_Model__c(Model_Name__c='MODEL'+i,Model_Year__c='2023',Product_Model_Id__c='MODID-'+i,Trim__c='Test Trim'));
        }
        insert prodmodelst;
        return prodmodelst;
        
        
    }
    public static List<STG_Offers__c> createStagingOfferHeader(Integer noofrecordsneeded, Integer noofmodelsperoffer){
        List<STG_Offers__c> newStgOffers=new List<STG_Offers__c>();
        //Create records for CPO Special Finance
        for (Integer i=0;i<noofrecordsneeded;i++)
        {
            newStgOffers.add(new STG_Offers__c(B2C_Offer_Id__c='AHFCSpecial-'+i,Offer_Record_Type__c='CPO_Special_Finance',Brand__c='A',AHFC_Sales_Program_Id__c=String.valueof(i),APR_1__c=i,Start_Date__c=System.today(),End_Date__c=System.today().addMonths(1)));
        }
        //Create records for CPO Special Finance
        /*for (Integer i=0;i<noofrecordsneeded;i++)
        {
            newStgOffers.add(new STG_Offers__c(B2C_Offer_Id__c='AHFCSpecialLease-'+i,Offer_Record_Type__c='New_Special_Lease',Brand__c='B'));
        }*/
        insert newStgOffers;
        OMTestDataFactory.createStagingOfferModels(newStgOffers,noofmodelsperoffer);
        OMTestDataFactory.createStagingOfferModelsError(newStgOffers,noofmodelsperoffer);
        return newStgOffers;
    }    
    public static List<STG_Offer_Eligible_Models__c>  createStagingOfferModels(List<STG_Offers__c> Stgofferslst, Integer noofmodelsperoffer){
        List<STG_Offer_Eligible_Models__c> stgoffmodellst=new List<STG_Offer_Eligible_Models__c>();
        List<STG_Offers__c> updateStgStatusList=new List<STG_Offers__c>();
        for (STG_Offers__c stgoffer:Stgofferslst)
        {
            for(Integer i=0;i<noofmodelsperoffer;i++){
                
                stgoffmodellst.add(new STG_Offer_Eligible_Models__c(B2C_Offer_Id__c=stgoffer.B2C_Offer_Id__c,Model_Id__c='MODID-'+i));
            }
            updateStgStatusList.add(new STG_Offers__c(Id=stgoffer.Id,Processing_Status__c='New'));
        }        
        insert stgoffmodellst;
        update updateStgStatusList;
        return stgoffmodellst;
        
    }  
    public static List<STG_Offer_Eligible_Models__c>  createStagingOfferModelsError(List<STG_Offers__c> Stgofferslst, Integer noofmodelsperoffer){
        List<STG_Offer_Eligible_Models__c> stgoffmodellst=new List<STG_Offer_Eligible_Models__c>();
        List<STG_Offers__c> updateStgStatusList=new List<STG_Offers__c>();
        for (STG_Offers__c stgoffer:Stgofferslst)
        {
            for(Integer i=0;i<noofmodelsperoffer;i++){
                
                stgoffmodellst.add(new STG_Offer_Eligible_Models__c(B2C_Offer_Id__c=stgoffer.B2C_Offer_Id__c,Model_Id__c='MODID-'));
            }
            updateStgStatusList.add(new STG_Offers__c(Id=stgoffer.Id,Processing_Status__c='New'));
        }        
        insert stgoffmodellst;
        update updateStgStatusList;
        return stgoffmodellst;
        
    }  
    public static list<Offer_Header__c> createOfferHeader(){
        List<Offer_Header__c>  lstheader = new list<Offer_Header__c>();
        lstheader.add(new Offer_Header__c(Name='Testing offer Header',Brand__c='A'));
        INSERT lstheader;
        return lstheader;
    }
    public static List<Offers__c> createoffer(){
        List<Offers__c>  lstoffer = new list<Offers__c>();
        lstoffer.add(new Offers__c(Name  = 'test',Brand__c = 'A',Special_category__c = 'Loyalty',Product_Type__c  = 'Used'));
        insert lstoffer;
        return lstoffer;
    }
    public static List<Offer_Header__c> createofferwithOfferId(Integer noofmodelsperoffer){
        List<Offer_Header__c>  lstheader = new list<Offer_Header__c>();
        List<Offers__c>  lstoffer = new list<Offers__c>();
         List<Offer_Eligible_Models__c>  lstofferModels = new list<Offer_Eligible_Models__c>();
        Id recordTypeId =Schema.SObjectType.Offer_Header__c.getRecordTypeInfosByDeveloperName().get('CPO_Special_Finance').getRecordTypeId();
        Id recordTypeIdOff =Schema.SObjectType.Offers__c.getRecordTypeInfosByDeveloperName().get('CPO_Special_Finance').getRecordTypeId();
        Id recordTypeIdOffModel =Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByDeveloperName().get('CPO_Special_Finance').getRecordTypeId();
        lstheader.add(new Offer_Header__c(Name  = 'test-11',Offer_Identifier__c='AHFCSpecial-0',RecordTypeId=recordTypeId,Brand__c='A',AHFC_Sales_Program_Id__c='12345'));
        insert lstheader;
        //insert corresponding offers
        //
         lstoffer.add(new Offers__c(Version_Number__c=1,Status__c='Active',Offer_Header__c=lstheader.get(0).Id,Name  = 'test-11',Brand__c = 'A',Product_Type__c  = 'Used',AHFC_Sales_Program_Id__c='12345',recordtypeid=recordTypeIdOff,APR_1__c=1.5));
        insert lstoffer;
        //Insert Models
        //
        for(Integer i=0;i<noofmodelsperoffer;i++)
        {
           lstofferModels.add(new Offer_Eligible_Models__c(name='MODEL'+i,Year__c='2023',Brand__c='A',Offer__c=lstoffer.get(0).Id,recordtypeId=recordTypeIdOffModel));
        }
        insert lstofferModels;
        return lstheader;
    }
    public static List<Boilerplate__c> createBoilerplate(){
        List<Boilerplate__c>  lstboilerplate = new list<Boilerplate__c>();
        lstboilerplate.add(new Boilerplate__c(Name  = 'test',Brand__c = 'A'));
        insert lstboilerplate;
        return lstboilerplate;
    }
      public static List<Offer_Eligible_Models__c> createEligiblemodel(){
        List<Offer_Eligible_Models__c>  lstEligiblemodel = new list<Offer_Eligible_Models__c>();
        lstEligiblemodel.add(new Offer_Eligible_Models__c(Name  = 'test',Brand__c = 'A'));
        insert lstEligiblemodel;
        return lstEligiblemodel;
    }
    
}