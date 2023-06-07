public class Batch_deletedebuglogs implements Database.Batchable<sObject>{
    // instance member to retain state across transactions
   
    
     public Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator(
            [SELECT Id FROM ApexLog order by loglength limit 1]
        );
    }
    public void execute(Database.BatchableContext bc, List<ApexLog> scope){
       
   for(Apexlog al: scope){
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(Url.getOrgDomainUrl().toExternalForm()+ '/services/data/v44.0/sobjects/Apexlog/'+al.Id);
    req.setMethod('DELETE');
    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    HttpResponse res = h.send(req);
    System.debug(res.getStatusCode());
}
        }
        
        
    
    public void finish(Database.BatchableContext bc){
        
    }

}