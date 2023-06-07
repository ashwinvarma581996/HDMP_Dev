public class B2BMegacategoryMappingTriggerHandler {
    
    public static void beforeUpdate(List<MegacategoryMapping__c> newMapping){
        updateAlternateKey(newMapping);        
    }
    public static void beforeInsert(List<MegacategoryMapping__c> newMapping){
        updateAlternateKey(newMapping);
    }
    private static void updateAlternateKey(List<MegacategoryMapping__c> newMapping){
        for(MegacategoryMapping__c mapping : newMapping){
            String sectionName = String.isBlank(mapping.SectionName__c)?'':mapping.SectionName__c;
            String groupName = String.isBlank(String.valueOf(mapping.GroupName__c))?'':String.valueOf(mapping.GroupName__c);
            mapping.AK_MegacategoryMapping__c = sectionName + '~' + groupName;
            //update mapping;
        }
    }
}