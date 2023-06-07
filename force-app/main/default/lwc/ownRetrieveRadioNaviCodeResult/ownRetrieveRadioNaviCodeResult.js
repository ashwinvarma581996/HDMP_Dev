import { LightningElement, api, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getProductByVIN from '@salesforce/apex/OwnGarageController.getProductByVIN';
import { CurrentPageReference } from 'lightning/navigation';
import { getProductContext, ISGUEST } from 'c/ownDataUtils';



export default class OwnRetrieveRadioNaviCodeResult extends OwnBaseElement {

    @api navserialnumber;
    @api radserialnumber;
    @api navcode;
    @api radcode;
    @api vin;
    @api trim;
    @api year;
    @api model;
    @api isboth;
    @api isradio;
    @api isnavigation;
    @api color;
    @track fb;
    @track brand;
    @track divisionId;
    @track isColor;
    currentPageReference = null;
    urlStateParameters = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        //console.log('currentPageReference', currentPageReference);
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            //console.log('this.urlStateParameters', this.urlStateParameters);
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.fb = this.urlStateParameters.fb || null;
        this.brand = this.urlStateParameters.brand || null;
    }

    connectedCallback() {
        this.initialize();
    }
    initialize = async () => {
    /*    this.vin = sessionStorage.getItem('rnv-vin');
        this.vin = this.vin.trim();
        var context;
        if (this.fb == 'true') {
            let origin = localStorage.getItem('origin');
            if (ISGUEST || origin == 'ProductChooser') {
                context = await getProductContext('', true);
            } else {
                context = await getProductContext('', false);
            }
            this.divisionId=context.product.divisionId;
            this.brand=context.product.division;
        } else {
            if (this.brand == 'Acura') {
                this.divisionId = 'B';
            } else {
                this.divisionId = 'A';
            }
        }
        
        //console.log('@@Image'+sessionStorage.getItem('rnv-image'));


        await getProductByVIN({ divisionId: this.divisionId, vin: this.vin, divisionName: this.brand })
            .then(result => {
                //console.log('@@result', JSON.stringify(result));
                let prod = JSON.parse(result);
                //console.log('@@result', JSON.stringify(prod));
                this.year = prod.modelDetail.year ? prod.modelDetail.year : '';
                this.trim = prod.modelDetail.trim ? prod.modelDetail.trim : '';
                this.color = prod.modelDetail.color.name ? '/ ' + prod.modelDetail.color.name : '-';
                this.model = prod.modelDetail.modelGroupName ? prod.modelDetail.modelGroupName : (prod.modelDetail.modelName ? prod.modelDetail.modelName : '-');
                //console.log('Apex callback');
                //console.log('result: ', JSON.stringify(this.color));
            })
            .catch(error => {
                //console.log('getProductByVIN: error');
                //console.log('error: ', error);
            });*/
        this.vin = sessionStorage.getItem('rnv-vin');
        this.navserialnumber = sessionStorage.getItem('rnv-navigationSerialNumber');
        this.radserialnumber = sessionStorage.getItem('rnv-radioSerialNumber');
        this.navcode = sessionStorage.getItem('rnv-navigationCode');
        this.radcode = sessionStorage.getItem('rnv-radiocode');
        this.isradio = sessionStorage.getItem('rnv-isRadio');
        this.isnavigation = sessionStorage.getItem('rnv-isNavigation');
        this.isboth = sessionStorage.getItem('rnv-isBoth');
        this.year = sessionStorage.getItem('rnv-year');
        this.trim = sessionStorage.getItem('rnv-trim');
        this.color = sessionStorage.getItem('rnv-color');
        this.model = sessionStorage.getItem('rnv-model');
        if (this.isnavigation == 'true') {
            this.isnavigation = true;
        } else {
            this.isnavigation = false;        }
        if (this.isradio == 'true') {
            this.isradio = true;
        } else {
            this.isradio = false;
        }
        if(this.color == "undefined"){
            this.isColor=false;
        }else{
            this.isColor=true;
        }


    }
}