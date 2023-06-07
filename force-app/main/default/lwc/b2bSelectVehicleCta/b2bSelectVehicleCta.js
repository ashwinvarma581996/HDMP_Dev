import {LightningElement, track, api} from 'lwc';

export default class B2bSelectVehicleCta extends LightningElement {

    @track showChangeVehicleModal = false;

    @api alignment

    @api buttonColor

    @api buttonTextColor

    @api buttonTextSize

    @api buttonLabel

    @api get ctaButtonAlign() {
        let ctaClasses = 'slds-m-vertical_medium slds-button slds-button_brand category-banner-cta';
        if (this.alignment) {
            var alignmentSetting = this.alignment;
            switch (alignmentSetting) {
                case 'Left':
                    alignmentSetting=' slds-float_left'
                    break;
                case 'Center':
                    alignmentSetting=' slds-float_center'
                    break;
                case 'Right':
                    alignmentSetting=' slds-float_right'
                    break;
            }
            ctaClasses = ctaClasses.concat(alignmentSetting);
        }
        return ctaClasses;
    }

    @api get ctaButtonStyles() {
        let resultCSS = [];
        if (this.buttonColor) {
            resultCSS.push(`background-color: ${this.buttonColor}!important`);
            resultCSS.push(`border-color: ${this.buttonColor}!important`);
        }
        if (this.buttonTextColor) {
            resultCSS.push(`color: ${this.buttonTextColor}!important`);
        }
        if (this.buttonTextSize) {
            var buttonTextSizeEm = this.buttonTextSize;
            switch (buttonTextSizeEm) {
                case 'Large':
                    buttonTextSizeEm='18px'
                    break;
                case 'Medium':
                    buttonTextSizeEm='16px'
                    break;
                case 'Small':
                    buttonTextSizeEm='14px'
                    break;
            }
            resultCSS.push(`font-size: ${buttonTextSizeEm}`);
        }
        return resultCSS.join('; ');
    }

    @api get ctaButtonLabel() {
        if (this.buttonLabel) {
            return this.buttonLabel;
        } else {
            return 'SELECT VEHICLE'
        }
    }

    categoryBannerSelectVehicle(event){
        this.showChangeVehicleModal = true;
    }

    closeChangeVehicleModal(event) {
        this.showChangeVehicleModal = false;
    }
}