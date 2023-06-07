import { api, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/Owners";
import basePath from '@salesforce/community/basePath';
import { CurrentPageReference } from 'lightning/navigation';
import getCIAMConfig from '@salesforce/apex/OwnUserHandler.getCIAMConfig';
import getPEOrMarineRecallsUpdateurl from '@salesforce/apex/OwnWarrantyController.getPEOrMarineRecallsUpdateurl';
import getRecallByOwnership from '@salesforce/apex/OwnRecallsController.getRecallByOwnership';
//Imtiyaz - RECALLS Start
import { ISGUEST, getOrigin, getContext, getGarage, getProductContext, getRecalls, getManagedContentByTopicsAndContentKeys, getDate} from 'c/ownDataUtils';
//Imtiyaz - RECALLS End
export default class ownRecallDetail extends OwnBaseElement {

    @api contentId98;
    @track content98;
    @api contentId97;
    @track content97;
    @api RecallBodyline1ID;
    @track RecallBodyline1;
    @api RecallBodyline2ID;
    @track RecallBodyline2;
    @api NoRecallNoGuestID;
    @track NoRecallNoGuest;
    @api NoRecallloggedInID;
    @track NoRecallloggedIn;
    @track context;
    @track division;
    @track isGuest = ISGUEST;
    @track showvalue;
    @track recallMessages;
    @track singleRecordForLargeScreen;
    @track singleRecordForSmallScreen;
    @track hasVin;
    @track vinNumber;
    @track hideEnterVin;
    @api saveToMyGarageContentId;

    //Imtiyaz - RECALLS Start
    @api contentMoreInfo;
    @api contentMoreInfoA;
    @api contentMoreInfoH;
    @api contentMoreInfoP;
    @track pspAdditionalInfo = {};
    //Imtiyaz - RECALLS End

    @track recallData = [];
    previousSection;
    @track singleRecall;
    showAccordian = true;
    noRecalls = false;
    noVIN = false;
    prevtargetId;
    vinHelpIcon = commonResources + '/Icons/garage_questionmark.png';
    @track totalRecalls = 0;
    @track lastupdatedDate;

    currentPageReference = null;
    urlStateParameters = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            //console.log('RECALLS: url parameters', this.urlStateParameters)
        }
    }

    connectedCallback() {
        //Imtiyaz - RECALLS Start
        this.lastupdatedDate = getDate(7);
        //console.log('$RECALLS: lastupdatedDate1: ',this.lastupdatedDate);
        //Imtiyaz - RECALLS End
        this.initialize();
    }

    //Imtiyaz - RECALLS Start
    get last_updated_date(){
        return this.lastupdatedDate ? this.lastupdatedDate : getDate(7);
    }
    //Imtiyaz - RECALLS End

    initialize = async () => {

        //Imtiyaz - RECALLS Start
        this.pspAdditionalInfo.content_text = 'This website provides information about safety recalls announced in the past 15 calendar years; older recalls are not included.';
        //console.log('$RECALLS: pspAdditionalInfo: ',JSON.parse(JSON.stringify(this.pspAdditionalInfo)));
        //Imtiyaz - RECALLS End

        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('RECALLS: From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getContext('');
        }
        if (this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-')) {
            this.vinNumber = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
            this.hasVin = true;
        }
        if (this.hasVin && this.context && this.context.product && this.context.product.ownershipId) {
            this.hideEnterVin = true;
        }
        //console.log('RECALLS: hideEnterVin: ', this.hideEnterVin);
        this.division = this.context.product.division;
        // this.division = 'Acura';
        // this.division = 'Honda';
        // this.division = 'Motorcycle/Powersports';
        // this.division = 'Powerequipment';
        // this.division = 'Marine';
        this.model = this.context.product.year + ' ' + this.context.product.model;
        //console.log('RECALLS: CONTEXT-ownRecallDetails: ', JSON.parse(JSON.stringify(this.context)));
        let contx = JSON.parse(JSON.stringify(this.context));
        //console.log('RECALLS: contx: ', contx);
        if(contx && contx.product && contx.product.recalls){
            contx.product.recalls.forEach(rm => {
                if(rm.mfrRecallStatus && rm.mfrRecallStatus.value && rm.mfrRecallStatus.value.includes('VIN/HIN')){
                    rm.mfrRecallStatus.value = rm.mfrRecallStatus.value.replaceAll('VIN/HIN', 'VIN');
                }
            });
        }
        this.context = contx;
        // this.garage = await getGarage('', '');
        // console.log('RECALLS: garage-------->', this.garage);

        if (this.context.product.recalls) {
            this.isGuest = true;
            this.displayRecalls(this.context.product.recalls);
            //console.log('RECALLS: getRecalls: productChooser');
        } else {
            if (this.isGuest) {
                let recallsData = await getRecalls(this.context);
                this.displayRecalls(recallsData);
                //console.log('RECALLS: getRecalls: vinOrModelId');
                this.isGuest = true;
            }
            else {
                //console.log('RECALLS: getRecalls: getRecallsSfdc');
                this.noVIN = this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-') ? false : true;
                await this.getRecallsSfdc();
            }
        }
    }

    //Imtiyaz - RECALLS Start
    async navigateToDealer(){
        this.publishToChannel({eventType: "click-event", eventMetadata: {action_type: "button", action_category: "body", action_label: "nearby dealers:More Dealers"} });
        sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: 'Powersports', divisionId: 'M' }));
        await this.sleep(2000);
        this.navigate('/find-a-dealer', {});
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    //Imtiyaz - RECALLS End

    getRecallsSfdc = async () => {
        let recallsmsgs = await getRecallByOwnership({ ownership: this.context.product.ownershipId });
        recallsmsgs.forEach(rm => {
            if(rm.Message__r && rm.Message__r.Body__c && rm.Message__r.Body__c.includes('VIN/HIN')){
                rm.Message__r.Body__c = rm.Message__r.Body__c.replaceAll('VIN/HIN', 'VIN');
            }
        });
        this.recallMessages = JSON.parse(JSON.stringify(recallsmsgs));
        this.totalRecalls = this.recallMessages.length;

        if (this.totalRecalls == 0) {
            //console.log('RECALLS: condition1 ', this.totalRecalls);
            this.noRecalls = true;
        } else if (this.totalRecalls == 1) {
            //console.log('RECALLS: condition2 ', this.totalRecalls);
            this.singleRecall = this.recallMessages[0];
            this.showAccordian = false;
            this.noRecalls = false;
        } else if (this.totalRecalls > 1) {
            //console.log('RECALLS: condition3 ', this.totalRecalls);
            this.showAccordian = true;
            this.noRecalls = false;
        }
        //console.log('RECALLS: SFDC - ', JSON.parse(JSON.stringify(this.recallMessages)));
        //console.log('RECALLS: recallmessages length --- ', this.recallMessages.length);
        //console.log('RECALLS: singleRecall --- ', JSON.parse(JSON.stringify(this.singleRecall)));
    }

    displayRecalls(recalls) {
        //console.log('RECALLS: displayRecalls :: : ', recalls);
        //console.log('RECALLS: recalls -- : ', JSON.parse(JSON.stringify(recalls)));
        //console.log('RECALLS: this.urlStateParameters : ', this.urlStateParameters);
        if (this.urlStateParameters && this.urlStateParameters.campaignId) {
            this.recallData = recalls.filter(element => {
                this.lastUpdatedDate = element.refreshDate ? element.refreshDate : this.lastUpdatedDate;
                //console.log('$RECALLS: lastupdatedDate2: ',this.lastupdatedDate);
                if ((this.displayPowerEquipment || this.displayMarine) && element.campaignStartDate) {
                    let campaignStartDate = element.campaignStartDate;
                    if (!campaignStartDate.includes('-')) {
                        campaignStartDate = campaignStartDate.substring(0, 4) + '-' + campaignStartDate.substring(4, 6) + '-' + campaignStartDate.substring(6, 8);
                        element.campaignStartDate = campaignStartDate;
                        this.lastUpdatedDate = campaignStartDate;
                        //console.log('$RECALLS: lastupdatedDate3: ',this.lastupdatedDate);
                    }
                } else {
                    this.lastUpdatedDate = element.refreshDate ? element.refreshDate : this.lastUpdatedDate;
                    //console.log('$RECALLS: lastupdatedDate4: ',this.lastupdatedDate);
                }
                return element.campaignID == this.urlStateParameters.campaignId
            });
        } else {
            recalls.forEach((element) => {
                //console.log('$RECALLS: element2: ',JSON.parse(JSON.stringify(element)));
                // if (!element.hasOwnProperty('remedyDescription')) element.remedyDescription = '-'
                // if (!element.hasOwnProperty('safetyRiskDescription')) element.safetyRiskDescription = '-'
                // if (!element.hasOwnProperty('recallDescription')) element.recallDescription = '-'
                if ((this.displayPowerEquipment || this.displayMarine) && element.campaignStartDate) {
                    let campaignStartDate = element.campaignStartDate;
                    if (!campaignStartDate.includes('-')) {
                        campaignStartDate = campaignStartDate.substring(0, 4) + '-' + campaignStartDate.substring(4, 6) + '-' + campaignStartDate.substring(6, 8);
                        element.campaignStartDate = campaignStartDate;
                        this.lastUpdatedDate = campaignStartDate;
                        //console.log('$RECALLS: lastupdatedDate5: ',this.lastupdatedDate);
                    }
                } else {
                    //console.log('$RECALLS: element.refreshDate: ',element.refreshDate);
                    this.lastUpdatedDate = element.refreshDate ? element.refreshDate : this.lastUpdatedDate;
                    //console.log('$RECALLS: lastupdatedDate6: ',this.lastupdatedDate);
                }
                this.recallData.push(element);
            });
        }

        //console.log('RECALLS: Recall Data----', JSON.parse(JSON.stringify(this.recallData)));

        this.totalRecalls = this.recallData.length;

        if (this.totalRecalls == 0) {
            this.noRecalls = true;
        } else if (this.totalRecalls == 1) {
            this.singleRecall = this.recallData[0];
            this.showAccordian = false;
            this.noRecalls = false;
        } else if (this.totalRecalls > 1) {
            this.showAccordian = true;
            this.noRecalls = false;
        }
        //console.log('RECALLS: noRecalls', this.noRecalls);
        //console.log('RECALLS: totalRecalls', this.totalRecalls);
        //console.log('RECALLS: singleRecall', JSON.parse(JSON.stringify(this.singleRecall)));
        //console.log('RECALLS: showAccordian', this.showAccordian);
        //console.log('RECALLS: isGuest', this.isGuest);
        //console.log('RECALLS: displayPowerEquipment', this.displayPowerEquipment);
    }
    toggleAccordionSection(event) {
        event.preventDefault();
        let element = event.currentTarget;
        let targetId = element.dataset.targetId;
    
        if (this.previousSection) {
            this.previousSection.querySelector(".custom-icon").iconName = 'utility:right';
            this.previousSection.querySelector(".custom-span").innerHTML = this.previousSection.querySelector(".custom-span").innerText;
            this.previousSection.classList.remove('slds-is-open');
            this.previousSection.classList.remove('section-open');
            this.previousSection.childNodes[0].style.background = '#FFFFFF';
            this.previousSection.childNodes[1].classList.remove('custom-content');
        }
    
        let orderedList = window.innerWidth > 600 ? this.template.querySelector(".accordion-large") : this.template.querySelector(".accordion-small");
        let section = orderedList.querySelector(`[data-id="${targetId}"]`);
        
        if (!section.classList.contains('slds-is-open')) {
            if(this.prevtargetId != targetId){
                element.querySelector('span').innerHTML = element.querySelector('span').innerText.bold();
                element.firstChild.iconName = 'utility:down';
                section.classList.add('slds-is-open');
                section.classList.add('section-open');
                section.childNodes[0].style.background = '#F5F5F5';
                section.childNodes[1].classList.add('custom-content');
                this.prevtargetId = targetId;
            }else{
                element.querySelector('span').innerHTML = element.querySelector('span').innerText;
                element.firstChild.iconName = 'utility:right';
                section.classList.remove('slds-is-open');
                section.classList.remove('section-open');
                section.childNodes[0].style.background = '#FFFFFF';
                section.childNodes[1].classList.remove('custom-content');
                this.prevtargetId = null;
            }
        }
        
        this.previousSection = section;
    }

    @api
    get displayAcura() {
        return (this.division === 'Acura');
    }
    @api
    get displayHonda() {
        return (this.division === 'Honda');
    }
    @api
    get displayPowerSports() {
        return (this.division === 'Motorcycle/Powersports' || this.division === 'Powersports');
    }
    @api
    get displayPowerEquipment() {
        return (this.division === 'Powerequipment');
    }
    @api
    get displayMarine() {
        return (this.division === 'Marine');
    }
    @api
    get isPEOrMarine() {
        return this.displayPowerEquipment || this.displayMarine;
    }

    handleVinHelpClick() {
        localStorage.setItem('VINHelpBreadcrumb', 'RecallsDetail');
        let vinHelpUrl = '/vin-help/?division=' + this.division;
        vinHelpUrl = this.division == 'Motorcycle/Powersports' ? '/vin-help/?division=Powersports' : vinHelpUrl;
        this.navigate(vinHelpUrl, {});
    }

    handleEnterVin() {
        sessionStorage.setItem('fromRecallCard', true);
        sessionStorage.setItem('fromRecallDetail', true);
        this.navigate('/enter-vin', {});
    }
    handleVINHelp() {

    }
    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }
    renderedCallback() {
        //Imtiyaz - RECALLS Start
        if (!this.lastUpdatedDate) {
            this.lastupdatedDate = getDate(7);
        }
        //Imtiyaz - RECALLS End
    }
    handleChangeCommunityPreference() {
        sessionStorage.setItem('defaulttab', 'Communication Preferences');
        if (this.isGuest) {
            getCIAMConfig()
                .then(result => {
                    //console.log('getCIAMConfig Data', result);
                    var currentLocation = window.location.origin + '/mygarage/s/' + 'my-account';
                    sessionStorage.setItem("RelayState", currentLocation);
                    let url = `${result.Ciam_Login_Url__c}&RelayState=${currentLocation}`
                    window.open(url, '_self');
                })
                .catch(error => {
                    //console.log('getCIAMConfig error: ' + JSON.stringify(error));
                });
        } else {
            this.navigate('/my-account', {});
        }
    }

    handleClickHere() {
        let division = this.displayPowerEquipment ? 'Powerequipment' : 'Marine';
        getPEOrMarineRecallsUpdateurl({ division: division }).then((result) => {
            //console.log('result: ', result);
            window.open(result, '_blank');
        }).catch((err) => {
            //console.error('err: ', err);
        });
    }
    handleSignupLogin(event){
        getCIAMConfig()
        .then(result => {
            let url;
            if(event.target.dataset.btn == 'Signup'){
                url = result.Ciam_SignUp_Url__c + `&RelayState=${window.location.href}`;
            }else{
                url = result.Ciam_Login_Url__c + `&RelayState=${window.location.href}`;
            }
            window.open(url, '_self');
        })
        .catch(error => {
            //console.log('getCIAMConfig error: ' + JSON.stringify(error));
        });
    }
    //Imtiyaz - RECALLS Start
    removeTags = (text) => {
        return text.replace(/(<([^>]+)>)/ig, '');
    }
    //Imtiyaz - RECALLS End
}