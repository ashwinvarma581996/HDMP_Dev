import { LightningElement, track, wire, api } from 'lwc';
import { ISGUEST, getProductContext, getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';
import { CurrentPageReference } from 'lightning/navigation';
import getPairingInstructionByPhone from '@salesforce/apex/OwnAPIController.getPairingInstructionByPhone';


export default class OwnBluetoothCompatibilityResult extends OwnBaseElement {
    @track sortBy = 'LastPublishedDate';
    @track onThePhonedata;
    @track firstPhonedata;
    @track subSequentdata;
    @track isOnThePhonedata;
    @track isFirstPhonedata;
    @track isSubSequentdata;
    @track iscompatible = false;
    @track disclaimer;
    @api hondaContentId;
    @api acuraContentId;
    contentKeys = [];
    @api title = '';
    @track fb;
    @track errorLogo;
    @track isDataLoading = true;
    @track hasDataExist = false;
    context;

    currentPageReference = null;
    urlStateParameters = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.fb = this.urlStateParameters.fb || null;
    }


    connectedCallback() {
        this.initialize();
        this.errorLogo = this.myGarageResource() + '/ahmicons/warning.png';
    }

    initialize = async () => {
        try {
            this.context = await getProductContext('', true);
            if (this.context) {
                this.divisionId = this.context.product.divisionId;
                this.modelId = this.context.product.modelId;
                this.carrierId = this.context.product.phoneCarrierId;
                this.manufacturerId = this.context.product.manufacturerId;
                this.phoneId = this.context.product.phoneModelId;
                if (this.divisionId == 'A') {
                    this.contentKeys.push(this.hondaContentId);
                } else {
                    this.contentKeys.push(this.acuraContentId);
                }

                let results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
                this.disclaimer = this.htmlDecode(results[0].body.value);

                getPairingInstructionByPhone({ modelId: this.modelId, carrierId: this.carrierId, manufacturerId: this.manufacturerId, phoneId: this.phoneId, divisionId: this.divisionId })
                    .then((data) => {
                        this.iscompatible = data.iscompatible;
                        this.firstPhonedata = data.firstPhonedata;
                        this.onThePhonedata = data.onThePhonedata;
                        this.subSequentdata = data.subSequentdata;
                        this.isFirstPhonedata = data.isFirstPhonedata;
                        this.isOnThePhonedata = data.isOnThePhonedata;
                        this.isSubSequentdata = data.isSubSequentdata;
                        this.isDataLoading = false;
                        this.hasDataExist = true;
                    }).catch((error) => {
                        console.error('Error:', error);
                        this.isDataLoading = false;
                        this.hasDataExist = true;
                    });
            }
        }
        catch (err) {
            //console.log('error'+err);
            this.isDataLoading = false;
            this.hasDataExist = true;
        }
    };

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
}