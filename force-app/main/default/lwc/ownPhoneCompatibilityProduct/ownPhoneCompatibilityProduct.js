import { api, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import getPhoneDataByModelId from '@salesforce/apex/OwnAPIController.getPhoneDataByModelId';
import { CurrentPageReference } from 'lightning/navigation';

import basePath from '@salesforce/community/basePath';



const BUTTON_DISABLE_CLASS = 'button-section-disable';
const BUTTON_ACTIVE_CLASS = 'button-section-active';
const FILL_COLOR_CLASS = 'find-brand-combobox';
const FILL_NO_COLOR_CLASS = 'custom-brand-combobox';
const CURSOR_NOT_ALLOWED = 'custom-cursor-notallowed';
const CUSTOM_INPUT_LABEL = 'custom-input-label';
const CUSTOM_INPUT_LABEL_DISABLED = 'custom-input-label-disabled';

export default class OwnPhoneCompatibilityProduct extends OwnBaseElement {
    @api divisionid;
    @api buttonName;
    @api contentId;
    @api sourceType;
    @track years;
    @track models;
    @track trims;
    @track modelId;
    @track year;
    @track model;
    @track trim;
    @track results;
    @track subTitle;
    @track title;
    @track contentKeys = [];
    @track divisionName;
    @track isError = false;
    @track errorLogo;
    errorMsg;


    connectedCallback() {
        this.errorLogo = this.myGarageResource() + '/ahmicons/warning.png';
        this.initialize();
        this.divisionName = this.divisionid === 'A' ? 'Honda' : 'Acura';
        // sessionStorage.setItem('AdobePhoneCompatibilityBrand', this.divisionName)
        /* if (this.sourceType === 'Phone') {
            document.title = 'HandsFreeLink: Check Phone Compatibility - Select your Vehicle';
        } else {
            document.title = 'Bluetooth: Check Phone Compatibility - Select your Vehicle';
        } */
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        //  this.sourceType = this.urlStateParameters.sourcetype || 'Phone';
    }

    handleFoundProduct(event) {
        const product = event.detail;
        //console.log('Test ' + product.modelId);
        const divisionLogo = this.divisionid === 'A' ? '/img/thumbnail_honda.png' : '/img/thumbnail_acura.png';
        getPhoneDataByModelId({ modelId: product.modelId, divisionId: this.divisionid }).then((result) => {
            if (result.arePhonesAvailable) {
                this.isError = false;
                /* let product = {
                     'divisionId': this.divisionid, 'division': divisionName,
                     'year': this.year, 'model': this.model, 'trim': this.trim,
                     'modelId': this.modelId,
                     'nickname': this.year + ' ' + this.model + ' ' + this.trim,
                     'image': this.myGarageResource()+divisionLogo
                 };*/
                const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
                context.product = product;
                localStorage.setItem('context', JSON.stringify(context));
                /*  if(document.location.pathname.includes('honda-handsfreelink-compatibility-check')) {
                      sessionStorage.setItem('frompage','HondaLink');
                  } else if(document.location.pathname.includes('acura-handsfreelink-compatibility-check')) {
                      sessionStorage.setItem('frompage','AcuraLink');
                  }*/
                if (this.sourceType == 'Phone') {
                    sessionStorage.setItem('frompage', 'HandsFreeLink');
                } else {
                    sessionStorage.setItem('frompage', 'Connect via Bluetooth');
                }
                let navigationPath = this.sourceType == 'Phone' ? '/phone-compatibility-phone?fb=true' : '/bluetooth-compatibility-phone?fb=true';
                this.navigate(navigationPath, {});
            } else {
                // this.showToast_error(this.errorMsg);
                this.isError = true;
            }
        }).catch((error) => {
            //console.log('error log');
            //console.log(error);
            this.isError = true;
        });

    }

    initialize = async () => {
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, null, null, '');
        this.results.forEach(r => {
            //console.log(r);
            this.subTitle = r.subTitle.value;
            this.title = r.descriptionLabel.value;
            this.errorMsg = r.sectionLabel.value;
        });
    };

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }

}