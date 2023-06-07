/*******************************************************************************
Name: B2B_IntegrationUtility
Business Unit: HDM
Date: 28/04/2022
Developer: Soumya Sahoo
Description: This class is used as utility class to fetch data from the back end by using SOQL statements
*******************************************************************************
MODIFICATIONS – V1 | 29/03/2022 | Sayalee | Added Header
MODIFICATIONS – V2 | 29/06/2022 | Soumya  | Query changes
MODIFICATIONS – V3 | 31/10/2022 | Soumya  | R2C2 related changes for Cart Updates and Multiple Shipping- HDMP-12228
MODIFICATIONS – V3 | 06/03/2023 | Saravanan  | gettaxcartitems - HDMP-16535
*******************************************************************************/
public without sharing class B2B_IntegrationUtility {
    public static Webcart getcartdetails(Id CartId){
        Webcart cartfetch=[SELECT Id,DealerId__c,DealerId__r.shippingStreet,DealerId__r.shippingCity,
                        DealerId__r.shippingPostalCode,DealerId__r.shippingState,
                        DealerId__r.Name,DealerId__r.POIID__c,Total_Installation_Charge__c,
                        CustomerStreet__c,Customer_State__c,CustomerCity__c,CustomerCountry__c,ShippingAmount__c,ownerId,
                           CustomerPostalCode__c
                        FROM WEbCart
                        WHERE Id=:cartId];
    return cartfetch;
    }
    public static Webcart getshippingdetails(Id CartId){
         Webcart shippingfetch=[SELECT Id,Pickup_Dealer__c,B2B_Shipping_Speed_Options__c,DealerId__r.Preferred_Shipping_Carrier__r.Name,ShippingAmount__c from Webcart where Id=:cartId];
        return shippingfetch;
    }
    public static List<CartItem> getCartItemdetails(Id CartId){
        List<CartItem> cartitemsfetch=[Select Id,Quantity,Product2.Length_in__c,Product2.Width_in__c,Product2.Height_in__c,Product2.Weight_lbs__c,
                                            Product2.B2B_Volume__c,Item_Package_quantity__c from CartItem where cartId =:cartId];
        return cartitemsfetch;
    }
    public static Map<String,Carrier_Speed__c> getShippingdata(String Carrier,Boolean preferredSpeed){
        Map<String,Carrier_Speed__c> categoryrecords = new Map<String,Carrier_Speed__c>();
        List<Carrier_Speed__c> metadatarecords=[select id,Carrier_Speed_Name__c,Carrier__r.Name,Honda_Shipping_Speed__c,Honda_Shipping_Speed__r.Honda_Speed_Name__c,Sort_Order__c from Carrier_Speed__c where Carrier__r.Name=:Carrier and Carrier__r.Is_Active__c=true order by Sort_Order__c];
        for(Carrier_Speed__c records:metadatarecords){
            if(preferredSpeed==true)
                categoryrecords.put(records.Honda_Shipping_Speed__r.Honda_Speed_Name__c,records);
            else    
            	categoryrecords.put(records.Carrier_Speed_Name__c,records);
        }
        return categoryrecords;
    }
    public static List<CartItem> gettaxcartitems(String CartId){
        // Saravanan LTIM added Product_type__c API for 16535
         List<CartItem> taxcartitems=[Select Id,Quantity,unitadjustedPrice,TotalAmount,Product2.StockKeepingUnit,Product_type__c,Product2.Core_Charge_Unit_Price__c from CartItem where cartId =:cartId ORDER By Sku];
        return taxcartitems;
    }
    
    public static List<B2B_Vehicle_Function_Code_Junction__c> getfunctioncodes(Integer gradeId,Integer year,integer divisionid,Integer catalogId,Integer doorId){
        List<Vehicle__c> modelrecordId=[SELECT id FROM Vehicle__c where inGradeID__c=:gradeId and iNYearID__c=:year and iNDivisionID__c=:divisionid and iNCatalogID__c=:catalogId and iNDoorID__c=:doorId Limit 1];
		List<B2B_Vehicle_Function_Code_Junction__c> functioncodes=new List<B2B_Vehicle_Function_Code_Junction__c>();
        if(!modelrecordId.isEmpty())
            functioncodes=[SELECT B2B_Function_Codes__r.B2B_Code__c FROM B2B_Vehicle_Function_Code_Junction__c WHERE B2B_Vehicle__c=:modelrecordId[0].id limit 5000];
        return functioncodes;    
    }
    public static string getcustomerpreferredshippingspeed(String userId){
        Id contactid=[select contactid from user where id=:userId Limit 1]?.contactid;
        List<Account> preferredSpeed=[select Preferred_Honda_Shipping_Speed__r.Honda_Speed_Name__c from Account where PersonContactId=:contactid Limit 1];
        if(preferredSpeed.size()>0)
            return preferredSpeed[0].Preferred_Honda_Shipping_Speed__r.Honda_Speed_Name__c;
        else
            return '';
    }
    public static List<Carrier_Speed__c> getCarrierSpeeds(String carrier){
        List<Carrier_Speed__c> categoryList=[SELECT Id,Carrier_Speed_Name__c FROM Carrier_Speed__c where Carrier__r.Name =:Carrier and Carrier__r.Is_Active__c=true order by Sort_Order__c];
        if(!categoryList.isEmpty())
            return categoryList;
        	else
            return categoryList;
    }
    public static Map<String,B2B_Error_Handling__mdt> getErrorHandlingCodes_Severity(string featureName){
        Map<String,B2B_Error_Handling__mdt> errorHandlingMap=new Map<String,B2B_Error_Handling__mdt>();
        for(B2B_Error_Handling__mdt errorData:[select errorCode__c,severity__c,error_Type__c from B2B_Error_Handling__mdt where Feature__c=:featureName]){
            errorHandlingMap.put(errorData.errorCode__c,errorData);
        }
        return errorHandlingMap;
    }
    // Below method added as part of HDMP-12228
    public static String getStandardSpeed(String carrier){
        String standardSpeed;
        List<Carrier_Speed__c> standardSpeedlist=[select Carrier_Speed_Name__c from Carrier_Speed__c where Carrier__r.Name=:Carrier and Carrier__r.Is_Active__c=true and Carrier__r.Is_Active__c=true and Sort_Order__c =1 order by Sort_Order__c limit 1];
        for(Carrier_Speed__c records:standardSpeedlist){
            standardSpeed = records.Carrier_Speed_Name__c;
        }
        return standardSpeed;
    }

}