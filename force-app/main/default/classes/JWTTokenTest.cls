//****************************************************************************** 
// File Name:       JWTTokenTest.cls
// Summary:         Apex Class for JWTToken.cls
// Created On:      02-02-2022
// Created By:      Arunprasad N (Wipro)
// Data I/O:        
// Honda Jira Story: Apex class for API of Honda MyGarage Experience
//===============================================================================
// Modification Log: 
// Feb 02, 2022 Arunprasad N (Wipro) initial coding 
// Feb 02, 2022 Sai Kotu (Wipro) added test methods
//*******************************************************************************

@isTest
public class JWTTokenTest {
    
    @isTest
    static void getAccessTokenTest(){
        String token=JWTToken.getAccessToken();
        System.assertEquals(true,!String.isBlank(token));
    }

}