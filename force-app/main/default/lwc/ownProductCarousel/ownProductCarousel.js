//=============================================================
// Title:    Honda Owners Experience - Products Carousel
//
// Summary:  This is a carousel card for garage product carousel functionality
//
// History:
// October 5, 2021 Ravindra (Wipro) Original Author
//============================================================= -->
import { api, LightningElement, track } from 'lwc';

import { setOrigin, getOrigin, ISGUEST, getGarageURL, getGarage, getContext, setProductContextUser, getProductContext } from 'c/ownDataUtils';

import { OwnBaseElement } from 'c/ownBaseElement';

import FORM_FACTOR from '@salesforce/client/formFactor';
import getManageSubscriptions from '@salesforce/apex/OwnAPIController.getManageSubscriptions';
import getCIAMConfig from '@salesforce/apex/OwnUserHandler.getCIAMConfig';
import getSSPSSOAcuralink from '@salesforce/apex/OwnAPIController.getSSPSSOAcuralink';
import getSSPSSOHondalink from '@salesforce/apex/OwnAPIController.getSSPSSOHondalink';
import mygarageurl from '@salesforce/label/c.MyGarageURL';
import getSSO from '@salesforce/apex/OwnAPIController.getSSO';
import getTrialEligibility from '@salesforce/apex/OwnAPIController.getTrialEligibility';

export default class OwnProductCarousel extends OwnBaseElement {
    @api context;
    @api isguest;
   // context;
    garage;
    garageLenght = 0;
    @track productDetails;
    @track alerticon = 'alert1.svg';
    @track fromProductChooser = false;
    productItems = [];
    enablePaging;
    firstItemIndex = 0;
    lastItemIndex = 0;
    year;
    @track displayedItems = [];
    urlString = window.location.href;
    baseURL = this.urlString.substring(0, this.urlString.indexOf("/s"));
    @api accountInfo;
    @track emptyGarageFlag = false;
    loginUrl;
    
    @track ciamDetailsLoaded = false;
    @track contextDetailsLoaded = false;
    
    @track showPopup = false;
    @api playStoreURL;
    @api appStoreURL;
    @api acuraPlayStoreURL;
    @api acuraAppStoreURL;
    popupAppStoreIcon = this.myGarageResource() + '/images/appstoreicon.png';
    popupPlayStoreIcon = this.myGarageResource() + '/images/playstoreicon.png';
    @track breadcrumb = {label: '', url: ''};
    @track popupText;
    @track divisionId;
    @api subscriptionsLoaded;
    isFreeTrailEligible =false;

    @api
    get detailsLoaded(){
        //console.log('Carousel: ', this.ciamDetailsLoaded && this.contextDetailsLoaded);
        return this.ciamDetailsLoaded && this.contextDetailsLoaded;
    }

    get isDesktop() {
        return FORM_FACTOR === 'Large';
    }

    @api
    get cardClass(){ 
         //return this.isDesktop ? 'slds-col slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_4-of-12' : 'slds-col slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_4-of-12' ;    
        return 'slds-col slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_4-of-12';
    }

    renderedCallback() {
        // console.log("inside Product renderedCallback line 40 " + this.accountInfo);
    }

    @api 
    get addButtonLabel(){
        return this.emptyGarageFlag ? 'FIND A PRODUCT' : 'ADD ANOTHER PRODUCT';
    }


    @api
    get displayBreadcrumb() {
        return (((this.fromProductChooser || this.isguest) && this.isDesktop) ||
            (this.fromProductChooser && !this.garageLenght > 0 || this.isguest) && !this.isDesktop);
    }

    @api
    refreshGarage(){
        //console.log('%%% REFRESH GARAGE');
        this.initialize();
    }

    @api
    get breadcrumbLabel() {
        let label = 'null';
        let garageProducts = JSON.parse(localStorage.getItem('garage'))
        //console.log('Garage Products From breadcrumblabel : ',garageProducts);
        let productDetails = this.fromProductChooser && garageProducts ? garageProducts.products[0] : 'undefined';
        let division = this.fromProductChooser ? productDetails.division : this.context.product.division;
        let year = garageProducts.products[0] != 'undefined' ? garageProducts.products[0].year : this.context.product.year;

        if (this.displayBreadcrumb) {
            label = (division === 'Honda' || division === 'Acura') ? division + ' Autos: Get Started' :
                division === 'Motorcycle/Powersports' ? year + ' Honda Powersports Adventure Motorcycles' :
                    this.context.product.breadcrumbLabel;

        }
        return label;
    }

    handleFind() {
        //this.domainName + '/hondaowners/s/login/?app=' + this.appId + `&RelayState=${window.location.href}`
        let url = this.loginUrl + `&RelayState=${window.location.href}`;
        this.isguest ? window.open(url, "_self") : this.navigate('/', {});
        
    }

    handleCrumbClick() {
        let garageProducts = JSON.parse(localStorage.getItem('garage'))
        let productDetails = this.fromProductChooser && garageProducts ? garageProducts.products[0] : 'undefined';
        let division = this.fromProductChooser ? productDetails.division : this.context.product.division;
        division = division === 'Motorcycle/Powersports' ?
            'powersports' : division.toLowerCase();
        let url = 'find-' + division;
        this.navigate('/' + url, {})
    }

    handleEdit(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('mode', {
            detail: {
                mode: 'edit'
            }
        });
        this.dispatchEvent(selectEvent);
    }

    initialize = async () => {
        this.fromProductChooser = getOrigin() === 'ProductChooser' && !this.isguest ? true : false;
        this.garage = await getGarage('');
        //console.log('Carousel garage: ' + JSON.stringify(this.garage));
        //localStorage.setItem('garage', JSON.stringify(this.garage));
        //console.log('CAROUSEL: Retrieving context.');
        this.context = await getContext('');
        //console.log('CONTEXT :::', JSON.stringify(this.context));
        if (this.accountInfo == true) {
            //this.handleGarageProductsAccountInfo();
            
            this.handleGarageProducts();
        }
        else {
            this.handleGarageProducts();
        }

        //console.log('Setting this.contextDetailsLoaded');
        this.contextDetailsLoaded = true;
        this.addBreadcrumb();
    };

    @api
    get isPreviousButtonEnabled() {
        return this.enablePaging && this.firstItemIndex > 0 ?
            true : false;
    }

    @api
    get isNextButtonEnabled() {
        return this.enablePaging && this.lastItemIndex != parseInt(this.productItems.length - 1) ?
            true : false;
    }

    @api
    get accountPageDetailsLoaded(){
        return (this.subscriptionsLoaded && this.detailsLoaded);
    }

    connectedCallback() {
        this.alerticon = this.myGarageResource() + '/ahmicons/' + this.alerticon;
        this.getCIAMdetails();
        this.initialize();
    }

    getCIAMdetails = async () => {
        getCIAMConfig().then(result => {
            this.loginUrl = result.Ciam_Login_Url__c;
            this.ciamDetailsLoaded = true;
        });
    }

    fillDisplayList(firstIndex, lastIndex) {
        //console.log('PRODUCT ITEMS : ',this.productItems);
        this.displayedItems = JSON.parse(JSON.stringify(this.productItems.slice(firstIndex, lastIndex + 1)));
    }

    handleGarageProducts() {
        let items = this.productItems;
        let i = 0;
        //console.log('Garage from carousel: ',this.garage.products);
        if (this.garage && this.garage.products) {
            this.getIndexing();
            //console.log('handleGarageProducts called on: ' + JSON.stringify(this.garage.products));
            this.garage.products.forEach( garageProduct => {
               // let packages;
                //console.log('Iteration: ' + JSON.stringify(garageProduct));
                //console.log('Iteration context: ' + JSON.stringify(this.context.product));
                //console.log('@@Iteration start: ',JSON.parse(JSON.stringify(garageProduct)));
                items.push({
                    id: garageProduct.productId,
                    label: garageProduct.nickname ? garageProduct.nickname : (garageProduct.year ? garageProduct.year + ' ' + garageProduct.model : garageProduct.model),
                    year: garageProduct.year,
                    model: garageProduct.model,
                    vin: garageProduct.vin,
                    divisionId: garageProduct.divisionId,
                    division: garageProduct.division,
                    divisionAccountInfo: garageProduct.division == 'Powerequipment' ? 'Power Equipment' : garageProduct.division,
                    name: garageProduct.nickname ? garageProduct.nickname : garageProduct.year + ' ' + garageProduct.model,
                    tooltip: (garageProduct.year ?? '') + ' ' + (garageProduct.model),
                    image: garageProduct.customerUploadedImage ?
                        garageProduct.customerUploadedImage : (garageProduct.productDefaultImage ?
                            garageProduct.productDefaultImage : this.baseURL + garageProduct.image),
                    pagename: getGarageURL(garageProduct.division),
                    telematicsPlatform: '',
                    isSelectedItem: (!this.accountInfo && this.context.product.productId === garageProduct.productId && !this.fromProductChooser) ?
                        'selectedItem product-label' : 'fig-caption product-label',
                    displayRecallAlert: (garageProduct.recallCount > 0 ? true : false),
                    recallCount: garageProduct.recallCount
                   // packages: packages,
                });
                //console.log('@@Iteration end: ',JSON.parse(JSON.stringify(items)));
                i++;
            });
        }
        this.emptyGarageFlag = this.garage.products && this.garage.products.length > 0 ? false : true;
           
        this.fillDisplayList(this.firstItemIndex, this.lastItemIndex);
        if(this.accountInfo && !this.emptyGarageFlag){
            this.getPackages();   
        }
    }

    async getPackages(){
        //console.log('Displayed Items before loop ::', this.displayedItems);

        for(let i = 0; i < this.displayedItems.length; i++){
            let packages;
            
            if(this.displayedItems && this.displayedItems[i] && this.displayedItems[i].vin){
                let manageSubs = await getManageSubscriptions({productIdentifier : this.displayedItems[i].vin, divisionId : this.displayedItems[i].divisionId})
                if(manageSubs && manageSubs.manageSubscriptions.devices && manageSubs.manageSubscriptions.devices[0] && manageSubs.manageSubscriptions.devices[0].programs && manageSubs.manageSubscriptions.devices[0].programs[0]) {
                    this.displayedItems[i].isPrimary = manageSubs.manageSubscriptions.devices[0].programs[0].role === 'PRIMARY' ? true : false;
                }
                if(manageSubs && manageSubs.vehicleFeature && manageSubs.vehicleFeature.vehicle){
                    this.displayedItems[i].telematicsPlatform = manageSubs.vehicleFeature.vehicle.telematicsPlatform;
                    this.displayedItems[i].enrollment = manageSubs.vehicleFeature.vehicle.enrollment;
                    this.displayedItems[i].ownership = manageSubs.vehicleFeature.vehicle.ownership;
                }
                if(manageSubs && manageSubs.packages) {
                    packages = manageSubs.packages.filter(record => record.status === "Active");
                    this.displayedItems[i].packages = (packages && packages.length > 0) ? packages : null;
                }
            }
        }
        //console.log('Displayed Items ', JSON.stringify(this.displayedItems));
    }

    async handlePackageNavigation(event){

        if(this.displayedItems && this.displayedItems.length > 0){
            let dataPack = event.currentTarget.dataset.packagename;
            let productIdentifier = event.currentTarget.dataset.vin;
            //console.log('Clicked productIdentifier : ',productIdentifier);

            let productRecord = this.displayedItems.find(prod => {
                return prod.vin == productIdentifier;
            });

            //console.log('Product Searched : ',productRecord);

            await getTrialEligibility({ productIdentifier: productRecord.vin, divisionId: productRecord.divisionId})
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

            if(productRecord.telematicsPlatform == 'MY13'){
                this.navigate('/sxm-phone-info',{});
            }else if(productRecord.telematicsPlatform == 'MY17' || productRecord.telematicsPlatform == 'MY21' || productRecord.telematicsPlatform == 'MY23'){
                if(productRecord.enrollment === 'N' && productRecord.ownership === 'N'){
                    this.showPopup = true;
                }else if(productRecord.telematicsPlatform == 'MY17' && productRecord.telematicsUnit == 'Y' && this.isFreeTrailEligible == true){
                    this.showPopup = true;
                }else{
                    this.singleSingOnToSXM(productRecord);
                }
            }
        }
        
    }

    singleSingOnToSXM(product){
        this.divisionId = product.divisionId;
        if(product.divisionId === 'A'){
            this.popupText = 'DOWNLOAD THE HONDALINK APP AND PAIR WITH YOUR HONDA TO START USING THESE FEATURES TODAY';
        }else{
            this.popupText = 'DOWNLOAD THE ACURALINK APP AND PAIR WITH YOUR ACURA TO START USING THESE FEATURES TODAY';
        }
        getSSO({ productIdentifier : product.vin })
            .then((data) => {
                //console.log('Data : ',data);
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
        // if(product.divisionId == 'B'){
        //     getSSPSSOAcuralink({ productIdentifier : product.vin , divisionId : product.divisionId })
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
        // }else if(product.divisionId == 'A'){
        //     getSSPSSOHondalink({ productIdentifier : product.vin , divisionId : product.divisionId })
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
        this.navigate(navigationUrl, {});
    }

    getIndexing() {
        this.garageLenght = this.garage.products.length;
        if (!this.accountInfo) {
            this.firstItemIndex = sessionStorage.getItem('firstItemIndex') != null ?
                sessionStorage.getItem('firstItemIndex') : 0;
           // console.log('getIndexing First Index', this.firstItemIndex);
            if (this.isDesktop) {
                this.enablePaging = this.garageLenght > 3 ? true : false;
            } else {
                this.enablePaging = this.garageLenght > 2 ? true : false;
            }
            if (this.isDesktop) {
                this.lastItemIndex = this.enablePaging == true ?
                    (sessionStorage.getItem('firstItemIndex') != null ? parseInt(this.firstItemIndex) + 2 : 2) :
                    parseInt(this.garageLenght - 1);
            } else {
                this.lastItemIndex = this.enablePaging == true ?
                    (sessionStorage.getItem('firstItemIndex') != null ? parseInt(this.firstItemIndex) + 1 : 1) :
                    parseInt(this.garageLenght - 1);
            }
        }else{
            this.firstItemIndex = 0;
            this.lastItemIndex = this.garageLenght;
            this.enablePaging = false;
        }
    }
    
    get tooltip() {
        return 'tooltip';
    }

    NextImage() {
        this.fillDisplayList(++this.firstItemIndex, ++this.lastItemIndex);
    }

    previousImage() {
        this.fillDisplayList(--this.firstItemIndex, --this.lastItemIndex);
    }

    handleIconClick(event) {
        let pagename = event.currentTarget.dataset.pagename;
        let id = event.currentTarget.dataset.id;
        this.handleSaveContext(id, pagename);
    }

    handleEditSettingsClick(event) {
        //Ravindra Ravindra (wipro) DOE-2441
        setOrigin('MyAccount');
        this.handleSaveContext(event.currentTarget.dataset.id, '/product-settings');

    }

  async handleSaveContext(id, pagename) {
        if(getOrigin() != 'MyAccount'){
            setOrigin('');
        }
        if ((id === undefined || id === null) && pagename) {
            this.navigate(pagename, {});
        } else {
            // const contextInput = {
            //     'communityContextId': ISGUEST ? '' : this.context ? this.context.communityContextId : '',
            //     'Level1': url,
            //     productId: id
            // };
            // this.context = setContextMenuL1(contextInput);
            sessionStorage.setItem('firstItemIndex', this.firstItemIndex);
            sessionStorage.setItem('getContextProductId', id);
            //this.navigate(pagename, {});
            const contextInput = {
                'productId': id,
                'productTab': 'Overview'
            };
            await setProductContextUser(contextInput);
            await this.sleep(2000);

            let mygarageURLLabel = mygarageurl === '/' ? '' : mygarageurl;
            window.open(mygarageURLLabel + '/s'+pagename, "_Self");
        }
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /* Account information section  start */
    get bodyClass() {
        return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body';
    }
    /* Account information section  end */
    addBreadcrumb = async () => {
        let context;
        if (getOrigin() == 'ProductChooser') {
            context = await getProductContext('', true);
        } else {
            context = await getProductContext('', false);
        }
        //console.log('ownProductCrousel: Context',JSON.parse(JSON.stringify(context)));
        if(context && context.product){
            if(context.product.division === 'Honda'){
                this.breadcrumb.label = 'Honda Autos: Get Started';
                this.breadcrumb.url = '/find-honda';
            }else if(context.product.division === 'Acura'){
                this.breadcrumb.label = 'Acura Autos: Get Started';
                this.breadcrumb.url = '/find-acura';
            }else if(context.product.division === 'Motorcycle/Powersports' || context.product.division === 'Powersports'){
                this.breadcrumb.label = 'Powersports: Get Started';
                this.breadcrumb.url = '/find-powersports';
            }else if(context.product.division === 'Powerequipment'){
                this.breadcrumb.label = 'Power Equipment: Get Started';
                this.breadcrumb.url = '/find-powerequipment';
            }else if(context.product.division === 'Marine'){
                this.breadcrumb.label = 'Honda Marine: Get Started';
                this.breadcrumb.url = '/find-marine';
            }
        }
    }
    handleBreadcrumb(){
        this.navigate(this.breadcrumb.url, {});
    }
}