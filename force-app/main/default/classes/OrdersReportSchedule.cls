global with sharing class OrdersReportSchedule implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        OrgWideEmailAddress orgWide = [SELECT Id, Address, DisplayName, Purpose FROM OrgWideEmailAddress Where DisplayName = 'Dreamshop Orders' LIMiT 1];
        
        
            ApexPages.PageReference report = Page.OrderReport;
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('Weekly_Report.xls');
            if(Test.isRunningTest()) { 
             attachment.setBody(blob.valueOf('Unit.Test'));
            } 
            else {
            	attachment.setBody(report.getContent());
            }
            attachment.setContentType('application/vnd.ms-excel');
            List<Messaging.SingleEmailMessage> singleEmailMsgList = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);
        	mail.setSubject('Weekly Orders Report - ' + datetime.now().format());
            mail.setOrgWideEmailAddressId(orgWide.Id);
            mail.setPlainTextBody('Please find the attached weekly report.');
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
            mail.setToAddresses(Label.Weekly_Report.split(';'));
            mail.setTargetObjectId(UserInfo.getUserId());
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        
    }
    
}