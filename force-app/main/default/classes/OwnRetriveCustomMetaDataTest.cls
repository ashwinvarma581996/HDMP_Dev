@isTest
public class OwnRetriveCustomMetaDataTest {
    
     @isTest
    static void getFinanceLinkTest(){
       Finance_SSO__mdt m= OwnRetriveCustomMetaData.getFinanceLink('Honda');        
    }
	@isTest
    static void getManualRequestTest(){
        Test.startTest();
        List<ManualRequest__mdt> m= OwnRetriveCustomMetaData.getManualRequest('Honda');  
        System.assert(m.size() >0);
        Test.stopTest();      
    }

    @isTest
    static void getmyQVehicleCompatibility(){
        Test.startTest();
        List<OwnmyQVehicleCompatibility__mdt> m= OwnRetriveCustomMetaData.getmyQVehicleCompatibility('Honda');  
        System.assert(m.size() >0);
        Test.stopTest();      
    }
}