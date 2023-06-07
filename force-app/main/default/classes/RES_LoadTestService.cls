/**
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 03-06-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@RestResource(urlMapping='/loadTest')
global without sharing class RES_LoadTestService {

    @HttpPost
    global static void start()
    {
        Map<String,Object> data ;
        try {
            Integer testPackageId =  Integer.valueOf(Math.random() * 3.0) ;
            Map<String,Object> defaultMap = RES_LoadTest.getNextPayLoad(testPackageId);
            data = RES_LoadTest.mergeMaps(null, defaultMap) ;
            Product2 product = RES_CapManagement.getProduct(RES_Settings.getSettings().capKey__c, data) ;
            String capGroupId = null ;
            String wl = RES_CapManagement.calcWaitlist(capGroupId, product?.Reservation_Cap_Group__r?.Reservation_Cap__c, product?.Reservation_Cap_Group__r?.Include_No_Deposit_in_Cap_Calculation__c) ;
            Boolean isWaitlisted = Math.random() > 0.75 ? true : false ;
            String contactId = RES_LoadTest.saveFormData() ;
            String productId = Res_Settings.getSettings().Reservation_Product_Id__c ;
            String rid = RES_LoadTest.saveReservation(JSON.serialize(data), isWaitlisted, contactId, productId, capGroupId) ;
            User u = RES_LoadTest.getLoginUser(RES_Settings.getSettings(),0) ;
            String sess = RES_LoadTest.startSession(u.id, contactId, rid) ;
            Order o ;
            if ( String.isNotBlank(sess)){
                o = RES_LoadTest.createOrder(product, [SELECT id FROM Account WHERE id = :RES_Settings.getSettings().Reservation_Account__c]) ;
            }

            RES_LeadCreation.postLeadsFromReservationAsync(rid,'127.0.0.1',true) ;
            RES_Send_Email.sendConfirmationByRes(rid) ;
            RES_GenerateConfirmationPayload.getReturnUrlFromReservation(rid) ;

            RestResponse res = RestContext.response ;
            res.statusCode = 200 ;
            Map<String,String> pl = new Map<String,String>() ;
            pl.put('wl',wl) ;
            pl.put('user',u.id) ;
            pl.put('sess',sess);
            pl.put('package',String.valueOf(testPackageId)) ;
            pl.put('iswl',String.valueof(isWaitlisted));
            pl.put('o',o?.id) ;
            res.responseBody = Blob.valueOf('true') ;

        }
        catch( Exception e){
            String msg = 'runTestElement Exception.  data ' + JSON.serialize(data) + 'Exception ' + e.getMessage()  ;
            RES_Logger.log(msg) ;
            RestResponse res = RestContext.response ;
            res.statusCode = 500 ;
            Map<String,Object> responsePayload = new Map<String,Object>() ;
            responsePayload.put('status',500) ;
            responsePayload.put('data', data) ;
            responsePayload.put('exception' , e.getMessage() ) ;
            res.responseBody = Blob.valueOf(JSON.serialize(responsePayload)) ;
        }
    }
}