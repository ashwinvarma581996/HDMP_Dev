global class B2B_UpdateAccPreferredCarrierBatch implements Database.Batchable<sObject>{
	global final string query;
	global B2B_UpdateAccPreferredCarrierBatch(){
		query = 'SELECT Preferred_Shipping_Carrier__c,PoIId__c,Current_Dealer_Order_Seq_Number__c FROM Account Where Name != \'Reservation Guest\' AND IsPersonAccount = FALSE AND ( DivisionCd__c = \'A\' Or DivisionCd__c = \'B\' )';
	}
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext BC, List<Account> scope){
        List<Carrier__c> carriers = [SELECT Id, Name FROM Carrier__c Where Name = 'FEDEX' LIMIT 1];
        List<Account> accounts = new List<Account>();
        if(carriers != null && carriers.size() > 0){
            for(Account acc: scope){
                if(acc.Preferred_Shipping_Carrier__c==null){
                    acc.Preferred_Shipping_Carrier__c = carriers[0].Id;
                    }
                if(acc.PoIId__c != '207617') {acc.Current_Dealer_Order_Seq_Number__c = 1;}
                accounts.add(acc);
            }
        }
        if(accounts.size() > 0){
            update accounts;
        }
	}
	global void finish(Database.BatchableContext BC){
	}
}
//Execute batch: Database.executeBatch(new B2B_UpdateAccPreferredCarrierBatch());