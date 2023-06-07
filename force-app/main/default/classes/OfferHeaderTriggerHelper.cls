public class OfferHeaderTriggerHelper {
/****************************************************************************
* Description: Preventing duplicate values and Updating Offer Identifier
* Name: Siva T
* ***************************************************************************/
    public void preventDuplicateRecords(List<Offer_Header__c> lstOfferHeaderNew) {
        set<string> filenames = new set<string>();
        Map<String, Offer_Header__c> fileRecordMap = new Map<String, Offer_Header__c>();

        for(Offer_Header__c offheader:lstOfferHeaderNew){
            filenames.add(offheader.Name);
            fileRecordMap.put(offheader.Name, offheader);
        }
        List<Offer_Header__c>  lstheader = [select id,name from Offer_Header__c where name IN:filenames];
        if(lstheader.size()>0){
            //iterate through duplicate name
            for(Offer_Header__c rec: lstheader)
            {
                Offer_Header__c recInstance = new Offer_Header__c();
                recInstance = fileRecordMap.get(rec.name);
                recInstance.Adderror('Already we have offer Header Name, Please Change Offer Name');
            }      
        }
    }
    

}