public class TriggerAdministrationHandler {
    
    public static boolean validateExecutionStatus(string triggerName)
    {
        boolean allowExec = true;
        Trigger_Administration__c settingRec = Trigger_Administration__c.getValues(triggerName);
        if(settingRec !=null && settingRec.ByPass_User_Id__c !=null && settingRec.ByPass_User_Id__c.contains(UserInfo.getUserId()))
        {
            allowExec = false;  
        }
        return allowExec;
    }
}