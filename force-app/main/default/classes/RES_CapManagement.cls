/**
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 03-25-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class RES_CapManagement {

    @AuraEnabled
    public static Map<String,String> isOnWaitlist(String dataStr)
    {
        try {
            if ( RES_Settings.getSettings().noCap__c)
            {

                return new Map<String,String> { 'IsWaitlist' => 'false' , 'Product' => getProduct(null,null).id , 'ReservationCapGroup' => null  } ;
            }


            Map<String,Object> data = (Map<String, Object>) JSON.deserializeUntyped(dataStr);


            String keyList = RES_Settings.getSettings().capKey__c ;

            Product2 product = getProduct(keyList,data) ;

            Map<String,String> rv = new Map<String,String>() ;

            rv.put('Product',product.id) ;
            rv.put('IsWaitlist', product.Reservation_Cap_Group__c != null && product.Reservation_Cap_Group__r.is_active__c
                ? calcWaitlist(product.Reservation_Cap_Group__c, product.Reservation_Cap_Group__r.Reservation_Cap__c,
                    product.Reservation_Cap_Group__r.Include_No_Deposit_in_Cap_Calculation__c)
                : 'false' );
            rv.put('ReservationCapGroup',product.Reservation_Cap_Group__c) ;

            return rv ;
        } catch (Exception e) {
            RES_Logger.log( 'Exception waitlist: ' +  e.getMessage()) ;
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex ;
        }
    }

    @TestVisible
    public static Product2 getProduct(String keyList, Map<String,Object> data)
    {
        List<Product2> products ;




        if ( !String.isBlank(keyList) && data != null && !data.isEmpty()){
            String key = buildKey(keyList, data) ;



            products = [ SELECT id, Reservation_Cap_Group__c, Reservation_Cap_Group__r.Reservation_Cap__c,
                                            Reservation_Cap_Group__r.Include_No_Deposit_in_Cap_Calculation__c , Reservation_Cap_Group__r.is_active__c
                                        FROM Product2
                                        WHERE Res_ProductId__c = :key ] ;
        }

        if ( products == null || products.isEmpty())
        {
            products = [ SELECT id, Reservation_Cap_Group__c, Reservation_Cap_Group__r.Reservation_Cap__c,
                            Reservation_Cap_Group__r.Include_No_Deposit_in_Cap_Calculation__c , Reservation_Cap_Group__r.is_active__c
                        FROM Product2
                        WHERE id = :RES_Settings.getSettings().Reservation_Product_Id__c ] ;
        }

        return products.isEmpty() ? new Product2(id = RES_Settings.getSettings().Reservation_Product_Id__c) : products[0] ;
    }

    @TestVisible
    public static String calcWaitlist(String id, Decimal cap, Boolean includeNoDeposit){
        if ( cap == null )
        {
            cap = RES_Settings.getSettings().Reservation_Cap__c ;
        }
        if ( cap == null )
        {
            return 'false' ;
        }
        if ( includeNoDeposit == null )
        {
            includeNoDeposit = RES_Settings.getSettings().Include_No_Deposit_in_Cap_Calculation__c ;
        }
        if ( includeNoDeposit == null){
            includeNoDeposit = false ;
        }
        String qry = 'SELECT count() FROM Reservation__c WHERE Completed__c = true' ;
        if ( id != null )
        {
            qry += ' AND Reservation_Cap_Group__c = \'' + id + '\'' ;
        }
        if ( includeNoDeposit  )
        {
            qry += ' AND Status__c IN (\'Deposit Made\',\'Reservation Made\')' ;
        }
        else {
            qry += ' AND Status__c = \'Deposit Made\'' ;
        }
        Decimal currentCnt = Database.countQuery(qry) ;
        return currentCnt >= cap ? 'true' : 'false' ;
    }

    private static String buildKey(String keyList, Map<String,Object> data){

        if ( keyList == null || data == null || data.isEmpty() ){

            return '' ;
        }
        String[] keys = keyList.split(',') ;
        String capKey = '' ;
        for ( String key : keys) {
            if ( capKey.length() > 0 )
            {
                capKey += '-' ;
            }
            if ( String.isEmpty(key)){
                capKey += '_' ;
            }
            else {
                String val = String.valueOf(data.get(key)) ;
                if ( String.isEmpty(val))
                {
                    capKey += '_' ;
                }
                else {
                    capKey += val ;
                }
            }
        }
        return capKey ;
    }

}