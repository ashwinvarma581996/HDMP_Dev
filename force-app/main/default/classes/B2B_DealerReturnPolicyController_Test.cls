@isTest

Public class B2B_DealerReturnPolicyController_Test{

    @testSetup static void setup() {
        
        Account acc = new Account(Name = 'TestAcct' , PoIId__c = '599516');
        
        insert acc;        
    }
    
    @isTest static void testgetReturnPolicyMetod1() {
    
        
        Account ac = [select id,PoIId__c ,Name from Account LIMIT 1 ];
    
        Test.startTest();
            B2B_DealerReturnPolicyController.getReturnPolicy(ac.PoIId__c);
        Test.stopTest();
        
        System.assert(ac.PoIId__c == '599516');
        
    }
    
      @isTest static void testgetReturnPolicyMetod2() {
    
        
        Account ac = [select id,PoIId__c ,Name from Account LIMIT 1 ];
    
        Test.startTest();
            B2B_DealerReturnPolicyController.getReturnPolicy('');
        Test.stopTest();
        
        System.assert(ac.PoIId__c == '599516');
        
    }
    


}