@isTest
public class On_Sandbox_CreationTest {
 @isTest 
	static void testrunApexClassMethod(){ 
     SandboxContext context ;
        On_Sandbox_Creation obj = new On_Sandbox_Creation();
        Test.startTest() ;
       obj.runApexClass( context);
        Test.stopTest() ;
    }
}