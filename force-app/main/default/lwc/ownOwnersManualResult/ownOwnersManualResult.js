import { LightningElement, track, api, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys, getProductContext, ISGUEST, getContext_fromBrowser } from 'c/ownDataUtils';
import getTrims from '@salesforce/apex/FindProductController.getTrims';// Trims
import getManualByVIN from '@salesforce/apex/OwnAPIController.getManualByVIN';
import getManualByModelPS from '@salesforce/apex/OwnManualsApiController.getManualByModelPS';
import getManualByVINAuto from '@salesforce/apex/OwnManualsApiController.getManualByVINAuto';
import getManualByModelIdAuto from '@salesforce/apex/OwnManualsApiController.getManualByModelIdAuto';
import getManualRequest from '@salesforce/apex/OwnRetriveCustomMetaData.getManualRequest';


export default class OwnOwnersManualResult extends OwnBaseElement {
    @track categories;
    @track subcategory;
    @track showResult = false;
    @track showSearchResult = false;
    @track category;
    @track resultData;
    @track showMessage;
    @track showData = false;
    @track showmanuals = false;

    @track results;
    @track divisionId; //Trims
    @track year; //Trims
    @track modelName; //Trims
    @track trims; //Trims
    @track trim; //Trims
    @track modelId; //Trims
    @track selectedYear;//Trims
    @track selectedModel;//Trims
    @track selectedDivisionID;//Trims
    @track displayHonda = false;
    @track displayPowerSports = false;
    @track displayPowerEquipment = false;
    @track displayMarine = false;
    @track selectedTrim = '';
    @track showTrimList = false;
    @track vehicleTrimList;
    @api HondacontentId;
    @api AcuracontentId
    @api PScontentId;
    @api PEcontentId;
    @api MarinecontentId;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track title
    @track subTitle
    @track footerData;
    @track ownersBody = 'This owner’s manual covers all models of your vehicle. You may find descriptions of equipment and features that are not on your particular model.';
    @track navigationBody = 'This manual describes the navigation and setup functions.';
    @track powerSportsEndpoint = 'https://cdn.powersports.honda.com/';
    @track warningImage = this.myGarageResource() + '/ahmicons/warning.png';
    @track navigationTitle;
    @track ownersTitle;
    @track navigationUrl;
    @track ownersUrl;
    @track vinNumber;
    @track adobeBody;
    @track printedCopy;
    @track isTrimsPresent;
    @track orderNow=  false;
    @track contextTrim;
    @track selectHere=false;

    connectedCallback() {
        this.initialize();
    }

    initialize = async () => {
        this.showData = false;
        this.showMessage = false;
        let origin = localStorage.getItem('origin');
        if (ISGUEST || origin == 'ProductChooser') {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        if (this.context) {
            this.selectedYear = this.context.product.year; //Trims
            this.selectedModel = this.context.product.model; //Trims
            this.selectedDivisionID = this.context.product.divisionId; //Trims
            this.division = this.context.product.division;
            this.modelId = this.context.product.modelId;
            this.vinNumber = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
            this.contextTrim=this.context.product.trim;
            //console.log('@@division' + this.division);
            if (this.division === 'Acura') {
                this.displayAcura = true;
                this.displayHonda = true;
                this.contentKeys.push(this.AcuracontentId);
            }
            if (this.division === 'Honda') {
                this.displayHonda = true;
                this.contentKeys.push(this.HondacontentId);
            }
            if (this.division === 'Motorcycle/Powersports' || this.division === 'Powersports') {
                this.displayPowerSports = true;
                this.contentKeys.push(this.PScontentId);
            }
            if (this.division === 'Powerequipment') {
                this.displayPowerEquipment = true;
                this.contentKeys.push(this.PEcontentId);
            }
            if (this.division === 'Marine') {
                this.displayMarine = true;
                this.contentKeys.push(this.MarinecontentId);
            }
            if (this.division === 'Powerequipment' || this.division === 'Marine') {
                //  this.displayPowerEquipment = true;
                await this.getOwnersManualByVIN();
            }
            if (this.division === 'Motorcycle/Powersports' || this.division === 'Powersports') {
                //  this.displayPowerEquipment = true;
                await this.getOwnersManualByModelIDPS();
            }
            if (this.vinNumber && this.vinNumber != '-') {
                this.trims = undefined;
                this.showTrimList = false;
                this.isTrimsPresent = false;
            }
            if (this.division === 'Acura' || this.division === 'Honda') {
                if (this.vinNumber && this.vinNumber != '-') {
                    await this.getOwnersManualByVINAuto();
                } else {
                    await this.getOwnersManualByModelIdAuto();
                }
            }
            this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
            this.results.forEach(r => {
                //console.log('@@Test' + JSON.stringify(r));
                if (r.subTitle) {
                    this.subTitle = r.subTitle.value;
                }
                if (r.phone2Number) {
                    this.ownersBody = r.phone2Number.value;
                }
                if (r.phoneNumber) {
                    this.navigationBody = r.phoneNumber.value;
                }
                if (this.division === 'Acura' || this.division === 'Honda') {
                    this.adobeBody = this.htmlDecode(r.body.value);
                    this.printedCopy = r.descriptionLabel.value;
                }
                if (this.division === 'Acura' || this.division === 'Honda' || this.division === 'Marine') {
                    this.footerData = this.htmlDecode(r.sectionContent.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>');
                }

            });
            if (this.division === 'Acura' || this.division === 'Honda' ) {
            if((this.selectedYear >= 2019 && this.selectedModel == 'Odyssey') ||( this.selectedYear >= 2019 && this.selectedYear <= 2022 && this.selectedModel == 'Pilot')){
                this.selectHere=true;
            }    
            await getManualRequest({brand: this.division}).then((data) => {
                //console.log('@@r'+JSON.stringify(data));
                data.forEach(arrayIteam =>{
                    if(arrayIteam.Year__c == this.selectedYear){
                    arrayIteam.Models__c.split(';').forEach(ele =>{
                        if(ele.includes('::')){
                            let modleAndTrim=ele.split('::');
                            if(this.selectedModel == modleAndTrim[0] && this.contextTrim.toLowerCase().includes(modleAndTrim[1])){
                                this.orderNow=true;
                            }
                        }else if(ele == this.selectedModel){
                            this.orderNow=true;
                        }
                    });
                    }
                });
                //console.log('@@s'+JSON.stringify(this.yearsArray));
         }).catch((error) => {
             //console.log('@@Error getting Data', error);
         });
        }
        }
        this.showData = true;
    }


  /*  @wire(getTrims, { divisionId: '$selectedDivisionID', year: '$selectedYear', modelName: '$selectedModel' }) //Trims
    wiredGetTrims({ error, data }) {
        if (data) {
            this.trims = data;
            console.log('Trims' + this.selectedYear + this.selectedModel, JSON.stringify(this.trims));
            if ((this.trims).length > 0) {
             //   this.showTrimList = true;
             //   this.isTrimsPresent = true;
                if (this.vinNumber && this.vinNumber != '-') {
                    this.showTrimList = false;
                    this.isTrimsPresent = false;
                }
                console.log('My Trims:', JSON.stringify(this.trims));
            }

        } else if (error) {
            // this.showToast_error(error);
            this.trims = undefined;
            this.trim = undefined;
            //  this.modelId = undefined;
        }
    }*/

    trimSelectHandler(event) {
        this.selectedTrim = event.detail.trim;
        this.modelId = event.detail.modelId;
        //console.log('selectedTrim', JSON.stringify(this.selectedTrim), '@@', this.modelId, '@@', event.detail.tab === undefined);
        if (!(event.detail.tab === undefined)) {
            if (event.detail.tab == 'false') {
                this.showTrimList = false;
            }
            if (this.division === 'Acura' || this.division === 'Honda') {
                if (this.vinNumber && this.vinNumber != '-') {
                    // this.getOwnersManualByModelIdAuto();
                } else {
                    this.getOwnersManualByModelIdAuto();
                }
            }
        }

    }

    getOwnersManualByVIN() {
        getManualByVIN({ productIdentifier: this.context.product.vin, divisionId: this.context.product.divisionId, division: this.context.product.division, modelId: this.context.product.modelId })
            .then((data) => {
                let [key, value] = Object.entries(data.manualsByModel)[0];
                this.resultData = value;
                if (this.resultData.length > 0) {
                    this.showMessage = false;
                } else {
                    this.showMessage = true;
                }
            }).catch((error) => {
                this.showMessage = true;
               // console.error('Error:', error);
            });
    }
    getOwnersManualByModelIDPS() {
        getManualByModelPS({ divisionId: this.context.product.divisionId, division: this.context.product.division, modelId: this.context.product.modelId })
            .then((data) => {
                this.resultData = data.manualsByModel;
                if (this.resultData.length > 0) {
                    this.showMessage = false;
                } else {
                    this.showMessage = true;
                }
            }).catch((error) => {
                this.showMessage = true;
                //console.log('Error:', error);
            });
    }
    getOwnersManualByModelIdAuto() {
       this.showmanuals=false;
        getManualByModelIdAuto({ divisionId: this.context.product.divisionId, division: this.context.product.division, modelId: this.modelId })
            .then((data) => {
                if (data.manualsList.length > 0) {
                    this.resultData = data.manualsList;
                    for(var i=0;i < data.manualsList.length  ; i++){
                        if(data.manualsList[i].title.toLowerCase().includes('owner') && data.manualsList[i].url.toLowerCase().includes('.pdf')){
                            this.ownersUrl= data.manualsList[i].url;
                        }
                    }
                    this.showMessage = false;
                } else {
                    this.showMessage = true;
                }
                this.showmanuals=true;
            }).catch((error) => {
                this.showmanuals=true;
                this.showMessage = true;
               // console.log('Error:', error);
            });
    }

    getOwnersManualByVINAuto() {
        this.showmanuals=false;
        getManualByVINAuto({ productIdentifier: this.vinNumber, divisionId: this.context.product.divisionId, division: this.context.product.division })
            .then((data) => {
                //console.log('@@TestVinNumber' + JSON.stringify(data));
                if (data.manualsList.length > 0) {
                    this.resultData = data.manualsList;
                    for(var i=0;i < data.manualsList.length  ; i++){
                        if(data.manualsList[i].title.toLowerCase().includes('owner') && data.manualsList[i].url.toLowerCase().includes('.pdf')){
                            this.ownersUrl= data.manualsList[i].url;
                        }
                    }
                    this.showMessage = false;
                } else {
                    this.showMessage = true;
                }
                this.showmanuals=true;
            }).catch((error) => {
                this.showmanuals=true;
                this.showMessage = true;
                //console.log('Error:', error);
            });
    }
    /*   get NavigationTitle() {
           return this.selectedYear + ' ' + this.selectedModel + ' NAVIGATION MANUAL';
       }
   
       get ownersTitle() {
           return this.selectedYear + ' ' + this.selectedModel + " OWNER'S MANUAL";
       }*/


    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }

    handleDownload() {
        this.navigate(this.ownersUrl, {});
    }

    handlebackdrop() {
        //console.log('TEst');
        this.showTrimList = true;
    }
    handleOrderNow(){
        this.navigate('/manual-request', {});
    }
    handleSelectHere(){
        this.navigate('/manual-request?page=braille', {});
    }

}