/*******************************************************************************
Name: B2B_GetSelectedDealerTest
Business Unit: HDM Dreamshop
Date: 27/12/2022
Developer: Faraz Ansari
Description: Test class for B2B_GetSelectedDealer apex.
********************************************************************************/
@isTest
private class B2B_GetSelectedDealerTest {
    @isTest static void testGetDealerInfo(){
        B2B_GetSelectedDealer.getDealerInfo('dealerName');
    }
}