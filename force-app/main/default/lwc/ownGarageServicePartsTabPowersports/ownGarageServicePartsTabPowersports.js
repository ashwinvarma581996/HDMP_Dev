import { api, LightningElement } from 'lwc';

export default class OwnGarageServicePartsTabPowersports extends LightningElement {

    //Added By : Abhishek Salecha on 8th October 2021
    @api protectionPlanContent;

    //Added By : Abhishek Salecha on 8th October 2021
    connectedCallback(){
        //console.log('This.protectionPlanContent', this.protectionPlanContent);
    }
}