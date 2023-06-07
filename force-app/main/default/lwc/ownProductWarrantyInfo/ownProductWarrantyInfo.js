import {api, track} from 'lwc';
import { ISGUEST, getProductContext, getContext, getOrigin} from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';
import getManualByModel from '@salesforce/apex/OwnAPIController.getManualByModelId';
import checkUserHasWarranty from '@salesforce/apex/OwnWarrantyController.checkUserHasWarranty';
import getWarrantyEndDate from '@salesforce/apex/OwnWarrantyController.getWarrantyEndDate';
import getEmissionWarrantyBooklet from '@salesforce/apex/OwnAPIController.getEmissionWarrantyBooklet';
import warranties from '@salesforce/resourceUrl/warranties';
export default class ownProductWarrantyInfo extends OwnBaseElement {
    @api icon;
    @api titlecolor = 'Honda Red';
    @api contentId;
    @api contentAutos;
    @api contentPS;
    @api contentEmissionWarrantyAll;
    @api contentEmissionWarrantyCA;
    @api saveToMyGarageContentId;
    @api contentIdPowerequipmentPage;
    @api dateWisePdfTopicPowerequipment;
    @api emmissionWisePdfTopicPowerequipment;
    @api warrantiesTopicPowersports;
   
    @api emmissionWisePdfTopicMarine;
    @api contentIdMarinePage;
    @api contentIdMarineDoc;

    //For Tire Warranty Cards
    @api contentTopicHonda;
    @api accordianTopicHonda;
    @api contentTopicAcura;
    @api accordianTopicAcura;

    guest = true;
    @track isGuest = ISGUEST;
    @track displayAcura = false;
    @track displayPowersports=false;
    @track displayPowerequipment=false;
    @track displayMarine=false;
    @track displayHonda = false;
    @track division;
    @track hideWarranty = false;

    @track states;
    @track bookletUrl;
    @track warrentyEndDate;
    @track showWarrentyMsg=false;
    manufacturedValue;
    showOutboardWarranty=false;
    headerLink;

    get manufacturedOptions() {
        return [
                 { label: 'Manufactured January1, 2016 to March 31, 2023', value: 'M01' },
                 { label: 'Manufactured on or after April 1, 2023', value: 'M02' }
               ];
    }

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + 'black-booklet.svg';
        this.initialize();
    }

    initialize = async () => {

        // const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
        // this.context = await getContext('');
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {

            this.context = await getProductContext('', true);

        } else {
            this.context = await getProductContext('', false);
            // this.context = await getContext('');
        }
        //console.log('$EW-CONTEXT', JSON.stringify(this.context));
        //console.log('$EW-CONTEXT', JSON.stringify(window.location.search));
        if(this.context && this.context.product){
        this.division = this.context.product.division;
        }
        if(window.location.search == '?help=marine'){
            this.division = 'Marine';
        }
        //console.log('division', JSON.stringify(this.division));
        if (this.division === 'Acura') {
            this.displayAcura = true;
        }
        if(this.division === 'Honda') {
            this.displayHonda = true;
          }
        if(this.division === 'Motorcycle/Powersports' || this.division == 'Powersports'){
            this.displayPowersports = true;
        }
        if(this.division === 'Marine'){
          this.displayMarine = true;
        }
        if(this.division === 'Powerequipment'){
          this.displayPowerequipment = true;
        }
        if(this.context && this.context.product){
            let vinNumber;
            if (this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-'))
                vinNumber = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
            await checkUserHasWarranty({ vinNumber: vinNumber ?? ''}).then((result) => {
                //console.log('$EW-checkUserHasWarranty_Result-', result);
                this.hideWarranty = Object.values(result)[0];
                //console.log('$EW-checkUserHasWarranty_hideWarranty-', this.hideWarranty);
            }).catch((err) => {
                //console.log('$EW-checkUserHasWarranty_Error-', err);
            });
            await getWarrantyEndDate({vinNumber: vinNumber ?? ''}).then((result) => {
                if(result != ''){
                this.warrentyEndDate=result;
                this.showWarrentyMsg=true;
                }else{
                 this.showWarrentyMsg=false;
                }
            }).catch((err) => {
                //console.log('@@error', err);
            });
        }
        if( ( this.displayAcura || this.displayHonda ) && this.context && this.context.product && this.context.product.modelId){
            await getEmissionWarrantyBooklet({modelId: this.context.product.modelId}).then((result) => {
                //console.log('$EW-Result',result);
                if(result.mot && result.mot.db_results && result.mot.db_results.assets && result.mot.db_results.assets.asset && result.mot.db_results.assets.asset[0] && result.mot.db_results.assets.asset[0]['@path']){
                    this.bookletUrl = 'https://owners.honda.com/' + result.mot.db_results.assets.asset[0]['@path'];
                    //console.log('$EW-Asset',result.mot.db_results.assets.asset[0]);
                }else{
                    //console.log('$EW-No_Asset');
                }
                if(result.mot && result.mot.db_results && result.mot.db_results.custom_types && result.mot.db_results.custom_types.custom_type && result.mot.db_results.custom_types.custom_type[0] && result.mot.db_results.custom_types.custom_type[0]['#text']){
                    let statesAndPdfs =  JSON.parse(result.mot.db_results.custom_types.custom_type[0]['#text']);
                    let statesToSend = [];
                    statesAndPdfs.forEach(stp => {
                        ////console.log('$EW-STP: ',stp);
                        if(stp.pdf && stp.pdf.toLowerCase() != 'null'){
                            statesToSend.push(stp);
                        }
                    });
                    if(statesToSend.length > 0){
                        this.states = JSON.stringify(statesAndPdfs);
                    }
                    //console.log('$EW-States',statesAndPdfs);
                }else{
                    //console.log('$EW-No_States');
                }
            }).catch((err) => {
                //console.log('$EW-Error',err);
            });
            //console.log('$EW-BookletUrl',this.bookletUrl);
        }
        
        //console.log('Product Warranty Info', this.accordianTopicAcura, this.accordianTopicAcura)
        //console.log('Emission Warranty Content 1', this.contentEmissionWarrantyAll);
        //console.log('Emission Warranty Content 2', this.contentEmissionWarrantyCA);

        let res = {};
        await getManualByModel({
                modelId: 'CS2188JNW,en,US',
                divisionId: 'A',
            })
            .then((result) => {
                res = result;
                 //console.log('getManualByModel resp!', res)
            })
            .catch((error) => {
                //console.log('getManualByModel error', error)
            })
            .finally(() => {});

    }

    renderedCallback(){
        let scrollClass = sessionStorage.getItem('scroll');
        //console.log('$Scroll: scrollClass - ',scrollClass);
        if(scrollClass){
            let scrollElement = this.template.querySelector("." + scrollClass);
            if(scrollElement){
                let elemenetChild = scrollElement.getElementFromChild();
                elemenetChild.scrollIntoView({behavior: "smooth", block: "start", inline: "start"});
                setTimeout(() => {
                    sessionStorage.removeItem('scroll');
                    //console.log('$Scroll: Removed');
                }, 1000);
            }
        }
    }
    
    @api
    get displayPowerSports() {

        let garage = JSON.parse(localStorage.getItem('garage'));
        return (this.division === 'Motorcycle/Powersports');
    }
    @api
    get displayPowerEquipment() {

        let garage = JSON.parse(localStorage.getItem('garage'));
        return (this.division === 'Powerequipment');
    }
    @api
    get displayMarine() {

        let garage = JSON.parse(localStorage.getItem('garage'));
        return (this.division === 'Marine');
    }

    handleManufactureDateChange(event) {
        this.activeDeactivateButton();
        //console.log(event.target.value);
        this.manufacturedValue = event.target.value;
        this.showOutboardWarranty=false;
    }

    handleFindPdfs(){
        this.showOutboardWarranty=true;
    }

    activeDeactivateButton() {
        this.template.querySelector('.find-button').classList.remove('slds-brand-button-inactive');
        this.template.querySelector('.find-button').classList.add('slds-brand-button-active');
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon ' : 'slds-p-left_small ';
    }

    handleHeaderClick(){
        this.headerLink=window.location.origin + warranties+'/marine/warranty-documents/outboards-motors-warranty-'+this.manufacturedValue+'.pdf';
       let isMobile = window.matchMedia("(max-width: 600px)").matches;
       if (isMobile) {
           window.open(this.headerLink, "_blank");
       } else {
           let pdfLink = this.headerLink;
           sessionStorage.setItem('pdflink', pdfLink);
           window.open(window.location.origin + window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/')) + '/pdf-document' + '?PDF=' + pdfLink.substring(pdfLink.lastIndexOf('/') + 1), "_blank");
       }
    }
}