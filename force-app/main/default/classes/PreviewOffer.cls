/*******************************************************************************************
 * Name : Bhupendra Sisodiya
 * Description: This class will used for Offer Preview Functionality on Offer record page.
 * 
 * ***************************************************************************************/

public with sharing class PreviewOffer {

@AuraEnabled
public static String previewOffer2(String recordID){
System.debug('inside preview offer 2');
    String recordIDnew =recordID.replaceAll('"','');

Offers__c  objOffer = [Select Id,

Total_Due_at_Signing__c,

Base_Monthly_Payment__c,
    
                       
Total_Monthly_Payment__c,   
    
End_Date_NUM__c,
Offer_Amount__c,

Term_Min_1__c,
Term_Min_2__c,
Term_Min_3__c,
Term_Min_4__c,
Term_Min_5__c,
Term_Min_6__c,
Term_Max_1__c,
Term_Max_2__c,
Term_Max_3__c,
Term_Max_4__c,
Term_Max_5__c,
Term_Max_6__c,
APR_1__c,
APR_2__c,
APR_3__c,
APR_4__c,
APR_5__c,
APR_6__c,
Sample_Model_Description__c,
Sample_APR__c,
Sample_Monthly_Payment__c,
Start_Date__c,
Start_Date_NUM__c,
Sample_Termmonths__c,
Short_Description__c,
toLabel(Brand__c),
Offer_Title__c,

Detailed_Description__c,
Terms_and_Conditions__c,
RecordTypeId,
RecordType.Name,

Additional_Info_URL__c,
Advertised_End_Date__c,
Advertised_End_Date_NUM__c,
Advertised_Start_Date__c,
Advertised_Start_Date_NUM__c,
AHFC_Approved__c,
AHM_Regions__c,

Banner_Disclaimer_3__c,
Banner_Disclaimer_4__c,
Banner_Disclaimer_5__c,
Banner_Disclaimer_Competitor_Model__c,
Banner_Disclaimer_Prefix__c,
Banner_Image_URL__c,
Banner_Sales_Program_Type__c,
Banner_Short_Description__c,
Boilerplate__c,

Bonus_Bucks_Amount__c,
Capital_Cost_Reduction__c,
Captive_Cash__c,

// Created__c,
// Creator_Name__c,
Credit_Tier__c,
Credit_Tier_Decs__c,
Credit_Tier_Description__c,
Custom_clone__c,
Custom_Offer_Attributes__c,
Cutline_Text__c,
Descriptive_Name__c,
Display_Type__c,
Double_Bonus_Bucks_Amount__c,
End_Date__c,
File_Name__c,

Group_Code__c,
Group_Name__c,
Group_Type__c,

Latest_Version__c,

Legal_Desclaimer__c,
LifeCycle__c,

Lock_Date__c,
Lock_Owner__c,

Min_Pay__c,

No_Interest_Required_Duration__c,
No_Payments_Required_Duration__c,

Offer_Availability__c,

Offer_Header__c,
Offer_Type__c,

Original_High_Balance_APR__c,
Other_Captive_Cash__c,
Owner_name__c,
Preview__c,
Priority__c,
PRISM_Offer_Status__c,

Product_Division_Name__c,
Product_Type__c,
Program_End_Date__c,
Program_Start_Date__c,
Promotion_Duration__c,
Promotion_Name__c,
Promotional_APR__c,
Record_Type_Name__c,
Related_Queue__c,
Picklist1__c,
Picklist_2__c,

Sales_Program_Type_CD__c,
Sales_Program_Type_Name__c,
Security_Deposit_Required__c,
Size__c,
Special_category__c,

Special_Region_Type_Name__c,
Standard_Program_APR_Low__c,
Standard_Program_APR_High__c,
Standard_Program_Date__c,
State_Code__c,
State_Name__c,
Status__c,
Synched_with_PRISM__c,
Term_Description__c,
Title__c,
Title_Name__c,
Total_Amount_Financed__c,
Transaction_Status__c,

Vehicle_Type__c,
Vehicle_Type_CD__c,

Version_Number__c,
Zero_Due__c
    from Offers__c where id=:recordIDnew];

System.debug('objOffer==>>'+objOffer);
List<PRISM_merge_tag__mdt> CusMetaList = [SELECT Id,Object_Name__c,Record_Type_Name__c,Field_API__c, Field_Name__c, Format__c, Variable_Name__c
                                            FROM  PRISM_merge_tag__mdt where Record_Type_Name__c=:objOffer.RecordType.Name and 
                                            Brand__c=:objOffer.Brand__c and 
                                            Object_Name__c IN ('Offers__c','Offer_Eligible_Models__c') ];
List<Offer_Eligible_Models__c> OffEligibleModelsList = [select Id,Featured_Offer__c, Model__c,Model_ID__c,Year__c,Name,Base_Monthly_Payment__c,Net_Capital_Cost__c,Acquisition_Fee__c,
Additional_Cash__c,
Adjusted_MSRP_with_DH__c, Annual_Miles__c,
Brand__c,
Capitalized_Cost_Reduction__c
,Captive_Cash_Lease_Amount__c
,Category__c

,Conquest_Cash__c
,CreatedById

,Dealer_Contribution__c

,Default_Image__c
,Depreciation_Amount__c
,Destination_Handling_charge__c
,Dh_Cost__c
,Featured__c

,Featured_Term__c

,Gross_Cap_Cost_After_Dealer_Contrib__c
,Gross_Cap_Cost_Before_Dealer_Contrib__c
,Gross_Margin__c
,Image_Color__c
,Image_Source_Name__c
,Incentive_Cycle_Id__c
,Include_Sample_Payment__c
,Invoice_Amount__c
,Invoice_Price_with_DH__c
,Large_Image_Path__c
,Lease_Option_Id__c
,Lease_Option_Type__c
,Terms_Months__c
,Loyalty_Cash__c
,Mileage__c
,Model_Code__c
,Model_Group_Name__c
,Model_Marketing_Name__c

,Model_Series__c
,Model_Series_Group_Name__c
,ModelParentSeriesGroupName__c
,Money_Factor__c
,MSRP__c

,Other_Captive_Cash_Lease_Amount__c
,OwnerId
,Program_Code__c
,Residual_Factor__c
,Residual_Pct__c
,Residual_Rate__c
,Residual_Value__c
,Segment__c
,Service_Charge_Amount__c
,Sort_Order__c
,Special_Region__c
,Title_Ident__c
,Total_Due_At_signing__c
,Total_Monthly_Payment__c,
Trim__c
, Offer__r.Short_Description__c,Offer__r.brand__c,Offer__r.Offer_Title__c,Offer__r.Legal_Desclaimer__c, Offer__r.Detailed_Description__c, Offer__r.Terms_and_Conditions__c from Offer_Eligible_Models__c where Offer__c=:recordIDnew 
//and (Include_Sample_Payment__c=true OR Featured_Offer__c =true) ];
and Featured_Offer__c =true ];

Map<String,Object> mapOfOfferFields=objOffer.getPopulatedFieldsAsMap();
Map<String,Object> oemFieldSet=new Map<String,Object>();
Map<Id,List<String>> mapOfOEMfinalList=new Map<Id,List<String>>();
Map<Id,String> mapOfDefaultImage =new Map<Id,String>();
Map<Id,Offer_Eligible_Models__c> newBoilerPlateDataMap = new Map<Id,Offer_Eligible_Models__c>();
String offers1='offerTitle'+objOffer.Offer_Title__c +'offerTitle'+ 'legalDesclaimer' + objOffer.Legal_Desclaimer__c +'legalDesclaimer'+'detailedDescription'+objOffer.Detailed_Description__c +'detailedDescription' + 'shortDescription'+ objOffer.Short_Description__c+'shortDescription' + 'termAndCondapex' + objOffer.Terms_and_Conditions__c+'termAndCondapex';
String specialSymbol1 ='<<';
String replaceWith11 ='&lt;&lt;';
String specialSymbol2='>>';
String replaceWith2 = '&gt;&gt;';
String offers2 = offers1.replaceAll(specialSymbol1,replaceWith11);
String offers3 = offers2.replaceAll(specialSymbol2,replaceWith2);
offers3 = replaceNewlinesWithBrTags(offers3);
String offers =offers3.stripHtmlTags();

System.debug('offers String====>>>>'+offers);
String boilerPlateCheck='true';
// String SdisableMarkAsPreviewed ='false';
If(objOffer.Boilerplate__c==null){
    boilerPlateCheck='false';
}





//for currency fields
// Get the object's describe result
Schema.DescribeSObjectResult dsr = Offer_Eligible_Models__c.sObjectType.getDescribe();
Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();

// Get the describe result for the Offers__c object
Schema.DescribeSObjectResult dsrOffers = Offers__c.sObjectType.getDescribe();
Map<String, Schema.SObjectField> fieldMapOffers = dsrOffers.fields.getMap();



System.debug('mapOfOfferFields==>>'+ mapOfOfferFields);
for(Offer_Eligible_Models__c objOEM:OffEligibleModelsList){
    
    oemFieldSet=objOEM.getPopulatedFieldsAsMap();
    //System.debug('oemfst'+oemFieldSet);
    String offerList=offers;
    for(PRISM_merge_tag__mdt objMDT:CusMetaList){
        System.debug('objMDT.Variable_Name__c ==>>'+objMDT.Variable_Name__c);
        System.debug('oemFieldSet.get(objMDT.Field_API__c) ==>>'+oemFieldSet.get(objMDT.Field_API__c));
        System.debug('mapOfOfferFields.get(objMDT.Field_API__c==>>'+mapOfOfferFields.get(objMDT.Field_API__c));

        if(offers.contains(objMDT.Variable_Name__c) && oemFieldSet.containsKey(objMDT.Field_API__c)){
            //offerList=offerList.replaceALL(objMDT.Variable_Name__c, String.valueOf(oemFieldSet.get(objMDT.Field_API__c)));
                // Get the field's describe result
        Schema.DescribeFieldResult dfr = fieldMap.get(objMDT.Field_API__c).getDescribe();

        // Check if the field is a currency field
        if (dfr.getType() == Schema.DisplayType.CURRENCY) {
            // Format the currency field
            // Try to cast the field value to Decimal
try {
    Decimal d = (Decimal)oemFieldSet.get(objMDT.Field_API__c);
    String s = formatCurrency(d);
    offerList=offerList.replaceALL(objMDT.Variable_Name__c, s);
} catch (Exception e) {
    System.debug('Error when formatting currency: ' + e.getMessage());
}
        } else if (objMDT.Field_API__c.contains('APR') || objMDT.Field_API__c.contains('Factor')) {
                // Treat the field as a percentage field
                try {
                    Decimal d = (Decimal)oemFieldSet.get(objMDT.Field_API__c);
                    String p = d.format();
                    offerList=offerList.replaceALL(objMDT.Variable_Name__c, p);
                } catch (Exception e) {
                    System.debug('Error when formatting percentage: ' + e.getMessage());
                }






        } else{
            offerList=offerList.replaceALL(objMDT.Variable_Name__c, String.valueOf(oemFieldSet.get(objMDT.Field_API__c)));
        }

        }
        if(offers.contains(objMDT.Variable_Name__c) && mapOfOfferFields.containsKey(objMDT.Field_API__c)){
            If(objMDT.Variable_Name__c.contains('DATE_NAME')){
            DateTime mydate = Date.valueOf(mapOfOfferFields.get(objMDT.Field_API__c));
            String formattedDate = String.valueOf(mydate.formatGmt('MMMM d, yyyy'));
            offerList=offerList.replaceALL(objMDT.Variable_Name__c, formattedDate);

            }
            else{
            //offerList=offerList.replaceALL(objMDT.Variable_Name__c, String.valueOf(mapOfOfferFields.get(objMDT.Field_API__c)));
            // Get the field's describe result
            Schema.DescribeFieldResult dfrOffers = fieldMapOffers.get(objMDT.Field_API__c).getDescribe();

            // Check if the field is a currency field
            if (dfrOffers.getType() == Schema.DisplayType.CURRENCY) {
                // Format the currency field
                // Try to cast the field value to Decimal
try {
    Decimal d = (Decimal)mapOfOfferFields.get(objMDT.Field_API__c);
    String s = formatCurrency(d);
    offerList=offerList.replaceALL(objMDT.Variable_Name__c, s);
} catch (Exception e) {
    System.debug('Error when formatting currency: ' + e.getMessage());
}
            } else if (objMDT.Field_API__c.contains('APR') || objMDT.Field_API__c.contains('Factor')) {
                // Treat the field as a percentage field
                try {
                    Decimal d = (Decimal)mapOfOfferFields.get(objMDT.Field_API__c);
                    String p = d.format();
                    offerList=offerList.replaceALL(objMDT.Variable_Name__c, p);
                } catch (Exception e) {
                    System.debug('Error when formatting percentage: ' + e.getMessage());
                }

            }
            else {
                offerList=offerList.replaceALL(objMDT.Variable_Name__c, String.valueOf(mapOfOfferFields.get(objMDT.Field_API__c)));
            }
        
        }
        }
    }
    
    mapOfOEMfinalList.put(objOEM.Id,offerList.split('Split'));
    System.debug('mapOfOEMfinalList==>>'+mapOfOEMfinalList);
    mapOfDefaultImage.put(objOEM.Id,objOEM.Default_Image__c);
    
    Offer_Eligible_Models__c newBoilerplate = updateModel(objOEM.Id, offerList);
    newBoilerPlateDataMap.put(objOEM.Id, newBoilerplate);
    
    
}
System.debug('map'+JSON.serializepretty(mapOfOEMfinalList));
List<WrapperClass> wcList = new List<WrapperClass>();

for(Id key:newBoilerPlateDataMap.keySet()){

WrapperClass wc = new WrapperClass();

if(newBoilerPlateDataMap.get(key) != null)
{
System.debug('NewBoilerPlateDataMap.get(key)====>>>>>>'+newBoilerPlateDataMap.get(key));
System.debug('NewBoilerPlateDataMap.keySet()====>>>>>>'+newBoilerPlateDataMap.keySet());
Offer_Eligible_Models__c oemDetails = newBoilerPlateDataMap.get(key);
if(oemDetails.Offer_Title__c!=null){
wc.OfferTitle = oemDetails.Offer_Title__c;
}

if(oemDetails.Short_Description__c!=null){
wc.ShortDescription = oemDetails.Short_Description__c;
}

if(oemDetails.Legal_Desclaimer__c!=null){
wc.LegalDesclaimer = oemDetails.Legal_Desclaimer__c;
}

if(oemDetails.Detailed_Description__c!=null){
wc.DetailedDescription = oemDetails.Detailed_Description__c; 
}
if(oemDetails.Terms_and_Conditions__c!=null){
wc.termsAndConditions = oemDetails.Terms_and_Conditions__c;
}


}

wc.checkCriteria = 'true';
wc.defaultImage = mapOfDefaultImage.get(key);
system.debug('boilerPlateCheck-->>'+boilerPlateCheck);
wc.boilerPlateCheckwp=boilerPlateCheck;
wc.oemId =key;
// wc.SdisableMarkAsPreviewed=SdisableMarkAsPreviewed;
wcList.add(wc);

}


System.debug('wclist ==>>'+wcList);
return JSON.serialize(wcList);
    
}



public static Offer_Eligible_Models__c updateModel(String modelId, String offer) {

System.debug('offer-->>'+offer);
String offerTitle = offer.substringBetween('offerTitle'); //Title
System.debug('offerTitle-->>' + offerTitle);
String shortDescription = offer.substringBetween('shortDescription'); //Short Description
System.debug('ShortDescription-->>' + shortDescription);
String legalDesclaimer = offer.substringBetween('legalDesclaimer'); //Legal Desclaimer  
System.debug('legalDesclaimer-->>' + legalDesclaimer);
String detailedDescription = offer.substringBetween('detailedDescription'); //Details Description
System.debug('detailedDescription-->>' + detailedDescription);
String termsAndConditions = offer.substringBetween('termAndCondapex'); // Terms And Conditions
System.debug('termsAndConditions -->>'+termsAndConditions);


Offer_Eligible_Models__c mod = new Offer_Eligible_Models__c();
mod.Id = modelId;
mod.Offer_Title__c = offerTitle;
mod.Short_Description__c = shortDescription;
mod.Legal_Desclaimer__c = legalDesclaimer;
mod.Detailed_Description__c = detailedDescription;
mod.Terms_and_Conditions__c = termsAndConditions;
System.debug('modelList====>>>>'+mod);
return mod;
}



// @AuraEnabled
//     public static void validateRecord(String recordTypeId, String specialCategory, Decimal offerAmount) {
//         List<String> validRecordTypes = new List<String>{'CPO_Special_Program', 'New_Special_Program'};
//         List<RecordType> recordTypes = [
//             SELECT Id, DeveloperName
//             FROM RecordType
//             WHERE SObjectType = 'Offers__c'
//             AND DeveloperName IN :validRecordTypes
//         ];
//         Set<Id> validRecordTypeIds = new Set<Id>();
//         for (RecordType rt : recordTypes) {
//             validRecordTypeIds.add(rt.Id);
//         }
//         if (validRecordTypeIds.contains(recordTypeId) && specialCategory != 'No Cash Offer' && offerAmount == null) {
//             throw new AuraHandledException('Please fill in the Offer Amount when Special Category is not "No Cash Offer".');
//         }
//     }

public static String replaceNewlinesWithBrTags(String str) {
    return str.replaceAll('(\\r\\n|\\r|\\n)', '<br/>');
}

    @AuraEnabled
    public static void validateRecord(String recordId) {
        Offers__c record = [
            SELECT Id, RecordTypeId, Special_Category__c, Offer_Amount__c
            FROM Offers__c
            WHERE Id = :recordId
        ];
        List<String> validRecordTypes = new List<String>{'CPO_Special_Program', 'New_Special_Program'};
        List<RecordType> recordTypes = [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE SObjectType = 'Offers__c'
            AND DeveloperName IN :validRecordTypes
        ];
        Set<Id> validRecordTypeIds = new Set<Id>();
        for (RecordType rt : recordTypes) {
            validRecordTypeIds.add(rt.Id);
        }
        if (validRecordTypeIds.contains(record.RecordTypeId) && record.Special_Category__c != 'No Cash Offer' && record.Offer_Amount__c == null) {
            throw new AuraHandledException('Please fill in the Offer Amount when Special Category is not "No Cash Offer".');
        }
    }






    public static String formatCurrency(Decimal d) {
        String s = d.format();
        Integer decimalIndex = s.indexOf('.');
         if (decimalIndex == -1) {
             // If there's no decimal point, add one with two zeros
             s += '.00';
         } else 
        if (decimalIndex == s.length() - 2) {
            // If there's only one digit after the decimal point, add a zero
            s += '0';
        }
        return s;
    }
    

@AuraEnabled
public static string updatepreview(String recordID){

String recordIDnew =recordID.replaceAll('"','');

List<Offers__c> offerList = [Select Id,Preview__c from Offers__c where id=:recordIDnew];


offerList[0].Preview__c=true;

update offerList[0];

return recordIDnew;


}

@AuraEnabled
public static string updateOfferRecord(List<Offers__c> offList){
String result;

List<Offers__c> offListNew = offList;
System.debug('inside preview offer 2');

for(Offers__c offitem : offListNew){

offitem.Preview__c=true;
offListNew.add(offitem);

}

update offList;

return result;
}


@AuraEnabled
public static String updateOemRecord(List<Offer_Eligible_Models__c> oemList) {
String result = 'true';
List<Offer_Eligible_Models__c> oemListNew = new List<Offer_Eligible_Models__c>();
System.debug('inside updateOemRecord');
for (Offer_Eligible_Models__c oemitem : oemList) {
oemitem.Id = oemitem.Id;
oemitem.Offer_Title__c = oemitem.Offer_Title__c;
oemitem.Short_Description__c = oemitem.Short_Description__c;
oemitem.Detailed_Description__c = oemitem.Detailed_Description__c;
oemitem.Legal_Desclaimer__c = oemitem.Legal_Desclaimer__c;
oemitem.Terms_and_Conditions__c = oemitem.Terms_and_Conditions__c;
oemListNew.add(oemitem);
}
update oemListNew;
return result;
}

@AuraEnabled
public static String getRecordTYPE(String recordId){
List<Offers__c> offerList = [Select Id,Name,recordTypeId,recordType.Name from Offers__c where Id=:recordId];
String recordTypeName;
System.debug('offerList---->> inside ----->getRecordTYPE --->'+ offerList);
if(offerList.size() > 0){
recordTypeName = offerList[0].recordType.Name;
System.debug('recordTypeName=>'+recordTypeName);
}
return recordTypeName;
}


@AuraEnabled
public static Boolean controlOkMarkAsPreviewButtonVisibility(String recordId){
List<Offers__c> offerList = [Select Id,Name,Preview__c,Status__c from Offers__c where Id=:recordId];
Boolean disableMarkasPreviewedbtn =false;
System.debug('offerList---->> inside ----->getRecordTYPE --->'+ offerList);
if(offerList.size() > 0){
If(offerList[0].Status__c != 'WIP' || offerList[0].Preview__c==true){
    disableMarkasPreviewedbtn =true;
}
System.debug('disableMarkasPreviewedbtn=>'+disableMarkasPreviewedbtn);
}
return disableMarkasPreviewedbtn;
}

@AuraEnabled
public static List<String> getPreviewControl(Id recordId){
List<String> outputList =new List<String>();
if(recordId ==null){
return outputList;
}

Offers__c offer = getOfferRecord(recordId);
if(offer ==null){
return outputList;
}

List<Offer_Eligible_Models__c> offEligibleModelsList = getOfferEligibleModels(recordId);


outputList = determinePreviewControl(offer, offEligibleModelsList);
return outputList;
}


@AuraEnabled
public static Offers__c getOfferDate(Id recordId) {
return [SELECT Id, format(Advertised_Start_Date__c), format(Advertised_End_Date__c), format(Start_Date__c), format(End_Date__c)
        FROM Offers__c
        WHERE Id = :recordId
        LIMIT 1]; 
}


private static Offers__c getOfferRecord(Id recordId){

return [
    select Id,RecordType.Name,Boilerplate__c
    from Offers__c
    where Id=:recordId
];
}



private static List<Offer_Eligible_Models__c> getOfferEligibleModels(Id recordId){

return [
select Id,Include_Sample_Payment__c,Featured_Offer__c,Offer__c,Is_Calculation_Done__c from Offer_Eligible_Models__c where Offer__c=:recordId
];

}

private static Integer getOfferEligibleModelsRecordCount(Id recordId){

Integer OemRecordCount =[
    select count() from Offer_Eligible_Models__c where Offer__c=:recordId];
return OemRecordCount;
}

private static List<String> determinePreviewControl(Offers__c offer,List<Offer_Eligible_Models__c> OffEligibleModelsList){


Integer OemRecordCount =getOfferEligibleModelsRecordCount(offer.Id);
String previewControl ='';
Boolean containsLease = offer.RecordType.Name.contains('Lease');
system.debug('### is Lease='+containsLease);
system.debug('### is Lease='+offer.RecordType.Name);
system.debug('### is Lease='+offer.Boilerplate__c);
// Boolean containsBoilerplate;
List<String> outputList = new List<String>();
if(offer.Boilerplate__c==null){
    previewControl='stopPreviewBoilerPlateError';
    outputList.add(previewControl);
    System.debug('previewControl==>>'+previewControl);
}
if(OemRecordCount<=0)
{
    previewControl='stopPreviewEligibleModelAssociateError';
    outputList.add(previewControl);
}
system.debug('### previewControl 1='+previewControl);
system.debug('### !containsLease 1='+!containsLease);
Boolean featureModelExists=false;
if(!containsLease){
    
    for(Offer_Eligible_Models__c model : offEligibleModelsList){

        if(model.Featured_Offer__c==true) {

            // previewControl='showOtherOffersPreview';
            //outputList.add(previewControl);
            //System.debug('====>showOtherOffersPreview'+previewControl);
            featureModelExists = true;
            break;
        } /*
        else{
                previewControl='stopPreviewIncSamPayOrFeaturedError';
                outputList.add(previewControl);
                System.debug('====>stopPreviewIncSamPayOrFeaturedError'+previewControl);
                break;
            }  */
        }
        if(featureModelExists) 
        {   
            previewControl='showOtherOffersPreview';
            outputList.add(previewControl);
            System.debug('====>showOtherOffersPreview'+previewControl);
        }
        else{
            previewControl='stopPreviewIncSamPayOrFeaturedError';
            outputList.add(previewControl);
            System.debug('====>stopPreviewIncSamPayOrFeaturedError'+previewControl);
        }
            system.debug('### previewControl 2='+previewControl); 
    
} else {

    Integer LeasePreviewCount =[
    select count() 
    from Offer_Eligible_Models__c 
    where Offer__c =:offer.id
    and Include_Sample_Payment__c=true
    and Featured_Offer__c=true
    ];
    system.debug('### previewControl 3='+previewControl);
    if(LeasePreviewCount>0){
        previewControl='showLeasePreview';
        outputList.add(previewControl);
    } else{
        previewControl='stopPreviewLeasePreview';
        outputList.add(previewControl);
    }
    for(Offer_Eligible_Models__c model : offEligibleModelsList){
        if(model.Include_Sample_Payment__c == true && model.Is_Calculation_Done__c != true){
            previewControl='stopPreviewApplyAllClearAllEditCashElementError';
            outputList.add(previewControl);
        }
        
    }
}

return outputList;
}




public class WrapperClass{
@AuraEnabled
public String  OfferTitle{get;set;}
@AuraEnabled
public String  ShortDescription{get;set;}
@AuraEnabled
public String  LegalDesclaimer{get;set;}
@AuraEnabled
public String  DetailedDescription{get;set;}
@AuraEnabled
public String  TermsAndConditions{get;set;}
@AuraEnabled
public String  checkCriteria{get;set;}
@AuraEnabled
public String defaultImage{get;set;}
@AuraEnabled
public String boilerPlateCheckwp{get;set;}
@AuraEnabled
public String oemId{get;set;}
@AuraEnabled
public String SdisableMarkAsPreviewed{get;set;}


}

}