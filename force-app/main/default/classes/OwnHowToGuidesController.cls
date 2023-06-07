public without sharing class OwnHowToGuidesController {
    @AuraEnabled
    public static void update_UserHasHowToGuides(Boolean hasHowToGuides) {
        update new User(Id = UserInfo.getUserId(), HasHowToGuides__c = hasHowToGuides);
    }
    @AuraEnabled
    public static void update_ShowMIMO(Boolean showMIMO) {
        update new User(Id = UserInfo.getUserId(), Show_MIMO__c = showMIMO);
    }
}