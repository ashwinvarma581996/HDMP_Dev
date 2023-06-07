@isTest(SeeAllData=true)
public class B2BMegacategoryMappingTriggerTest {
    @isTest
    private static void insertMegacategoryMappingTest(){
        //Insert the initial record
        MegacategoryMapping__c mapping = new MegacategoryMapping__c(SectionName__c = 'Test Section Name', 
                                                                    GroupName__c ='Test Group Name');
        insert mapping;
        
        //Insert the duplicate record (same Section and Group Names as above)
        mapping = new MegacategoryMapping__c(SectionName__c = 'Test Section Name',
                                             GroupName__c ='Test Group Name');
        
        Test.startTest();
        Database.SaveResult result = Database.insert(mapping, false);
        Test.stopTest();
        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        String errorMsg; 
        if(result.getErrors().size() > 0){
            System.debug('Error message: '+result.getErrors()[0].getMessage());
            //Sample full message:
            //duplicate value found: AK_MegacategoryMapping__c duplicates value on record with id: a1d75000000AYiX
            errorMsg = result.getErrors()[0].getMessage().substring(0,21);
        }
        System.assertEquals('duplicate value found',errorMsg);
    }
    @isTest
    private static void updateMegacategoryMappingTest(){
        //Insert the initial record
        MegacategoryMapping__c mapping = new MegacategoryMapping__c(SectionName__c = 'Test Section Name', 
                                                                    GroupName__c ='Test Group Name');
        insert mapping;
        
        //Update the record just inserted
        mapping = new MegacategoryMapping__c(Id = mapping.id,
                                             SectionName__c = 'Test Section Name',
                                             GroupName__c ='Test Group Name');
        
        Test.startTest();
        Database.SaveResult result = Database.update(mapping, false);
        Test.stopTest();
        System.assert(result.isSuccess());
    }
}