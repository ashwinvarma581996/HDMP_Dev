//============================================================================
// Title:    Honda Owners Experience - Product Image
//
// Summary:  Owners Product Image - Product image display component
//
// Details:  Handles the error event of an <img> tag to replace invalid
//           image links with the correct brand logo image
//
//
// History:
// March 29, 2022 Alexander D (Wipro) Original Author
//===========================================================================


import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnProductImage extends OwnBaseElement {

    hondaLogoSrc =  '/resource/MyGarage/img/thumbnail_honda.png';
    acuraLogoSrc = '/resource/MyGarage/img/thumbnail_acura.png';
    powersportsLogoSrc = '/resource/MyGarage/img/thumbnail_powersports.png';
    powerequipmentLogoSrc = '/resource/MyGarage/img/thumbnail_powerequipment.png';
    marineLogoSrc = '/resource/MyGarage/img/thumbnail_marine.png';

    @api productImage;
    //@track brandLogoImage;
    @api brand;
    //@track imgError = false;
    @track imgErrorState = {image:this.productImage, hasError:false};

    urlString = window.location.href;
    baseURL = this.urlString.substring(0, this.urlString.indexOf("/s"));

    @api
    get image(){
        if ((this.imgErrorState.image==this.productImage && this.imgErrorState.hasError) || this.productImage === null){
            //console.log('Product Image: Returning brand image');
            if (this.brand == 'Acura'){
                return this.baseURL + this.acuraLogoSrc;
            }
            else if (this.brand == 'Honda'){
                return this.baseURL + this.hondaLogoSrc;
            }
            else if (this.brand == 'Powersports' || this.brand == 'Motorcycle/Powersports'){
                return this.baseURL + this.powersportsLogoSrc;
            }
            else if (this.brand == 'Marine'){
                return this.baseURL + this.marineLogoSrc;
            }
            else if (this.brand == 'Powerequipment'){
                return this.baseURL + this.powerequipmentLogoSrc;
            }
            else{
                if(document.location.pathname.includes('acura')){
                    return this.baseURL + this.acuraLogoSrc;
                }else{
                    return this.baseURL + this.hondaLogoSrc;
                }
            }
        }
        else{
           // console.log('Product Image: Returning product image');
            return this.productImage;
        }
    }

    connectedCallback(){
        //console.log('Product Image connected callback 1');
        //console.log('@@##'+this.productImage);
        //console.log(this.brand);
        //this.brandLogoImage = this.baseURL + this.acuraLogoSrc;
        //console.log('Product Image connected callback 1.5');
        /* if (this.brand == 'Acura'){
            this.brandLogoImage = this.baseURL + this.acuraLogoSrc;
        }
        else if (this.brand == 'Honda'){
            this.brandLogoImage = this.baseURL + this.hondaLogoSrc;
        }
        else if (this.brand == 'Powersports'){
            this.brandLogoImage = this.baseURL + this.powersportsLogoSrc;
        }
        else if (this.brand == 'Marine'){
            this.brandLogoImage = this.baseURL + this.marineLogoSrc;
        }
        else if (this.brand == 'Powerequipment'){
            this.brandLogoImage = this.baseURL + this.powerequipmentLogoSrc;
        } */
        //console.log('Product Image connected callback 2');
    }

    handleImgError(event){
        //console.log('IMG ERROR: ');
        //console.log(JSON.stringify(event));
        //console.log(this.brand);
        //console.log(this.productImage);
        //this.imgError = true;
        this.imgErrorState.image = this.productImage;
        this.imgErrorState.hasError = true;
    }

}