import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getManageSubscriptions from '@salesforce/apex/OwnAPIController.getManageSubscriptions';

export default class OwnSubscriptions extends OwnBaseElement {

    @api vin;
    @api divisionId;
    @api pageType;

    @track packagesList = [];

    get hasPackages() {
        return this.packagesList && this.packagesList.length > 0;
    }

    get accountPage() {
        return this.pageType === 'account' ? true : false;
    }
    get productDetailsPage() {
        return this.pageType === 'pdp' ? true : false;
    }

    connectedCallback(){
        //this.getPackages();
        this.initialize();
    }

    initialize = async() => {
        let manageSubs = await getManageSubscriptions({productIdentifier : this.vin, divisionId : this.divisionId})
        if(manageSubs && manageSubs.packages) {
            manageSubs.packages.forEach(pack => {
                if(pack.status === "Active"){
                    this.packagesList.push(pack.packageDisplayName);
                }
            });
        }
    }
}