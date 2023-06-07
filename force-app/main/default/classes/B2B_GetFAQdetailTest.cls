@isTest
public class B2B_GetFAQdetailTest {
    @testSetup 
    public static void setup(){
    FAQ__c f=new FAQ__c(Sr_No__c=1, Question__c='what is estore?', Answer__c='A B2B platform.');
    insert(f);
    }
    @isTest 
    public static void B2BGetFAQDetailTest() {
    list<FAQ__c> flist=new list<FAQ__c>();
    flist= B2B_GetFAQdetail.getFAQ();   	
    
    }
}