@isTest
public class RES_CopyControllerTest {
 @isTest 
	static void testgetSingleCopySets(){ 
        Test.startTest() ;
        RES_CopyController.getSingleCopySets('test',true,true);
        Test.stopTest() ;
    }
}