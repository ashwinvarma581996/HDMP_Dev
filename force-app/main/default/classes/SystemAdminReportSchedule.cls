/*==============================================================================================

Class Name : SystemAdminReportSchedule
Purpose    : This Apex Class is a scheduler which send weekly email having all the Active System Administrators users.
Test Class : SystemAdminReportScheduleTest

----------------------------------------History--------------------------------------------------
VERSION         AUTHOR                          DATE                DETAIL
1.0             Pradeep Singh                27-01-2023          Initial Version

===============================================================================================*/
global with sharing class SystemAdminReportSchedule implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        OrgWideEmailAddress orgWide = [SELECT Id, Address, DisplayName, Purpose FROM OrgWideEmailAddress Where DisplayName = 'Dreamshop Orders' LIMIT 1];
        
        B2B_Email_Scheduled_Report__mdt reportInfo = [SELECT Id,To_Email_Addresses__c, Email_Body__c, Subject__c, DeveloperName FROM B2B_Email_Scheduled_Report__mdt LIMIT 1];
        
        String htmlBody = reportInfo.Email_Body__c + '<br/><br/> <table border="1" style="border-collapse: collapse"><tr><th>Salesforce ID</th><th>Name</th><th>Username</th><th>Email</th></tr>';
        
        for(User u : [SELECT Id, Name, Profile.Name, email,userName from User where Profile.Name = 'System Administrator' and IsActive=True]){
            htmlBody += '<tr><td>' + u.Id + '</td><td>' + u.Name+ '</td><td>' + u.UserName+ '</td><td>' + u.Email+ '</td></tr>';
        }
        
        htmlBody += '</table>';
        List<Messaging.SingleEmailMessage> singleEmailMsgList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSaveAsActivity(false);
        mail.setOrgWideEmailAddressId(orgWide.Id);
        mail.setHtmlBody(htmlBody);
        mail.subject = reportInfo.Subject__c;
        mail.setToAddresses(reportInfo.To_Email_Addresses__c.split(';'));
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});

    }
    
}