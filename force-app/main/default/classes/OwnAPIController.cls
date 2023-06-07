//****************************************************************************** 
// File Name:       OwnAPIController.cls
// Summary:         Apex Class for Garage 
// Created On:      10-18-2021
// Created By:      Arunprasad N (Wipro)
// Test Classes:    OwnAPIControllerTest.cls
// Data I/O:        
// Honda Jira Story: Apex class for API of Honda MyGarage Experience
//===============================================================================
// Modification Log: 
// October 18, 2021 Arunprasad N (Wipro) initial coding
//*******************************************************************************
public without sharing class OwnAPIController { 
   
    public static void setJWTAccessToken(){
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.MyGarageConnectedFeature');
        String cachedToken = (String)orgPart.get('JWTAccessToken');
        if(cachedToken == null){
            orgPart.put('JWTAccessToken', 'Bearer ' + JWTToken.getAccessToken());
        }
    }
    
    public static void setJWTAccessTokenToNULL(){
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.MyGarageConnectedFeature');
        orgPart.put('JWTAccessToken', null);
    }
    
    
    public static List<String> getConnectedPlatforms(){
        List<String> connectedPlatforms = new List<String>{'MY16','MY17','MY21','MY23','2ZS'};
            return connectedPlatforms;
    }
    
    @AuraEnabled (cacheable = true)
    public static Subscriptions getManageSubscriptions(String productIdentifier, String divisionId) {
        Subscriptions subscriptions = new Subscriptions();
        List<Packages> packagesList = new List<Packages>();
        OwnHttpCalloutService service;
        HttpResponse res= new HttpResponse();
        try {
            if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
                OwnProductController.Context productContext = OwnProductController.getProductContext('');
                if(productContext != null){
                    if(String.isNotBlank(productContext.product.productIdentifier)){
                        productIdentifier = productContext.product.productIdentifier;
                    }
                    if(String.isNotBlank(productContext.product.divisionId)){
                        divisionId = productContext.product.divisionId;
                    }
                }
            }
            setJWTAccessToken();
            List<String> endpointParameters = new List<String>{productIdentifier};
                Attribute attribute = new Attribute();
            attribute.divisionId = divisionId;
            ManageSubscriptions managesubscriptions = new ManageSubscriptions();
            service = new OwnHttpCalloutService('ManageSubscriptions', attribute, endpointParameters);
            res=service.sendRequest();
            String response = res.getBody();
            system.debug('@@managesubscriptions'+response);
            Error error = (Error)JSON.deserialize(response, Error.class);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                setJWTAccessTokenToNULL();
            }
            response = response.replace('"devices":""', '"devices":null');
            if(res.getStatusCode() != 200 && res.getStatusCode() != 201){
                System.enqueueJob(new OwnMyGarageUtils('ManageSubscriptions',productIdentifier+divisionId,0,'OwnAPIController','getManageSubscriptions','API',''+service.getRequest()+String.valueOf(service.getHeaderParameters())+service.getRequestBody(),res.getBody(),''+res.getStatusCode()));
       }
            managesubscriptions = (ManageSubscriptions)JSON.deserialize(response, ManageSubscriptions.class);
            
            VehicleFeatures vehicleFeature = productIdentifierLookUp(productIdentifier, divisionId);
            List<Packages> defaultPackages = getPackages(productIdentifier, divisionId);
            List<Packages> allDefaultPackages = new List<Packages>();
            for(Packages defaultPackage : defaultPackages){
                if(!defaultPackage.packageAPIName.equalsIgnoreCase('Basic')){
                    Packages defaultPack = new Packages();
                    defaultPack.packageDisplayName = defaultPackage.packageDisplayName;
                    defaultPack.packageName = defaultPackage.packageName;
                    defaultPack.packageAPIName = defaultPackage.packageAPIName;
                    defaultPack.status = defaultPackage.status;
                    defaultPack.link = defaultPackage.link;
                    defaultPack.icon = defaultPackage.icon;
                    allDefaultPackages.add(defaultPack);
                }
            }
            
            Set<String> packageNames = new Set<String>();
            for(Packages defaultPackage : defaultPackages){
                if(!defaultPackage.packageAPIName.equalsIgnoreCase('Basic')){
                    if(vehicleFeature.vehicle.telematicsUnit == 'Y'){
                        if(vehicleFeature.vehicle.enrollment.equalsIgnoreCase('N') && vehicleFeature.vehicle.ownership.equalsIgnoreCase('N')){
                            //Condition for Basic package Added By Abhishek Salecha for resolving DOE-4944
                            if(!defaultPackage.packageAPIName.equalsIgnoreCase('Link')){ //&& !defaultPackage.packageAPIName.equalsIgnoreCase('Basic')
                                defaultPackage.status = 'Not Enrolled';
                                defaultPackage.link = 'Sign Up';
                                defaultPackage.icon = 'utility:clear';
                            }
                        }else{
                            if(managesubscriptions.devices != null){
                                for(Programs program : managesubscriptions.devices[0].programs){
                                    if(vehicleFeature.vehicle.enrollment.equalsIgnoreCase('N') && vehicleFeature.vehicle.ownership.equalsIgnoreCase('Y') && program.role == 'PRIMARY'){
                                        defaultPackage.status = 'Not Enrolled';
                                        defaultPackage.link = 'Sign Up';
                                        defaultPackage.icon = 'utility:clear';
                                    }
                                    if(program.packageTypes.size() > 0){
                                        //String status = '';
                                        if(program.role != 'PRIMARY'){
                                            defaultPackage.packageName = 'Error';
                                            defaultPackage.status = 'Access to this vehicle is restricted to authorized users.If you are an authorized user, please Sign In or Register. If you are not an authorized user, please contact the primary driver to request access.';
                                            defaultPackage.link = '';
                                            defaultPackage.icon = 'utility:error';
                                        }
                                        for(Packages responsePack : program.packages){
                                            if(defaultPackage.packageAPIName.equalsIgnoreCase(responsePack.packageName)){
                                                defaultPackage.enrollmentEndDate = responsePack.enrollmentEndDate;
                                                if(program.role == 'PRIMARY'){
                                                    if(responsePack.subscriptionStatus.equalsIgnoreCase('not enrolled') || responsePack.subscriptionStatus.equalsIgnoreCase('cancelled')){
                                                        defaultPackage.status = 'Not Enrolled';
                                                        defaultPackage.link = 'Sign Up';
                                                        defaultPackage.icon = 'utility:clear';
                                                    }else if(responsePack.subscriptionStatus.equalsIgnoreCase('active') || responsePack.subscriptionStatus.equalsIgnoreCase('enrolled')){
                                                        if(DateTime.valueOf(defaultPackage.enrollmentEndDate) >= System.today()){
                                                            defaultPackage.status = 'Active';
                                                            defaultPackage.link = 'Manage';
                                                            defaultPackage.icon = 'utility:success';
                                                            defaultPackage.variant = 'success';
                                                        }else{
                                                            defaultPackage.status = 'Expired';
                                                            defaultPackage.link = 'Manage';
                                                            defaultPackage.icon = 'utility:warning';
                                                            defaultPackage.variant = 'error';
                                                            defaultPackage.textVariant = 'slds-text-color_destructive slds-text-title_bold';
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }else{
                                defaultPackage.packageName = 'Error';
                                defaultPackage.status = 'Access to this vehicle is restricted to authorized users.If you are an authorized user, please Sign In or Register. If you are not an authorized user, please contact the primary driver to request access.';
                                defaultPackage.link = '';
                                defaultPackage.icon = 'utility:error';
                            }
                        }
                    }
                    if(!packageNames.contains(defaultPackage.packageName)){
                        packageNames.add(defaultPackage.packageName);
                        packagesList.add(defaultPackage);
                    }
                }
            }
            subscriptions.packages = packagesList;
            subscriptions.vehicleFeature = vehicleFeature; 
            subscriptions.manageSubscriptions = manageSubscriptions;
            subscriptions.allDefaultPackages = allDefaultPackages;
        } catch (Exception err) {
            Packages pack = new Packages();
            pack.packageDisplayName = '';
            pack.packageName = 'Error';
            pack.status = 'DATA UNAVAILABLE';
            pack.link = '';
            pack.icon = '';
            packagesList.add(pack);
            subscriptions.packages = packagesList;
            subscriptions.vehicleFeature = new VehicleFeatures();
            subscriptions.manageSubscriptions = new ManageSubscriptions();
            subscriptions.allDefaultPackages = packagesList;
        }
        return subscriptions;
    }
    
    @AuraEnabled (cacheable = true)
    public static MyVehicle getMyVehicles(String productIdentifier, String divisionId) {
        if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        setJWTAccessToken();
        List<String> endpointParameters = new List<String>{productIdentifier};
        Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        MyVehicle myVehicle = new MyVehicle();
        HttpResponse res= new HttpResponse();
        OwnHttpCalloutService service = new OwnHttpCalloutService('MyVehicles', attribute, endpointParameters);
        res=service.sendRequest();
        String response = res.getBody();
        if(res.getStatusCode() != 200 && res.getStatusCode() != 201){
            System.enqueueJob(new OwnMyGarageUtils('MyVehicles',productIdentifier+divisionId,0,'OwnAPIController','getMyVehicles','API',''+service.getRequest()+service.getHeaderParameters()+service.getRequestBody(),res.getBody(),''+res.getStatusCode()));
       }
        Error error = (Error)JSON.deserialize(response, Error.class);
        if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
            setJWTAccessTokenToNULL();
        }
        myVehicle = (MyVehicle)JSON.deserialize(response, MyVehicle.class);
        return myVehicle;
    }
    
    @AuraEnabled (cacheable = true)
    public static MyProfile getMyProfile(String productIdentifier, String divisionId) {
        if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        setJWTAccessToken();
        List<String> endpointParameters = new List<String>{productIdentifier};
            Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        MyProfile profile = new MyProfile();
        OwnHttpCalloutService service = new OwnHttpCalloutService('MyProfile', attribute, endpointParameters);
        String response = service.sendRequest().getBody();
        Error error = (Error)JSON.deserialize(response, Error.class);
        if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
            setJWTAccessTokenToNULL();
        }
        profile = (MyProfile)JSON.deserialize(response, MyProfile.class);
        
        List<Packages> packages = new List<Packages>();
        for(Programs program : profile.devices[0].programs){
            if(program.packageTypes.size() > 0){
                String status = '';
                if(program.role != 'PRIMARY'){
                    status = 'Error';
                }
                Packages pack = new Packages();
                pack.packageName = 'Link';
                pack.status = 'Complimentary';
                pack.link = 'Learn More';
                packages.add(pack);
                for(Packages responsePack : program.packages){
                    pack = new Packages();
                    pack.packageName = responsePack.packageName;
                    pack.enrollmentEndDate = responsePack.enrollmentEndDate;
                    if(status == 'Error'){
                        pack.packageName = 'Error';
                        pack.status = 'Access to this vehicle is restricted to authorized users.If you are an authorized user, please Sign In or Register. If you are not an authorized user, please contact the primary driver to request access.';
                        pack.link = '';
                        pack.icon = 'utility:error';
                    }else{
                        if(responsePack.subscriptionStatus.equalsIgnoreCase('not enrolled') || responsePack.subscriptionStatus.equalsIgnoreCase('cancelled')){
                            pack.status = 'Not Enrolled';
                            pack.link = 'Sign Up';
                            pack.icon = 'utility:clear';
                        }else if(responsePack.subscriptionStatus.equalsIgnoreCase('active') || responsePack.subscriptionStatus.equalsIgnoreCase('enrolled')){
                            if(DateTime.valueOf(pack.enrollmentEndDate) >= System.today()){
                                pack.status = 'Active';
                                pack.link = 'Manage';
                                pack.icon = 'utility:success';
                                pack.variant = 'success';
                            }else{
                                pack.status = 'Expired';
                                pack.link = 'Manage';
                                pack.icon = 'utility:clear';
                            }
                        }
                    }
                    packages.add(pack);
                }
            }
        }
        profile.packages = packages;
        return profile;
    }
    
    @AuraEnabled (cacheable = true)
    public static List<Feature> getKeyFeatures(){
        List<OwnKeyFeature__mdt> featuresList = [SELECT Id, MasterLabel, DeveloperName, FeatureDescription__c, FeatureName__c, Status__c, Icon__c FROM OwnKeyFeature__mdt Order By DeveloperName];
        
        List<Feature> keyFeatures = new List<Feature>();
        if(featuresList.size() >0){
            for(OwnKeyFeature__mdt featureRecord : featuresList){
                Feature keyFeature = new Feature();
                keyFeature.featureDisplayName = featureRecord.MasterLabel;
                keyFeature.featureName = featureRecord.FeatureName__c;
                keyFeature.featureDescription = featureRecord.FeatureDescription__c;
                keyFeature.status = featureRecord.Status__c;
                keyFeature.icon = String.isNotBlank(featureRecord.Icon__c) ? featureRecord.Icon__c : '';
                switch on featureRecord.DeveloperName {
                    when 'AmazonAlexa' {		
                        keyFeature.featureIcon = 'alexa.svg';
                        keyFeature.variant = '';
                        keyFeature.showFooter = true;
                        keyFeature.hasCurrentFeature = true;
                        keyFeature.includesAmazon = true;
                        keyFeature.isError = false;
                        keyFeature.isNewUser = false;
                        keyFeature.linkLabel = 'Edit on Amazon';
                        keyFeature.hasAmazonFeature = false;
                        keyFeature.hasDriverFeedbackFeature = false;
                    }	
                    when 'DriverFeedback' {		
                        keyFeature.featureIcon = 'score88.svg';
                        keyFeature.variant = '';
                        keyFeature.showFooter = false;
                        keyFeature.hasCurrentFeature = true;
                        keyFeature.includesAmazon = false;
                        keyFeature.isError = false;
                        keyFeature.isNewUser = false;
                        keyFeature.linkLabel = 'Learn More';
                        keyFeature.hasAmazonFeature = false;
                        keyFeature.hasDriverFeedbackFeature = false;
                    }
                }
                keyFeatures.add(keyFeature);
            }
        }
        return keyFeatures;
    }
    
    @AuraEnabled (cacheable = true)
    public static ManageSubscriptions getMyVehicleAndMyProfile(String productIdentifier, String divisionId) {
        ManageSubscriptions managesubscriptions = new ManageSubscriptions();
        try{
            if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
                OwnProductController.Context productContext = OwnProductController.getProductContext('');
                if(productContext != null){
                    if(String.isNotBlank(productContext.product.productIdentifier)){
                        productIdentifier = productContext.product.productIdentifier;
                    }
                    if(String.isNotBlank(productContext.product.divisionId)){
                        divisionId = productContext.product.divisionId;
                    }
                }
            }
            setJWTAccessToken();
            List<String> endpointParameters = new List<String>{productIdentifier};
                Attribute attribute = new Attribute();
            attribute.divisionId = divisionId;
            OwnHttpCalloutService service = new OwnHttpCalloutService('ManageSubscriptions', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            Error error = (Error)JSON.deserialize(response, Error.class);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                setJWTAccessTokenToNULL();
            }
            managesubscriptions = (ManageSubscriptions)JSON.deserialize(response, ManageSubscriptions.class);
        }catch(Exception ex){
        }
        return managesubscriptions;
    }
    
    @AuraEnabled (cacheable = true)
    public static FeatureList getFeatureListByProductIdentifier(String productIdentifier, String divisionId) {
        if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        List<String> endpointParameters = new List<String>{productIdentifier};
            Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        VehicleFeatures vehicleResponseCache;
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            vehicleResponseCache = (VehicleFeatures)sessionPart.get('flv' + productIdentifier + userId);
        }
        List<Feature> keyFeatures = getKeyFeatures();
        List<Feature> features = new List<Feature>();
        FeatureList featureList = new FeatureList();
        VehicleFeatures vehicleResponse = new VehicleFeatures();
        if(vehicleResponseCache == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('FeatureListByVIN', attribute, endpointParameters);
            HttpResponse res= new HttpResponse();
            res=service.sendRequest();
            String response = res.getBody();
            Error error = (Error)JSON.deserialize(response, Error.class);
            if(error.status == 'ERROR'){
                for(Feature keyFeature : keyFeatures){
                    keyFeature.icon = '';
                    keyFeature.variant = '';
                    keyFeature.linkLabel = '';
                    keyFeature.isError = true;
                    keyFeature.showFooter = false;
                    keyFeature.status = 'DATA UNAVAILABLE';
                    features.add(keyFeature);
                }
                featureList.vehicle = null;
                featureList.feature = features;
                return featureList;
            }
            if(res.getStatusCode() != 200 && res.getStatusCode() != 201)
        	{
                System.enqueueJob(new OwnMyGarageUtils('FeatureListByVIN',productIdentifier+divisionId,0,'OwnAPIController','getFeatureListByProductIdentifier','API',''+service.getRequest()+service.getHeaderParameters()+service.getRequestBody(),res.getBody(),''+res.getStatusCode()));
        	}
            vehicleResponse = (VehicleFeatures)JSON.deserialize(response, VehicleFeatures.class);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                sessionPart.put('flv' + productIdentifier + userId, vehicleResponse);
            }
        }else{
            vehicleResponse = vehicleResponseCache;
        }
        
        VehicleDetails vehicle = new VehicleDetails();
        String userRole = '';
        String status = 'Not Available';
        VehicleFeatures vehicleFeature = productIdentifierLookUp(productIdentifier, divisionId);
        String packageAPIName = 'HPP_UBI_SCORE';
        if(vehicleFeature.vehicle.telematicsUnit == 'Y'){
            if(vehicleFeature.vehicle.enrollment.equalsIgnoreCase('N') && vehicleFeature.vehicle.ownership.equalsIgnoreCase('N')){
                status = 'Not Enrolled';
            }else{
                ManageSubscriptions managesubscriptions = getMyVehicleAndMyProfile(productIdentifier, divisionId);
                status = 'Not Enrolled';
                if(managesubscriptions.devices != null){
                    for(Programs program : managesubscriptions.devices[0].programs){
                        if(packageAPIName.equalsIgnoreCase(program.name)){
                            if(program.role != 'PRIMARY'){
                                status = 'Error';
                            }else if(program.enrollmentStatus.equalsIgnoreCase('optIn') || program.enrollmentStatus.equalsIgnoreCase('active') || program.enrollmentStatus.equalsIgnoreCase('enrolled')){
                                status = 'Active';
                            }else {
                                status = 'Not Enrolled';
                            }
                        }
                    }
                }else{
                    status = 'Error';
                }
            }
        }
        for(Model modelResponse : vehicleResponse.vehicle.model){
            if(modelResponse.modelId.equalsIgnoreCase(vehicleResponse.vehicle.modelId)){
                vehicle = vehicleResponse.vehicle;
                if(modelResponse.feature.size() > 0){
                    for(Feature keyFeature : keyFeatures){
                        Boolean hasExist = false;
                        for(Feature featureResponse : modelResponse.feature){
                            if((featureResponse.featureCategoryDesc.equalsIgnoreCase('Key Features') || featureResponse.featureCategoryDesc.equalsIgnoreCase('Remote Command')) && keyFeature.featureName == featureResponse.featureName){
                                hasExist = true;
                                if(featureResponse.featureName == 'Driver Feedback'){
                                    keyFeature.status = status;
                                    if(vehicleFeature.vehicle.enrollment.equalsIgnoreCase('N') && vehicleFeature.vehicle.ownership.equalsIgnoreCase('N')){
                                        keyFeature.linkLabel = 'Sign-up';
                                    }
                                    if(status == 'Active'){
                                        keyFeature.icon = 'utility:success';
                                        keyFeature.variant = 'success';
                                    }else if(status == 'Not Enrolled' || status == 'Expired'){
                                        keyFeature.icon = 'utility:clear';
                                        keyFeature.variant = '';
                                    }else if(status == 'Error'){
                                        keyFeature.icon = '';
                                        keyFeature.variant = '';
                                        keyFeature.linkLabel = '';
                                        keyFeature.isError = true;
                                        keyFeature.showFooter = false;
                                        keyFeature.status = 'Access to this vehicle is restricted to authorized users.If you are an authorized user, please Sign In or Register. If you are not an authorized user, please contact the primary driver to request access.';
                                    }
                                    keyFeature.hasDriverFeedbackFeature = true;
                                }
                                if(featureResponse.featureName == 'Amazon Alexa Skill'){
                                    MyVehicle vehiclesInfo = getEligibleVehicle(divisionId);
                                    String thirdPartyEligibilityStatus = '';
                                    if(vehiclesInfo != null && vehiclesInfo.vehicleInfo != null){
                                        for(VehicleInfo vehicleInfo : vehiclesInfo.vehicleInfo){
                                            if(productIdentifier == vehicleInfo.VIN){
                                                thirdPartyEligibilityStatus = vehicleInfo.thirdPartyEligibilityStatus;
                                            }
                                        }
                                    }
                                    keyFeature.status = status;
                                    if(vehicleFeature.vehicle.enrollment.equalsIgnoreCase('N') && vehicleFeature.vehicle.ownership.equalsIgnoreCase('N')){
                                        keyFeature.linkLabel = 'Sign-up';
                                    }
                                    if(status != 'Error' && thirdPartyEligibilityStatus.equalsIgnoreCase('LINKED')){
                                        keyFeature.status = 'Active';
                                        keyFeature.icon = 'utility:success';
                                        keyFeature.variant = 'success';
                                        keyFeature.hasAmazonFeature = true;
                                    }else if(status != 'Error' && thirdPartyEligibilityStatus.equalsIgnoreCase('ELIGIBLE')){
                                        keyFeature.icon = 'utility:clear';
                                        keyFeature.variant = '';
                                        keyFeature.status = 'Not Enrolled';
                                        keyFeature.hasAmazonFeature = true;
                                    }else if(status != 'Error' && thirdPartyEligibilityStatus == '' && vehicleFeature.vehicle.ownership.equalsIgnoreCase('N')){
                                        keyFeature.icon = 'utility:warning';
                                        keyFeature.variant = '';
                                        keyFeature.status = 'Data Unavailable';
                                        keyFeature.linkLabel = '';
                                        keyFeature.showFooter = false;
                                        keyFeature.hasAmazonFeature = true;
                                    }else if(status == 'Error'){
                                        keyFeature.icon = '';
                                        keyFeature.variant = '';
                                        keyFeature.linkLabel = '';
                                        keyFeature.isError = true;
                                        keyFeature.showFooter = false;
                                        keyFeature.hasAmazonFeature = true;
                                        keyFeature.status = 'Access to this vehicle is restricted to authorized users.If you are an authorized user, please Sign In or Register. If you are not an authorized user, please contact the primary driver to request access.';
                                    }
                                    if(!keyFeature.hasAmazonFeature){
                                        keyFeature.icon = 'utility:clear';
                                        keyFeature.variant = '';
                                        keyFeature.linkLabel = '';
                                        keyFeature.isError = true;
                                        keyFeature.showFooter = false;
                                        keyFeature.status = 'Not Available';
                                    }
                                    
                                }
                                features.add(keyFeature);
                            }
                        }
                        if(!hasExist){
                            keyFeature.showFooter = false;
                            keyFeature.linkLabel = '';
                            features.add(keyFeature);
                        }
                    }
                }
            }
        }
        featureList.vehicle = vehicle;
        featureList.feature = features;
        return featureList;
    }
    
    @AuraEnabled (cacheable = true)
    public static FeatureList getFeatureListByModelInformation(String year, String model, String modelId, String divisionId) {
        if(String.isBlank(year) || String.isBlank(model) || String.isBlank(modelId) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.year)){
                    year = productContext.product.year;
                }
                if(String.isNotBlank(productContext.product.model)){
                    model = productContext.product.model;
                }
                if(String.isNotBlank(productContext.product.modelId)){
                    modelId = productContext.product.modelId;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        if(String.isNotBlank(modelId)){
            String modelGroupValue = getModelGroupFromProductChooser(modelId, divisionId);
            if(modelGroupValue != ''){
                model = modelGroupValue.replaceAll(' ', '%20');
            }
        }
        List<String> endpointParameters = new List<String>{year, model};
            Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        Models modelListCatche;
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            modelListCatche = (Models)sessionPart.get('flm' + year + modelId + divisionId + userId);
        }
        Models modelList = new Models();
        if(modelListCatche == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('FeatureListByModel', attribute, endpointParameters);
            HttpResponse res= new HttpResponse();
            res=service.sendRequest();
            String response = res.getBody();
            if(res.getStatusCode() != 200 && res.getStatusCode() != 201)
        	{
                System.enqueueJob(new OwnMyGarageUtils('FeatureListByModel',year+model+modelId+divisionId,0,'OwnAPIController','getFeatureListByModelInformation','API',''+service.getRequest()+service.getHeaderParameters()+service.getRequestBody(),res.getBody(),''+res.getStatusCode()));
        	}
            modelList = (Models)JSON.deserialize(response, Models.class);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                sessionPart.put('flm' + year + modelId + divisionId + userId, modelList);
            }
        }else{
            modelList = modelListCatche; 
        }
        
        List<Feature> keyFeatures = getKeyFeatures();
        List<Feature> features = new List<Feature>();
        FeatureList featureList = new FeatureList();
        Model modelObj = new Model();
        for(Model modelResponse : modelList.model){
            if(modelResponse.modelId.equalsIgnoreCase(modelId)){
                modelObj = modelResponse;
                if(modelResponse.feature.size() > 0){
                    for(Feature keyFeature : keyFeatures){
                        Boolean hasExist = false;
                        for(Feature featureResponse : modelResponse.feature){
                            if((featureResponse.featureCategoryDesc.equalsIgnoreCase('Key Features') || featureResponse.featureCategoryDesc.equalsIgnoreCase('Remote Command')) && keyFeature.featureName == featureResponse.featureName){
                                hasExist = true;
                                keyFeature.status = 'Not Enrolled';
                                keyFeature.icon = 'utility:clear';
                                keyFeature.variant = '';
                            }
                        }
                        if(!hasExist){
                            features.add(keyFeature);
                        }
                    }
                }
            }
        }
        featureList.model = modelObj;
        featureList.feature = features;
        return featureList;
    }
    
    
    public class VehiclePackages{
        public Set<String> packageSet;
        public String telematicsPlatform;
    }
    
    private static VehiclePackages getPackageListByProductIdentifier(String productIdentifier, String divisionId) {
        if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        List<String> endpointParameters = new List<String>{productIdentifier};
            Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        VehicleFeatures vehicleResponseCache;
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            vehicleResponseCache = (VehicleFeatures)sessionPart.get('flv' + productIdentifier + userId);
        }
        VehicleFeatures vehicleResponse = new VehicleFeatures();
        if(vehicleResponseCache == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('FeatureListByVIN', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            vehicleResponse = (VehicleFeatures)JSON.deserialize(response, VehicleFeatures.class);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                sessionPart.put('flv' + productIdentifier + userId, vehicleResponse);
            }
        }else{
            vehicleResponse = vehicleResponseCache;
        }
        
        VehicleDetails vehicle = new VehicleDetails();
        Set<String> packageSet = new Set<String>();
        VehiclePackages vehiclePackagesAndDetails = new VehiclePackages();
        for(Model modelResponse : vehicleResponse.vehicle.model){
            if(modelResponse.modelId.equalsIgnoreCase(vehicleResponse.vehicle.modelId)){
                vehicle = vehicleResponse.vehicle;
                vehiclePackagesAndDetails.telematicsPlatform = vehicle.telematicsPlatform;
                if(modelResponse.feature.size() > 0){
                    for(Feature featureResponse : modelResponse.feature){
                        if(String.isNotBlank(featureResponse.packageName)){
                            packageSet.add(featureResponse.packageName);
                        }
                    }
                }
            }
        }
        vehiclePackagesAndDetails.packageSet = packageSet;
        return vehiclePackagesAndDetails;
    }
    
    private static VehiclePackages getPackageListByModelInformation(String year, String model, String modelId, String divisionId) {
        if(String.isBlank(year) || String.isBlank(model) || String.isBlank(modelId) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.year)){
                    year = productContext.product.year;
                }
                if(String.isNotBlank(productContext.product.model)){
                    model = productContext.product.model;
                }
                if(String.isNotBlank(productContext.product.modelId)){
                    modelId = productContext.product.modelId;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        List<String> endpointParameters = new List<String>{year, model};
            Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        Models modelListCatche;
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            modelListCatche = (Models)sessionPart.get('flm' + year + modelId + divisionId + userId);
        }
        Models modelList = new Models();
        if(modelListCatche == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('FeatureListByModel', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            modelList = (Models)JSON.deserialize(response, Models.class);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                sessionPart.put('flm' + year + modelId + divisionId + userId, modelList);
            }
        }else{
            modelList = modelListCatche; 
        }
        
        Model modelObj = new Model();

        Set<String> packageSet = new Set<String>();
        VehiclePackages vehiclePackagesAndDetails = new VehiclePackages();
        
        for(Model modelResponse : modelList.model){
            if(modelResponse.modelId.equalsIgnoreCase(modelId)){
                vehiclePackagesAndDetails.telematicsPlatform = modelResponse.telematicsPlatform;
                modelObj = modelResponse;
                if(modelResponse.feature.size() > 0){
                    for(Feature featureResponse : modelResponse.feature){
                        if(String.isNotBlank(featureResponse.packageName)){
                            packageSet.add(featureResponse.packageName);
                        }
                    }
                }
            }
        }

        vehiclePackagesAndDetails.packageSet = packageSet;
        return vehiclePackagesAndDetails;
    }
    
    public static List<Packages> getPackages(String productIdentifier, String divisionId){
        VehiclePackages vehiclePackagesAndDetails = getPackageListByProductIdentifier(productIdentifier, divisionId);
        List<OwnPackage__mdt> packageList = [SELECT Id, MasterLabel, DeveloperName, PackageAPIName__c, Order__c, Status__c,
                                             Link__c, Icon__c FROM OwnPackage__mdt ORDER BY Order__c ASC];
        
        List<Packages> packages = new List<Packages>();
        if(packageList.size() >0){
            for(OwnPackage__mdt packageObj: packageList){
                if(vehiclePackagesAndDetails.packageSet.contains(packageObj.DeveloperName) || (vehiclePackagesAndDetails.packageSet.contains('Remote') && packageObj.DeveloperName == 'Telematics')){
                    if(packageObj.DeveloperName != 'Remote' || vehiclePackagesAndDetails.telematicsPlatform != 'MY21'){
                        Packages pack= new Packages();
                        pack.packageDisplayName = packageObj.MasterLabel;
                        if(packageObj.DeveloperName == 'Telematics'){
                            pack.packageName = 'Remote';
                        }else{
                            pack.packageName = packageObj.DeveloperName;
                        }
                        pack.packageAPIName = packageObj.PackageAPIName__c;
                        pack.status = packageObj.Status__c;
                        pack.link = packageObj.Link__c;
                        pack.icon = String.isNotBlank(packageObj.Icon__c) ? packageObj.Icon__c : '';
                        packages.add(pack);    
                    }
                }
            }
        }
        return packages;
    }
    public static List<Packages> getPackagesByModelInformation(String year, String model, String modelId, String divisionId){
        VehiclePackages vehiclePackagesAndDetails = getPackageListByModelInformation(year, model, modelId, divisionId);
        List<OwnPackage__mdt> packageList = [SELECT Id, MasterLabel, DeveloperName, PackageAPIName__c, Order__c, Status__c,
                                             Link__c, Icon__c FROM OwnPackage__mdt ORDER BY Order__c ASC];
        
        List<Packages> packages = new List<Packages>();
        if(packageList.size() >0){
            for(OwnPackage__mdt packageObj: packageList){
                if(vehiclePackagesAndDetails.packageSet.contains(packageObj.DeveloperName) || (vehiclePackagesAndDetails.packageSet.contains('Remote') && packageObj.DeveloperName == 'Telematics')){
                    if(packageObj.DeveloperName != 'Remote' || vehiclePackagesAndDetails.telematicsPlatform != 'MY21'){
                        Packages pack= new Packages();
                        pack.packageDisplayName = packageObj.MasterLabel;
                        if(packageObj.DeveloperName == 'Telematics'){
                            pack.packageName = 'Remote';
                        }else{
                            pack.packageName = packageObj.DeveloperName;
                        }
                        pack.packageAPIName = packageObj.PackageAPIName__c;
                        pack.status = packageObj.Status__c;
                        pack.link = packageObj.Link__c;
                        pack.icon = String.isNotBlank(packageObj.Icon__c) ? packageObj.Icon__c : '';
                        packages.add(pack);
                    }
                }
            }
        }
        return packages;
    }
    
    @AuraEnabled (cacheable = true)
    public static List<Packages> getPackages(){
        List<OwnPackage__mdt> packageList = [SELECT Id, MasterLabel, DeveloperName, PackageAPIName__c, Order__c, Status__c,
                                             Link__c, Icon__c FROM OwnPackage__mdt ORDER BY Order__c ASC];
        
        List<Packages> packages = new List<Packages>();
        if(packageList.size() >0){
            for(OwnPackage__mdt packageObj: packageList){
                Packages pack= new Packages();
                pack.packageDisplayName = packageObj.MasterLabel;
                pack.packageName = packageObj.DeveloperName;
                pack.packageAPIName = packageObj.PackageAPIName__c;
                pack.status = packageObj.Status__c;
                pack.link = packageObj.Link__c;
                pack.icon = String.isNotBlank(packageObj.Icon__c) ? packageObj.Icon__c : '';
                packages.add(pack);
            }
        }
        return packages;
    }
    
    public static String getModelGroupFromProductChooser(String modelId, String divisionId){
        String modelGroupFieldName = 'model';
        List<String> subDivisions = new List<String>{'Honda', 'Acura'};
        Map<String, String> tierFieldNameMap = new Map<String, String>();
        List<Product_Chooser_Control__c> productChooserControls = [SELECT Id, Name, Application_Name__c, Product_Chooser_Control_Alternate_Identi__c, Product_Subdivision__c, Tier_Name__c, Tier_Number__c FROM Product_Chooser_Control__c WHERE Application_Name__c = 'My_Garage' AND Product_Subdivision__c IN :subDivisions];
        for(Product_Chooser_Control__c productChooserControl : productChooserControls){
            
            //string tierName = productChooserControl.Tier_Name__c.replaceAll('(\\s+)', '');
            String tierName = String.isNotBlank(productChooserControl.Tier_Name__c) ? productChooserControl.Tier_Name__c : '';
            if(tierName.containsIgnoreCase(modelGroupFieldName)){
                String productDivisionId = '';
                if(productChooserControl.Product_Subdivision__c == 'Honda'){
                    productDivisionId = 'A';
                }
                if(productChooserControl.Product_Subdivision__c == 'Acura'){
                    productDivisionId = 'B';
                }
                tierFieldNameMap.put(productDivisionId, 'Tier'+productChooserControl.Tier_Number__c+'__c');
            }
        }
        String queryString = 'SELECT Id, ';
        queryString += ' ' + tierFieldNameMap.get(divisionId) + ' '; 
        queryString += 'FROM Product_Chooser__c ';
        queryString += 'WHERE Product_Model__r.Product_Model_Id__c = :modelId ';
        queryString += 'LIMIT 1';
        String safeQueryString = String.escapeSingleQuotes(queryString);
        String modelGroup = '';
        if(!Test.isRunningTest()){
            Product_Chooser__c productChooser = Database.query(safeQueryString);
            if(productChooser != null){
                modelGroup = String.valueOf(productChooser.get(tierFieldNameMap.get(divisionId)));
            }
        }
        return modelGroup;
    }
    
    @AuraEnabled (cacheable = true)
    public static List<PackagesByTrim> getFeatureListByModelByPackages(String year, String model, String modelId, String divisionId, String origin) {
        if(origin != 'ProductChooser' && (String.isBlank(year) || String.isBlank(model) || String.isBlank(divisionId))){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.year)){
                    year = productContext.product.year;
                }
                if(String.isNotBlank(productContext.product.model)){
                    model = productContext.product.model;
                }
                if(String.isNotBlank(productContext.product.modelId)){
                    modelId = productContext.product.modelId;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        if(String.isNotBlank(modelId)){
            String modelGroupValue = getModelGroupFromProductChooser(modelId, divisionId);
            if(modelGroupValue != ''){
                model = modelGroupValue.replaceAll(' ', '%20');
            }
        }
        List<String> endpointParameters = new List<String>{year, model};
            Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        OwnHttpCalloutService service = new OwnHttpCalloutService('FeatureListByModel', attribute, endpointParameters);
        HttpResponse res= new HttpResponse();
        res=service.sendRequest();
        String response = res.getBody();
        system.debug('@@test'+response);
        if(res.getStatusCode() != 200 && res.getStatusCode() != 201)
        	{
                System.enqueueJob(new OwnMyGarageUtils('FeatureListByModel',year+model+modelId+divisionId,0,'OwnAPIController','getFeatureListByModelByPackages','API',''+service.getRequest()+service.getHeaderParameters()+service.getRequestBody(),res.getBody(),''+res.getStatusCode()));
        	}
        List<PackagesByTrim> packagesByTrims = new List<PackagesByTrim>();
        Set<String> trimNames = new Set<String>();   
        if(String.isNotBlank(response)){
            Models modelList = (Models)JSON.deserialize(response, Models.class);
            Set<String> uniquePackages = new Set<String>();
            for(Model modelResponse : modelList.model){
                /* !modelResponse.modelMsrp.equals('999999.99') Condtion added by Abhishek Salecha for DOE-4863 */
                /* if(String.isNotBlank(modelResponse.modelTrimTypeCode) ){  */
                /* Condition Changed by Abhishek Salecha as per mentioned in comment of DOE-4957 */
                if(modelResponse.modelTypeCode.equalsIgnoreCase('KA') && !modelResponse.modelMsrp.equals('999999.99')){//modelResponse.telematicsUnit.equalsIgnoreCase('Y')  && 
                    String trimName = '';
                    String selectedModelId = modelResponse.modelId;
                    if(String.isNotBlank(modelResponse.modelTrimMarketingName)){
                        trimName = modelResponse.modelTrimMarketingName;
                    }else if(String.isNotBlank(modelResponse.modelTrimTypeCode)){
                        trimName = modelResponse.modelTrimTypeCode;
                    }else if(String.isNotBlank(modelResponse.ModelGroupNameFriendly)){
                        trimName = modelResponse.modelGroupNameFriendly;
                    }
                    if(String.isNotBlank(trimName)){
               
                        Map<String , PackageFeatures> packageToFeatures = new Map<String , PackageFeatures>();
                        List<Packages> defaultPackages = getPackages();
                        for(Packages packageRecord : defaultPackages){
                            if(modelResponse.telematicsPlatform == 'MY21' && packageRecord.packageName == 'Telematics'){
                                packageRecord.packageName = 'Remote';
                            }
                            if(packageRecord.packageName != 'Telematics'){
                                packageToFeatures.put(packageRecord.packageName, new PackageFeatures(packageRecord.packageName));
                            }
                        }
                        
                        for(Feature featureRecord : modelResponse.feature){
                            for(Packages packageRecord : defaultPackages){
                                if(featureRecord.packageName.containsIgnoreCase(packageRecord.packageName) && !hasExcludedFeatures(featureRecord.FeatureName)){
                                    if(!uniquePackages.contains(packageRecord.packageName)) uniquePackages.add(packageRecord.packageName);
                                    packageToFeatures.get(packageRecord.packageName).features.add(featureRecord);
                                    packageToFeatures.get(packageRecord.packageName).isAvailable = true;
                                    break;
                                }
                            }
                        } 
                        
                        
                        List<PackageFeatures> packFeatures = new List<PackageFeatures>();
                        for(String packName : packageToFeatures.keySet()){
                            packFeatures.add(packageToFeatures.get(packName));
                        }
                        if(!trimNames.contains(trimName)){//modelResponse.modelTrimTypeCode
                            trimNames.add(trimName);//modelResponse.modelTrimTypeCode
                            PackagesByTrim packsByTrim = new PackagesByTrim();
                            packsByTrim.trimName = trimName;//modelResponse.modelTrimTypeCode;
                            packsByTrim.modelId = selectedModelId;
                            packsByTrim.telematicsPlatform = modelResponse.telematicsPlatform;
                            packsByTrim.telematicsUnit = modelResponse.telematicsUnit;
                            packsByTrim.packageToFeatures = packFeatures;
                            packagesByTrims.add(packsByTrim);
                        }else{
                            for(PackagesByTrim packsByTrim : packagesByTrims){
                                if(packsByTrim.trimName == trimName && selectedModelId == modelId){
                                    packsByTrim.modelId = selectedModelId;
                                    packsByTrim.packageToFeatures = packFeatures;
                                }
                            }
                        }
                    }    
                }
            }
            if(packagesByTrims.size() > 0){
                List<PackagesByTrim> filteredPackagesByTrims = new List<PackagesByTrim>();
                
                for(PackagesByTrim packageByTrimRecord : packagesByTrims){
                    List<PackageFeatures> packFeatureRecords = new List<PackageFeatures>();
                    for(PackageFeatures packFeatureRecord : packageByTrimRecord.packageToFeatures){
                        if(uniquePackages.contains(packFeatureRecord.packageName)){
                            packFeatureRecords.add(packFeatureRecord);
                        }
                    }
                    packageByTrimRecord.packageToFeatures = packFeatureRecords;
                    filteredPackagesByTrims.add(packageByTrimRecord);
                }
                system.debug('@@fil'+filteredPackagesByTrims);
                return filteredPackagesByTrims;
            }
        }
        system.debug('@@package'+packagesByTrims);
        return packagesByTrims;
    }
    
    @AuraEnabled (cacheable = true)
    public static List<PackagesByTrim> getFeatureListByVINByPackages(String productIdentifier, String divisionId, String origin) {
        if(origin != 'ProductChooser' && (String.isBlank(productIdentifier) || String.isBlank(divisionId))){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        List<String> endpointParameters = new List<String>{productIdentifier};
            Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        OwnHttpCalloutService service = new OwnHttpCalloutService('FeatureListByVIN', attribute, endpointParameters);
        HttpResponse res= new HttpResponse();
        res=service.sendRequest();
        String response = res.getBody();
        system.debug('@@Test'+response);
        if(res.getStatusCode() != 200 && res.getStatusCode() != 201)
        	{
                System.enqueueJob(new OwnMyGarageUtils('FeatureListByVIN',productIdentifier+divisionId,0,'OwnAPIController','getFeatureListByVINByPackages','API',''+service.getRequest()+service.getHeaderParameters()+service.getRequestBody(),res.getBody(),''+res.getStatusCode()));
        	}
        List<PackagesByTrim> packagesByTrims = new List<PackagesByTrim>();
        Set<String> trimNames = new Set<String>();  
        if(String.isNotBlank(response)){
            VehicleFeatures vehicleSpecs = (VehicleFeatures)JSON.deserialize(response, VehicleFeatures.class);
            Set<String> uniquePackages = new Set<String>();
            for(Model modelResponse : vehicleSpecs.vehicle.model){
                /* !modelResponse.modelMsrp.equals('999999.99') Condtion added by Abhishek Salecha for DOE-4863 */
                /* String.isNotBlank(modelResponse.modelTrimTypeCode)  */
                /* Condition Changed by Abhishek Salecha as per mentioned in comment of DOE-4957 */
                if(modelResponse.modelTypeCode.equalsIgnoreCase('KA') && !modelResponse.modelMsrp.equals('999999.99')){//modelResponse.telematicsUnit.equalsIgnoreCase('Y')  && 
                    String trimName = '';
                    String selectedModelId = modelResponse.modelId;
                    if(String.isNotBlank(modelResponse.modelTrimMarketingName)){
                        trimName = modelResponse.modelTrimMarketingName;
                    }else if(String.isNotBlank(modelResponse.modelTrimTypeCode)){
                        trimName = modelResponse.modelTrimTypeCode;
                    }else if(String.isNotBlank(modelResponse.ModelGroupNameFriendly)){
                        trimName = modelResponse.modelGroupNameFriendly;
                    }
                    if(String.isNotBlank(trimName)){
                        Map<String , PackageFeatures> packageToFeatures = new Map<String , PackageFeatures>();
                        List<Packages> defaultPackages = getPackages();
                        for(Packages packageRecord : defaultPackages){
                            if(modelResponse.telematicsPlatform == 'MY21' && packageRecord.packageName == 'Telematics'){
                                packageRecord.packageName = 'Remote';
                            }
                            if(packageRecord.packageName != 'Telematics'){
                                packageToFeatures.put(packageRecord.packageName, new PackageFeatures(packageRecord.packageName));
                            }
                        }
                        for(Feature featureRecord : modelResponse.feature){
                            for(Packages packageRecord : defaultPackages){
                                if(featureRecord.packageName.containsIgnoreCase(packageRecord.packageName) && !hasExcludedFeatures(featureRecord.FeatureName)){
                                    if(!uniquePackages.contains(packageRecord.packageName)) uniquePackages.add(packageRecord.packageName);
                                    packageToFeatures.get(packageRecord.packageName).features.add(featureRecord);
                                    packageToFeatures.get(packageRecord.packageName).isAvailable = true;
                                    break;
                                }
                            }
                        } 
                        List<PackageFeatures> packFeatures = new List<PackageFeatures>();
                        for(String packName : packageToFeatures.keySet()){
                            if(packageToFeatures.containsKey(packName)){
                                packFeatures.add(packageToFeatures.get(packName));
                            }
                            
                        }
                        if(!trimNames.contains(trimName)){//modelResponse.modelTrimTypeCode
                            trimNames.add(trimName);//modelResponse.modelTrimTypeCode
                            PackagesByTrim packsByTrim = new PackagesByTrim();
                            packsByTrim.trimName = trimName;//modelResponse.modelTrimTypeCode;
                            packsByTrim.modelId = selectedModelId;
                            packsByTrim.telematicsPlatform = modelResponse.telematicsPlatform;
                            packsByTrim.telematicsUnit = modelResponse.telematicsUnit;
                            packsByTrim.packageToFeatures = packFeatures;
                            packagesByTrims.add(packsByTrim);
                        }else{
                            for(PackagesByTrim packsByTrim : packagesByTrims){
                                if(packsByTrim.trimName == trimName && selectedModelId == vehicleSpecs.vehicle.modelId){
                                    packsByTrim.modelId = selectedModelId;
                                    packsByTrim.packageToFeatures = packFeatures;
                                }
                            }
                        }
                    }                    
                }
            }
            if(packagesByTrims.size() > 0){
                List<PackagesByTrim> filteredPackagesByTrims = new List<PackagesByTrim>();
                
                for(PackagesByTrim packageByTrimRecord : packagesByTrims){
                    List<PackageFeatures> packFeatureRecords = new List<PackageFeatures>();
                    for(PackageFeatures packFeatureRecord : packageByTrimRecord.packageToFeatures){
                        if(uniquePackages.contains(packFeatureRecord.packageName)){
                            packFeatureRecords.add(packFeatureRecord);
                        }
                    }
                    packageByTrimRecord.packageToFeatures = packFeatureRecords;
                    filteredPackagesByTrims.add(packageByTrimRecord);
                }
                return filteredPackagesByTrims;
            }
        }
        return packagesByTrims;
    }
    
    @AuraEnabled (cacheable = true)
    public static phoneDataWrapper getPhoneDataByModelId(String modelId, String divisionId) {
        if(String.isBlank(modelId) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.modelId)){
                    modelId = productContext.product.modelId;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        setJWTAccessToken();
        List<String> endpointParameters = new List<String>();
        Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        attribute.modelId = modelId;
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        PhoneData phoneDataCache;
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            phoneDataCache = (PhoneData)sessionPart.get('pdm' + modelId + divisionId + userId);
        }
        PhoneData phoneData = new PhoneData();
        PhoneDataWrapper phoneDataWrapper;
        if(phoneDataCache == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('PhoneDataByModelId', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            Error error = (Error)JSON.deserialize(response, Error.class);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                setJWTAccessTokenToNULL();
            }
            if(error.header != null){
                phoneDataWrapper=new PhoneDataWrapper();
            }else{
                if(String.isNotBlank(response)) {
                    response=response.replace('@id','id');
                    response=response.replace('@name','name');
                    response=response.replace('@thumb','thumb');
                    phoneData = (PhoneData)JSON.deserialize(response,PhoneData.class);
                    if(UserInfo.getUserType() != 'Guest'){
                        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                        sessionPart.put('pdm' + modelId + divisionId + userId, phoneData);
                    }
                    phoneDataWrapper=new PhoneDataWrapper(phoneData);
                }else{
                    phoneDataWrapper=new PhoneDataWrapper();
                }
            }	            
        }else{
            phoneDataWrapper=new PhoneDataWrapper(phoneDataCache);
        }
        
        return phoneDataWrapper;
    }
    @AuraEnabled (cacheable = true)
    public static ParingDataWrapper getPairingInstructionByPhone(String modelId, String carrierId, String manufacturerId, String phoneId, String divisionId) {
        PhonePbResultData phoneResults ;
        if(String.isBlank(modelId) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.modelId)){
                    modelId = productContext.product.modelId;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        setJWTAccessToken();
        List<String> endpointParameters = new List<String>();
        Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        attribute.modelId = modelId;
        attribute.carrierId = carrierId;
        attribute.manufacturerId = manufacturerId;
        attribute.phoneId = phoneId;
        
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        PhonePbResultData phoneResultsCache;
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            phoneResultsCache = (PhonePbResultData)sessionPart.get('pbr' + modelId + carrierId + manufacturerId + phoneId + divisionId + userId);
        }
        
        if(phoneResultsCache == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('GetPairingInstructionByPhone', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            Error error = (Error)JSON.deserialize(response, Error.class);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                setJWTAccessTokenToNULL();
            }
            if(String.isNotBlank(response)) {
                response=response.replace('@id','id');
                response=response.replace('@name','name');
                response=response.replace('@sort','sortOrder');
                response=response.replace('@description','description');
                response=response.replace('@thumb','thumb');
                response=response.replace('@type','type');
                response=response.replace('#text','text');
                response=response.replace('@passed','passed');
                response=response.replace('@num','num');
                response=response.replace('@thumb','thumb');
                phoneResults = (PhonePbResultData)JSON.deserialize(response, PhonePbResultData.class);
                if(UserInfo.getUserType() != 'Guest'){
                    Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                    sessionPart.put('pp' + modelId + carrierId + manufacturerId + phoneId + divisionId + userId, response);
                }
            }
        }else{
            phoneResults = phoneResultsCache;
        }
        
        return new ParingDataWrapper(phoneResults);
    }
    
    @AuraEnabled (cacheable = true)
    public static FeatureCategoryWrapper getFeaturesByPhone(String modelId, String carrierId, String manufacturerId, String phoneId, String divisionId) {
        if(String.isBlank(modelId) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.modelId)){
                    modelId = productContext.product.modelId;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        setJWTAccessToken();
        List<String> endpointParameters = new List<String>();
        Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        attribute.modelId = modelId;
        attribute.carrierId = carrierId;
        attribute.manufacturerId = manufacturerId;
        attribute.phoneId = phoneId;
        
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        PhoneResultData phoneResultsCache;
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            phoneResultsCache = (PhoneResultData)sessionPart.get('pp' + modelId + carrierId + manufacturerId + phoneId + divisionId + userId);
        }
        PhoneResultData phoneResults = new PhoneResultData();
        if(phoneResultsCache == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('FeaturesByPhone', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            Error error = (Error)JSON.deserialize(response, Error.class);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                setJWTAccessTokenToNULL();
            }
            if(String.isNotBlank(response)) {
                response=response.replace('@id','id');
                response=response.replace('@name','name');
                response=response.replace('@sort','sortOrder');
                response=response.replace('@description','description');
                response=response.replace('@thumb','thumb');
                phoneResults = (PhoneResultData)JSON.deserialize(response,PhoneResultData.class);
                if(UserInfo.getUserType() != 'Guest'){
                    Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                    sessionPart.put('pp' + modelId + carrierId + manufacturerId + phoneId + divisionId + userId, phoneResults);
                }
            }
        }else{
            phoneResults = phoneResultsCache;
        }
        return new FeatureCategoryWrapper(phoneResults);
    }
    
    @AuraEnabled (cacheable = true)
    public static String getValidateCustomerIdentity(String productIdentifier, String divisionId) {
        if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        List<String> endpointParameters = new List<String>();
        Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        attribute.productIdentifier = productIdentifier;
        
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        CustomerIdentity customerDetailsCache;
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            customerDetailsCache = (CustomerIdentity)sessionPart.get('vci' + productIdentifier + userId);
        }
        CustomerIdentity customerDetails = new CustomerIdentity();
        if(customerDetailsCache == null){	
            OwnHttpCalloutService service = new OwnHttpCalloutService('ValidateCustomerIdentity', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            customerDetails = (CustomerIdentity)JSON.deserialize(response, CustomerIdentity.class);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                sessionPart.put('vci' + productIdentifier + userId, customerDetails);
            }
        }else{
            customerDetails = customerDetailsCache;
        }
        return customerDetails.hondaCustomerCode;
    }
    
    @AuraEnabled (cacheable = true)
    public static VehicleFeatures productIdentifierLookUp(String productIdentifier, String divisionId) {
        if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        List<String> endpointParameters = new List<String>{productIdentifier};
            Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        VehicleFeatures vehicleResponseCache;
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            vehicleResponseCache = (VehicleFeatures)sessionPart.get('vl' + productIdentifier + userId);
        }
        VehicleFeatures vehicleResponse = new VehicleFeatures();
        if(vehicleResponseCache == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('VinLookUp', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            vehicleResponse = (VehicleFeatures)JSON.deserialize(response, VehicleFeatures.class);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                sessionPart.put('vl' + productIdentifier + userId, vehicleResponse);
            }
        }else{
            vehicleResponse = vehicleResponseCache;
        }
        return vehicleResponse;
    }
    
    @AuraEnabled (cacheable = true)
    public static MyVehicle getEligibleVehicle(String divisionId){
        List<String> endpointParameters = new List<String>();
        Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        attribute.programName = divisionId == 'A' ? 'ALEXA_HONDALINK_SKILL' : 'ALEXA_ACURALINK_SKILL';
        
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        MyVehicle vehicleInfoResponseCache;
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            vehicleInfoResponseCache = (MyVehicle)sessionPart.get('ev' + divisionId + userId);
        }
        try{
        }catch(Exception e){}
        MyVehicle vehicleInfoResponse = new MyVehicle();
        if(vehicleInfoResponseCache == null || vehicleInfoResponseCache.vehicleInfo == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('EligibleVehicle', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            System.debug('@@res: '+response);
            vehicleInfoResponse = (MyVehicle)JSON.deserialize(response, MyVehicle.class);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                sessionPart.put('ev' + divisionId + userId, vehicleInfoResponse);
            }
        }else{
            vehicleInfoResponse = vehicleInfoResponseCache;
        }
        return vehicleInfoResponse;
    }
    
    @AuraEnabled (cacheable = true)
    public static VehicleEligibility getTrialEligibility(String productIdentifier, String divisionId) {
        if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        HttpResponse res= new HttpResponse();
        List<String> endpointParameters = new List<String>{productIdentifier};
            Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        VehicleEligibility vehicleResponseCache;
        if(UserInfo.getUserType() != 'Guest'){
            User currentUser =  getCurrentUser();
            attribute.accessToken = currentUser != null && String.isNotBlank(currentUser.CIAMToken__c) ? currentUser.CIAMToken__c : '';
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            vehicleResponseCache = (VehicleEligibility)sessionPart.get('te' + productIdentifier + userId);
        }
        VehicleEligibility vehicleResponse = new VehicleEligibility();
        if(vehicleResponseCache == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('TrialEligibility', attribute, endpointParameters);
            res=service.sendRequest();
            system.debug(res.getBody());
            system.debug(res.getStatusCode());
            String response = res.getBody();
            if(res.getStatusCode() != 200 && res.getStatusCode() != 201)
        	{
                System.enqueueJob(new OwnMyGarageUtils('TrialEligibility',productIdentifier+divisionId,0,'OwnAPIController','getTrialEligibility','API',''+service.getRequest()+service.getHeaderParameters()+service.getRequestBody(),res.getBody(),''+res.getStatusCode()));
        	}
            vehicleResponse = (VehicleEligibility)JSON.deserialize(response, VehicleEligibility.class);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                sessionPart.put('te' + productIdentifier + userId, vehicleResponse);
            }
        }else{
            vehicleResponse = vehicleResponseCache;
        }
        return vehicleResponse;
    }
    
    @AuraEnabled (cacheable = true)
    public static SSPSSO getSSPSSOAcuralink(String productIdentifier, String divisionId) {
        SSPSSO sspSSOResponse = new SSPSSO();
        String response; 
        HttpResponse res= new HttpResponse();
        if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        List<String> endpointParameters = new List<String>();
        Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        attribute.vin = productIdentifier;
        
        if(UserInfo.getUserType() != 'Guest'){
            User currentUser =  getCurrentUser();
            attribute.accessToken = currentUser != null && String.isNotBlank(currentUser.CIAMToken__c) ? currentUser.CIAMToken__c : '';
            System.debug('getSSP Attributes : '+attribute);
            System.debug('getSSP Endpoints Parameters : '+endpointParameters);
            OwnHttpCalloutService service = new OwnHttpCalloutService('GetSSPSSOAcuralink', attribute, endpointParameters);
           	res=service.sendRequest(); 
            response = res.getBody();  
            sspSSOResponse.statusCode = service.sendRequest().getStatusCode();
            System.debug('getSSP Response : '+response);
            if(res.getStatusCode() != 200 && res.getStatusCode() != 201)
        	{
                System.enqueueJob(new OwnMyGarageUtils('GetSSPSSOAcuralink',productIdentifier+divisionId,0,'OwnAPIController','getSSPSSOAcuralink','API',''+service.getRequest()+service.getHeaderParameters()+service.getRequestBody(),res.getBody(),''+res.getStatusCode()));
        	}
        }
       	
        sspSSOResponse.response = response;
        return sspSSOResponse;
    }
    @AuraEnabled (cacheable = true)
    public static SSPSSO getSSPSSOHondalink(String productIdentifier, String divisionId) {
        SSPSSO sspSSOResponse = new SSPSSO();
        String response;
        
        if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        List<String> endpointParameters = new List<String>();
        Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        attribute.vin = productIdentifier;
        
        if(UserInfo.getUserType() != 'Guest'){
            User currentUser =  getCurrentUser();
            attribute.accessToken = currentUser != null && String.isNotBlank(currentUser.CIAMToken__c) ? currentUser.CIAMToken__c : '';
            System.debug('getSSP Attributes : '+attribute);
            System.debug('getSSP Endpoints Parameters : '+endpointParameters);
            OwnHttpCalloutService service = new OwnHttpCalloutService('GetSSPSSOHondalink', attribute, endpointParameters);
            response = service.sendRequest().getBody();  
            sspSSOResponse.statusCode = service.sendRequest().getStatusCode();        
            System.debug('getSSP Response : '+response);
        }
        sspSSOResponse.response = response;
        return sspSSOResponse;
    }

    @AuraEnabled (cacheable = true)
    public static SSPSSO getSSO(String productIdentifier) {
        SSPSSO sspSSOResponse = new SSPSSO();
        String response;
        HttpResponse res= new HttpResponse();
        if(String.isBlank(productIdentifier)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
            }
        }
        List<String> endpointParameters = new List<String>();
        Attribute attribute = new Attribute();
        attribute.divisionId = 'B';
        attribute.vin = productIdentifier;
        
        if(UserInfo.getUserType() != 'Guest'){
            User currentUser =  getCurrentUser();
            attribute.accessToken = currentUser != null && String.isNotBlank(currentUser.CIAMToken__c) ? currentUser.CIAMToken__c : '';
            OwnHttpCalloutService service = new OwnHttpCalloutService('getSSO', attribute, endpointParameters);
            res=service.sendRequest();
            if(res.getStatusCode() != 200 && res.getStatusCode() != 201)
        	{
                System.enqueueJob(new OwnMyGarageUtils('getSSO',productIdentifier,0,'OwnAPIController','getSSO','API',''+service.getRequest()+service.getHeaderParameters()+service.getRequestBody(),res.getBody(),''+res.getStatusCode()));
        	}
            response = res.getBody();  
            sspSSOResponse.statusCode = res.getStatusCode();        
            System.debug('getSSO Response : '+response);
            
        }
        sspSSOResponse.response = response;
        return sspSSOResponse;
    }

    private static User getCurrentUser(){
        if(UserInfo.getUserType() != 'Guest'){
            return [Select Id, Username, CIAMToken__c From User Where Id =: UserInfo.getUserId()];
        }
        return null;
    }

    @AuraEnabled
    public static void hidasTokenRevoke() {
        
        try {
            if(UserInfo.getUserType() != 'Guest'){
                //String userId = UserInfo.getUserId();
                // Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                // String access_token = (String)sessionPart.get('ciamtoken' +  userId);
                User currentUser =  getCurrentUser();
                if(currentUser != null && String.isNotBlank(currentUser.CIAMToken__c)){
                    List<String> endpointParameters = new List<String>();
                    Attribute attribute = new Attribute();
                    attribute.divisionId = 'A';
                    attribute.accessToken = currentUser.CIAMToken__c;
                    OwnHttpCalloutService service = new OwnHttpCalloutService('HidasTokenRevoke', attribute, endpointParameters);
                    String response = service.sendRequest().getBody();
                    //sessionPart.put('ciamtoken' + userId, null);
                    currentUser.CIAMToken__c = null;
                    update currentUser;
                }
            }    
        } catch (Exception err) {
        }
                
    }
    
    @AuraEnabled (cacheable = true)
    public static VehicleFeatures productIdentifierLookUpByProductId(String productId) {
        String productIdentifier = '';
        String divisionId = '';
        OwnProductController.Context productContext = OwnProductController.getProductContext(productId);
        if(productContext != null){
            if(String.isNotBlank(productContext.product.productIdentifier)){
                productIdentifier = productContext.product.productIdentifier;
            }
            if(String.isNotBlank(productContext.product.divisionId)){
                divisionId = productContext.product.divisionId;
            }
        }
        VehicleFeatures vehicleFeature = new VehicleFeatures();
        if(String.isNotBlank(productIdentifier)){
            vehicleFeature = productIdentifierLookUp(productIdentifier, divisionId);
        }
        return vehicleFeature;
    }
    
    @AuraEnabled (cacheable = true)
    public static String sendToMyVehicles(String requestBody, String divisionId){
        List<String> endpointParameters = new List<String>();
        Attribute attribute = new Attribute();
        //attribute.divisionId = divisionId;
        attribute.divisionId = 'A'; // Alexander Dzhitenov (Wipro) DOE-4839: Use Honda header parameters, since Acura header parameters cause issues in the API
        setJWTAccessToken();
        OwnHttpCalloutService service = new OwnHttpCalloutService('MyVehiclesPost', attribute, endpointParameters);
        service.setRequestBody(requestBody);
        Map<String, String> headerParam = service.getHeaderParameters();
        String response = service.sendRequest().getBody();
        Error error = (Error)JSON.deserialize(response, Error.class);
        if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
            setJWTAccessTokenToNULL();
        }
        return response;
    }
    
    public static boolean hasExcludedFeatures(string feature){
        if(string.isBlank(feature)){
            return false;
        }
        set<string> featureSet = new set<string>{'Key by amazon in-car delivery'};
            
            return featureSet.contains(feature.toLowerCase());
    }
    
    public static String getBrandLineProductByDivision(String brand, String divisionId){
        
        List<String> endpointParameters = new List<String>();
        Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        if (brand == 'Powersports'){
            attribute.divisionId = 'A';
        }
        setJWTAccessToken();
        String metadataName = ( (brand == 'Powersports') ? 'GetBrandLineProductByDivision_Powersport' : 'GetBrandLineProductByDivision_' + brand);
        OwnHttpCalloutService service = new OwnHttpCalloutService(metadataName, attribute, endpointParameters);
        
        Map<String, String> headerParam = service.getHeaderParameters();
        //service.setHeaderParameter('ClientDomain', 'test.ownerportal.honda.com');
        HttpResponse response = service.sendRequest();

        String responseBody = response.getBody();

        System.debug(responseBody);

        Error error = (Error)JSON.deserialize(responseBody, Error.class);
        if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
            setJWTAccessTokenToNULL();
        }
        
        return responseBody;
    }
 
    @AuraEnabled (cacheable = true)
    public static String getCustomerServiceStatus(String eUserIdent){
        String CIAMToken = [SELECT CIAMToken__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].CIAMToken__c;
        if(String.isBlank(CIAMToken) || CIAMToken==null){
            return 'not success';   
        }else{
            List<String> endpointParameters = new List<String>{};
            OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
            attribute.divisionId = 'A';
            String auth = 'Bearer ' + CIAMToken;
            OwnHttpCalloutService service = new OwnHttpCalloutService('CustomerServiceStatus', attribute, endpointParameters);
            service.setHeaderParameter('eUserIdent',eUserIdent);
            service.setHeaderParameter('Authorization',auth);
            String response = service.sendRequest().getBody();
            Map<String, Object> customerServiceStatus = (Map<String, Object>)JSON.deserializeUntyped(response);
            System.debug('$$CustomerServiceStatusResponse: '+ customerServiceStatus);
            if(customerServiceStatus.containsKey('status') && customerServiceStatus.containsKey('responseBody')){
                Map<String, Object> accountStatus = (Map<String, Object>)customerServiceStatus.get('responseBody');
                if(customerServiceStatus.get('responseBody') != null && accountStatus.get('accountStatus') != null && accountStatus.get('accountStatus') == 'deleted'){
                    return 'not success';
                }else{
                    return 'success';   
                }
            }
            else{
                return 'not success';
            }
        }
        
    }

    @AuraEnabled (cacheable = true)
    public static RecallData getRecallsByProductIdentifier(String productIdentifier, String divisionId) {
        //productIdentifier = '5FNRL6H84KB764126';
        if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }   
        }
        //setJWTAccessToken();
        List<String> endpointParameters = new List<String>();
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = divisionId;
        attribute.productIdentifier = productIdentifier;
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        RecallData recallDataCache;
        RecallData recalls = new RecallData();
        // Alexander Dzhitenov (Wipro) Saving recalls data during login sequence - Removed session cache, since it is not available during asynchronous operations
        /* if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarage');
            recallDataCache = (RecallData)sessionPart.get('rp' + productIdentifier + userId);
        } */
        if(recallDataCache == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('RecallData', attribute, endpointParameters);
            HttpResponse res= new HttpResponse();
            res=service.sendRequest();
            String response = validateRecallResponse(res.getBody());
            System.debug('response'+response);
            if(res.getStatusCode() != 200 && res.getStatusCode() != 201)
        	{
                System.enqueueJob(new OwnMyGarageUtils('RecallData',productIdentifier+divisionId,0,'OwnAPIController','getRecallsByProductIdentifier','API',''+service.getRequest()+service.getHeaderParameters()+service.getRequestBody(),res.getBody(),''+res.getStatusCode()));
        	}
            Error error = (Error)JSON.deserialize(response, Error.class);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                setJWTAccessTokenToNULL();
            }
            recalls = (RecallData)JSON.deserialize(response, RecallData.class);
            /* if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarage');
                sessionPart.put('rp' + productIdentifier + userId, recalls);
            } */
        }/* else{
            recalls = recallDataCache;
        } */
        System.debug('recalls'+recalls);
        return recalls;
        
    }

    @AuraEnabled (cacheable = true)
    public static RecallData getRecallsByModel(String year, String model, String modelId, String divisionId) {
        if(String.isBlank(modelId) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.modelId)){
                    modelId = productContext.product.modelId;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        //setJWTAccessToken();
        List<String> endpointParameters = new List<String>();
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.year = '2015';
        attribute.modelId = '10';
        attribute.divisionId = 'A';
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        RecallData recallDataCache;
        RecallData recalls = new RecallData();
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarage');
            recallDataCache = (RecallData)sessionPart.get('rm' + attribute.year + attribute.modelId);
        }
        if(recallDataCache == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('RecallDataByModel', attribute, endpointParameters);
            HttpResponse res= new HttpResponse();
            res=service.sendRequest();
            String response = res.getBody();
            if(res.getStatusCode() != 200 && res.getStatusCode() != 201)
        	{
                System.enqueueJob(new OwnMyGarageUtils('RecallDataByModel',year+model+modelId+divisionId,0,'OwnAPIController','getRecallsByModel','API',''+service.getRequest()+service.getHeaderParameters()+service.getRequestBody(),res.getBody(),''+res.getStatusCode()));
        	}
            System.debug('response'+response);
            Error error = (Error)JSON.deserialize(response, Error.class);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                setJWTAccessTokenToNULL();
            }
            recalls = (RecallData)JSON.deserialize(response, RecallData.class);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarage');
                sessionPart.put('rm' + attribute.year + attribute.modelId, recalls);
            }
        }else{
            recalls = recallDataCache;
        }
        
        System.debug('recalls'+recalls);
        return recalls;
        
    }
    @AuraEnabled
    public static RadioCodeService getRadioCode(String code){
        List<String> endpointParameters = new List<String>{code, 'B2C'};
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'A';
        RadioCodeService radioCodeServiceObject=new RadioCodeService();
        OwnHttpCalloutService service = new OwnHttpCalloutService('RadioCodeService', attribute, endpointParameters);
        String response = service.sendRequest().getBody();
        System.debug('response:: '+response);
        // Error error = (Error)JSON.deserialize(response, Error.class);
        //     System.debug('Error Response---'+error);
        //     radioCodeServiceObject = (RadioCodeService)JSON.deserialize(response, RadioCodeService.class);
        //     if(radioCodeServiceObject.radioCodeBody){
        //         System.debug('new  Response---'+radioCodeServiceObject.radioCodeBody);
        //         radioCodeServiceObject.error = true;
        //         radioCodeServiceObject.errorMsg = 'Data Unavailable';
        //         return radioCodeServiceObject;
        //     }
        radioCodeServiceObject = (RadioCodeService)System.JSON.deserialize(response, RadioCodeService.class);
        radioCodeServiceObject.radioresponse = response;
        System.debug(radioCodeServiceObject);
        return radioCodeServiceObject;
    }
    //DOE-2375 Starts
    @AuraEnabled
    public static RadioCodeService getNavigationCode(String code){
        List<String> endpointParameters = new List<String>{code, 'B2C'};
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'A';
        RadioCodeService radioCodeServiceObject=new RadioCodeService();
        OwnHttpCalloutService service = new OwnHttpCalloutService('RadioCodeService', attribute, endpointParameters);
        String response = service.sendRequest().getBody();
        System.debug('response:: '+response);
        radioCodeServiceObject = (RadioCodeService)System.JSON.deserialize(response, RadioCodeService.class);
        System.debug(radioCodeServiceObject);
        radioCodeServiceObject.navigationresponse = response;
        return radioCodeServiceObject;
    }
    //DOE-2375 Ends
    
    /*@AuraEnabled
    public static String getUserLocation(String latitude,String longitude){
        List<String> endpointParameters = new List<String>{latitude + ',' + longitude};
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'A';
        Response userLocation = new Response();
        OwnHttpCalloutService service = new OwnHttpCalloutService('BingReverseGeocode', attribute, endpointParameters);
        String response = service.sendRequest().getBody();
        userLocation = (Response)JSON.deserialize(response, Response.class);
        System.debug('getUserLocation'+userLocation);
        return userLocation.resourceSets[0].resources[0].address.postalCode;
    }*/

    @AuraEnabled
    public static DealerLocator getDealerByPoiId(String poiId, String poiType, String ownershipId, String brand, String latitude, String longitude) {
        try{
            setJWTAccessToken();
            List<String> endpointParameters = new List<String>{};
            OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
            attribute.divisionId = 'A';
            attribute.poiType = poiType;
            attribute.searchRadius = '20';
            attribute.pOIId = poiId;
            if(String.isNotBlank(poiId) && String.isNotBlank(latitude) && String.isNotBlank(longitude)){
                attribute.referenceCoordinates = latitude + ',' + longitude;
            }
            attribute.filters = '';
            if(String.isBlank(poiId)){
                // if(poiType == 'A'){
                //     attribute.filters = 'ATTR_A_AT%20%7C%20ATTR_A_47%20%7C%20ATTR_A_48%20%7C%20ATTR_A_49';
                // }else if(poiType == 'B'){
                //     attribute.filters = 'ATTR_B_AT%20%7C%20ATTR_B_47%20%7C%20ATTR_B_48';
                // }else 
                if(poiType == 'M'){
                    attribute.filters = 'ATTR_M_AT';
                }else if(poiType == 'P' && (brand == 'Power Equipment' || brand == 'Powerequipment')){
                    attribute.filters = 'ATTR_P_AT';
                }else if(poiType == 'P' && brand == 'Marine'){
                    attribute.filters = 'ATTR_P_X4';
                }
            }
            attribute.state = '';
            attribute.city = '';
            // if(String.isNotBlank(attribute.referenceCoordinates) && String.isNotBlank(latitude) && String.isNotBlank(longitude)){
            //     attribute.latitude=latitude;
            //     attribute.longitude=longitude;
            // }
            System.debug('This is getDealerLocator : '+attribute);
    
            OwnHttpCalloutService service = new OwnHttpCalloutService('DealerLocator', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            System.debug('response'+response);
            Error error = (Error)JSON.deserialize(response, Error.class);
            System.debug('Error Response---'+error);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                setJWTAccessTokenToNULL();
            }
            
            DealerLocator dealerLocator = (DealerLocator)JSON.deserialize(response, DealerLocator.class);
            if((poiType == 'A' || poiType == 'B') && (dealerLocator.poiResponse == null || dealerLocator.poiResponse.pois == null || dealerLocator.poiResponse.pois.poi == null)){
                attribute.poiType = 'BODYSHOP';
                attribute.filters = '';
                service = new OwnHttpCalloutService('DealerLocator', attribute, endpointParameters);
                response = service.sendRequest().getBody();
                System.debug('response'+response);
                error = (Error)JSON.deserialize(response, Error.class);
                System.debug('Error Response---'+error);
                if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                    setJWTAccessTokenToNULL();
                }
                dealerLocator = (DealerLocator)JSON.deserialize(response, DealerLocator.class);
            }
            if(dealerLocator.poiResponse == null || dealerLocator.poiResponse.pois == null || dealerLocator.poiResponse.pois.poi == null){
                dealerLocator.error = true;
                dealerLocator.errorMsg = 'No dealers found by this ' + poiId + ' PoiId';  
                return dealerLocator;
            }else{
                String poiIdent = '';
                if(String.isNotBlank(ownershipId)){
                    List<Ownership__c> ownerships = [Select Id, Preferred_Dealer__c, Preferred_Dealer__r.POIID__c From Ownership__c where Id =: ownershipId AND Preferred_Dealer__c != null Limit 1];
                    if(ownerships.size() > 0){
                        poiIdent = ownerships[0].Preferred_Dealer__r.POIID__c;
                    }
                }
                for (DealerLocatorInfo dealerLocationDetails : dealerLocator.poiResponse.pois.poi) {
                    dealerLocationDetails.isFavorite = false;
                    if(String.isNotBlank(poiIdent) && dealerLocationDetails.poiid == poiIdent){
                        dealerLocationDetails.isFavorite = true;
                    }
                }
            }
            System.debug('dealerLocator'+dealerLocator);
            return dealerLocator;
            
        }catch(Exception e){
            DealerLocator dealerLocator = new DealerLocator();
            dealerLocator.error = true;
            dealerLocator.errorMsg = 'Unable to find dealers';  
            return dealerLocator;
        }
    }
   
    @AuraEnabled
    public static DealerLocator getDealerLocator(String latitude, String longitude, String poiType, String ownershipId, String brand) {
        try{
            List<String> endpointParameters = new List<String>{};
            OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
            attribute.divisionId = 'A';
            attribute.poiType = poiType;
            attribute.searchRadius = '20';
            attribute.pOIId = '';
            attribute.filters = '';
            // if(poiType == 'A'){
            //     attribute.filters = 'ATTR_A_AT%20%7C%20ATTR_A_47%20%7C%20ATTR_A_48%20%7C%20ATTR_A_49';
            // }else if(poiType == 'B'){
            //     attribute.filters = 'ATTR_B_AT%20%7C%20ATTR_B_47%20%7C%20ATTR_B_48';
            // }else 
            if(poiType == 'M'){
                attribute.filters = 'ATTR_M_AT';
            }else if(poiType == 'P' && (brand == 'Power Equipment' || brand == 'Powerequipment')){
                attribute.filters = 'ATTR_P_AT';
            }else if(poiType == 'P' && brand == 'Marine'){
                attribute.filters = 'ATTR_P_X4';
            }
            String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
            DealerLocator dealerLocator = new DealerLocator();
            DealerLocator dealerLocatorCache;
            System.debug('This is getDealerLocator : '+attribute);

            String poiid = '';
            if(UserInfo.getUserType() != 'Guest' && String.isNotBlank(ownershipId)){
                List<Ownership__c> ownerships = [Select Id, Preferred_Dealer__c, Preferred_Dealer__r.POIID__c From Ownership__c where Id =: ownershipId AND Preferred_Dealer__c != null Limit 1];
                if(ownerships.size() > 0){
                    poiid = ownerships[0].Preferred_Dealer__r.POIID__c;
                }
            }
    
            String dealerType = '';
            // if(userId != ''){
            //     // List<User> user = [SELECT Id, AccountId FROM User WHERE username='brucebanner@gmail.com.dev3'];
            //     List<User> user = [SELECT Id, AccountId FROM User WHERE Id=:userId];
            //     System.debug('user->>'+user);
            //     List<Account> objUser = [SELECT Id, PersonMailingCity, PersonMailingState, PersonMailingPostalCode FROM Account WHERE Id=:user[0].AccountId ];
            //     //User objUser = [SELECT City, State, PostalCode FROM User WHERE Id =: userId];
            //     System.debug('Account---'+objuser);
            //     if((objUser[0].PersonMailingCity != null && objUser[0].PersonMailingState != null) || objUser[0].PersonMailingPostalCode !=null){
            //         attribute.state = objUser[0].PersonMailingState !=null ? objUser[0].PersonMailingState.replace(' ', '%20') : '';
            //         attribute.city = objUser[0].PersonMailingCity !=null ? objUser[0].PersonMailingCity.replace(' ', '%20') : '';
            //         attribute.latitude='';
            //         attribute.longitude='';
            //         System.debug('state--'+attribute.city);
            //         attribute.zipCode = objUser[0].PersonMailingPostalCode !=null ? objUser[0].PersonMailingPostalCode : '';
            //         dealerType = 'MyDealer';
            //     }else if(String.isNotBlank(latitude) && String.isNotBlank(longitude)){
            //         attribute.latitude=latitude;
            //         attribute.longitude=longitude;
            //         dealerType = 'NearByDealer';
            //     }else{
            //         if(String.isNotBlank(poiid)){
            //             DealerLocator favDealers = getDealerByPoiId(poiid, poiType, ownershipId, brand);
            //             if(favDealers.poiResponse != null && favDealers.poiResponse.pois != null && favDealers.poiResponse.pois.poi.size() > 0){
            //                 return favDealers;
            //             }else{
            //                 dealerLocator.error = true;
            //                 dealerLocator.errorMsg = 'Unable to find dealers! Please either enable your location or update your account address.';
            //                 return dealerLocator;    
            //             }
            //         }else{
            //             dealerLocator.error = true;
            //             dealerLocator.errorMsg = 'Unable to find dealers! Please either enable your location or update your account address.';
            //             return dealerLocator;    
            //         }
            //     } 
            // }else{
            //     System.debug('user location');
            //     attribute.latitude=latitude;
            //     attribute.longitude=longitude;
            //     System.debug('lat-long'+attribute.latitude+attribute.longitude);
            // }
            if(String.isNotBlank(latitude) && String.isNotBlank(longitude)){
                attribute.latitude=latitude;
                attribute.longitude=longitude;
            }else{
                if(String.isNotBlank(poiid)){
                    DealerLocator favDealers = getDealerByPoiId(poiid, poiType, ownershipId, brand, latitude, longitude);
                    if(favDealers.poiResponse != null && favDealers.poiResponse.pois != null && favDealers.poiResponse.pois.poi.size() > 0){
                        return favDealers;
                    }else{
                        dealerLocator.error = true;
                        dealerLocator.errorMsg = 'Unable to find dealers! Please enable your location.';
                        return dealerLocator;    
                    }
                }else{
                    dealerLocator.error = true;
                    dealerLocator.errorMsg = 'Unable to find dealers! Please enable your location.';
                    return dealerLocator;    
                }
            } 
            OwnHttpCalloutService service = new OwnHttpCalloutService('DealerLocator', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            System.debug('getDealerLocator response'+response);
            Error error = (Error)JSON.deserialize(response, Error.class);
            System.debug('Error Response---'+error);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                setJWTAccessTokenToNULL();
            }
            dealerLocator = (DealerLocator)JSON.deserialize(response, DealerLocator.class);
            dealerLocator.dealerType = dealerType;
            if(dealerLocator.poiResponse == null || dealerLocator.poiResponse.pois == null || dealerLocator.poiResponse.pois.poi == null){
                if(UserInfo.getUserType() != 'Guest' && String.isNotBlank(poiid)){
                    DealerLocator favDealers = getDealerByPoiId(poiid, poiType, ownershipId, brand, latitude, longitude);
                    if(favDealers.poiResponse != null && favDealers.poiResponse.pois != null && favDealers.poiResponse.pois.poi.size() > 0){
                        return favDealers;
                    }else{
                        dealerLocator.error = true;
                        dealerLocator.errorMsg = 'No dealers available at your location';  
                        return dealerLocator;    
                    }
                }else{
                    dealerLocator.error = true;
                    dealerLocator.errorMsg = 'No dealers available at your location';  
                    return dealerLocator;    
                }
            }else if(UserInfo.getUserType() != 'Guest' && dealerLocator.poiResponse.pois != null && dealerLocator.poiResponse.pois.poi.size() > 0 && String.isNotBlank(ownershipId) ){
                boolean favoriteFound = false; 
                for (DealerLocatorInfo dealerLocationDetails : dealerLocator.poiResponse.pois.poi) {
                    dealerLocationDetails.isFavorite = false;
                    if(String.isNotBlank(poiid) && dealerLocationDetails.poiid == poiid){
                        dealerLocationDetails.isFavorite = true;
                        favoriteFound = true;
                    }
                }

                if(String.isNotBlank(poiid) && !favoriteFound){
                    DealerLocator favDealers = getDealerByPoiId(poiid, poiType, ownershipId, brand, latitude, longitude);
                    if(favDealers.poiResponse != null && favDealers.poiResponse.pois != null && favDealers.poiResponse.pois.poi.size() > 0){
                        dealerLocator.poiResponse.pois.poi.addAll(favDealers.poiResponse.pois.poi);
                    }
                }
            }            
            System.debug('dealerLocator'+dealerLocator);
            return dealerLocator;
    
        }catch(Exception e){
            DealerLocator dealerLocator = new DealerLocator();
            dealerLocator.error = true;
            dealerLocator.errorMsg = 'Unable to find dealers ';  
            return dealerLocator;
        }        
       
    }

    @AuraEnabled
    public static boolean updateFavoriteDealer(String poiId, String ownershipId, String accountName){
        try {
            if(String.isNotBlank(poiId) && String.isNotBlank(ownershipId)){
                List<Ownership__c> ownerships = [Select Id , Preferred_Dealer__c From Ownership__c where Id =: ownershipId Limit 1];
                if(ownerships.size() > 0){
                    List<Account> accounts = [Select Id From Account where PoIId__c =: poiId Limit 1];
                    if(accounts.size() > 0){
                        if(ownerships[0].Preferred_Dealer__c == accounts[0].Id){
                            ownerships[0].Preferred_Dealer__c = null;
                        }else{
                            ownerships[0].Preferred_Dealer__c = accounts[0].Id;
                        }
                        update ownerships[0];
                    }else{
                        List<User> users = [Select Id, Name, Profile.Name From User Where Profile.Name = 'System Administrator' Limit 1];
                        Account newDealer = new Account();
                        newDealer.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
                        newDealer.PoIId__c = poiId;
                        newDealer.OwnerId = users[0].Id;
                        newDealer.name = accountName;
                        insert newDealer;
    
                        ownerships[0].Preferred_Dealer__c = newDealer.Id;
                        update ownerships[0];
                    }
                    return true;
                }else{
                    return false;
                }
            }else{
                return false;
            }    
        } catch (Exception err) {
            System.debug('Error message :: '+err.getMessage());
            return false;
        } 
        
    }

    @AuraEnabled (cacheable = true)
    public static DealerLocator searchDealers(String latitude, String longitude, String poiType, String city, String state, String postalCode, String miles, String ownershipId, String brand, String pOIName, String filterCode) {
        //setJWTAccessToken();
       // System.debug('!!dlerWrap=='+dlerWrap);
        // string latitude = dlerWrap.latitude;
        // string longitude = dlerWrap.longitude;
        string zipcode = postalCode;//string.isNotBlank(dlerWrap.zipCode) ? dlerWrap.zipCode : '';
        
        // if(String.isNotBlank(latitude) && String.isNotBlank(longitude)){
        //     zipcode = getUserLocation(latitude,longitude);
        // }

        List<String> endpointParameters = new List<String>{};
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'A';
        attribute.poiType = string.isNotBlank(poiType) ? poiType : '';
        attribute.zipCode = String.isNotBlank(zipCode) ? zipcode : '';
        attribute.state = string.isNotBlank(state) ? state : '';
        attribute.city = string.isNotBlank(city) ? city.replaceAll( ' ' , '%20') : '';
        attribute.searchRadius = miles;
        attribute.pOIId = '';
        attribute.poiName = string.isNotBlank(pOIName) ? pOIName.replaceAll( ' ' , '%20') : '';
        if((String.isNotBlank(pOIName) || String.isNotBlank(city)) && String.isNotBlank(latitude) && String.isNotBlank(longitude)){
            attribute.referenceCoordinates = latitude + ',' + longitude;
        }
        attribute.filters = '';
        // if(poiType == 'A'){
        //     attribute.filters = 'ATTR_A_AT%20%7C%20ATTR_A_47%20%7C%20ATTR_A_48%20%7C%20ATTR_A_49';
        // }else if(poiType == 'B'){
        //     attribute.filters = 'ATTR_B_AT%20%7C%20ATTR_B_47%20%7C%20ATTR_B_48';
        // }else 
        if(poiType == 'M'){
            attribute.filters = 'ATTR_M_AT';
        }else if(poiType == 'P' && (brand == 'Power Equipment' || brand == 'Powerequipment')){
            attribute.filters = filterCode; //'ATTR_P_X3%2CATTR_P_GG%2CATTR_P_16';//ATTR_P_X3%20%7C%20ATTR_P_GG%20%7C%20ATTR_P_16
        }else if(poiType == 'P' && brand == 'Marine'){
            attribute.filters = 'ATTR_P_X4';
        }
        // if(String.isNotBlank(attribute.referenceCoordinates) && String.isNotBlank(latitude) && String.isNotBlank(longitude)){
        //     attribute.latitude=latitude;
        //     attribute.longitude=longitude;
        // }
        // attribute.state = 'TX';
        // attribute.city = 'Austin';

        System.debug('!!zipCode'+zipCode);
        

        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        DealerLocator dealerLocator = new DealerLocator();
        DealerLocator dealerLocatorCache;

        if(dealerLocatorCache == null){
            System.debug('Attributes :: '+attribute);
            OwnHttpCalloutService service = new OwnHttpCalloutService('DealerLocator', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            System.debug('response'+response);
            Error error = (Error)JSON.deserialize(response, Error.class);
            System.debug('Error Response---'+error);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                setJWTAccessTokenToNULL();
            }
            dealerLocator = (DealerLocator)JSON.deserialize(response, DealerLocator.class);
            if(dealerLocator.poiResponse == null || dealerLocator.poiResponse.pois == null || dealerLocator.poiResponse.pois.poi == null){
                dealerLocator.error = true;
                dealerLocator.errorMsg = 'Sorry, there are no results based on the information you provided. ';
                return dealerLocator;
            }else if(UserInfo.getUserType() != 'Guest' && dealerLocator.poiResponse.pois.poi.size() > 0){
                String poiid = '';
                List<Ownership__c> ownerships = [Select Id, Preferred_Dealer__c, Preferred_Dealer__r.POIID__c From Ownership__c where Id =: ownershipId AND Preferred_Dealer__c != null Limit 1];
                if(ownerships.size() > 0){
                    poiid = ownerships[0].Preferred_Dealer__r.POIID__c;
                }
                
                for (DealerLocatorInfo dealerLocationDetails : dealerLocator.poiResponse.pois.poi) {
                    dealerLocationDetails.isFavorite = false;
                    if(String.isNotBlank(poiid) && dealerLocationDetails.poiid == poiid){
                        dealerLocationDetails.isFavorite = true;
                    }
                }
            }
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarage');
                sessionPart.put('dl' + userId, dealerLocator);
            }
        }else{
            dealerLocator = dealerLocatorCache;
        }
        
        System.debug('dealerLocator'+dealerLocator);
        return dealerLocator;
    }


    @AuraEnabled
    public static ServiceAppointments getServiceAppointments(String divisionId){
        ServiceAppointments appointmentsResponse = new ServiceAppointments();
        try{
            if(UserInfo.getUserType() != 'Guest'){
                List<String> endpointParameters = new List<String>{};
                Attribute attribute = new Attribute();
                attribute.divisionId = divisionId;
                //attribute.federationIdentifier = '500000343';
                //attribute.email = 'ciamhonda@gmail.com';
                
                User userDetails = [SELECT Id, FederationIdentifier, Email FROM User WHERE Id =: UserInfo.getUserId() Limit 1];
                attribute.federationIdentifier = userDetails.FederationIdentifier;
                attribute.email = userDetails.Email;
    
                System.debug('Attributes :: '+attribute);
                OwnHttpCalloutService service = new OwnHttpCalloutService('GetUserServiceAppointments', attribute, endpointParameters);
                String response = service.sendRequest().getBody();
                System.debug('response'+response);
                appointmentsResponse.appointments = (List<ServiceAppointment>)JSON.deserialize(response, List<ServiceAppointment>.class);
                appointmentsResponse.isError = false;
            
            }else{
                appointmentsResponse.isError = true;
                appointmentsResponse.errorMessage = 'Please login to check service appointments';
            }
            System.debug('appointmentsList'+appointmentsResponse.appointments);
            return appointmentsResponse;
        }catch(Exception err){
            appointmentsResponse.isError = true;
            appointmentsResponse.errorMessage = 'Unable to load service appointments';
            return appointmentsResponse;
        }        
    }


    @AuraEnabled (cacheable = true)
    public static string getManualByModelId(string modelId, string divisionId) {

        List<String> endpointParameters = new List<String>{};
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = divisionId;
        OwnHttpCalloutService service = new OwnHttpCalloutService('getManualByModelId', attribute, endpointParameters);
        String response = service.sendRequest().getBody();
        system.debug('!!response-'+response);
        return response;
    }

    @AuraEnabled (cacheable = true)
    public static ManualsDataWrapper getManualByVIN(string productIdentifier, string divisionId,String division,String modelId) {
        if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        ManualsResultData ManualsDatacache;
        List<String> endpointParameters = new List<String>{};
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = divisionId;
        attribute.vin = productIdentifier;
        attribute.division = division;
        OwnHttpCalloutService service = new OwnHttpCalloutService('GetManualsByVin', attribute, endpointParameters);
        String response = service.sendRequest().getBody();
        ManualsDatacache=(ManualsResultData)JSON.deserialize(response,ManualsResultData.class);
        system.debug('!!response-'+response);
        ManualsDataWrapper m=new ManualsDataWrapper(ManualsDatacache,modelId);
        return m;
    }

    //Created By Abhishek Salecha on 18/5/2022
    @AuraEnabled
    public static ConsumerProfileResp getConsumerProfileByWebUserID(){
        List<User> userRecords = [Select Id, FederationIdentifier From User where Id =: UserInfo.getUserId()];
        ConsumerProfileResp consumerProfileResponse;
        if(userRecords.size() > 0 && String.isNotBlank(userRecords[0].FederationIdentifier)){
            OwnConsumerProfileService.ConsumerProfileSOAP soapService = new OwnConsumerProfileService.ConsumerProfileSOAP();
            OwnConsumerProfileService.ConsumerProfileResp response = soapService.GetConsumerProfileByEUserIdent(userRecords[0].FederationIdentifier);
            System.debug('Consumer Profile Respons : '+response);
            if(response != null){
                consumerProfileResponse = new ConsumerProfileResp();
                if(response.ConsumerProfiles.size() > 0){
                    consumerProfileResponse.consumerProfiles = new List<ConsumerProfile>();
                    for(OwnConsumerProfileService.ConsumerProfile consumerProfileRecord : response.ConsumerProfiles){
                        ConsumerProfile consumerProfileDetails = new ConsumerProfile();
                        if(consumerProfileRecord.Dealers.size() > 0){
                            consumerProfileDetails.dealers = new List<DealerInfo>();
                            for(OwnConsumerProfileService.DealerInfo dealerDetails : consumerProfileRecord.Dealers){
                                DealerInfo dealer = new DealerInfo();
                                dealer.dealerName = dealerDetails.DealerName;
                                dealer.dealerNumber = dealerDetails.DealerNumber;
                                dealer.division = dealerDetails.Division.trim();
                                dealer.lastDateOfTrx = dealerDetails.LastDateOfTrx;
                                dealer.model = dealerDetails.Model;
                                dealer.productID = dealerDetails.ProductID;
                                dealer.relation = dealerDetails.Relation;
                                dealer.year = dealerDetails.Year;
                                consumerProfileDetails.dealers.add(dealer);
                            }
                        }
                        consumerProfileResponse.consumerProfiles.add(consumerProfileDetails);
                    }
                }
            }
        }
        return consumerProfileResponse;
    }


    public class ServiceAppointments{
        @AuraEnabled
        public List<ServiceAppointment> appointments {get;set;}
        @AuraEnabled 
        public String errorMessage {get;set;}
        @AuraEnabled 
        public Boolean isError {get;set;}
    }    
    public class ServiceAppointment{
        @AuraEnabled
        public String appointmentIdent {get;set;}
        @AuraEnabled
        public String appointmentForDisplay {get;set;}
        @AuraEnabled
        public String apptScheduledDate {get;set;}
        @AuraEnabled
        public String apptStatusCd {get;set;}
        @AuraEnabled
        public String apptPrimaryServiceType {get;set;}
        @AuraEnabled
        public String apptStatusNameDisplay {get;set;}
        @AuraEnabled
        public String dealerName {get;set;}
        @AuraEnabled
        public String ossProviderCd {get;set;}
        @AuraEnabled
        public String modelName {get;set;}
        @AuraEnabled
        public String modelYear {get;set;}
        @AuraEnabled
        public String dealerNo {get;set;}
        @AuraEnabled
        public Integer oldAppointmentIdent {get;set;}
        @AuraEnabled
        public String appointmentVendorID {get;set;}
    }

    public class ConsumerProfileResp {
        @AuraEnabled
        public List<ConsumerProfile> consumerProfiles {get;set;}
    }
    public class ConsumerProfile {
        @AuraEnabled
        public List<DealerInfo> dealers {get;set;}
    }
    public class DealerInfo {
        @AuraEnabled
        public String dealerNumber {get;set;}
        @AuraEnabled
        public String dealerName {get;set;}
        @AuraEnabled
        public String productID {get;set;}
        @AuraEnabled
        public String division {get;set;}
        @AuraEnabled
        public String model {get;set;}
        @AuraEnabled
        public String year {get;set;}
        @AuraEnabled
        public String relation {get;set;}
        @AuraEnabled
        public Date lastDateOfTrx {get;set;}
    }


    public class DealerLocator{
        @AuraEnabled
        public String dealerType {get;set;}
        @AuraEnabled
        public POIResponse poiResponse {get;set;}
        @AuraEnabled
        public Boolean error {get;set;}
        @AuraEnabled
        public String errorMsg {get;set;}
    }
    public class POIResponse{
        @AuraEnabled
        public POIs pois {get;set;}
    }
    public class POIs{
        @AuraEnabled
        public List<DealerLocatorInfo> poi {get;set;}
    }
    public class DealerLocatorInfo{
        @AuraEnabled
        public string POIName{get;set;}
        @AuraEnabled
        public string corporationName {get;set;}
        @AuraEnabled
        public string address {get;set;}
        @AuraEnabled
        public string fullAddress {get;set;}
        @AuraEnabled
        public string internetAddress {get;set;}
        @AuraEnabled
        public string city {get;set;}
        @AuraEnabled
        public string state {get;set;}
        @AuraEnabled
        public string zipCode {get;set;}
        @AuraEnabled
        public string phone {get;set;}
        @AuraEnabled
        public string latitude {get;set;}
        @AuraEnabled
        public string longitude {get;set;}
        @AuraEnabled
        public string poiid {get;set;}
        @AuraEnabled
        public boolean isFavorite {get;set;}
        @AuraEnabled
        public string distance {get;set;}
        @AuraEnabled
        public Departments departments {get;set;}
        @AuraEnabled
        public DealerAttributes attributes {get;set;}
        @AuraEnabled
        public String poiType {get;set;}
    }

    public class Departments{
        @AuraEnabled
        public List<Department> department {get;set;}
    }
    public class Department{
        @AuraEnabled
        public string name {get;set;}
        @AuraEnabled
        public List<OperationHour> operationHour {get;set;}
    }
    public class OperationHour{
        @AuraEnabled
        public string text {get;set;}
    }
    public class DealerAttributes{
        @AuraEnabled
        public List<DealerAttribute> attribute {get;set;}
    }
    public class DealerAttribute{
        @AuraEnabled
        public string code {get;set;}
        @AuraEnabled
        public string name {get;set;}
    }



    public class RecallData{
        @AuraEnabled
        public Response response {get;set;}
        @AuraEnabled
        public Boolean isError {get;set;}
    }

    public class Response {
		@AuraEnabled
		public RecallsResponse recalls_response;
        @AuraEnabled
        public List<ResourceSet> resourceSets{get;set;}
	}
    public class ResourceSet{
        @AuraEnabled
        public List<Resource> resources{get;set;}
    }
    public class Resource{
        @AuraEnabled
        public Address address {get;set;}
    }
    public class Address{
        @AuraEnabled
        public String postalCode {get;set;}
        @AuraEnabled
        public String adminDistrict {get;set;}
        @AuraEnabled
        public String adminDistrict2 {get;set;}
    }
    
    public class RecallsResponse {
        @AuraEnabled
        public RecallsResponseInner response {get;set;}
    }
    public class RecallsResponseInner{
        @AuraEnabled
        public Recall recall {get;set;}
        @AuraEnabled
        public String error {get;set;}
    }
    public class Recall{
        @AuraEnabled
        public CampaignType campaignType {get;set;}
        @AuraEnabled
        public String category {get;set;}
        @AuraEnabled
        public String division_cd {get;set;}
        @AuraEnabled
        public String model_group_name {get;set;}
        @AuraEnabled
        public String Subdivision_name {get;set;}
        @AuraEnabled
        public String VIN {get;set;}
    }
    
    public class CampaignType{
        @AuraEnabled
        public List<Campaign> campaign {get;set;}
    }
    public class Campaign{
        @AuraEnabled
        public string campaignBulletinID {get;set;}
        @AuraEnabled
        public string campaignDescription {get;set;}
        @AuraEnabled
        public string campaignID {get;set;}
        @AuraEnabled
        public string campaignStartDate {get;set;}
        @AuraEnabled
        public string mfrNotes {get;set;}
        @AuraEnabled
        public string recallDate {get;set;}
        @AuraEnabled
        public string refreshDate {get;set;}
        @AuraEnabled
        public string recallDescription {get;set;}
        @AuraEnabled
        public string recallNumber {get;set;}
        @AuraEnabled
        public string remedyDescription {get;set;}
        @AuraEnabled
        public string safetyRiskDescription {get;set;}
        @AuraEnabled
        public MfrRecallStatus mfrRecallStatus {get;set;}
    }
    public class MfrRecallStatus{
        @AuraEnabled
        public string value {get;set;}
    }

    //Radio start
    public class RadioCodeService{
        @AuraEnabled public radioHeader Header{get;set;}
        @AuraEnabled public List<RadioCodeBody> RadioCodeBody{get;set;}
        @AuraEnabled public boolean error{get;set;}
        @AuraEnabled public String errorMsg{get;set;}
        @AuraEnabled public String radioresponse{get;set;}
        @AuraEnabled public String navigationresponse{get;set;}
    }
    public class radioHeader {
        @AuraEnabled public String Message{get;set;}
        @AuraEnabled public String ReturnCode{get;set;}
        @AuraEnabled public String ReturnType{get;set;}
	}

	public class RadioCodeBody {
        @AuraEnabled public String Code{get;set;}
        @AuraEnabled public String DivisionCode{get;set;}
        @AuraEnabled public String Make{get;set;}
        @AuraEnabled public String RadioModelCode{get;set;}
	}

    public class ManualsDataWrapper {
        @AuraEnabled public Map<String,List<cls_pub>> manualsByModel= new Map<String,List<cls_pub>>();
        @AuraEnabled public boolean isMultiple;
     
        public ManualsDataWrapper(ManualsResultData manuals,String modelId){
            isMultiple =true;
            Integer count =0;
            try{
                if(manuals.mot.model != null){
                    for(cls_model m:manuals.mot.model){
                        if(m.model_id == modelId){
                       List<cls_pub> pubList = new List<cls_pub>();
                        for(cls_pub p:m.pubs.pub){
                            cls_pub pub = p;
                            pubList.add(pub);
                            count++;
                        }
                       manualsByModel.put(m.model_id,pubList);
                        }
                    }
                }
                if(count == 1){
                    isMultiple=false;
                }
 
         }catch(Exception e){
         }
 
        }
    }


    public class ManualsResultData{
        public cls_mot mot {get;set;}
   }
   class cls_mot {
       public List<cls_model> model {get;set;}
   }
   class cls_model {
       public String country_cd {get;set;}
       public String lanugage_cd {get;set;}	
       public String vin {get;set;}	
       public String model_id {get;set;}	
       public cls_pubs pubs {get;set;}
   }
   class cls_pubs {
       @AuraEnabled public List<cls_pub> pub {get;set;}
   }
   class cls_pub {
       public String country_cd {get;set;}	
       public String language_cd {get;set;}	
       @AuraEnabled public String model {get;set;}	
       @AuraEnabled public String title {get;set;}	//Common replacement parts guide
       @AuraEnabled public String trim {get;set;}	
       @AuraEnabled public String url {get;set;}	//https://cdn.powerequipment.honda.com/pe/pdf/manuals/otr54654.pdf
       @AuraEnabled public String year {get;set;}	
   }
    
    public class SSPSSO{
        @AuraEnabled
        public Integer statusCode {get;set;}
        @AuraEnabled
        public String response {get;set;}
    }
    
    public class VehicleEligibility{
        @AuraEnabled
        public string status {get;set;}
        @AuraEnabled
        public EligibilityResponse responseBody {get;set;}
    }
    
    public class EligibilityResponse{
        @AuraEnabled
        public boolean eligibilityFlag {get;set;}
        @AuraEnabled
        public List<EligibleProduct>  eligibleProducts {get;set;}
    }
    
    public class EligibleProduct{
        @AuraEnabled
        public string productName {get;set;}
    }
    
    public class CustomerIdentity{
        @AuraEnabled
        public string status {get;set;}
        @AuraEnabled
        public String hondaCustomerCode {get;set;}
        
    }
    
    public class Attribute {
        @AuraEnabled
        public string id {get;set;}
        @AuraEnabled
        public string divisionId {get;set;}
        @AuraEnabled
        public string subDivisionCd {get;set;}
        @AuraEnabled
        public string division {get;set;}
        @AuraEnabled
        public String modelId {get;set;}
        @AuraEnabled
        public String carrierId {get;set;}
        @AuraEnabled
        public String manufacturerId {get;set;}
        @AuraEnabled
        public String phoneId {get;set;}
        @AuraEnabled
        public String productIdentifier {get;set;}
        @AuraEnabled
        public String event {get;set;}
        @AuraEnabled
        public String vehicleAlias {get;set;}
        @AuraEnabled
        public String licensePlate {get;set;}
        @AuraEnabled
        public String vin {get;set;}
        @AuraEnabled
        public String year {get;set;}
        @AuraEnabled
        public String applicationId {get;set;}
        @AuraEnabled
        public Boolean echoInput {get;set;}
        @AuraEnabled
        public String serverIp {get;set;}
        @AuraEnabled
        public String sessionId {get;set;}
        @AuraEnabled
        public String domain {get;set;}
        @AuraEnabled
        public String environment {get;set;}
        @AuraEnabled
        public String checkSum {get;set;}
        @AuraEnabled
        public String programName {get;set;}
        @AuraEnabled 
        public String accessToken {get;set;}
        @AuraEnabled
        public String city {get;set;}
        @AuraEnabled
        public String state {get;set;}
        @AuraEnabled
        public String zipcode {get;set;}
        @AuraEnabled
        public String poiType {get;set;}
        @AuraEnabled
        public String searchRadius {get;set;}
        @AuraEnabled
        public String pOIId {get;set;}
        @AuraEnabled
        public String filters {get;set;}
        @AuraEnabled
        public String key {get;set;}
        @AuraEnabled
        public String latitude {get;set;}
        @AuraEnabled
        public String longitude {get;set;}
        @AuraEnabled
        public String requestBody {get;set;}
        @AuraEnabled
        public String email {get;set;}
        @AuraEnabled
        public String poiName {get;set;}
        @AuraEnabled
        public String productDivisionCD {get;set;}
        @AuraEnabled
        public String referenceCoordinates {get;set;}
        @AuraEnabled 
        public String federationIdentifier {get;set;}
    }
    
    public class Error {
        @AuraEnabled
        public Header header {get;set;}
        @AuraEnabled
        public String status {get;set;}
    }
    
    public class Header {
        @AuraEnabled
        public String code {get;set;}
        @AuraEnabled
        public String errorType {get;set;}
        @AuraEnabled
        public String node {get;set;}
        @AuraEnabled
        public String errorDescription {get;set;}
        @AuraEnabled
        public String errorCode {get;set;}
    }
    
    public class Subscriptions {
        @AuraEnabled
        public List<Packages> packages {get;set;}
        @AuraEnabled
        public ManageSubscriptions manageSubscriptions {get;set;}
        @AuraEnabled
        public VehicleFeatures vehicleFeature {get;set;}
        @AuraEnabled
        public List<Packages> allDefaultPackages {get;set;}
    }
    
    public class ManageSubscriptions {
        @AuraEnabled
        public List<VehicleInfo> vehicleInfo {get;set;}
        @AuraEnabled
        public List<Devices> devices {get;set;}
    }
    
    public class MyVehicle {
        @AuraEnabled
        public List<VehicleInfo> vehicleInfo {get;set;}
    }
    
    public class VehicleInfo { 
        @AuraEnabled public String VIN {get;set;}
        @AuraEnabled public String VINHeader {get;set;}
        @AuraEnabled public String divisionCode {get;set;}
        @AuraEnabled public String divisionName {get;set;}
        @AuraEnabled public String modelYear {get;set;}
        @AuraEnabled public String modelId {get;set;}
        @AuraEnabled public String modelCode {get;set;}
        @AuraEnabled public String modelTypeCode {get;set;}
        @AuraEnabled public String modelTrimTypeCode {get;set;}
        @AuraEnabled public String factoryCode {get;set;}
        @AuraEnabled public String factoryName {get;set;}
        @AuraEnabled public String exteriorBaseColorCode {get;set;}
        @AuraEnabled public String exteriorBaseColorName {get;set;}
        @AuraEnabled public String exteriorMarketingColorCode {get;set;}
        @AuraEnabled public String manufacturingColorCode {get;set;}
        @AuraEnabled public String modelGroupNameFriendly {get;set;}
        @AuraEnabled public String embeddedNavi {get;set;}
        @AuraEnabled public String telematicsFlag {get;set;}
        @AuraEnabled public String telematicsPlatform {get;set;}
        @AuraEnabled public String asset34FrontPath {get;set;}
        @AuraEnabled public String countryCoded {get;set;}
        @AuraEnabled public String largeFrontImage {get;set;}
        @AuraEnabled public String enrollment {get;set;}
        @AuraEnabled public String enrollmentMethod {get;set;}
        @AuraEnabled public String telematicsUnit {get;set;}
        @AuraEnabled public String ownership {get;set;}
        @AuraEnabled public String associationDate {get;set;}
        @AuraEnabled public String relationshipStatus {get;set;}
        @AuraEnabled public String thirdPartyEligibilityStatus {get;set;}
    }
    
    public class FeatureList {
        @AuraEnabled
        public VehicleDetails vehicle {get;set;}
        @AuraEnabled
        public List<Feature> feature {get; set;}
        @AuraEnabled
        public Model model {get;set;}
    }
    
    public class PackagesByTrim{
        @AuraEnabled
        public String trimName {get;set;}
        @AuraEnabled
        public String modelId {get;set;}
        @AuraEnabled
        public String telematicsPlatform {get;set;}
        @AuraEnabled
        public String telematicsUnit {get;set;}
        @AuraEnabled
        public List<PackageFeatures> packageToFeatures {get;set;}
    }
    
    public class PackageFeatures{
        @AuraEnabled
        public String packageName {get; set;}
        @AuraEnabled
        public Boolean isAvailable {get; set;}
        @AuraEnabled
        public List<Feature> features {get; set;}
        
        public PackageFeatures(String packageName){
            this.packageName = packageName;
            this.features = new List<Feature>();
            this.isAvailable = false;
        }
    }
    
    public class VehicleFeatures{
        @AuraEnabled
        public VehicleDetails vehicle  {get;set;}
    }
    
    public class VehicleDetails {
        @AuraEnabled
        public String modelId  {get;set;}
        @AuraEnabled
        public string enrollment {get; set;}
        @AuraEnabled
        public string ownership {get; set;}
        @AuraEnabled
        public String telematicsPlatform  {get;set;}
        @AuraEnabled
        public String telematicsUnit  {get;set;}
        @AuraEnabled
        public String telematicsFlag  {get;set;}
        @AuraEnabled
        public List<Model> model {get;set;}
        @AuraEnabled public String VIN {get;set;}
        @AuraEnabled public String divisionCode {get;set;}
        @AuraEnabled public String divisionName {get;set;}
        @AuraEnabled public String modelYear {get;set;}
        @AuraEnabled public String modelCode {get;set;}
        @AuraEnabled public String modelTrimTypeCode {get;set;}
    }
    
    public class Models {
        @AuraEnabled
        public List<Model> model {get;set;}
    }
    
    public class Model {
        @AuraEnabled
        public String modelId {get; set;}
        @AuraEnabled
        public String telematicsUnit {get; set;}
        @AuraEnabled
        public List<Feature> feature {get; set;}
        @AuraEnabled
        public String modelTrimTypeCode {get; set;}
        @AuraEnabled
        public String telematicsPlatform  {get;set;}
        @AuraEnabled
        public String modelMsrp {get;set;}
        @AuraEnabled 
        public String modelTypeCode {get;set;}
        @AuraEnabled 
        public String modelTrimMarketingName {get;set;}
        @AuraEnabled 
        public String modelGroupNameFriendly {get;set;}
    }
    
    public class Feature {
        @AuraEnabled
        public String packageName {get; set;}
        @AuraEnabled
        public String featureCategoryDesc {get; set;}
        @AuraEnabled
        public String featureName {get; set;}
        @AuraEnabled
        public String featureDisplayName {get; set;}
        @AuraEnabled
        public String featureDescription {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String icon {get; set;}
        @AuraEnabled
        public String variant {get; set;}
        @AuraEnabled
        public Boolean showFooter {get; set;}
        @AuraEnabled
        public Boolean hasCurrentFeature {get; set;}
        @AuraEnabled
        public Boolean includesAmazon {get; set;}
        @AuraEnabled
        public Boolean isError {get; set;}
        @AuraEnabled
        public Boolean isNewUser {get; set;}
        @AuraEnabled
        public Boolean hasAmazonFeature {get; set;}
        @AuraEnabled
        public Boolean hasDriverFeedbackFeature {get; set;}
        @AuraEnabled
        public String linkLabel {get; set;}
        @AuraEnabled
        public String featureIcon {get; set;}
        
        @AuraEnabled
        public String id; //107
        @AuraEnabled
        public String name; //Phone Pairing-Passive
        @AuraEnabled
        public String description; //Ability of the phone to successfully pair and connect to the handsfree system by initiating the pairing from the HFL system.
        @AuraEnabled
        public String sortOrder; //5
    }
    
    public class MyProfile {
        @AuraEnabled
        public List<Devices> devices {get; set;}   
        @AuraEnabled
        public List<Packages> packages {get; set;}
    }
    
    public class Devices {
        @AuraEnabled
        public List<Programs> programs {get; set;}
    }
    
    public class Programs {
        @AuraEnabled
        public String role {get; set;}
        @AuraEnabled
        public String enrollmentStatus {get; set;}
        @AuraEnabled
        public List<String> packageTypes {get; set;}
        @AuraEnabled
        public List<Packages> packages {get; set;}
        @AuraEnabled
        public String name {get; set;}
    }
    
    public class Packages {
        @AuraEnabled
        public String packageDisplayName {get; set;}
        @AuraEnabled
        public String packageName {get; set;}
        @AuraEnabled
        public String packageAPIName {get; set;}
        @AuraEnabled
        public String subscriptionStatus {get; set;}
        @AuraEnabled
        public String enrollmentEndDate {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String link {get; set;}
        @AuraEnabled
        public String icon {get; set;}
        @AuraEnabled
        public String variant {get; set;}
        @AuraEnabled
        public String textVariant {get;set;}
    }
    public class PhoneData{
        @AuraEnabled
        public Mot mot {get;set;}
    }
    public class PhoneResultData{
        @AuraEnabled
        public Mot mot {get;set;}
    }
    public class Mot {
        @AuraEnabled public Db_results db_results{get;set;}
    }
    public class Db_results {
        @AuraEnabled public Carriers carriers{get;set;}
        @AuraEnabled public Features features{get;set;}
    }
    public class Carriers {
        @AuraEnabled public List<Carrier> carrier{get;set;}
    }
    public class Carrier {
        @AuraEnabled public String id{get;set;}	
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public Manufacturers manufacturers{get;set;}
    }
    public class Manufacturers {
        @AuraEnabled public List<Manufacturer> manufacturer{get;set;}
    }
    public class Manufacturer {
        @AuraEnabled public String id{get;set;}	
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public Phones phones{get;set;}
    }
    public class Phones{
        @AuraEnabled public List<phone> phone{get;set;}
    }
    public class Phone {
        @AuraEnabled public String id{get;set;}
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public String thumb{get;set;}
    }
    public class PhoneDataWrapper {
        @AuraEnabled public boolean arePhonesAvailable;
        @AuraEnabled public List<Carrier> carrierList;
        @AuraEnabled public Map<String,List<Manufacturer>> manufacturerMap;
        @AuraEnabled public Map<String,List<Phone>> phoneMap;
        public  PhoneDataWrapper(){
            arePhonesAvailable=false; 
            carrierList=new List<Carrier>();
            manufacturerMap=new Map<String,List<Manufacturer>>();
            phoneMap=new Map<String,List<Phone>>();
        }
        public  PhoneDataWrapper(PhoneData phoneData){
            Integer phoneCount=0; 
            arePhonesAvailable=false; 
            carrierList=new List<Carrier>();
            manufacturerMap=new Map<String,List<Manufacturer>>();
            phoneMap=new Map<String,List<Phone>>();
            try{
                if(phoneData.mot.db_results.carriers.carrier != null){
                    for(Carrier c:phoneData.mot.db_results.carriers.carrier){
                        carrierList.add(c);
                        List<Manufacturer> manufacturerList=new List<Manufacturer>();    
                        for(Manufacturer m:c.manufacturers.manufacturer){
                            manufacturerList.add(m);
                            List<Phone> phoneList=new List<Phone>();    
                            for(Phone p:m.phones.phone){
                                phoneList.add(p);
                                phoneCount=phoneCount+1;
                            }
                            phoneMap.put(c.id+m.id,phoneList);
                        }
                        manufacturerMap.put(c.id,manufacturerList); 
                    }
                    if(phoneCount > 0){
                        arePhonesAvailable=true;
                    }
                }
            }catch(Exception e){
            }
        }
    }
    
    public class Features {
        @AuraEnabled public List<Feature_category> feature_category;
    }
    public class Feature_category {
        @AuraEnabled public String id; //BSC
        @AuraEnabled public String name; //Basic Features
        @AuraEnabled public String sortOrder; //5
        @AuraEnabled public List<feature> feature;
    }

    public class PhonePbResultData{
        @AuraEnabled public MotPb mot {get;set;}
    }
    public class MotPb {
        @AuraEnabled public Db_resultsPb db_results{get;set;}
    }
    public class Db_resultsPb {
        @AuraEnabled public carriersPb carriers{get;set;}
    }
    public class carriersPb{
        @AuraEnabled public carrierPb carrier{get;set;}
    }
    public class carrierPb{
        @AuraEnabled public modelPb model{get;set;}
    }
    public class modelPb{
        @AuraEnabled public phonePb phone{get;set;}
    }	
    public class phonePb{
        @AuraEnabled public compatibility compatibility{get;set;}
        @AuraEnabled public pairing_instruction pairing_instruction{get;set;}
    }
    public class compatibility{
        @AuraEnabled public String passed{get;set;}
        @AuraEnabled public String text{get;set;}
    }
    public class pairing_instruction{
        @AuraEnabled public list<instruction> instruction{get;set;}
    }
    public class instruction{
        @AuraEnabled public String type{get;set;}
        @AuraEnabled public list<step> step{get;set;}
        @AuraEnabled public instructionInner instruction{get;set;}
    }
    public class instructionInner{
        @AuraEnabled public String type{get;set;}
        @AuraEnabled public list<step> step{get;set;}
    }
    public class step{
        @AuraEnabled public String num{get;set;}
        @AuraEnabled public String text{get;set;}
    }
    
    public class ParingDataWrapper{
        @AuraEnabled public boolean iscompatible=false;
        @AuraEnabled public map<String,List<step>> data;
        @AuraEnabled public List<step> onThePhonedata;
        @AuraEnabled public List<step> firstPhonedata;
        @AuraEnabled public List<step> subSequentdata;
        @AuraEnabled public boolean isOnThePhonedata=false;
        @AuraEnabled public boolean isFirstPhonedata=false;
        @AuraEnabled public boolean isSubSequentdata=false;
        
        public ParingDataWrapper(PhonePbResultData p){
            try{
            compatibility comp = p.mot.db_results.carriers.carrier.model.phone.compatibility;
            if(comp.passed == 'Y'){
                iscompatible=true;
            }
            data=new map<String,List<step>>();
            try{
            for(instruction i:p.mot.db_results.carriers.carrier.model.phone.pairing_instruction.instruction){
                List<Step> steps=new List<Step>();
                for(Step s:i.step){
                    Step st=new Step();
                    st.num = s.num;
                    st.text = s.text;
                    steps.add(st); 
                }
                data.put(i.type,steps);
            }
            instructionInner ii=p.mot.db_results.carriers.carrier.model.phone.pairing_instruction.instruction[0].instruction;
            List<Step> steps=new List<Step>();
            for(Step s:ii.step){
                Step st=new Step();
                st.num = s.num;
                st.text = s.text;
                steps.add(st); 
            }
            data.put(ii.type,steps);
        }catch(Exception e){}
            if(data.containsKey('First Time')){    
                firstPhonedata=data.get('First Time');
                isFirstPhonedata=true;
                    }
            if(data.containsKey('On the Phone')){
                onThePhonedata=data.get('On the Phone');
                isOnThePhonedata=true;
            }
            if(data.containsKey('Subsequent')){
                subSequentdata=data.get('Subsequent');
                isSubSequentdata=true;
            }
                }catch(Exception e){
            }
        }  
    }

    public class FeatureCategoryWrapper{
        @AuraEnabled public boolean hasData=false;
        @AuraEnabled public List<Feature_category>  featurecategory;
        
        public FeatureCategoryWrapper(PhoneResultData phoneResultData){
            try{
                featurecategory=new List<Feature_category>();
                featurecategory=phoneResultData.mot.db_results.features.feature_category;
                hasData=true;
            }catch(Exception e){
                e.getCause();
            } 
        }
    }
    @AuraEnabled (cacheable = true)
    public static String getProductByVin(String vin, String divisionId) {
        List<String> endpointParameters = new List<String>{vin};
            Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        OwnHttpCalloutService service = new OwnHttpCalloutService('VinLookUp', attribute, endpointParameters);
        String response = service.sendRequest().getBody();
        return response;
    }
    @AuraEnabled (cacheable = true)
    public static String vinMasterSearchResponse(String vin, String divisionId){
        return vinMasterSearch(vin, divisionId, '').getBody();
    }

    public static HttpResponse vinMasterSearch(String vin, String divisionId){
        return vinMasterSearch(vin, divisionId, '');
    }
    
    public static HttpResponse vinMasterSearch(String vin, String divisionId, String subDivisionCd){

        List<String> endpointParameters = new List<String>{};
        Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        attribute.vin = vin;
        OwnHttpCalloutService service;
        if (!String.isEmpty(subDivisionCd)){
            attribute.subDivisionCd = subDivisionCd;
            System.debug('***** SUBDIVISION CODE SET TO: ' + attribute.subDivisionCd);
        }

        setJWTAccessToken();

        HttpResponse response = new HttpResponse();

        if (divisionId == 'A' || divisionId == 'B' || divisionId == 'M'){

            OwnAdditionalApiParams__mdt additionalRequestParameters = [ SELECT Application_Id__c, Check_Sum__c, Domain__c, Echo_Input__c,
                                                                        Environment__c, Server_Ip__c, Session_Id__c
                                                                        FROM OwnAdditionalApiParams__mdt
                                                                        WHERE DeveloperName = 'VinMasterSearch'
                                                                        ];
            attribute.applicationId = additionalRequestParameters.Application_Id__c;
            attribute.echoInput = additionalRequestParameters.Echo_Input__c;
            attribute.serverIp = additionalRequestParameters.Server_Ip__c;
            attribute.sessionId = additionalRequestParameters.Session_Id__c;
            attribute.domain = additionalRequestParameters.Domain__c;
            attribute.environment = additionalRequestParameters.Environment__c;
            attribute.checkSum = additionalRequestParameters.Check_Sum__c;
            service = new OwnHttpCalloutService('VinMasterSearch', attribute, endpointParameters);
            
            response = service.sendRequest();
       //     System.debug('@@TestVIN'+JSON.serialize(response));
        }
        else if (divisionId == 'P'){

            service = new OwnHttpCalloutService('GetModelsBySerialNo', attribute, endpointParameters);

            response = service.sendRequest();
        }
        if(response.getStatusCode() != 200 && response.getStatusCode() != 201){
            System.enqueueJob(new OwnMyGarageUtils('vinMasterSearch',vin+divisionId,0,'OwnAPIController','vinMasterSearch','API',''+service.getRequest()+service.getHeaderParameters()+service.getRequestBody(),response.getBody(),''+response.getStatusCode()));
        }
        Error error = (Error)JSON.deserialize(response.getBody(), Error.class);
        if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
            setJWTAccessTokenToNULL();
        }

        return response;
    }

    public static HttpResponse getAllUserVehiclesFromMyVehicles(){
        Attribute attribute = new Attribute();
        attribute.divisionId = 'A';
        setJWTAccessToken();
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.MyGarageConnectedFeature');
        String cachedToken = (String)orgPart.get('JWTAccessToken');
        OwnHttpCalloutService getAllVehiclesService = new OwnHttpCalloutService('MyVehiclesGetAll', attribute, new List<String>());
        Map<String, String> headersMap = getAllVehiclesService.getHeaderParameters();
        HttpResponse response = getAllVehiclesService.sendRequest();

        Error error = (Error)JSON.deserialize(response.getBody(), Error.class);
        if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
            setJWTAccessTokenToNULL();
        }

        return response;
    }

    public static HttpResponse getProductChooserData(String year, String brand){
        HttpResponse response;
        setJWTAccessToken();
        if (brand == 'Acura'){
            /* List<InputParamsWrapper> headerParams = (List<InputParamsWrapper>) JSON.deserialize(calloutMetadata.HeaderParameters__c, InputParamsWrapper.class); */
            //String endPoint = this.calloutMetadata.Endpoint__c;
            OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
            attribute.year = year;
            attribute.divisionId = 'A';
            OwnHttpCalloutService productChooserCalloutService = new OwnHttpCalloutService('ProductChooser_Acura', attribute, new List<String>());
            response = productChooserCalloutService.sendRequest();
        }
        else if (brand == 'Honda'){
            /* List<InputParamsWrapper> headerParams = (List<InputParamsWrapper>) JSON.deserialize(calloutMetadata.HeaderParameters__c, InputParamsWrapper.class); */
            
            OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
            attribute.year = year;
            attribute.divisionId = 'A';
            OwnHttpCalloutService productChooserCalloutService = new OwnHttpCalloutService('ProductChooser_Honda', attribute, new List<String>());
            
            response = productChooserCalloutService.sendRequest();
        }
        else if (brand == 'Powersports'){
            OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
            attribute.year = year;
            attribute.divisionId = 'A';
            OwnHttpCalloutService productChooserCalloutService = new OwnHttpCalloutService('ProductChooser_Powersports', attribute, new List<String>());
            
            response = productChooserCalloutService.sendRequest();
        }
        System.debug(response.getBody());
        Error error = (Error)JSON.deserialize(response.getBody(), Error.class);
        if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
            setJWTAccessTokenToNULL();
        }

        return response;
    }
    @AuraEnabled (cacheable = true)
    public static RecallData getRecallsByModelId(String modelId, String divisionId) {
        if(String.isBlank(modelId) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.modelId)){
                    modelId = productContext.product.modelId;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        //setJWTAccessToken();
        List<String> endpointParameters = new List<String>();
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.modelId = modelId;
        attribute.divisionId = divisionId;
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        RecallData recallDataCache;
        RecallData recalls = new RecallData();
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarage');
            recallDataCache = (RecallData)sessionPart.get('rm' + attribute.modelId);
        }
        if(recallDataCache == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('RecallDataByModelID', attribute, endpointParameters);
            HttpResponse res= new HttpResponse();
            res=service.sendRequest();
            String response = validateRecallResponse(res.getBody());
            System.debug('response'+response);
            if(res.getStatusCode() != 200 && res.getStatusCode() != 201)
        	{
                System.enqueueJob(new OwnMyGarageUtils('RecallDataByModelID',modelId+divisionId,0,'OwnAPIController','getRecallsByModelId','API',''+service.getRequest()+service.getHeaderParameters()+service.getRequestBody(),res.getBody(),''+res.getStatusCode()));
        	}
            Error error = (Error)JSON.deserialize(response, Error.class);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                setJWTAccessTokenToNULL();
            }
            recalls = (RecallData)JSON.deserialize(response, RecallData.class);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarage');
                sessionPart.put('rm' + attribute.modelId, recalls);
            }
        }else{
            recalls = recallDataCache;
        }
        
        System.debug('recalls'+recalls);
        return recalls;
        
    }
    /*@AuraEnabled (cacheable = true)
    Public static string getManualIds(){
        List<String> endpointParameters = new List<String>{};
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'A';
        OwnHttpCalloutService service = new OwnHttpCalloutService('GetManualsByVINAuto', attribute, endpointParameters);
        String response = service.sendRequest().getBody();
        system.debug('==11==22==33==44=='+response);
        return response;
    }*/
    private static String validateRecallResponse(String apiResponse){
        System.debug(apiResponse);
        Boolean responseListError = false;
        Map<String, Object> responseTopLevel = (Map<String, Object>) JSON.deserializeUntyped(apiResponse);
        Map<String, Object> response = (Map<String, Object>) responseTopLevel.get('response');
        System.debug(response);
        Map<String, Object> recallsResponse = (Map<String, Object>) response.get('recalls_response');
        System.debug(recallsResponse);
        Map<String, Object> responseL2 = (Map<String, Object>) recallsResponse.get('Response');
        System.debug(responseL2);
        Map<String, Object> recall = (Map<String, Object>) responseL2.get('Recall');
        System.debug(recall);
        Map<String, Object> campaignType = (Map<String, Object>) recall.get('CampaignType');
        System.debug(campaignType);
        try{
            List<Object> campaign = (List<Object>) campaignType.get('Campaign');
        }
        catch (Exception e){
            responseListError = true;
            System.debug('%%%Exception ' + e);
            System.debug(recall.get('CampaignType'));
            campaignType.put('Campaign', (List<Object>) JSON.deserializeUntyped('[' + JSON.serialize(campaignType.get('Campaign')) + ']'));
            System.debug(recall.get('CampaignType'));
        }
        System.debug(responseTopLevel);
        String validResponse = JSON.serialize(responseTopLevel);
        System.debug(validResponse);
        return responseListError ? JSON.serialize(responseTopLevel) : apiResponse;
    }

    @AuraEnabled
    public static String getProductServiceNotes(String vin, String divisionId){
        List<String> endpointParameters = new List<String>{};
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = divisionId;
        String response = '';

        System.debug('Before OwnHttpCalloutService');

        if (divisionId == 'A') {
            OwnHttpCalloutService service = new OwnHttpCalloutService('ServiceNotesHonda', attribute, endpointParameters);
            service.setHeaderParameter('input', '{\"VIN\":\"'+vin+'\",\"DATASOURCE\":\"RepairOrders\"}');

            System.debug('service printout, ' + service);

            response = service.sendRequest().getBody();
            system.debug('getProductServicesNotes Honda ' + response);
        } else if (divisionId == 'B') {
            OwnHttpCalloutService service = new OwnHttpCalloutService('ServiceNotesAcura', attribute, endpointParameters);
            service.setHeaderParameter('input', '{\"VIN\":\"'+vin+'\",\"DATASOURCE\":\"RepairOrders\"}');

            System.debug('service printout, ' + service);

            response = service.sendRequest().getBody();
            system.debug('getProductServicesNotes Acura ' + response);
        }
        
        return response;
    }
    
	@AuraEnabled (cacheable = true)
    public static Map<String, Object> getOffers(String productDivisionCD){
        List<String> endpointParameters = new List<String>{};
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'A';
        attribute.productDivisionCD = productDivisionCD;
        OwnHttpCalloutService service = new OwnHttpCalloutService('SpecialOffers', attribute, endpointParameters);
        String response = service.sendRequest().getBody();
        Map<String, Object> completeDetailResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        return completeDetailResponse;
    }

    @AuraEnabled (cacheable = true)
    public static Map<String, Object> getEmissionWarrantyBooklet(String modelId){
        List<String> endpointParameters = new List<String>{};
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'A';
        attribute.modelId = modelId;
        OwnHttpCalloutService service = new OwnHttpCalloutService('EmissionWarrantyBooklet', attribute, endpointParameters);
        String response = service.sendRequest().getBody();
        Map<String, Object> completeDetailResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('$$completeDetailResponse: '+completeDetailResponse);
        return completeDetailResponse;
    }
   
    @AuraEnabled
    public static HowToGuide_Response getCompleteDetails(String divisionId, String modelYear, String model){
        try{
            String url;
            url = 'content/' + modelYear + '/Features.' + modelYear +'.'+ model +'.xml';
            url = url.replace(' ','%20');
            List<String> endpointParameters = new List<String>{url};
            OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
            attribute.divisionId = divisionId;
            String endpoint;
            if(divisionId =='A'){
                endpoint = 'getHondaHowToGuides';
            }else if(divisionId =='B'){
                endpoint = 'getAcuraHowToGuides';
            }
            OwnHttpCalloutService service = new OwnHttpCalloutService(endpoint, attribute, endpointParameters);
            HttpResponse res = service.sendRequest();
            HowToGuide_Response wrapObj = new HowToGuide_Response();
            if(res.getStatusCode() == 200){
                String xmlResponse = res.getBody();
                // xmlResponse = xmlResponse.remove('<![CDATA[');
                // xmlResponse = xmlResponse.remove(']]>');
                // xmlResponse = xmlResponse.replace('&','&#38;');
                // xmlResponse = xmlResponse.replace('<p>','&lt;p&gt;');
                // xmlResponse = xmlResponse.replace('</p>','&lt;/p&gt;');
                // // xmlResponse = xmlResponse.replace('<a','&lt;a');
                // // xmlResponse = xmlResponse.replace('>','&gt;');
                // // xmlResponse = xmlResponse.replace('</a>','&lt;/a&gt;');
                // xmlResponse = xmlResponse.replace('<h3>','&lt;h3&gt;');
                // xmlResponse = xmlResponse.replace('</h3>','&lt;/h3&gt;');
                // xmlResponse = xmlResponse.replace('<sup>','&lt;sup&gt;');
                // xmlResponse = xmlResponse.replace('</sup>','&lt;/sup&gt;');
                // xmlResponse = xmlResponse.replace('<em>','&lt;em&gt;');
                // xmlResponse = xmlResponse.replace('</em>','&lt;/em&gt;');
                // xmlResponse = xmlResponse.remove('\n');

                System.debug('xmlResponse'+xmlResponse);
                String originalResponse = xmlResponse;
                String newStr = '';
                for(Integer i = 0; i< originalResponse.length();){  
                    System.debug('newStr Index : '+originalResponse.length());
                    newStr += originalResponse.substring(0,originalResponse.indexOf('<![CDATA['));
                    Integer htmlStartingIndex = originalResponse.indexOf('<![CDATA[')+9;
                    Integer htmlEndIndex = originalResponse.indexOf(']]>');
                    newStr += originalResponse.substring(htmlStartingIndex,htmlEndIndex).escapeHTML4();
                    System.debug('newStr originalResponse: '+originalResponse);
                    originalResponse = originalResponse.substring(htmlEndIndex +3);
                    if(originalResponse.indexOf('<![CDATA[') == -1){
                        newStr += originalResponse;
                        break;
                    }
                    //i = htmlEndIndex + 3;
                }
                newStr = newStr.replace('&lt;sup&gt;reg&lt;/sup&gt;','&lt;sup&gt;&reg;&lt;/sup&gt;');
                newStr = newStr.replace('&lt;p&gt;[OTA]&lt;/p&gt;','');
                System.debug('newStr->'+newStr);
                Dom.Document doc = new Dom.Document(); 
                doc.load(newStr);
                Dom.XMLNode response = doc.getRootElement();
                List<feature_H> featureList = new List<feature_H>();
                for(Dom.XMLNode features : response.getChildElements()) {
                    System.debug('features-->'+features);
                    feature_H featureObj = new feature_H();
                    featureObj.id = features.getAttribute('id', null);
                    if(features.getChildElement('title', null) != null){
                        featureObj.title = features.getChildElement('title', null).getText();
                        featureObj.title = featureObj.title.replace('reg', '&reg;');
                    }
                    if(features.getChildElement('disclaimer', null) != null){
                        featureObj.disclaimer = features.getChildElement('disclaimer', null).getText();
                        featureObj.disclaimer = featureObj.disclaimer.replace('reg', '&reg;');
                    } 
                    if(features.getChildElement('view', null) != null){
                        List<View> viewList = new List<View>();
                        for(Dom.XMLNode view : features.getChildElements()) {
                            View viewObj = new View();
                            viewObj.type = view.getAttribute('type', null);
                            if(view.getChildElement('title', null) != null){
                                viewObj.title = view.getChildElement('title', null).getText();
                                viewObj.title =  viewObj.title.replace('reg', '&reg;');
                            }
                            if(view.getChildElement('content', null) != null){
                                System.debug('viewObj.content ='+view.getChildElement('content', null));
                                viewObj.content = view.getChildElement('content', null).getText();
                                viewObj.content = viewObj.content.replace('reg', '&reg;');
                            }
                            if(view.getChildElement('data', null) != null){
                                viewObj.data = view.getChildElement('data', null).getText();
                            }
                            if(String.isNotBlank(viewObj.type) && viewObj.type != 'Video'){
                                viewList.add(viewObj);
                            }
                        }
                        if(viewList != null && viewList.size() >0){
                            featureObj.view = viewList;
                        }
                    }
                    if(features.getChildElement('links', null) != null){
                        List<Link> linkList = new List<Link>();
                        for(Dom.XMLNode links : features.getChildElements()) {
                            for(Dom.XMLNode link : links.getChildElements()) {
                                Link linkObj = new Link();
                                if(link.getChildElement('text', null) != null){
                                    linkObj.text = link.getChildElement('text', null).getText();
                                    linkObj.text =  linkObj.text.replace('reg', '&reg;');
                                }
                                if(link.getChildElement('src', null) != null){
                                    linkObj.src = link.getChildElement('src', null).getText();
                                    linkObj.src =  linkObj.src.replace('reg', '&reg;');
                                }
                                if(string.isNotBlank(linkObj.text) || string.isNotBlank(linkObj.src)){
                                    linkList.add(linkObj);
                                }
                            }
                        }
                         if(linkList != null && linkList.size() >0){
                            featureObj.links = linkList;
                        }
                    }
                    if(featureObj.view != null && featureObj.view.size() >0){
                        featureList.add(featureObj);
                        wrapObj.feature = featureList;
                    }
                }
                wrapObj.error = false;
            }else{
                wrapObj.error = true;
            }
            return wrapObj;
        }catch(Exception e){
            System.debug('Exception--->'+ e.getMessage());
            System.debug('Exception--->'+ e.getStackTraceString());
            HowToGuide_Response wrapObj = new HowToGuide_Response();
            wrapObj.error = true;
            return wrapObj;
        }
        
    }
   
    public class HowToGuide_Response{
        @AuraEnabled public List<feature_H> feature {get;set;}
        @AuraEnabled public Boolean error {get;set;}
    }
    public class feature_H{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String title {get;set;}
        @AuraEnabled public String disclaimer {get;set;}
        @AuraEnabled public List<View> view {get;set;}
        @AuraEnabled public List<Link> Links {get;set;}
    }
    public class View{
        @AuraEnabled public String title {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String content {get;set;}
        @AuraEnabled public String data {get;set;}
    }
    public class Link{
        @AuraEnabled public String text {get;set;}
        @AuraEnabled public String src {get;set;}
    }
}