//****************************************************************************** 
// File Name:       EshoppingExpiredRequest.cls
// Summary:         This is request class for Expired status to sync with Outbound
// Created On:      14-04-2023
// Created By:      Manohar 
// Test Classes:   
// Data I/O:        
// Honda Jira Story: 
//*******************************************************************************
public  class EshoppingExpiredRequest {
   
    /**********************************************************************************
     * Purpose : This method is responsible to prepare request for Expired offer and to integrate with outboubd
     * InPut : String offer Id, string offerStatus,string recType
     * OutPut : void 
     *********************************************************************************/
    public static void processRequest(string offerId,string offerStatus,string recType)
    {
        if(OfferId !=null && recType !=null)
        {
            Offers__c offer = [select id,offer_header__c from offers__c where Id=:offerId];
            
            string requestJSON;
            HTTPResponse response;
            if(recType == OfferMgmtConstants.STANDARDSPECIALS_INTEGRATION) //standard specials
            {
                EshoppingExpiredRequestWrapper requestWrapper = new EshoppingExpiredRequestWrapper();
                EshoppingExpiredRequestWrapper.cls_StandardSpecial stdSpecial = new EshoppingExpiredRequestWrapper.cls_StandardSpecial();
                stdSpecial.StandardSpecialId = offer.offer_header__c;
                stdSpecial.Action ='Delete';
                requestWrapper.StandardSpecial = stdSpecial;
                requestJSON = JSON.serialize(requestWrapper);
                system.debug('Standard Special Request JSON:'+requestJSON);
                response = OfferOutboundService.makeCallout(requestJSON,OfferId,offerStatus,'EshoppingExpiredRequest',OfferMgmtConstants.STANDARDSPECIALS_INTEGRATION);
            }
            else   if(recType == OfferMgmtConstants.SPECIALS_INTEGRATION)//speecials
            {
                EshoppingExpiredSpecialRequestWrapper requestWrapper = new EshoppingExpiredSpecialRequestWrapper();   
                EshoppingExpiredSpecialRequestWrapper.cls_Special Special = new EshoppingExpiredSpecialRequestWrapper.cls_Special();
                Special.SpecialId = offer.offer_header__c;
                Special.Action ='Delete';
                requestWrapper.Specials = Special; 
                requestJSON = JSON.serialize(requestWrapper);
                system.debug('Special Request JSON:'+requestJSON); 
                response = OfferOutboundService.makeCallout(requestJSON,OfferId,offerStatus,'EshoppingExpiredRequest',OfferMgmtConstants.SPECIALS_INTEGRATION);
                
            }
            if(response !=null)//update offer record based on response.
            {
                OfferOutboundService.updateOffer(offerId,offerStatus,response);
            }
        }
    }
}