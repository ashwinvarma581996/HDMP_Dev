/* =======================================================================================
Purpose : This class is used to redirect user to home page whenever unauthorized Dreamshop page is visited.
-------------------------------------------------------------------------------------------

History
-------
VERSION        AUTHOR                  DATE                DETAIL
1.0            Pradeep Singh           12-10-2022          Intial Version

============================================================================================*/
global with sharing class CommunitiesLogin_DreamshopController {

    global CommunitiesLogin_DreamshopController () {}
    
    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
    
        final PageReference target = new PageReference(Site.getBaseSecureUrl());
        target.setRedirect(true);
        // This is a permanent redirection
        target.setRedirectCode(301);
        return target;
    }
}