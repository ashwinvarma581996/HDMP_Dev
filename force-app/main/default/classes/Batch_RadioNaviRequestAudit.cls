global class Batch_RadioNaviRequestAudit implements Database.Batchable<string>, Database.Stateful{
    
    global boolean isReRunRequired = false;
    global Iterable<string> start(Database.BatchableContext ctx) {
        return new list<String> { 'Radio_Navi_Request__c', 'Radio_Navi_Request_Failure__c'}; 
    }
   
    global void execute(Database.BatchableContext dt, list<string> lstsObjectName){
        list<sObject> radNavRequestSuccess = new list<sObject>();
        list<sObject> radNavRequestFailure = new list<sObject>();
        system.debug('lstsObjectName==>>'+lstsObjectName.size());
        for(string strObjectName : lstsObjectName) {
            if(strObjectName == 'Radio_Navi_Request__c'){
                for(sObject objsObject : database.query('Select Id from ' + strObjectName + ' where CreatedDate != LAST_N_DAYS:31')) {
                    if(radNavRequestSuccess.size() < 9998)
                        radNavRequestSuccess.add(objsObject);
                    else {
                        isReRunRequired = true;
                        break;
                    }
                }
            }
            else{
                for(sObject objsObject : database.query('Select Id from ' + strObjectName + ' where CreatedDate != LAST_N_DAYS:31')) {
                    if(radNavRequestFailure.size() < 9998)
                        radNavRequestFailure.add(objsObject);
                    else {
                        isReRunRequired = true;
                        break;
                    }
                }
            }
        }
        
        
        if(radNavRequestFailure.size()>0){
            system.debug('radNavRequestFailure==>>'+radNavRequestFailure.size());
            delete radNavRequestFailure;
        }else if(radNavRequestSuccess.size()>0){
            system.debug('radNavRequestSuccess==>>'+radNavRequestSuccess.size());
            delete radNavRequestSuccess;
        }
        
    }
    
    public void finish(Database.BatchableContext dt){
        if(isReRunRequired) {
            Database.executebatch(new Batch_RadioNaviRequestAudit());
       }
    }
}