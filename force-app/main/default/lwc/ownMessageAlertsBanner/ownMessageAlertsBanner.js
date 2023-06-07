import { LightningElement, track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import getAlerts from '@salesforce/apex/ownMessageController.getAlerts';

export default class OwnMessageAlertsBanner extends OwnBaseElement {
    @track isPdpOrHome;
    @track initialtext;
    @api safetyAlertsTopic = 'Safety Alerts';
    @api productAlertsTopic = 'Product Alerts';

    connectedCallback() {
        //this.initialtext = 'There are alerts for your garage products.';
        this.initialtext = 'There is an alert available. ';
        let pdpPages = ['/garage-acura', '/garage-honda', '/garage-powersports', '/garage-powerequipment', '/garage-marine'];
        pdpPages.forEach(pg => {
            if(window.location.href.includes(pg)){
                this.isPdpOrHome = true;
            }
        });
        if(window.location.href.endsWith('/s/')){
            this.isPdpOrHome = true;
        }
        //this.getAlertsCMSContent();
    }

    /* async getAlertsCMSContent(){
        let topics = [this.safetyAlertsTopic, this.productAlertsTopic];
        let content = await getManagedContentByTopicsAndContentKeys([], topics, this.pageSize, this.managedContentType);
        this.isPdpOrHome = content.length > 0 ? true : false;
    } */

    async getDisplayAlert(){
        getAlerts()
            .then(result => {
                this.isPdpOrHome = result.length > 0 ? true : false;
            })
            .catch(error => {
                //console.log(JSON.stringify(error));
            })
    }

    handleViewAlerts(){
        this.navigate('/messages', {});
    }

    handleClose(){
        this.isPdpOrHome = false;
    }
}