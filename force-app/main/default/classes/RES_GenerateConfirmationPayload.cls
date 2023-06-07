/**
 * @description       : Used to create the url to
 * return to sitecore
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 01-22-2022
 * @last modified by  : eantonson@gorillagroup.com
**/
public without sharing class RES_GenerateConfirmationPayload {

    @AuraEnabled
    public static string getReturnUrlFromReservation(String reservationId){
        try {
            List<Reservation__c> reservations = [SELECT id,
                                                    Sitecore_id__c,
                                                    uniqueModelId__c,
                                                    Name,Model_Name__c,
                                                    Vehicle_Model_Series__c, Model_Year__c,
                                                    Model_ID__c, Exterior_Color__c,
                                                    Exterior_Color_Code__c, Interior_Color__c,
                                                    Interior_Color_Code__c, Dealer_Name__c, Dealer_Phone__c,
                                                    Deposit_Amount__c, Redirect_URL__c,
                                                    Is_Participating__c, IsWaitlist__c,
                                                    Accessories__c, Approval_Code__c, Model_Name_Standalone__c, Package_Name__c
                                                FROM Reservation__c
                                                WHERE id = :reservationId ] ;
            return processReservation(reservations[0]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }


    @InvocableMethod(label='GenerateConfirmation' description='description')
    public static List<String> generateConfirmationUrl(List<id> ids)
    {
        return generate(ids) ;
    }

    public static List<String> generate(List<Id> ids) {

        List<Reservation_Session__c> sessions = [SELECT Reservation__c, Cart__c FROM Reservation_Session__c WHERE Cart__c IN :ids ORDER BY CreatedDate DESC ] ;

        Map<String,String> cartReservationMap = new Map<String,String>() ;

        for ( Reservation_Session__c session : sessions )
        {
            if ( !cartReservationMap.containsKey(session.Cart__c ))
            {
                cartReservationMap.put(session.cart__c, session.Reservation__c) ;
            }
        }


        List<Reservation__c> reservations = [SELECT id,
                                                    Sitecore_id__c,
                                                    uniqueModelId__c,
                                                    Name, Model_Name__c,
                                                    Vehicle_Model_Series__c,
                                                    Model_Year__c,
                                                    Model_ID__c, Exterior_Color__c,
                                                    Exterior_Color_Code__c, Interior_Color__c,
                                                    Interior_Color_Code__c, Dealer_Name__c, Dealer_Phone__c,
                                                    Deposit_Amount__c, Redirect_URL__c,
                                                    Is_Participating__c, IsWaitlist__c,
                                                    Accessories__c, Approval_Code__c, Model_Name_Standalone__c, Package_Name__c
                                            FROM Reservation__c
                                            WHERE id IN :cartReservationMap.values() ] ;

        List<String> rv = new List<String>() ;

        for ( Id id : ids )
        {
            String reservationId = cartReservationMap.get(id) ;
            Reservation__c reservation ;
            for ( Reservation__c r : reservations )
            {
                if ( r.id == reservationId )
                {
                    reservation = r ;
                    break ;
                }
            }
            rv.add(processReservation(reservation)) ;
        }

        return rv ;

    }

    private static string processReservation(Reservation__c reservation)
    {
        if ( reservation == null )
        {
            return '/';
        }

        String template = '\'{\'  "id":"{0}", "uniqueModelId":"{1}", "modelName":"{2}", "reservationNumber":"{3}",'
        +'"vehicleModelSeries":"{4}", "modelYear":{5}, "modelId":"{6}", "exteriorColor":"{7}", "exteriorColorCode":"{8}", "interiorColor":"{9}", '
            + '"interiorColorCode":"{10}", "dealerName":"{11}", "dealerPhoneNumber":"{12}", "depositAmount":"{13}", "type": {14} , "accessories": {15}, "modelNameStandalone": "{16}", '
            + '"packageName": "{17}" \'}\'';

        String s = reservation.Name ;
        String resNbr = s.substring(0,2) + '1' + s.substring(2).reverse() ;

        String reservationCode = String.isBlank(reservation.Approval_Code__c) ? resNbr : reservation.Approval_Code__c;

        List<String> values = new List<String>() ;
        /*Example response:{ {
            "id": "87BCC4B8CC8242BCB65C0C0B12595013",
            "uniqueModelId":"YD8H9NKNW-1",
            "modelName":"MDX",
            "reservationNumber":"XXXX",
            "vehicleModelSeries":"MDX Type S",
            "modelYear":2022,
            "modelId":"YD8H8NKNW",
            "exteriorColor":"Performance White Pearl",
            "exteriorColorCode":"B-621",
            "interiorColor":"Red",
            "interiorColorCode":"RE",
            "dealerName":"Acura of Sherman Oaks",
            "dealerPhoneNumber":"818-528-1300",
            "depositAmount":"500",
            "type": 1 | 2 | 3
            "accessories": [{
                    "opCode": "MDX0022058",
                    "name": "Black Premium Plus Package",
                    "msrp": "1423"
                }, {
                    "opCode": "MDX0022024",
                    "name": "Premium Sports Package",
                    "msrp": "1956"
                }, {
                    "opCode": "MDX0022024",
                    "name": "20-inch Dark Chrome-Look Alloy Wheels",
                    "msrp": "2557"
                }]
            },
            "modelNameStandalone": "MDX",
            "packageName": "XXX",
            */

        //New fields added 06/14/22
        values.add(reservation.Sitecore_id__c) ;
        values.add(reservation.uniqueModelId__c) ;
        values.add(reservation.Model_Name__c) ;
        //
        values.add(reservationCode);
        values.add(reservation.Vehicle_Model_Series__c) ;
        values.add(reservation.Model_Year__c) ;
        values.add(reservation.Model_ID__c) ;
        values.add(reservation.Exterior_Color__c);
        values.add(reservation.Exterior_Color_Code__c);
        values.add(reservation.Interior_Color__c) ;
        values.add(reservation.Interior_Color_Code__c) ;
        values.add(reservation.Dealer_Name__c) ;
        values.add(reservation.Dealer_Phone__c);
        values.add(String.valueof(reservation.Deposit_Amount__c)) ;
        values.add(reservation.IsWaitlist__c ? '3' : ( reservation.Is_Participating__c ? '1' : '2')) ;
        values.add(reservation.Accessories__c);
        values.add(reservation.Model_Name_Standalone__c);
        values.add(reservation.Package_Name__c);
        String jsonStr = String.format(template,values);
        // String b64Str = EncodingUtil.base64Encode(Blob.valueOf(jsonStr)) ;
        String url = String.join(new List<String>{ reservation.Redirect_url__c , '?data=' , jsonStr },'');
        return url;
    }
}