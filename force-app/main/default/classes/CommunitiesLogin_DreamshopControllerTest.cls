/* =======================================================================================
Purpose : Test class for CommunitiesLogin_DreamshopController.
-------------------------------------------------------------------------------------------

History
-------
VERSION        AUTHOR                  DATE                DETAIL
1.0            Pradeep Singh           12-10-2022          Intial Version

============================================================================================*/
@IsTest global with sharing class CommunitiesLogin_DreamshopControllerTest {
    @IsTest(SeeAllData=true) 
    global static void testCommunitiesLoginController () {
       CommunitiesLogin_DreamshopController controller = new CommunitiesLogin_DreamshopController(); 
        controller.forwardToAuthPage();
    }    
}