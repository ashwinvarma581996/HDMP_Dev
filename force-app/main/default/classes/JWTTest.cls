//****************************************************************************** 
// File Name:       JWTTest.cls
// Summary:         Apex Class for JWT.cls
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
public class JWTTest {
    
    @isTest
    static void getAccessTokenTest(){
        String token=JWTToken.getAccessToken();
        System.assertEquals(true,!String.isBlank(token));
    }

}