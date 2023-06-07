trigger UserTrigger on User (after insert) {
    public static Boolean runTrigger = true;
    
    if(runTrigger){
    List<WebCart> webCartToInsert = new List<WebCart>();
    List<WebStore> ws             = [SELECT Id FROM Webstore LIMIT 1];
    Set<Id> contactIds            = new Set<Id>();
    Set<Id> cartOwnerIds          = new Set<Id>();
    Map<Id,WebCart> cartMap       = new Map<Id,WebCart>();
    for(User u : Trigger.New){
        if(u.IsPortalEnabled){
            contactIds.add(u.ContactId);
            cartOwnerIds.add(u.Id);
        }
    }
    
    Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN: contactIds]);
    for(WebCart webCartRec : [SELECT Id,OwnerId FROM WebCart WHERE OwnerId IN: cartOwnerIds AND Status = 'Active']){
        cartMap.put(webCartRec.OwnerId,webCartRec);
    }
    if(!ws.isEmpty()){
        for(User u : Trigger.New){
            if(u.IsPortalEnabled && !cartMap.containsKey(u.Id) && contactMap.containsKey(u.ContactId)){
                WebCart newWebCart = new WebCart(OwnerId=u.Id,Status='Active',Name='Cart',AccountId=contactMap.get(u.ContactId).AccountId,webstoreId=ws[0].Id);
                webCartToInsert.add(newWebCart );
            }
        }
        if(!webCartToInsert.isEmpty()){
            insert webCartToInsert;
        }
    }
    }
}