public class ownConsumerApiController {
    @AuraEnabled (cacheable = false)
    public static Map<String,Map<String,ConsumerPreference>> getConsumerPreferenceByEmail(){
        Map<String,Map<String,ConsumerPreference>> ConsumerPreferenceresultmap;
        String response='';
        /*HttpRequest req = new HttpRequest();
HttpResponse res =new HttpResponse();
req.setEndpoint('https://ws-qa2.hondaweb.com/ECRM/PreferenceCenter/');
req.setMethod('POST');
req.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://www.honda.com/header" xmlns:pref="http://PreferenceCenterMessage">\n'+
'<soapenv:Header>\n'+
'<head:hondaMsgHeader>\n'+
'<head:messageId>207e19bb-189b-4079-b6e2-0ef259bed267</head:messageId>\n'+
'<head:siteId>7a075db5b4b04c04afdc0b75fc135a80</head:siteId>\n'+
'<head:businessId>HONDALINK CONNECT</head:businessId>\n'+
'<head:collectedTimestamp>2020-11-30T09:55:29+00:00</head:collectedTimestamp>\n'+
'</head:hondaMsgHeader>\n'+
'</soapenv:Header>\n'+
'<soapenv:Body>\n'+
'<pref:ConsumerPrefReq>\n'+
'<pref:Email>BAILEY.CRYSTAL1902@YAHOO.COM</pref:Email>\n'+
'<pref:BusinessEntity>Powersports</pref:BusinessEntity>\n'+
'<pref:BusinessEntity>Honda</pref:BusinessEntity>\n'+
'<pref:BusinessEntity>Acura</pref:BusinessEntity>\n'+
'<pref:BusinessEntity>Power Equipment</pref:BusinessEntity>\n'+
'<pref:BusinessEntity>Marine</pref:BusinessEntity>\n'+
'</pref:ConsumerPrefReq>\n'+
'</soapenv:Body>\n'+
'</soapenv:Envelope>');
req.setHeader('Authorization', 'Basic c2VydmljZV9vd25lcnNfYjJjX3FhOkZlZXQkNzcx');
Http http =new Http();*/
        List<String> endpointParameters = new List<String>();
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'P';
        attribute.email = UserInfo.getUserEmail();
        // attribute.environment =  w.getXmlString();
        OwnHttpCalloutService service = new OwnHttpCalloutService('getConsumerPreference', attribute, endpointParameters);
        try{
            // res = http.send(req);
            //     System.debug('response'+res.getBody());
            //response=res.getBody();
            response = service.sendRequest().getBody();
            ConsumerPreferenceresultmap =new Map<String,Map<String,ConsumerPreference>>();
            //   resultmap=new Map<String,Map<String,List<ConsumerInterest>>>(); 
            Dom.Document doc= new Dom.Document();
            doc.load(response);
            List<ConsumerPreference> prefList =new List<ConsumerPreference>();
            for(Dom.XmlNode node: doc.getRootElement().getChildElements()){
                system.debug('node:'+node.getName());
                if(node.getName() == 'Body'){
                    for(Dom.XmlNode ConsumerPref: node.getChildElements()){
                        system.debug('node:'+ConsumerPref.getName());
                        if(ConsumerPref.getName() == 'ConsumerPrefResp'){
                            for(Dom.XmlNode innerConsumerPref: ConsumerPref.getChildElements()){
                                system.debug('node:'+innerConsumerPref.getName());
                                ConsumerPreference pref=new ConsumerPreference(innerConsumerPref);
                                prefList.add(pref);
                            }
                        }
                    } 
                }
                for(ConsumerPreference pf: prefList){
                    if(!ConsumerPreferenceresultmap.containsKey(pf.CategoryName)){
                        Map<String,ConsumerPreference> consumerPreferenceMap = new Map<String,ConsumerPreference>();
                        consumerPreferenceMap.put(pf.BusinessEntity,pf);
                        ConsumerPreferenceresultmap.put(pf.CategoryName,consumerPreferenceMap);
                    }else{
                        Map<String,ConsumerPreference> consumerPreferenceMap =ConsumerPreferenceresultmap.get(pf.CategoryName);
                        List<ConsumerInterest> cinterest=new List<ConsumerInterest>();
                        consumerPreferenceMap.put(pf.BusinessEntity,pf);
                        ConsumerPreferenceresultmap.put(pf.CategoryName,consumerPreferenceMap);
                    }
                    
                }
            }
            
        }catch(Exception e){
            system.debug('error'+e);
        }
        return ConsumerPreferenceresultmap;
    }
    
    
    
    public class ConsumerPreference{
        @AuraEnabled public String InterestID;
        @AuraEnabled public String BusinessEntity;
        @AuraEnabled public String CategoryName;
        @AuraEnabled public boolean isConsumerInterestPresent;
        @AuraEnabled public boolean DefaultValue;
        @AuraEnabled public boolean OptInFlag;
        @AuraEnabled public List<ConsumerInterest> consumerInterest;
        public ConsumerPreference(Dom.XmlNode inNode){
            isConsumerInterestPresent=false;
            consumerInterest =new List<ConsumerInterest>();
            for(Dom.XmlNode innerNode: inNode.getChildElements()){
                if(innerNode.getName() == 'InterestID'){
                    InterestID = String.valueOf(innerNode.gettext());
                }
                if(innerNode.getName() == 'BusinessEntity'){
                    BusinessEntity =String.valueOf(innerNode.gettext());
                }
                if(innerNode.getName() == 'CategoryName'){
                    CategoryName = String.valueOf(innerNode.gettext());
                }
                if(innerNode.getName() == 'DefaultValue'){
                    if(String.valueOf(innerNode.gettext()) == 'Y'){
                        DefaultValue = true;
                    }else{
                        DefaultValue = false;   
                    }
                }
                if(innerNode.getName() == 'OptInFlag'){
                    if(String.valueOf(innerNode.gettext()).trim() == 'Y'){
                        OptInFlag = true;
                    }else{
                        OptInFlag = false;   
                    }
                    
                }
                if(innerNode.getName() == 'ConsumerInterest'){
                    ConsumerInterest ci=new ConsumerInterest(innerNode);
                    if(!(CategoryName == 'Events' && ci.InterestName.contains('20')))
                    {
                    consumerInterest.add(ci);
                    isConsumerInterestPresent=true;
                    }
                }
                
            } 
        }
    }
    
    public class ConsumerInterest{
        @AuraEnabled public String InterestID;
        @AuraEnabled public String InterestName;
        @AuraEnabled public boolean DefaultValue;
        @AuraEnabled public boolean OptInFlag;
        public ConsumerInterest(Dom.XmlNode innerNode){
            for(Dom.XmlNode inNode: innerNode.getChildElements()){
                if(inNode.getName() == 'InterestID'){
                    InterestID = String.valueOf(inNode.gettext());
                }
                if(inNode.getName() == 'InterestName'){
                    InterestName =String.valueOf(inNode.gettext());
                }
                if(inNode.getName() == 'DefaultValue'){
                    if(String.valueOf(inNode.gettext()) == 'Y'){
                        DefaultValue = true;
                    }else{
                        DefaultValue = false;   
                    }
                }
                if(inNode.getName() == 'OptInFlag'){
                    if(String.valueOf(inNode.gettext()) == 'Y'){
                        OptInFlag = true;
                    }else{
                        OptInFlag = false;   
                    }
                }
            }
        }
        
        
    }
    @AuraEnabled (cacheable = true)
    public static String saveConsumerPreferenceByEmail(List<String> selectedItems,List<String> unSelectedItems){
        String response;
        try{
            xmlStreamWriter w = new xmlStreamWriter();
            for(String s:selectedItems){
                w.writeStartElement(null,'pref:Preference',null);
                w.writeStartElement(null,'pref:InterestID',null);
                w.writeCharacters(s);
                w.writeEndElement();
                w.writeStartElement(null,'pref:OptInFlag',null);
                w.writeCharacters('Y');
                w.writeEndElement();
                w.writeEndElement();
            }
            for(String s:unSelectedItems){
                w.writeStartElement(null,'pref:Preference',null);
                w.writeStartElement(null,'pref:InterestID',null);
                w.writeCharacters(s);
                w.writeEndElement();
                w.writeStartElement(null,'pref:OptInFlag',null);
                w.writeCharacters('N');
                w.writeEndElement();
                w.writeEndElement();
            }
            List<String> endpointParameters = new List<String>();
            OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
            attribute.divisionId = 'P';
            attribute.email = UserInfo.getUserEmail();
            attribute.environment =  w.getXmlString();
            OwnHttpCalloutService service = new OwnHttpCalloutService('saveConsumerPreference', attribute, endpointParameters);
            response = service.sendRequest().getBody();
        }catch(Exception ex){
            system.debug('@@Exception'+ex);
        }
        return response;
    }
    
    @AuraEnabled(cacheable = true)
    public static  Map<String,String> getTimeZome(){
        Map<String,String> timezoneMap=new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = User.TimeZoneSidKey.getdescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
        {
            timezoneMap.put(p.getlabel(),p.getValue());            
        }
        return timezoneMap;
    }
    
    @AuraEnabled(cacheable = true)
    public static  List<OwnCommunicationPreference__mdt> getCommunicationPreference(){
        List<OwnCommunicationPreference__mdt> pref=[select Title__c,MasterLabel,ShortForm__c,ShowData__c,SortOrder__c from OwnCommunicationPreference__mdt where ShowData__c = true order by SortOrder__c asc];
        return pref;
    }
    
}