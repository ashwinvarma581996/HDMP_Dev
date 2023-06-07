@isTest
public class Test_GetRecordLockStatus {
@isTest
    public static void CanGetRecordLockStatus() {

        //create record
		List<Offer_Header__c>  lstheader = new list<Offer_Header__c>();
        lstheader.add(new Offer_Header__c(Name='Testing offer Header1',Brand__c='A'));
        INSERT lstheader;
        
        List<Offers__c>  lstoffer = new list<Offers__c>();
        lstoffer.add(new Offers__c(Name  = 'test',Brand__c = 'A', Offer_Header__c=lstheader[0].id));
        insert lstoffer;

        
        //lock it
        Approval.lock(lstoffer[0].Id);

        //call GetRecordLockStatus
        List<Id> idList= new List<Id>();
        idList.add(lstoffer[0].Id);

        List<GetRecordLockStatus.Response> getstatusResponseList = GetRecordLockStatus.GetStatus(idList);
         
        //inspect result

        System.assertEquals(getstatusResponseList[0].locked,true);
       


    }
}