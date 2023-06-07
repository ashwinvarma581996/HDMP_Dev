/*
Name: B2B_BatchSettleBTTransactions
Created By : Rajrishi Kaushik
Date : 29/08/2021
Description : This is a Batch class to update Order's transaction status to settled.
*/

global class B2B_BatchSettleBTTransactions implements Database.Batchable<sObject>, Database.AllowsCallouts {
   
    // start method to query on Order objects
    global Database.QueryLocator start(Database.BatchableContext bc)  {
        String transactionStatus = 'Submitted_For_Settlement';
        Integer minTime = Integer.valueOf(Label.BT_Settle_Min_Time);
        Integer maxTime = Integer.valueOf(Label.BT_Settle_Max_Time);
        Datetime nextTime = System.now().addHours(maxTime); //24
        DateTime preTime = System.now().addHours(minTime); //25
        String query = 'SELECT Id, BT_Transaction_Status__c, Send_Email_To_Customer__c, OrderedDate, LastModifiedDate FROM Order '; 
        if(!Test.isRunningTest()){
          query += 'WHERE LastModifiedDate >=: preTime AND LastModifiedDate <=: nextTime AND BT_Transaction_Status__c =: transactionStatus';  
        }        
        System.debug('query : '+query);
        return Database.getQueryLocator(query);
    }
    
    // execute method to run buisness logic for updating the Orders data.
    global void execute(Database.BatchableContext bc, List<Order> lstOrders){
        System.debug('lstOrders : '+ lstOrders);
		List<Order> lstUpdateOrders = new List<Order>();
        for(Order objOrder : lstOrders){ 
            objOrder.BT_Transaction_Status__c = 'Settled';
            objOrder.Send_Email_To_Customer__c = false;
            lstUpdateOrders.add(objOrder);
        }
        
        if(!lstUpdateOrders.isEmpty())
            update lstUpdateOrders;
        
    }
    
    //finish method
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}