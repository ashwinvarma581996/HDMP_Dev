//============================================================================
// Title:    Honda MyGarage Experience - My Account "Honda/AcuraLink Subscription Status"
//
// Summary:  This is the My Account "Honda/AcuraLink Subscription Status" html seen at the page of the Honda MyGarage Community
//
// Details:  My Account for pages
//
// History:
// November 22, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================

import { LightningElement, track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getMyProducts } from 'c/ownDataUtils';
import getManageSubscriptions from '@salesforce/apex/OwnAPIController.getManageSubscriptions';
import getValidateCustomerIdentity from '@salesforce/apex/OwnAPIController.getValidateCustomerIdentity';
import getHondaProductID from '@salesforce/apex/OwnProductController.getHondaProductID';
import getSSPSSOAcuralink from '@salesforce/apex/OwnAPIController.getSSPSSOAcuralink';
import getSSPSSOHondalink from '@salesforce/apex/OwnAPIController.getSSPSSOHondalink';
import getPackages from '@salesforce/apex/OwnAPIController.getPackages'; 
import { getProductContext, ISGUEST, addProduct, nonConnectedPlatformMap } from 'c/ownDataUtils';
import { updateRecord } from 'lightning/uiRecordApi';
import UserId from '@salesforce/user/Id';
import ID from '@salesforce/schema/User.Id';
import CUSTOMERID from '@salesforce/schema/User.CustomerID__c';
import LASTVISITEDPRODUCT from '@salesforce/schema/User.Last_Visited_Product_ID__c';
import VIN from '@salesforce/schema/User.VIN__c';
import BRAND from '@salesforce/schema/User.Brand__c';
import getSSO from '@salesforce/apex/OwnAPIController.getSSO';
import getTrialEligibility from '@salesforce/apex/OwnAPIController.getTrialEligibility';

export default class OwnAutoLinkSubscriptionStatus extends OwnBaseElement {
   
    image = this.myGarageResource() + '/images/product.png';
    @api packages =[];//= ['Link', 'Security', 'Remote', 'Concierge','Telematics'];
    @track products = [];
    @api subscriptions = [];
    @api vehicleInfos;
    @track isGuest;
    @api ssoInitiatingURL;
    @api androidAppLink;
    @api iosAppLink;
    warningicon;
    @track connectedPlatforms;
    zsTelematicsPlatform = '2ZS';
    isFreeTrailEligible =false;

    @track showPopup = false;
    @api playStoreURL;
    @api appStoreURL;
    @api acuraPlayStoreURL;
    @api acuraAppStoreURL;
    popupAppStoreIcon = this.myGarageResource() + '/images/appstoreicon.png';
    popupPlayStoreIcon = this.myGarageResource() + '/images/playstoreicon.png';
    @track popupText;
    @track divisionId;

    connectedCallback(){
        this.isGuest = ISGUEST;
        this.warningicon = this.myGarageResource() + '/ahmicons/warning.png';
        //console.log('ownAutoLinkSubscription connected callback');
    }

    get collength(){
        return this.packages ? this.packages.length : 1 ;
    }
    
    async handleExplore(){
        let context = await getProductContext('', false);
        let brand;
       // console.log('this.context',context);
        if(context.product){
            if(context.product.divisionId == 'A'){
                brand = 'honda';
            }else if(context.product.divisionId == 'B'){
                brand = 'acura';
            }
        }
        this.navigate('/'+brand+'-product-compatibility-result',{});
    }

    handleLink = async(event) => {
        this.isFreeTrailEligible=false;
        //console.log('handleLink');
        //console.log('this.ssoInitiatingURL : ',this.ssoInitiatingURL);
        //console.log('this.vehicleInfos', JSON.stringify(this.vehicleInfos));
        
        let productIdentifier = event.currentTarget.dataset.id;
        //console.log('This is product Identifier : ',productIdentifier);
        //productIdentifier = "5FNRL6H84KB764126";
        
        let link = event.currentTarget.dataset.value;
        let dataPack = event.currentTarget.dataset.pack;
        //console.log('This is product IdentifierdataPack : ',dataPack);
        let product;
        let brand;
        product = this.vehicleInfos.find(prod => {
            return prod.VIN == productIdentifier;
        });
        //console.log('product',JSON.stringify(product));
        await this.updateUser(product);

        if(product.divisionCode === 'A'){
            this.popupText = 'DOWNLOAD THE HONDALINK APP AND PAIR WITH YOUR HONDA TO START USING THESE FEATURES TODAY';
        }else{
            this.popupText = 'DOWNLOAD THE ACURALINK APP AND PAIR WITH YOUR ACURA TO START USING THESE FEATURES TODAY';
        }
       
        if(product.divisionCode == 'A'){
            brand = 'honda';
            this.divisionId='A';
        }else if(product.divisionCode == 'B'){
            brand = 'acura';
            this.divisionId='B';
        }

        await getTrialEligibility({ productIdentifier: productIdentifier, divisionId: this.divisionId})
        .then((data) => {
            //console.log('isFreeTrailEligibleData : ', JSON.stringify(data.responseBody));
            let vehicleEligibility = data.responseBody;
            if (vehicleEligibility) {
                let currentVehicleEligibility = JSON.parse(JSON.stringify(vehicleEligibility));
                //console.log('This is this.vehicleEligibility', JSON.stringify(vehicleEligibility));
                if (currentVehicleEligibility && currentVehicleEligibility.eligibilityFlag && currentVehicleEligibility.eligibleProducts) {
                    for (const eligibilityProduct of currentVehicleEligibility.eligibleProducts) {
                        if (eligibilityProduct.productName.toLowerCase().includes(dataPack.toLowerCase())) {
                            this.isFreeTrailEligible=true;
                            //console.log('@@isFreeTrailEligible'+this.isFreeTrailEligible);
                            break;
                        }
                    }
                }
            }

        }).catch((error) => {
            //console.log('Error : ', error);
        });

        switch (link.toLowerCase()) {
            
                //Commented for CTA changes
                // const prod = {'divisionId': product.divisionCode, 'division': product.divisionName, 'year': product.modelYear, 'model': product.modelCode, 'nickname': product.modelYear + ' ' + product.modelCode};
                // console.log('added product  :-  ',prod);
                // const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
                // context.product = prod;
                // localStorage.setItem('context', JSON.stringify(context));
                // sessionStorage.setItem('frompage', 'My Account');
                // this.navigate('/'+brand+'-product-compatibility-result',{});
                // break;
            case 'learn more':
                let url = brand == 'honda' ? '/honda-product-compatibility-result' : '/acura-product-compatibility-result';
                this.navigate(url, {});
                break;
            case 'sign up':
            case 'manage':
                //console.log('dataPack : ',dataPack);
                //Added New If For DOE-5069 By ABHISHEK SALECHA
                // if(dataPack == 'Remote' && brand == 'acura' && product.telematicsUnit == 'Y' && product.telematicsPlatform =='MY21'){
                //     this.showPopup = true;
                // }
                // else 
                if(dataPack == 'Security' || dataPack == 'Remote' || dataPack == 'Concierge'){
                    if(brand == 'acura' || brand == 'honda'){
                        // if(product.telematicsPlatform == 'MY13'){
                        //     this.navigate('/sxm-phone-info',{}); //'sirius-xm-phone-info'
                        // }
                        if((product.telematicsPlatform == 'MY17' || product.telematicsPlatform == 'MY21' || product.telematicsPlatform == 'MY23') && product.telematicsUnit == 'Y'){//
                            if(product.enrollment === 'N' && product.ownership === 'N'){
                                this.showPopup = true;
                            }else if(product.telematicsPlatform == 'MY17' && product.telematicsUnit == 'Y' && this.isFreeTrailEligible == true ){
                                this.showPopup = true;
                            }else{
                                this.singleSingOnToSXM(product);
                            }
                            //this.navigate(this.ssoInitiatingURL,{});
                        }
                    }
                    // else if(brand == 'honda'){
                    //     if(product.telematicsPlatform == 'MY17' && product.telematicsUnit == 'Y'){
                    //         this.singleSingOnToSXM(product);
                    //         //this.navigate(this.ssoInitiatingURL,{});
                    //     }
                    // }   
                }
                else if((dataPack == 'Standard' || dataPack == 'Connect' || dataPack == 'Premium') && brand == 'acura'){
                    if(product.telematicsPlatform == 'MY13'){
                        this.navigate('/sxm-phone-info',{}); //'sirius-xm-phone-info'
                    }
                }
                else if(dataPack == 'Link'){
                    let deviceDetails = navigator.userAgent.toLowerCase();
                    let navigationURL = deviceDetails.indexOf("android") > -1 ? this.androidAppLink : this.iosAppLink; 
                    //console.log('This is navigation URL : ',navigationURL);
                    if(brand == 'honda' && (product.telematicsPlatform == 'MY16' || product.telematicsPlatform =='MY17' || product.telematicsPlatform =='MY21' || product.telematicsPlatform =='MY23' || product.telematicsPlatform =='2ZS')){
                            this.navigate(navigationURL,{});//
                    }  
                    if(brand == 'acura' && (product.telematicsPlatform =='MY17' || product.telematicsPlatform =='MY23')){
                            this.navigate(navigationURL,{});//    
                    }
                }               
                break;
            // case 'learn more':
            //     if(dataPack == 'Link'){
            //         if(brand == 'honda'){
            //             if(product.telematicsPlatform == 'MY16' || product.telematicsPlatform =='MY17' || product.telematicsPlatform =='MY21' || product.telematicsPlatform =='MY23' || product.telematicsPlatform =='2ZS'){
            //                 this.navigate('https://ownersdev1-americanhondamotors.cs195.force.com/mygarage/idp/login?app=0sp02000000005B',{});
            //             }
            //         }
            //     }
            //     break;    
       }
    }
    
    handleEditPin = async (event) => {
        let productIdentifier = event.currentTarget.dataset.id;
        //productIdentifier = "5FNRL6H84KB764126";
        let product;
        product = this.vehicleInfos.find(prod => {
            return prod.VIN == productIdentifier;
        });
        await this.updateUser(product);
        //console.log('product  : ',product);

        if(product.divisionCode === 'A'){
            this.popupText = 'DOWNLOAD THE HONDALINK APP AND PAIR WITH YOUR HONDA TO START USING THESE FEATURES TODAY';
        }else{
            this.popupText = 'DOWNLOAD THE ACURALINK APP AND PAIR WITH YOUR ACURA TO START USING THESE FEATURES TODAY';
        }

        if(product.telematicsPlatform == '2ZS'){
            let deviceDetails = navigator.userAgent.toLowerCase();
            let navigationURL = deviceDetails.indexOf("android") > -1 ? this.androidAppLink : this.iosAppLink; 
            this.navigate(navigationURL,{}); //'mobile-app'
        }
        else if(product.telematicsPlatform == 'MY17'){
            //this.singleSingOnToSXM(product);
            this.showPopup = true;
            // this.navigate(this.ssoInitiatingURL,{});
        }
        else if(product.telematicsPlatform == 'MY13'){
            this.navigate('/sxm-phone-info',{});
        }//Added New If For DOE-5069 By ABHISHEK SALECHA
        else if(product.telematicsUnit == 'Y' && product.telematicsPlatform =='MY21' && product.divisionCode == 'B'){
            this.showPopup = true;  
        }
    }

    updateUser = async (product) => { 
       let productId = await getHondaProductID({productIdentifier: product.VIN});
       //console.log('productId',productId); 
       let customerId = await getValidateCustomerIdentity({productIdentifier : product.VIN, divisionId : product.divisionCode});
       //console.log('customerId',customerId); 
       const fields = {};
            fields[ID.fieldApiName] = UserId;
            fields[VIN.fieldApiName] = product.VIN;
            fields[BRAND.fieldApiName] = product.divisionName;
            if(productId){
            fields[LASTVISITEDPRODUCT.fieldApiName] = productId;
            }
            if(customerId){
                fields[CUSTOMERID.fieldApiName] = customerId;
            }

        const recordInput = { fields };
        await updateRecord(recordInput)
                .then((result) => {
                    //console.log('result',result);
                })
                .catch(error => {
                    //console.log('error',error);
                });
    }

    singleSingOnToSXM(product){
        this.divisionId = product.divisionCode;
        if(product.divisionCode === 'A'){
            this.popupText = 'DOWNLOAD THE HONDALINK APP AND PAIR WITH YOUR HONDA TO START USING THESE FEATURES TODAY';
        }else{
            this.popupText = 'DOWNLOAD THE ACURALINK APP AND PAIR WITH YOUR ACURA TO START USING THESE FEATURES TODAY';
        }
        getSSO({ productIdentifier : product.VIN })
            .then((data) => {
                //console.log('Data : ',typeof(data));
               // console.log('Data : ',data);
                if(data.statusCode === 200){
                    if(this.isJSON(data.response)){
                        let jsonResponse = JSON.parse(data.response);
                        if(jsonResponse && jsonResponse.body && jsonResponse.body.status === 'success'){
                          this.navigate(jsonResponse.body.url, {});
                        }else{
                          this.showPopup = true;
                        }
                      }else{
                        let ssoDiv = this.template.querySelector(`[data-id="sso"]`);
                        ssoDiv.innerHTML = data.response;
                        //console.log('this querySelector : ',this.template.querySelector('form'));
                        this.template.querySelector('form').submit();
                      }
                }else{
                    this.showPopup = true;
                }
            })
            .catch((error) => {
                //console.log('Error : ',error);
                this.showPopup = true;
            });
        // if(product.divisionCode == 'B'){
        //     getSSPSSOAcuralink({ productIdentifier : product.VIN , divisionId : product.divisionCode })
        //     .then((data) => {
        //         console.log('Data : ',typeof(data));
        //         console.log('Data : ',data);
        //         if(data.statusCode === 200){
        //             let ssoDiv = this.template.querySelector(`[data-id="sso"]`);
        //             ssoDiv.innerHTML = data.response;
        //             console.log('this querySelector : ',this.template.querySelector('form'));
        //             this.template.querySelector('form').submit();
        //         }else{
        //             this.showPopup = true;
        //         }
        //     })
        //     .catch((error) => {
        //         console.log('Error : ',error);
        //         this.showPopup = true;
        //     });
        // }
        // if(product.divisionCode == 'A'){
        //     getSSPSSOHondalink({ productIdentifier : product.VIN , divisionId : product.divisionCode })
        //     .then((data) => {
        //         console.log('Data : ',data);
        //         if(data.statusCode === 200){
        //             let ssoDiv = this.template.querySelector(`[data-id="sso"]`);
        //             ssoDiv.innerHTML = data.response;
        //             console.log('this querySelector : ',this.template.querySelector('form'));
        //             this.template.querySelector('form').submit();
        //         }else{
        //             this.showPopup = true;
        //         }
        //     })
        //     .catch((error) => {
        //         console.log('Error : ',error);
        //         this.showPopup = true;
        //     });
        // }
    }

    isJSON(str) {
        try {
            return (JSON.parse(str) && !!str);
        } catch (e) {
            return false;
        }
    }

    closePopup(){
        this.showPopup = false;
    }

    handleNavigations(event){
        this.showPopup = false;
        let navigationUrl;
        if(this.divisionId == 'A'){
            navigationUrl =  event.currentTarget.dataset.hondaurl;
        }else if(this.divisionId == 'B'){
            navigationUrl =  event.currentTarget.dataset.acuraurl;
        }
       // console.log('@@navigationUrl'+navigationUrl);
        this.navigate(navigationUrl, {});
    }

}