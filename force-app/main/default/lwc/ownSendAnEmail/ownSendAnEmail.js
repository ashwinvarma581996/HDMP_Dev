import { api, LightningElement, track, wire } from 'lwc';
import {
    OwnBaseElement
} from 'c/ownBaseElement';
import FORM_FACTOR from '@salesforce/client/formFactor';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import {ISGUEST, getProductContext} from 'c/ownDataUtils';
import CRRSBaseUrl from '@salesforce/label/c.CRRS_Site_Base_Url';

export default class OwnSendAnEmail extends OwnBaseElement {
    userRec = {};
    context;
    @track breadCrumbLabel = 'Honda Autos';
    @track crumbUrl = 'help-honda';
    @track brand = 'Honda';

    CRRSSite = CRRSBaseUrl;
    loadCount = 1;
    pageUrlJson = {
        'Honda' : 'own_hondaownerw2c',
        'Acura' : 'own_AcuraOwnerW2C',
        'Powersports' : 'own_psw2c',
        'Powerequipment' : 'own_pew2c',
        'Marine' : 'own_marinew2c'
    }

    brandHelpCenterUrl = {
        'Honda':'/help-honda',
        'Acura':'/help-acura',
        'Powersports':'/help-powersports',
        'Powerequipment':'/help-powerequipment',
        'Marine':'/help-marine',
    }

    crumbLabels = {
        
        'Honda':'Honda Autos',
        'Acura':'Acura Autos',
        'Powersports':'Honda Powersports',
        'Powerequipment':'Honda Powerequipment',
        'Marine':'Honda Marine',
    }
    get isDesktop() {
        return FORM_FACTOR === 'Large';
    }

    handleCrumbClick(){
        this.navigate(this.crumbUrl, {});
    }
    
    renderedCallback(){
        console.log('On render')
    }



    connectedCallback(){
        this.brand = sessionStorage.getItem('BrandName') ? sessionStorage.getItem('BrandName') : 'Honda';
        this.breadCrumbLabel = this.crumbLabels[this.brand];
        this.crumbUrl = this.brandHelpCenterUrl [ this.brand];
        if(this.breadCrumbLabel.includes('Powerequipment')){
            this.breadCrumbLabel = this.breadCrumbLabel.replace('Powerequipment','Power Equipment');
        }
        this.initialize();
    }
    
    frameHeight(event){

        console.log('On Load Called');
    }


    get LinkVal(){
        let usr = this.userRec;
        let prodInf = this.context;
        let vfPage = this.pageUrlJson[this.brand];
        let pageUrl = this.CRRSSite + vfPage;
        let paramsStr = '?pg=' + vfPage;
        if(usr){
            paramsStr+= usr.FirstName!=null ? '&firstName='+usr.FirstName : '';
            paramsStr+= usr.LastName!=null ? '&lastName='+usr.LastName : '';
            paramsStr+= usr.Email!=null ? '&SuppliedEmail='+usr.Email : '';
        }
        
        if(prodInf && prodInf.product){
            paramsStr+= prodInf.product.productIdentifier!=null ? '&vin='+prodInf.product.productIdentifier : '';
        }

        pageUrl+=paramsStr;
        return pageUrl;
    }

    @wire(getRecord, { recordId: USER_ID, fields: ['User.FirstName', 'User.LastName', 'User.Email'] })
    userData({error, data}) {
        if(data) {
            console.log('data***', JSON.stringify(data));

            let fld = data.fields;

            this.userRec = {
                FirstName : fld.FirstName.value,
                LastName : fld.LastName.value,
                Email : fld.Email.value
            }
            console.log('--userRec--', this.userRec);
        } 
        else if(error) {
            console.log('error ====> '+JSON.stringify(error));
        } 
    }

    initialize = async () => {
        
        this.context = await getProductContext('', ISGUEST);
        console.log('--context--', this.context);
        console.log('ISGUEST ', ISGUEST);
    };
}