@isTest
public class ownRecaptchaControllerTest {

    @isTest
    public static void mainRecaptchaTest(){
        
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ownRecaptchaController_MockService());
        ownRecaptchaController.verifyCaptcha('StringTestPositive');
        Test.stopTest();    
        
    }
    
	@isTest
    public static void mainRecaptchaTestNotSuccess(){
              
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ownRecaptchaController_MockService());
        ownRecaptchaController.verifyCaptcha('StringTestFail');
        Test.stopTest();
        
    }
    
    @isTest
    public static void mainRecaptchaTestWrongCode(){
              
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ownRecaptchaController_MockService());
        ownRecaptchaController.verifyCaptcha('St');
        Test.stopTest();
        
    }
    
}