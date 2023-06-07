import { track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { ISGUEST, getProductContext, getOrigin } from 'c/ownDataUtils';
import getUserMailingState from '@salesforce/apex/OwnWarrantyController.getUserMailingState';
import getWarrantyBooklets from '@salesforce/apex/OwnAPIController.getEmissionWarrantyBooklet';
import checkUserHasWarranty from '@salesforce/apex/OwnWarrantyController.checkUserHasWarranty';

export default class OwnAllWarrantyInformationAutos extends OwnBaseElement {
    @track isLoading = true;
    @api emissionWarrantyContentId;
    @api tireWarrantyContentId;
    @track tireWarrantyIcon;
    context;
    @track emissionWarrantyURL = '';
    @track warrantyBookletURL = '';
    @track showWarrantyBooklet;
    @track showEmissionWarranty;
    tireWarrantyHeaderLink = '/warranty-info';
    @track showTireWarranty = false;
    get firstCardClass() {
        if (this.showWarrantyBooklet) {
            return 'first-warranty-card';
        }
    }
    get secondCardClass() {
        if (this.showWarrantyBooklet && this.showEmissionWarranty) {
            return 'second-warranty-card';
        }
        else {
            return 'first-warranty-card';
        }
    }
    get thirdCardClass() {
        if (this.showWarrantyBooklet && this.showEmissionWarranty) {
            return 'third-warranty-card';
        } else if (!this.showWarrantyBooklet && this.showEmissionWarranty) {
            return 'second-warranty-card';
        } else if (this.showWarrantyBooklet && !this.showEmissionWarranty) {
            return 'second-warranty-card';
        } else {
            return 'first-warranty-card';
        }
    }
    connectedCallback() {
      //  console.log('$EW content-id', this.tireWarrantyContentId)
        this.initialize();
    }

    initialize = async () => {
        if (getOrigin() == 'ProductChooser') {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        if (this.context.product.divisionId == 'B') {
            this.tireWarrantyIcon = ISGUEST ? 'warranty.svg' : 'wheel.svg';
        } else {
            this.tireWarrantyIcon = 'warranty.svg';
        }
        //console.log('$EW tireWarrantyIcon', this.tireWarrantyIcon)
        let userState = await getUserMailingState();
        let hasWarrantyBooklet;
        //console.log('$EW state', userState);
        await getWarrantyBooklets({ modelId: this.context.product.modelId }).then((result) => {
           // console.log('$EW-Result', result);
            //Waranty Booklet
            if (result.mot && result.mot.db_results && result.mot.db_results.assets && result.mot.db_results.assets.asset && result.mot.db_results.assets.asset[0] && result.mot.db_results.assets.asset[0]['@path']) {
                this.warrantyBookletURL = 'https://owners.honda.com/' + result.mot.db_results.assets.asset[0]['@path'];
                hasWarrantyBooklet = true;
              //  console.log('$EW-warrantyBooklet-Asset', this.warrantyBookletURL, hasWarrantyBooklet);
            } else {
                hasWarrantyBooklet = false;
              //  console.log('$EW-No-warrantyBooklet-Asset', hasWarrantyBooklet);
            }
            //Emission Warranty 
            if (ISGUEST || (userState === null && !ISGUEST)) {
                if (result.mot && result.mot.db_results && result.mot.db_results.custom_types && result.mot.db_results.custom_types.custom_type && result.mot.db_results.custom_types.custom_type[0] && result.mot.db_results.custom_types.custom_type[0]['#text']) {
                    let statesAndPdfs = JSON.parse(result.mot.db_results.custom_types.custom_type[0]['#text']);
                    //console.log('$EW-Result ISGUEST', JSON.stringify(statesAndPdfs));
                    for (let i = 0; i < statesAndPdfs.length; i++) {
                        if (statesAndPdfs[i].pdf && statesAndPdfs[i].pdf.toLowerCase() != 'null') {
                            //console.log('$EW-if ', i);
                            this.emissionWarrantyURL = '/warranty-info';
                            this.showEmissionWarranty = true;
                            break;
                        }
                    }
                } else {
                    this.showEmissionWarranty = false;
                    //console.log('$EW-NO-EmissionWarranty-states', this.showEmissionWarranty);
                }
            }
            else {
                if (result.mot && result.mot.db_results && result.mot.db_results.custom_types && result.mot.db_results.custom_types.custom_type && result.mot.db_results.custom_types.custom_type[0] && result.mot.db_results.custom_types.custom_type[0]['#text']) {
                    let statesAndPdfs = JSON.parse(result.mot.db_results.custom_types.custom_type[0]['#text']);
                    //console.log('$EW-Result', JSON.stringify(statesAndPdfs));
                    for (let i = 0; i < statesAndPdfs.length; i++) {
                        //console.log('$EW-for');
                        if (statesAndPdfs[i].state.toLowerCase() == userState.toLowerCase()) {
                            //console.log('$EW-if 1');
                            if (statesAndPdfs[i].pdf && statesAndPdfs[i].pdf.toLowerCase() != 'null') {
                                //console.log('$EW-if 2');
                                this.emissionWarrantyURL = 'https://owners.honda.com/Documentum/' + statesAndPdfs[i].pdf;
                                this.showEmissionWarranty = true;
                                break;
                            }
                            break;
                        }
                    }
                    if (this.emissionWarrantyURL == '') { this.showEmissionWarranty = false };
                    //console.log('$EW-EmissionWarranty-Asset', this.emissionWarrantyURL, this.showEmissionWarranty);
                } else {
                    this.showEmissionWarranty = false;
                    //console.log('$EW-NO-EmissionWarranty-Asset', this.showEmissionWarranty);
                }
            }
        }).catch((err) => {
            this.showEmissionWarranty = false;
            this.hasWarrantyBooklet = false;
            //console.log('$EW-Error-getWarrantyBooklets', err);
        });
        let hideWarranty;
        let vinNumber;
        if (this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-'))
            vinNumber = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
        await checkUserHasWarranty({ vinNumber: vinNumber ?? '' }).then((result) => {
            //console.log('$EW-checkUserHasWarranty_Result-', result);
            hideWarranty = Object.values(result)[0];
            //console.log('$EW-checkUserHasWarranty_hideWarranty-', hideWarranty);
        }).catch((err) => {
            //console.log('$EW-checkUserHasWarranty_Error-', err);
        });
        this.showWarrantyBooklet = !hideWarranty && hasWarrantyBooklet ? true : false;
        this.showTireWarranty = true;
        this.isLoading = false;
    }
}