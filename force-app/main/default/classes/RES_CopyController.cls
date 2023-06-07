/**
 * Description: Controller for the copy classes
 * that used the model to determine
 * Author: eantonson@gorillagroup.com
 * @group             :
 * @last modified on  : 01-19-2022
 * @last modified by  : eantonson@gorillagroup.com
**/
public without sharing class RES_CopyController {
    //class variables
    public static List<Res_Copy_Set__c> listCopySet;
    public static Res_Copy_Set__c singleCopySet;

    @AuraEnabled(cacheable=true)
    //entry method used to return all of the
    //RES_CopySet objects.
    public static Res_Copy_Set__c getSingleCopySets(String modelName, Boolean waitlisted, Boolean isParticipantDealer) {
        //local variables
        Res_Copy_Set__c copyToReturn;
        String copyType = '';
        if(waitlisted) {
            copyType = 'waitlist';
        } else {
            if(isParticipantDealer) {
                copyType = 'isParticipantDealer';
            } else {
                copyType = 'notParticipantDealer';
            }
        }
       //see if there is one that matches
        try {
            copyToReturn = [SELECT Id, buttonText__c,
                                            headingText__c, Model__c,
                                            Name, subHeaderText__c,
                                            windowDocumentTitle__c, By_Clicking_Copy__c
                                        FROM Res_Copy_Set__c
                                        WHERE Name =: copyType
                                        AND Model__c =: modelName
                                        LIMIT 1] ;
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
            //create a default to return
            // copyToReturn = new Res_Copy_Set__c(
            //     Name = 'DEAFULT',
            //     subHeaderText__c = 'An Error has occured on copy load',
            //     Model__c = 'An Error has occured on copy load',
            //     headingText__c = 'Contact Info',
            //     buttonText__c = 'An Error has occured on copy load',
            //     windowDocumentTitle__c = 'An Error has occured on copy load',
            //     By_Clicking_Copy__c = 'An Error has occured on copy load'
            // );
            copyToReturn = [SELECT Id, buttonText__c,
                                            headingText__c, Model__c,
                                            Name, subHeaderText__c,
                                            windowDocumentTitle__c, By_Clicking_Copy__c
                                        FROM Res_Copy_Set__c
                                        WHERE Name =: copyType
                                        AND Model__c = 'Default'
                                        LIMIT 1];
        }
        //return value
        return copyToReturn;
    }
}