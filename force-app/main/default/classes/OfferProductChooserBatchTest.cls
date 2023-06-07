//****************************************************************************** 
// File Name:       OfferProductChooserBatchTest.cls
// Summary:         Test class for OfferProductChooserBatch.cls
// Created On:      03-13-2023
// Created By:      Manoharan Nirmalraj(B2C)
// Test Classes:    OfferProductChooserBatchTest.cls
// Data I/O:        
// 
//*******************************************************************************
@isTest
public class OfferProductChooserBatchTest {
   
    @isTest static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new OwnProdChoosMockRespGen());
        OfferProductChooserBatch productChooserHBatch = new OfferProductChooserBatch('Honda', 'A','New');
        ID batchprocessidH = Database.executeBatch(productChooserHBatch, 1);
        System.debug('batchprocessidH' + batchprocessidH);
    }
    @isTest static void testMethod2() {
        Test.setMock(HttpCalloutMock.class, new OwnProdChoosMockRespGen());
        OfferProductChooserBatch productChooserHBatch = new OfferProductChooserBatch('Honda', 'A','Used');
        ID batchprocessidH = Database.executeBatch(productChooserHBatch, 1);
        System.debug('batchprocessidH' + batchprocessidH);
    }

    @isTest static void testMethod3() {
        Test.setMock(HttpCalloutMock.class, new OwnProdChoosMockRespGen());
        OfferProductChooserBatch productChooserHBatch = new OfferProductChooserBatch('Acura', 'B','New');
        ID batchprocessidH = Database.executeBatch(productChooserHBatch, 1);
        System.debug('batchprocessidH' + batchprocessidH);
    }

    @isTest static void testMethod4() {
        Test.setMock(HttpCalloutMock.class, new OwnProdChoosMockRespGen());
        OfferProductChooserBatch productChooserHBatch = new OfferProductChooserBatch('Acura', 'B','Used');
        ID batchprocessidH = Database.executeBatch(productChooserHBatch, 1);
        System.debug('batchprocessidH' + batchprocessidH);
    }

    @isTest static void testMethod5() {
        Test.setMock(HttpCalloutMock.class, new OwnProdChoosMockRespGen());
        OfferProductChooserBatch productChooserHBatch = new OfferProductChooserBatch('Powersports', 'M','New');
        ID batchprocessidH = Database.executeBatch(productChooserHBatch, 1);
        System.debug('batchprocessidH' + batchprocessidH);
    }
}