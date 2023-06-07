import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnQuickStartGuideSteps extends OwnBaseElement {
    @api contentId;
    @api containerBodyName;
    @api sourceType;
    @api brandName;
    @track productImage = this.myGarageResource() + '/images/quickstartguideproduct.png';

    @api setContainerBody(value) {
        //console.log('value  :-  ',value);
        this.containerBodyName = value;
    }
    
    get isGetToKnowYourHonda() {
        return this.containerBodyName == 'Get_to_know_your_Honda'
    }

    get isConnectyourSmartphone() {
        return this.containerBodyName == 'Connect_your_Smartphone'
    }

    get isGetToKnowYourMotor() {
        return this.containerBodyName == 'Get_to_Know_Your_Motor'
    }

    get isSourceTypePdp() {
        return this.sourceType == 'PDP';
    }

    get isAcura() {
        return this.brandName == 'Acura';
    }

    get isHonda() {
        return this.brandName == 'Honda';
    }

    get isPowersports() {
        return this.brandName == 'Powersports';
    }

    get isPowerequipment() {
        return this.brandName == 'Powerequipment';
    }

    get isMarine() {
        return this.brandName == 'Marine';
    }
}