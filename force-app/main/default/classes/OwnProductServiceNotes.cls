public without sharing class OwnProductServiceNotes {

    @AuraEnabled(cacheable = false)
    public static List<Product_Service_Note__c> getServiceNotes(String ownerShip){
        try {
            List<Product_Service_Note__c> retList = [
            SELECT Ownership__c, Service_Date__c, Usage__c, Location__c, Note__c, Name, Oil_Change__c, Scheduled_Maintenance__c, 
            Brakes__c, Tire_Rotation__c, Alignment__c, Multi_Point_Inspection__c, Other__c, Total_Cost__c, Others__c,
            Tune_Up_Packages__c, Tires__c, Repairs__c, Full_Service__c, End_of_Season_Maintenance__c, Battery__c, Operating_Hours__c
            FROM Product_Service_Note__c
            WHERE Ownership__c = :ownerShip
            ORDER BY Service_Date__c DESC            
            ];

            if(!retList.IsEmpty())
            {
                return retList;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* @AuraEnabled(cacheable = true)
    public static List<API_Product_Service_Note> getServiceRecordVIN_Acura(String vin){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://ws-qa2.hondaweb.com/REST/EVRM/1.0/getDetailsById');
        req.setMethod('GET');
        
        req.setHeader('Authorization', 'Basic c2VydmljZV9ldnJtX2IyY19xYTpMaW5lbkA0Mw==');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('hondaHeaderType.messageId','207e19bb-189b-4079-b6e2-0ef259bed267');
        req.setHeader('hondaHeaderType.siteId','00e0e97f0fb543208a918fc946dea334');
        req.setHeader('hondaHeaderType.businessId','ACURALINK CONNECT');
        req.setHeader('hondaHeaderType.systemId','com.honda.hondalink.cv_web');
        //req.setHeader('hondaHeaderType.collectedTimestamp','2012-01-01T14:02:41.548-05:00'); //Add a param to input time
        req.setHeader('input', '{\"VIN\":\"'+vin+'\",\"DATASOURCE\":\"RepairOrders\"}');//Add a param to input VIN
     
        Http http = new Http();
        HTTPResponse res = http.send(req);
        //System.debug(res.getBody());

    
        JSONParser parser = JSON.createParser(res.getBody());
        List<API_Product_Service_Note> apiServiceNotes = new List<API_Product_Service_Note>();
        API_Product_Service_Note note = new API_Product_Service_Note();
        String repairOrderNumHolder;

        List<Service_Job> jobList = new List<Service_Job>();
        Service_Job curJob = new Service_Job();
        Integer jobCount = 0;

        while (parser.nextToken() != null) {
            if(String.isNotEmpty(note.apiName)){
                apiServiceNotes.add(note);
                system.debug('Added ' + note + ' to api service notes ' +apiServiceNotes);
                note = new API_Product_Service_Note();
                note.servicePerformed = '';
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'cproNum')) {
                    system.debug('In parser');
                    
                    parser.nextToken();
                    repairOrderNumHolder = parser.getText();

                    
                    jobCount = 0;

                    while (parser.getText() != 'cproNum') {
                        note.apiName = repairOrderNumHolder;
                        note.Id = repairOrderNumHolder;
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'dlr_nm')) {
                                parser.nextToken();
                                note.serviceFacility = parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'city_nm')) {
                                parser.nextToken();
                                note.serviceFacility += ', ';
                                note.serviceFacility += parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'ro_complete_dt')) {
                                parser.nextToken();
                                note.recordDate = parser.getText();

                                system.debug('Date ' + note.recordDate);
                                note.Service_DateTempc = Date.parse(note.recordDate);

                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'ro_invoice_dt')) {
                                parser.nextToken();
                                note.recordDate = parser.getText();

                                system.debug('Date ' + note.recordDate);
                                if(String.isNotBlank(note.recordDate)){
                                note.Service_DateTempc = Date.parse(note.recordDate);}

                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'prod_div_nm')) {
                                parser.nextToken();
                                note.productDivision = parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'mileage_out')) {
                                parser.nextToken();
                                note.Mileage = parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'op_nm')) {
                                parser.nextToken();
                                if (jobCount != 0){
                                    jobList.add(curJob);
                                    system.debug('Adding ' + curJob);
                                }
                                jobCount += 1;
                                curJob = new Service_Job();
                                
                                if (jobCount < 10) {
                                    curJob.Job = '0' + String.valueOf(jobCount);
                                }
                                else{
                                    curJob.Job = String.valueOf(jobCount);
                                }
                                

                                if (String.isEmpty(note.servicePerformed) || String.isBlank(note.servicePerformed)) {
                                    note.servicePerformed += parser.getText();

                                    curJob.Service = parser.getText();
                                }
                                else {
                                    note.servicePerformed += ', ';
                                    note.servicePerformed += parser.getText();

                                    curJob.Service = parser.getText();
                                }
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'corr_desc')) {
                                parser.nextToken();
                                curJob.Description = parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'part_no')) {
                                parser.nextToken();
                                
                                if (String.isEmpty(curJob.partNumbers) || String.isBlank(curJob.partNumbers)) {
                                    curJob.partNumbers += parser.getText();
                                }
                                else {
                                    curJob.partNumbers += ' | ';
                                    curJob.partNumbers += parser.getText();
                                }

                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'part_desc')) {
                                parser.nextToken();
                                
                                if (String.isEmpty(curJob.partNames) || String.isBlank(curJob.partNames)) {
                                    curJob.partNames += parser.getText();
                                }
                                else {
                                    curJob.partNames += ' | ';
                                    curJob.partNames += parser.getText();
                                }

                            }
                        parser.nextToken();
                    }

                    if (jobCount != 0){
                        jobList.add(curJob);
                        system.debug('Adding ' + curJob);
                        jobCount = 0;
                    }
                    
                    //Add currentJobList                   
                    if (!(jobList.isEmpty())) {
                        note.serviceJobList = jobList;
                        jobList = new List<Service_Job>();
                    }

                parser.nextToken();
            }
        }
        system.debug('List of api service notes' + apiServiceNotes);
        system.debug('Service Jobs List' + jobList);
        return apiServiceNotes;
    }

    @AuraEnabled(cacheable = true)
    public static List<API_Product_Service_Note> getServiceRecordVIN_Honda(String vin){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://ws-qa2.hondaweb.com/REST/EVRM/1.0/getDetailsById');
        req.setMethod('GET');
        
        req.setHeader('Authorization', 'Basic c2VydmljZV9ldnJtX2IyY19xYTpMaW5lbkA0Mw==');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('hondaHeaderType.messageId','207e19bb-189b-4079-b6e2-0ef259bed267');
        req.setHeader('hondaHeaderType.siteId','00e0e97f0fb543208a918fc946dea334');
        req.setHeader('hondaHeaderType.businessId','HONDALINK CONNECT');
        req.setHeader('hondaHeaderType.systemId','com.honda.hondalink.cv_web');
        //req.setHeader('hondaHeaderType.collectedTimestamp','2012-01-01T14:02:41.548-05:00'); //Add a param to input time
        req.setHeader('input', '{\"VIN\":\"'+vin+'\",\"DATASOURCE\":\"RepairOrders\"}');//Add a param to input VIN

     
        Http http = new Http();
        HTTPResponse res = http.send(req);
        //System.debug(res.getBody());

        JSONParser parser = JSON.createParser(res.getBody());
        List<API_Product_Service_Note> apiServiceNotes = new List<API_Product_Service_Note>();
        API_Product_Service_Note note = new API_Product_Service_Note();
        String repairOrderNumHolder;

        List<Service_Job> jobList = new List<Service_Job>();
        Service_Job curJob = new Service_Job();
        Integer jobCount = 0;

        while (parser.nextToken() != null) {
            if(String.isNotEmpty(note.apiName)){
                apiServiceNotes.add(note);
                system.debug('Added ' + note + ' to api service notes ' +apiServiceNotes);
                note = new API_Product_Service_Note();
                note.servicePerformed = '';
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'cproNum')) {
                    system.debug('In parser');
                    
                    parser.nextToken();
                    repairOrderNumHolder = parser.getText();

                    
                    jobCount = 0;

                    while (parser.getText() != 'cproNum') {
                        note.apiName = repairOrderNumHolder;
                        note.Id = repairOrderNumHolder;
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'dlr_nm')) {
                                parser.nextToken();
                                note.serviceFacility = parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'city_nm')) {
                                parser.nextToken();
                                note.serviceFacility += ', ';
                                note.serviceFacility += parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'ro_complete_dt')) {
                                parser.nextToken();
                                note.recordDate = parser.getText();

                                system.debug('Date ' + note.recordDate);
                                note.Service_DateTempc = Date.parse(note.recordDate);

                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'ro_invoice_dt')) {
                                parser.nextToken();
                                note.recordDate = parser.getText();

                                system.debug('Date ' + note.recordDate);
                                if(String.isNotBlank(note.recordDate)){
                                note.Service_DateTempc = Date.parse(note.recordDate);}

                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'prod_div_nm')) {
                                parser.nextToken();
                                note.productDivision = parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'mileage_out')) {
                                parser.nextToken();
                                note.Mileage = parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'op_nm')) {
                                parser.nextToken();
                                if (jobCount != 0){
                                    jobList.add(curJob);
                                    system.debug('Adding ' + curJob);
                                }
                                jobCount += 1;
                                curJob = new Service_Job();
                                
                                if (jobCount < 10) {
                                    curJob.Job = '0' + String.valueOf(jobCount);
                                }
                                else{
                                    curJob.Job = String.valueOf(jobCount);
                                }

                                if (String.isEmpty(note.servicePerformed) || String.isBlank(note.servicePerformed)) {
                                    note.servicePerformed += parser.getText();

                                    curJob.Service = parser.getText();
                                }
                                else {
                                    note.servicePerformed += ', ';
                                    note.servicePerformed += parser.getText();

                                    curJob.Service = parser.getText();
                                }
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'corr_desc')) {
                                parser.nextToken();
                                curJob.Description = parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'part_no')) {
                                parser.nextToken();
                                
                                if (String.isEmpty(curJob.partNumbers) || String.isBlank(curJob.partNumbers)) {
                                    curJob.partNumbers += parser.getText();
                                }
                                else {
                                    curJob.partNumbers += ' | ';
                                    curJob.partNumbers += parser.getText();
                                }

                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'part_desc')) {
                                parser.nextToken();
                                
                                if (String.isEmpty(curJob.partNames) || String.isBlank(curJob.partNames)) {
                                    curJob.partNames += parser.getText();
                                }
                                else {
                                    curJob.partNames += ' | ';
                                    curJob.partNames += parser.getText();
                                }

                            }
                        parser.nextToken();
                    }

                    if (jobCount != 0){
                        jobList.add(curJob);
                        system.debug('Adding ' + curJob);
                        jobCount = 0;
                    }
                    
                    //Add currentJobList                   
                    if (!(jobList.isEmpty())) {
                        note.serviceJobList = jobList;
                        jobList = new List<Service_Job>();
                    }

                parser.nextToken();
            }
        }
        system.debug('List of api service notes' + apiServiceNotes);
        system.debug('Service Jobs List' + jobList);
        return apiServiceNotes;
    } */

    @AuraEnabled
    public static String  getServiceRecordVIN_Acura_ResponseBody(String vin)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://ws-qa2.hondaweb.com/REST/EVRM/1.0/getDetailsById');
        req.setMethod('GET');
        
        req.setHeader('Authorization', 'Basic c2VydmljZV9ldnJtX2IyY19xYTpMaW5lbkA0Mw==');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('hondaHeaderType.messageId','207e19bb-189b-4079-b6e2-0ef259bed267');
        req.setHeader('hondaHeaderType.siteId','00e0e97f0fb543208a918fc946dea334');
        req.setHeader('hondaHeaderType.businessId','ACURALINK CONNECT');
        req.setHeader('hondaHeaderType.systemId','com.honda.hondalink.cv_web');
        //req.setHeader('hondaHeaderType.collectedTimestamp','2012-01-01T14:02:41.548-05:00'); //Add a param to input time*/
        req.setHeader('input', '{\"VIN\":\"'+vin+'\",\"DATASOURCE\":\"RepairOrders\"}');//Add a param to input VIN
     
        Http http = new Http();
        HTTPResponse res = http.send(req);
        //System.debug(res.getBody());

        /*
        Needed Information from res.getBody()
        roDto:customerROList:dealerInfo:dlr_nm (Location)
        roDto:customerROList:dealerInfo:prod_div_nm (Brand Division)
        roDto:customerROList:cproInfo:mileage_in (Usage)
        roDto:customerROList:customerJob:codesList:corr_desc (Service)
        roDto:customerROList:

        */
        return res.getBody();
    }

    @AuraEnabled
    public static String  getServiceRecordVIN_Honda_ResponseBody(String vin)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://ws-qa2.hondaweb.com/REST/EVRM/1.0/getDetailsById');
        req.setMethod('GET');
        
        req.setHeader('Authorization', 'Basic c2VydmljZV9ldnJtX2IyY19xYTpMaW5lbkA0Mw==');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('hondaHeaderType.messageId','207e19bb-189b-4079-b6e2-0ef259bed267');
        req.setHeader('hondaHeaderType.siteId','00e0e97f0fb543208a918fc946dea334');
        req.setHeader('hondaHeaderType.businessId','HONDALINK CONNECT');
        req.setHeader('hondaHeaderType.systemId','com.honda.hondalink.cv_web');
        //req.setHeader('hondaHeaderType.collectedTimestamp','2012-01-01T14:02:41.548-05:00'); //Add a param to input time
        req.setHeader('input', '{\"VIN\":\"'+vin+'\",\"DATASOURCE\":\"RepairOrders\"}');//Add a param to input VIN

     
        Http http = new Http();
        HTTPResponse res = http.send(req);
        //System.debug(res.getBody());

        /*
        Needed Information from res.getBody()
        roDto:customerROList:dealerInfo:dlr_nm (Location)
        roDto:customerROList:dealerInfo:prod_div_nm (Brand Division)
        roDto:customerROList:cproInfo:mileage_in (Usage)
        roDto:customerROList:customerJob:codesList:corr_desc (Service)
        roDto:customerROList:

        */
        return res.getBody();
    }

   /*  @AuraEnabled
    public static List<API_Product_Service_Note> parseProductServiceNotes(String responseBody){
        
        JSONParser parser = JSON.createParser(responseBody);
        List<API_Product_Service_Note> apiServiceNotes = new List<API_Product_Service_Note>();
        API_Product_Service_Note note = new API_Product_Service_Note();
        String repairOrderNumHolder;

        List<Service_Job> jobList = new List<Service_Job>();
        Service_Job curJob = new Service_Job();
        Integer jobCount = 0;

        while (parser.nextToken() != null) {
            if(String.isNotEmpty(note.apiName)){
                apiServiceNotes.add(note);
                system.debug('Added ' + note + ' to api service notes ' +apiServiceNotes);
                note = new API_Product_Service_Note();
                note.servicePerformed = '';
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'cproNum')) {
                    system.debug('In parser');
                    
                    parser.nextToken();
                    repairOrderNumHolder = parser.getText();

                    
                    jobCount = 0;

                    while (parser.getText() != 'cproNum') {
                        note.apiName = repairOrderNumHolder;
                        note.Id = repairOrderNumHolder;
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'dlr_nm')) {
                                parser.nextToken();
                                note.serviceFacility = parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'city_nm')) {
                                parser.nextToken();
                                note.serviceFacility += ', ';
                                note.serviceFacility += parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'ro_complete_dt')) {
                                parser.nextToken();
                                note.recordDate = parser.getText();

                                system.debug('Date ' + note.recordDate);
                                note.Service_DateTempc = Date.parse(note.recordDate);

                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'ro_invoice_dt')) {
                                parser.nextToken();
                                note.recordDate = parser.getText();

                                system.debug('Date ' + note.recordDate);
                                if(String.isNotBlank(note.recordDate)){
                                note.Service_DateTempc = Date.parse(note.recordDate);}

                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'prod_div_nm')) {
                                parser.nextToken();
                                note.productDivision = parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'mileage_out')) {
                                parser.nextToken();
                                note.Mileage = parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'op_nm')) {
                                parser.nextToken();
                                if (jobCount != 0){
                                    jobList.add(curJob);
                                    system.debug('Adding ' + curJob);
                                }
                                jobCount += 1;
                                curJob = new Service_Job();
                                
                                if (jobCount < 10) {
                                    curJob.Job = '0' + String.valueOf(jobCount);
                                }
                                else{
                                    curJob.Job = String.valueOf(jobCount);
                                }

                                if (String.isEmpty(note.servicePerformed) || String.isBlank(note.servicePerformed)) {
                                    note.servicePerformed += parser.getText();

                                    curJob.Service = parser.getText();
                                }
                                else {
                                    note.servicePerformed += ', ';
                                    note.servicePerformed += parser.getText();

                                    curJob.Service = parser.getText();
                                }
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'corr_desc')) {
                                parser.nextToken();
                                curJob.Description = parser.getText();
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'part_no')) {
                                parser.nextToken();
                                
                                if (String.isEmpty(curJob.partNumbers) || String.isBlank(curJob.partNumbers)) {
                                    curJob.partNumbers += parser.getText();
                                }
                                else {
                                    curJob.partNumbers += ' | ';
                                    curJob.partNumbers += parser.getText();
                                }

                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'part_desc')) {
                                parser.nextToken();
                                
                                if (String.isEmpty(curJob.partNames) || String.isBlank(curJob.partNames)) {
                                    curJob.partNames += parser.getText();
                                }
                                else {
                                    curJob.partNames += ' | ';
                                    curJob.partNames += parser.getText();
                                }

                            }
                        parser.nextToken();
                    }

                    if (jobCount != 0){
                        jobList.add(curJob);
                        system.debug('Adding ' + curJob);
                        jobCount = 0;
                    }
                    
                    //Add currentJobList                   
                    if (!(jobList.isEmpty())) {
                        note.serviceJobList = jobList;
                        jobList = new List<Service_Job>();
                    }

                parser.nextToken();
            }
        }
        system.debug('List of api service notes' + apiServiceNotes);
        system.debug('Service Jobs List' + jobList);
        return apiServiceNotes;
    }

    public class API_Product_Service_Note {
        @AuraEnabled public String apiName {get; set;}
        @AuraEnabled public String Mileage {get; set;}
        @AuraEnabled public String serviceFacility {get; set;}
        @AuraEnabled public String servicePerformed {get; set;}
        @AuraEnabled public String productDivision {get; set;}
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public Boolean apiRecord {get; set;}
        @AuraEnabled public String recordDate {get; set;}
        @AuraEnabled public Date Service_DateTempc {get; set;}
        @AuraEnabled public List<Service_Job> serviceJobList {get; set;}


        Public API_Product_Service_Note(){
            servicePerformed = '';
            apiRecord = true;
        }
    } 

    public class Service_Job {
        @AuraEnabled public String Job {get; set;}
        @AuraEnabled public String Service {get; set;}
        @AuraEnabled public String Description {get; set;}
        @AuraEnabled public String partNames {get; set;}
        @AuraEnabled public String partNumbers {get; set;}

        Public Service_Job(){
            partNames = '';
            partNumbers = '';
        }
    } */
}