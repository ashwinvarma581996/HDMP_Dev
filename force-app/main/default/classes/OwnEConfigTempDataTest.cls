//****************************************************************************** 
// File Name:       OwnEConfigTempDataTest.cls
// Summary:         Test Class for OwnEConfigTempData.cls
// Created On:      27-12-2021
// Created By:      Arunprasad N (Wipro)
// Data I/O:        
// Honda Jira Story: Apex class for API of Honda MyGarage Experience
//===============================================================================
// Modification Log: 
// December 27, 2021 Arunprasad N (Wipro) initial coding 
// Feb 02, 2022 Sai Kotu (Wipro) added test methods
//*******************************************************************************
@isTest
public class OwnEConfigTempDataTest {
    @testsetup
    static void testSetup(){
        Profile adm = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole role1 = [SELECT Id FROM UserRole WHERE Name = 'Honda Owner' LIMIT 1];
        User testUserAdmin = new User (
            FirstName='admin',
            LastName='user',
            Alias = 'admin',
            Email = 'admin1@test.com',
            Username =  System.now().millisecond() + 'admin1@test.com',
            ProfileId = adm.Id,
            UserRoleId = role1.Id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert testUserAdmin;
    }
    
     @isTest
    static void getPowerModelDataTest(){
        List<String> modelList=new List<String>();
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        system.runAs(adminUser){
        OwnEConfigTempData.ModelDataWrapper wrapper=OwnEConfigTempData.getPowerModelData();
            for(OwnEConfigTempData.Powersports ps:wrapper.powersportsRecords){
                modelList.add(ps.modelId);
            }
        }
        system.assert(modelList.contains('FTF4X4'));
    }

}