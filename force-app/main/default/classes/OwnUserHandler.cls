//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class OwnUserHandler implements Auth.SamlJitHandler{
    private class JitException extends Exception{
    }

    public static String loginOperation;

    private void handleUser(boolean create, User u, Map<String, String> attributes, String federationIdentifier){

        String account = handleAccount(create, u, attributes, federationIdentifier);

        system.debug('create ==>' + create);
        system.debug('user ==>' + u);
        system.debug('attributes==>' + attributes);
        system.debug('federationIdentifier ==>' + federationIdentifier);
        system.debug('Username ==>' + attributes.get('username'));

        if (create && attributes.containsKey('username')){
            u.Username = attributes.get('username');
        }

        if (attributes.containsKey('First Name')){
            u.FirstName = attributes.get('First Name');
        }
        if (attributes.containsKey('Last Name')){
            u.LastName = attributes.get('Last Name');
        }
        if (attributes.containsKey('Email')){
            u.Email = attributes.get('Email');
        }
        if(attributes.containsKey('Bearer Token')){
            u.CIAMToken__c = attributes.get('Bearer Token');
        }

        if (attributes.containsKey('userId')){
            u.CIAM_User_ID__c = attributes.get('userId');
        }
        
        if (create){
            u.FederationIdentifier = federationIdentifier;
            String alias = '';
            if (u.FirstName == null || u.FirstName == ''){
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
            Id profileId = [Select Id, Name
                            from Profile
                            where Name = 'Honda Sites User'].Id; //DOE-4360 Ravindra Ravindra (Wipro)
            u.ProfileId = profileId;
            u.ContactId = account;
            u.Last_Visited_Product_Tab__c = 'First-time user';
            System.debug('UserId ' + u);
            //loginOperation = 'create';
            //garageCache.put('loginOperation', 'create');
        } else{
            //loginOperation = 'update';
            //garageCache.put('loginOperation', 'update');
            update (u);
        }
    }

    private String handleAccount(boolean create, User u, Map<String, String> attributes, String federationIdentifier){
        Account personAccount;
        boolean newAccount = false;

        if (create){
            RecordType personAccountRecordType = [SELECT Id
                                                  FROM RecordType
                                                  WHERE Name = 'Person Account' and SObjectType = 'Account'];
            personAccount = new Account();
            personAccount.RecordType = personAccountRecordType;

            newAccount = true;

        } else{
            String contactId;
            contactId = [select contactId
                         from User
                         where FederationIdentifier = :federationIdentifier].contactId;
            personAccount = [select Id
                             from Account
                             where PersonContactId = :contactId];
        }
        if (attributes.containsKey('Email')){
            personAccount.PersonEmail = attributes.get('Email');
        }
        if (attributes.containsKey('First Name')){
            personAccount.FirstName = attributes.get('First Name');
        }
        if (attributes.containsKey('Last Name')){
            personAccount.LastName = attributes.get('Last Name');
        }
        if (newAccount){
            insert (personAccount);
        } else{
            update (personAccount);
        }
        String personConId = [Select PersonContactId
                              From Account
                              Where Id = :personAccount.Id].PersonContactId;
        return personConId;
    }

    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion){
        system.debug('handleJit==>' + create);
        //System.debug('portalId Id' + EncodingUtil.base64Decode(assertion).toString().contains('/mygarage'));
        
        //String account = handleAccount(create, u, attributes, federationIdentifier);
        handleUser(create, u, attributes, federationIdentifier);
        //handleUser(create, u, attributes, federationIdentifier, account);
    }

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion){
        system.debug('createUser method ==>' + attributes);
        User u = new User();
        handleJit(true, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        return u;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion){
        system.debug('updateUser method ==>' + attributes);
        User u = [SELECT id, FirstName, ContactId
                  from user
                  WHERE federationIdentifier = :federationIdentifier];
        handleJit(false, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    }

    @AuraEnabled
    public static CIAM_Configuration__c getCIAMConfig(){

        //OwnGarageController.getUserVehiclesFromAPI(UserInfo.getUserId());

        return CIAM_Configuration__c.getInstance(UserInfo.getOrganizationId());
    }

}