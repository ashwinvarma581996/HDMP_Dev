//****************************************************************************** 
// File Name:       OfferBatchScheduler.cls
// Summary:         This class works as schedular class for Offer batch which makes offer records to Active/Expired
// Created On:      04-03-2023
// Created By:      Rama Iyer
// Test Classes:   
// Data I/O:        
// Honda Jira Story: 
//*******************************************************************************
global class OfferBatchScheduler implements Schedulable {
    /* Constructor*/
    public OfferBatchScheduler() {
    }
    /* execute*/
    global void execute(SchedulableContext sc)
    {
        
        OfferBatch offer = new OfferBatch();
        Database.executeBatch(offer,200);
        /*
        string timeinterval = '0 10 * * * ?';
        System.schedule('OfferBatchScheduler',timeinterval, new OfferBatchScheduler());
        */
    }

}