/**
 * @description       : 
 * @author            : eantonsonh@gorillagroup.com
 *
 * 
**/
@isTest
public with sharing class testRES_Util {

    @isTest static void TestisSandbox() {
        //test if in sandbox
        Test.startTest();
        boolean sandbox = RES_Util.isSandox();
        String sandboxName = RES_Util.getSandboxName(URL.getSalesforceBaseUrl().getHost()) ;
        System.assertEquals( sandboxName == null ? false : true , sandbox   ) ;
        Test.stopTest();
    }

    @isTest static void TestisSandboxProd() {
        //test if in sandbox
        Test.startTest();
        RES_Util.defaultHost = 'production' ;
        boolean sandbox = RES_Util.isSandox();
        String sandboxName = RES_Util.getSandboxName(URL.getSalesforceBaseUrl().getHost()) ;
        System.assertEquals( sandboxName == null ? false : true , sandbox   ) ;
        Test.stopTest();
    }

    @isTest static void TestNamedCreds() {
        //test if in sandbox
        Test.startTest();
        String namedCreds = RES_Util.getNamedCreds('Lead_Service');
      
        if ( Test.isRunningTest())
        {
            Organization[] org = [SELECT isSandbox FROM Organization WHERE id = :System.UserInfo.getOrganizationId()] ;
            if ( org[0].isSandbox )
            {
                System.assert('callout:Lead_Service'.length() < namedCreds.length()) ;
            }
            else {
                System.assertEquals('callout:Lead_Service', namedCreds) ;
            }
            System.assert(namedCreds.startsWith('callout:')) ;
        }
        Test.stopTest();        
    }

    @isTest
    public static void testIsSFId(){
        Test.startTest();
        Boolean isId = RES_Util.isSalesforceID(UserInfo.getOrganizationId()) ;
        Test.stopTest();
        System.assert(isId, 'Expected org ID to return true') ;
    }
    
    @isTest
    public static void testIsNotSFId(){
        Test.startTest();
        Boolean isId = RES_Util.isSalesforceID('no id here!') ;
        Test.stopTest();
        System.assert(!isId, 'Expected org ID to return true') ;
    }
}