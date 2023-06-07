public class B2B_Fetch_PersonAccount {
    public Static String getPersonAccount(string userid){
        String personAccountId;
        user personuser=B2B_Logged_IN_Utility.getUserdetails(userid);
        if(personuser!=Null && personuser.federationIdentifier!=Null && personuser.contactid!=Null){
            Account personAccountDetails = B2B_Logged_IN_Utility.getPersonAccountDetails(personuser.contactid);
            if(personAccountDetails!=Null)
                personAccountId=personAccountDetails.id;
            else
                personAccountId=Null;
        }
        return personAccountId;
    }
}