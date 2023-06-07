import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getFinanceLink from '@salesforce/apex/OwnRetriveCustomMetaData.getFinanceLink';
import { ISGUEST } from 'c/ownDataUtils';

export default class OwnFinanceAndMarketplace extends OwnBaseElement {
    @api redirectlink;
    @api title = "Finance";
    @api body = "Honda Financial Services is your one-stop shop for your Honda finance needs. Register for a Honda Financial Services account to make payments online, view your payment history, go paperless and more";
    @api buttontitle = "GO TO HONDA FINANCE";
    @api isdreamshop = false;
    @api redirectloginlink;

    connectedCallback() {
        if (!this.isdreamshop) {
            this.initialize();
        }
    }

    initialize = async () => {
        await getFinanceLink({ brand: 'Honda' }).then((data) => {
            this.redirectlink = data.Login_Link__c;
            //console.log('@@Data', data.Login_Link__c);
        }).catch((error) => {
            //console.log('@@Error getting Data', error);
        });
    }
    handleRedirect() {
        if (this.isdreamshop && !ISGUEST) {
            this.navigate(this.redirectloginlink, {})
        } else {
            this.navigate(this.redirectlink, {})
        }
    }
}