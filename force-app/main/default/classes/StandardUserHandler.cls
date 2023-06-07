/**********************************************************************
Name: StandardUserHandler
Business Unit:HDM
Developer : Deepak Mali
Description: This JitHandler class used for handling create user and update automatically when user login and register on ciam page
Test Class:StandardUserRegistrationHandlerTest
MODIFICATIONS- Soumya Sahoo (HDMP-6467)
MODIFICATIONS – Palak | (Added header and removal of commented code)
MODIFICATIONS – Imtiyaz | (Added Field User_Origination__c)
*************************************************************/
global class StandardUserHandler implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    private void handleUser(boolean create, User u, Map<String, String> attributes, String federationIdentifier) {
        String personContactId = handleAccount(create,attributes, federationIdentifier);
        
            if (create && attributes.containsKey(B2B_Constant.USERNAME)){
                u.Username = attributes.get(B2B_Constant.USERNAME);
            }
           	if (attributes.containsKey(B2B_Constant.FIRSTNAME)){
            	u.FirstName = attributes.get(B2B_Constant.FIRSTNAME);
        	}
        	if (attributes.containsKey(B2B_Constant.LASTNAME)){
            	u.LastName = attributes.get(B2B_Constant.LASTNAME);
        	}
        	if (attributes.containsKey(B2B_Constant.EMAIL)){
            	u.Email = attributes.get(B2B_Constant.EMAIL);
            }
        	if(String.isNotEmpty(federationIdentifier)){
            	u.FederationIdentifier = federationIdentifier;
        	}
            if(create){
               
                u.CIAM_User_ID__c = attributes.containsKey(B2B_Constant.USERID) ? attributes.get(B2B_Constant.USERID) : '';
                String alias = '';
            	if (u.FirstName == null){
                	alias = u.LastName;
            	} else{
                	alias = u.FirstName.charAt(0) + u.LastName;
            	}
            	if (alias.length() > 5){
                	alias = alias.substring(0, 5);
            	}
                u.Alias = alias;
            	u.TimeZoneSidKey = 'GMT';
            	u.LocaleSidKey = 'en_US';
            	u.LanguageLocaleKey = 'en_US';
            	u.EmailEncodingKey = 'UTF-8';
                //Start: Added By Imtiyaz to store the name of the current application from where user registered, 23 here in this case api name for HDM label from picklist
                //u.User_Origination__c = '23';//Commenting For AMS 284
                //End: Added By Imtiyaz
                Profile pfile = B2B_Logged_IN_Utility.getProfileDetails();
                if(pfile!=Null)
                    u.ProfileId = pfile.id;
                if(personContactId!=Null)
                	u.ContactId=personContactId;
            }else{
                update (u);
            }
    }
    private String handleAccount(boolean create,Map<String, String> attributes,String federationIdentifier){
       	Account personAccount;
        boolean newAccount = false;
        Account acc=new Account();
        if (create){
            RecordType personAccountRecordType = B2B_Logged_IN_Utility.getRecordType();
            personAccount = new Account();
            personAccount.RecordType = personAccountRecordType;
            newAccount = true;
        }else{
            personAccount =B2B_Logged_IN_Utility.getPersonAccountId(federationIdentifier);
        }
        if (attributes.containsKey(B2B_Constant.EMAIL)){
            personAccount.PersonEmail = attributes.get(B2B_Constant.EMAIL);
        }
        if (attributes.containsKey(B2B_Constant.FIRSTNAME)){
            personAccount.FirstName = attributes.get(B2B_Constant.FIRSTNAME);
        }
        if (attributes.containsKey(B2B_Constant.LASTNAME)){
            personAccount.LastName = attributes.get(B2B_Constant.LASTNAME);
        }
        if (newAccount){
            insert (personAccount);
            handleBuyerGroupAccount(personAccount.id,personAccount.FirstName,personAccount.LastName);
            handleBuyerGroupMembers(personAccount.id,create);
        } else{
            update (personAccount);
            handleBuyerGroupAccount(personAccount.id,personAccount.FirstName,personAccount.LastName);
            handleBuyerGroupMembers(personAccount.id,create);
        }
        String personConId = B2B_Logged_IN_Utility.getPersoncontactId(personAccount);
        return personConId;
    }
    private void handleBuyerGroupMembers(Id accountId,Boolean create){
        BuyerGroupMember buyermember=new BuyerGroupMember();
        
        List<BuyerGroupMember> existingBuyerGroupMember=[select id from BuyerGroupMember where BuyerId=:accountId Limit 1];
		if(existingBuyerGroupMember.isEmpty()){
            buyermember.BuyerId=accountid;
            if(create)
                buyermember.BuyerGroupId=B2B_Logged_IN_Utility.getBuyerGroupID();
            else
                buyermember.BuyerGroupId=B2B_Logged_IN_Utility.getMigratedBuyerGroupID();
    	insert buyermember;
        }
    }
    private void handleBuyerGroupAccount(Id accountId,String firstName,String lastName){
        
        List<BuyerAccount> existingBuyer=[select id from BuyerAccount where BuyerId=:accountId limit 1];
		if(existingBuyer.isEmpty()){
            BuyerAccount buyeracc=new BuyerAccount();
			buyeracc.BuyerId=accountId;
			buyeracc.IsActive=B2B_Constant.TRUE_FLAG;
			buyeracc.BuyerStatus= B2B_Constant.BUYER_STATUS;
			buyeracc.Name=firstName + lastName;
			insert buyeracc;
        }
    }
    
    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               handleUser(create, u, attributes, federationIdentifier);
                           }
    
    //it will be create new 
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               User usr = new User();
                               handleJit(true, usr, samlSsoProviderId, communityId, portalId,
                                         federationIdentifier, attributes, assertion);
                               return usr;
                           }
    //it will be update the user 
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               User u =B2B_Logged_IN_Utility.getUserId(federationIdentifier);
                                      handleJit(false, u, samlSsoProviderId, communityId, portalId,
                                         federationIdentifier, attributes, assertion);
                           }
}