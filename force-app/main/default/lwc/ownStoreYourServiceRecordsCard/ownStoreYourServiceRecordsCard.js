import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getCIAMConfig from '@salesforce/apex/OwnUserHandler.getCIAMConfig';
import { getRecord } from 'lightning/uiRecordApi';
import { getOrigin, ISGUEST, getContext } from 'c/ownDataUtils';

export default class OwnManualCard extends OwnBaseElement {
    @api brandName;
    @api brand;
    @api icon = 'checklist.svg';
    @api title = 'STORE YOUR SERVICE RECORDS';
    @api titlecolor;
    @api headerlink;
    @api showforwardicon;
    @api showfooter;
    @api loginlink;
    @api createlink;
    @api overview;

    domainName;
    appId;
    @track loginUrl;
    @track signUpUrl;
    
    @track context;
    @track serviceMaintenanceBody = ' to track all maintenance performed on your vehicle by dealers and keep a record of maintenance performed at other service facilities.';

    @track objMetadataValues = {};

    show=true;

    get bodyClass(){
        return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body';
    }

    get titleClass(){
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get iconClass(){
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    connectedCallback(){
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.initialize();
    }

    initialize = async () => {
        const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
        if (!context || getOrigin() != 'ProductChooser') {
            this.context = await getContext('');
        } else {
            this.context = context;
        }

        if(this.context.product.division == "Powerequipment" || this.context.product.division == "Marine" ){
            //console.log('Marine or PE');
            this.serviceMaintenanceBody = ' to track all maintenance performed on your product by dealers and keep a record of maintenance performed at other service facilities.';
        }
        else if(this.context.product.division == "Acura")
        {
            //console.log('Acura');
            this.serviceMaintenanceBody = ' to track all maintenance performed by dealers and keep a record of maintenance performed at other service facilities.';
        }
        else if(this.context.product.division == "Honda" || this.context.product.division == "Powersports" )
        {
            //console.log(' Honda or PS');
            this.serviceMaintenanceBody = ' to track all maintenance performed on your vehicle by dealers and keep a record of maintenance performed at other service facilities.';
        }
        //console.log('Serv Body ', this.serviceMaintenanceBody);


        getCIAMConfig().then(result => {
            this.domainName = result.Domain_Name__c;
            this.appId = result.Application_Id__c;
            this.loginUrl = result.Ciam_Login_Url__c;
            this.signUpUrl = result.Ciam_SignUp_Url__c;
            //console.log('Custom Settings :', this.domainName + '--' + this.appId);
        })

        

    }

    handleClickHeader(){
        //this.navigate(this.headerlink, {}); 
    }

    handleClickAction(){
       
    }

    handleClickFooter(){
           
    }

    handleClick(event) {
        // //Ravindra Ravindra(Wipro)  DOE-4370
        if(this.isguest){
            var currentLocation = window.location;
            sessionStorage.setItem("RelayState", currentLocation.href);
        }
        //end

        let button = event.target.getAttribute('data-id');
        let url = '';

        if (this.domainName != undefined && this.appId != undefined) {
            // if (button === 'Sign_Up') {
            //     url = this.domainName + '/hondaowners/s/login/SelfRegister?app=' + this.appId + `&RelayState=${window.location.href}`;
            // } else if (button === 'Log_In') {
            //     url = this.domainName + '/hondaowners/s/login/?app=' + this.appId + `&RelayState=${window.location.href}`;
            // }
            if (button === 'Sign_Up') {
                //console.log(this.signUpUrl);
                url = this.signUpUrl + `&RelayState=${window.location.href}`;
            } else if (button === 'Log_In') {
                //console.log(this.loginUrl);
                url = this.loginUrl + `&RelayState=${window.location.href}`;
               // url = this.domainName + '/mygarage/s/login?app=' + this.appId + `&RelayState=${window.location.href}`;
            }
            //console.log('URL == ', url);
            sessionStorage.setItem("isUserLogin", true);
            window.open(url, '_self');
            
            /* const config = {
                type: 'standard__webPage',
                attributes: {
                    url: url
                }
            };
            this[NavigationMixin.GenerateUrl](config)
                .then(url => {
                    window.open(url, '_self')
                }); */
        }

    }
}