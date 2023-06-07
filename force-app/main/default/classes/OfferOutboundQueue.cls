//****************************************************************************** 
// File Name:       OfferOutboundQueue.cls
// Summary:         Apex Class for to transfer offer records from salesforce to Eshoppy through outbound integration.
// Created On:      02-25-2023
// Created By:      Rama Iyer
// Test Classes:    
// JIRA Story :     
//===============================================================================
public class OfferOutboundQueue implements Queueable,Database.AllowsCallouts {
    
    private List<Offers__c> lstOffers;//holds the offers from trigger context
    private map<Id,string> mapOfferRecType;//key - Id, value - developername
    private set<string> setFinanceRecTypeNames=new set<string>{'CPO_Standard_Finance','CPO_Standard_Lease','New_Standard_Finance','New_Standard_Lease','Power_Sports_AHFC',
        													   'Power_Sports_Bonus_Bucks','Power_Sports_Generic',
        														'Power_Sports_Honda_Card','CPO_Special_Program','New_Special_Program'};
    private set<string> setSpecialRecTypeNames= new set<string>{'New_Special_Finance','CPO_Special_Finance','CPO_Special_Lease','New_Special_Lease'};
    
    /*Constructor - Initiates the local variables from trigger context*/
    public OfferOutboundQueue(List<Offers__c> offerList)
    {
        this.lstOffers = offerList;
        mapOfferRecType = GetOfferRecordTypesUtility.getOfferRecordTypeNames();
    }
    /*Execute method is responsible to check offer records and call the respective outbound API based on status and record type*/
    public void execute(QueueableContext queCont) {
        
        for(Offers__c offerRec:lstOffers){
           //if(offerRec.status__c=='Submitted'||offerRec.status__c=='Approved'||offerRec.status__c=='Expired' ||offerRec.status__c=='Active')
           if(offerRec.status__c=='Submitted'||offerRec.status__c=='Approved'||offerRec.status__c=='Active') 
           {
               if(setFinanceRecTypeNames.contains((string)mapOfferRecType.get(offerRec.RecordTypeId)))
               {
                   EshoppyOutboundRequest.sendOutboundEshoppyReq(offerRec.Id,offerRec.status__c);
               }
               else if(setSpecialRecTypeNames.contains((string)mapOfferRecType.get(offerRec.RecordTypeId)))
               {
                    if(offerRec.Sales_Program_CD__c != null)
                        {
                            EshoppyOutboundSpecialRequest.sendOutboundSpecialEshoppyReq(offerRec.Id,offerRec.status__c);
                        }
                        else
                        {
                            EshoppyOutboundRequest.sendOutboundEshoppyReq(offerRec.Id,offerRec.status__c);
                        }
               }           
           } 
           else if(offerRec.status__c=='Expired') 
           {
            
            if(setFinanceRecTypeNames.contains((string)mapOfferRecType.get(offerRec.RecordTypeId)))
            {
                EshoppingExpiredRequest.processRequest(offerRec.Id,offerRec.status__c,OfferMgmtConstants.STANDARDSPECIALS_INTEGRATION);
            }
            else if(setSpecialRecTypeNames.contains((string)mapOfferRecType.get(offerRec.RecordTypeId)))
            {
                if(offerRec.Sales_Program_CD__c != null)
                {
                    EshoppingExpiredRequest.processRequest(offerRec.Id,offerRec.status__c,OfferMgmtConstants.SPECIALS_INTEGRATION);

                }
                else
                {
                    EshoppingExpiredRequest.processRequest(offerRec.Id,offerRec.status__c,OfferMgmtConstants.STANDARDSPECIALS_INTEGRATION);
                }
            }           

           }     
           
        }
    }
}