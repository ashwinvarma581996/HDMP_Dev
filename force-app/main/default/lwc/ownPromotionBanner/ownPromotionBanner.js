import { api, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getProductContext, getOrigin, getContext, getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
export default class OwnPromotionBanner extends OwnBaseElement {
    
    @api contentId;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track body;
    @track title;
    @track productImage;
    @track context;
    @api playStoreURL;
    @api appStoreURL;
    @api acuraPlayStoreURL;
    @api acuraAppStoreURL;
    @track showPopup =false;
    popupAppStoreIcon = this.myGarageResource() + '/images/appstoreicon.png';
    popupPlayStoreIcon = this.myGarageResource() + '/images/playstoreicon.png';
    @track buttonText = 'DOWNLOAD NOW';
    
    connectedCallback(){
        this.initialize();
        this.contentKeys.push(this.contentId);
        getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType).then( response =>{
            response.forEach(r => {
                this.title = r.title.value;
                this.body = this.htmlDecode(r.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>');
            });
        }).catch(e => {
            //console.log('Error Occured : ',e.getMessage());
        });
    }
    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        this.fromProductChooser = fromProductChooser;
        //console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getContext('');
        }
        //console.log('Context********', this.context);
        if(this.context && this.context.product){
            if(this.context.product.division === 'Honda'){
                this.productImage = this.myGarageResource() + '/images/promotion-banner-honda.png';
            }else if(this.context.product.division === 'Acura'){
                this.productImage = this.myGarageResource() + '/images/promotion-banner-acura.png';
            }else if(this.context.product.division === 'Motorcycle/Powersports' || this.context.product.division === 'Powersports'){
                this.productImage = this.myGarageResource() + '/images/promotion-banner-ps.png';
            }else if(this.context.product.division === 'Powerequipment'){
                this.productImage = this.myGarageResource() + '/images/promotion-banner-pe.png';
            }else if(this.context.product.division === 'Marine'){
                this.buttonText = 'VIEW OFFERS'
                this.productImage = this.myGarageResource() + '/images/promotion-banner-marine.png';
            }
        }
    }

    handleButtonClick(){
        if(this.context.product.division === 'Marine'){
            this.navigate(this.appStoreURL, {});
        }else{
            this.showPopup = true;
        }
    }

    closePopup(){
        this.showPopup = false;
    }

    handleNavigations(event){
        let navigationUrl;
        if(this.context.product.division === 'Honda'){
          navigationUrl =  event.currentTarget.dataset.hondaurl;
        }else if(this.context.product.division === 'Acura'){
          navigationUrl =  event.currentTarget.dataset.acuraurl;
        }
        this.navigate(navigationUrl, {});
        this.showPopup = false;
    }

    get popupText(){
        if(this.context.product.divisionId === 'A'){
            return 'DOWNLOAD THE HONDALINK APP AND PAIR WITH YOUR HONDA TO START USING THESE FEATURES TODAY';
        }else{
            return 'DOWNLOAD THE ACURALINK APP AND PAIR WITH YOUR ACURA TO START USING THESE FEATURES TODAY';
        }
    }
}