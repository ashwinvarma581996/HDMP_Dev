/*
Created By : Rajrishi Kaushik
Date : 07/07/2021
Description : This is a Schedule class to call B2B_BatchRefreshBTDetails class everyday.
*/

global class B2B_ScheduleRefreshBTDetails implements Schedulable, Database.AllowsCallouts {
    
  	//execute method   
    global void execute(SchedulableContext ctx) {
        //call batch class
        Id batchJobId = Database.executeBatch(new B2B_BatchRefreshBTDetails(), 10);
    }
}