import { track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getProductContext, getOrigin } from 'c/ownDataUtils';
import getRecallsCount from '@salesforce/apex/OwnRecallsController.getRecallsCount';
//Imtiyaz - RECALLS Start
import PSP_Banner_Text1 from '@salesforce/label/c.PSP_Banner_Text1';
import PSP_Banner_Link1 from '@salesforce/label/c.PSP_Banner_Link1';
import PSP_Banner_Text2 from '@salesforce/label/c.PSP_Banner_Text2';
import PSP_Banner_Link2 from '@salesforce/label/c.PSP_Banner_Link2';
import PE_Banner_Text1 from '@salesforce/label/c.PE_Banner_Text1';
import PE_Banner_Link1 from '@salesforce/label/c.PE_Banner_Link1';
import PE_Banner_Text2 from '@salesforce/label/c.PE_Banner_Text2';
import PE_Banner_Link2 from '@salesforce/label/c.PE_Banner_Link2';
//Imtiyaz - RECALLS End
export default class ownRecallsNotification extends OwnBaseElement {
    @track hasRecall;
    @track productName;
    @track context;
    @track isrecallclosed;
    @track recallsCount = 0;
    @track isPdpPage;
    @track isPdpOrHome;
    @track initialtext;
    @track initialTextPdp;
    @track products;
    @track isAuto;

    //Imtiyaz - RECALLS Start
    get PSP_Banner_Text1(){
        return PSP_Banner_Text1;
    }
    get PSP_Banner_Text2(){
        return PSP_Banner_Text2;
    }
    get PSP_Banner_Link1(){
        return PSP_Banner_Link1;
    }
    get PSP_Banner_Link2(){
        return PSP_Banner_Link2;
    }

    get PE_Banner_Text1(){
        return PE_Banner_Text1;
    }
    get PE_Banner_Text2(){
        return PE_Banner_Text2;
    }
    get PE_Banner_Link1(){
        return PE_Banner_Link1;
    }
    get PE_Banner_Link2(){
        return PE_Banner_Link2;
    }
    //Imtiyaz - RECALLS End

    connectedCallback() {
        //console.log('$LBL: ownRecallsNotification connectedCallback');

        //console.log('$LBL: isFindOrSearchPsp_HasLabel1: ',this.isFindOrSearchPsp_HasLabel1);
        //console.log('$LBL: PSP_Banner_Text1: ',this.PSP_Banner_Text1);
        //console.log('$LBL: PSP_Banner_Link1: ',this.PSP_Banner_Link1);
        //console.log('$LBL: isFindOrSearchPsp_HasLabel2: ',this.isFindOrSearchPsp_HasLabel2);
        //console.log('$LBL: PSP_Banner_Text2: ',this.PSP_Banner_Text2);
        //console.log('$LBL: PSP_Banner_Link2: ',this.PSP_Banner_Link2);
        
        //console.log('$LBL: isFindOrSearchPE_HasLabel1: ',this.isFindOrSearchPE_HasLabel1);
        //console.log('$LBL: PE_Banner_Text1: ',this.PE_Banner_Text1);
        //console.log('$LBL: PE_Banner_Link1: ',this.PE_Banner_Link1);
        //console.log('$LBL: isFindOrSearchPE_HasLabel2: ',this.isFindOrSearchPE_HasLabel2);
        //console.log('$LBL: PE_Banner_Text2: ',this.PE_Banner_Text2);
        //console.log('$LBL: PE_Banner_Link2: ',this.PE_Banner_Link2);

        this.publishToChannel({});
        let pdpPages = ['/garage-acura', '/garage-honda', '/garage-powersports', '/garage-powerequipment', '/garage-marine', 'service-maintenance', 'garage-', 'service-maintenance'];
        pdpPages.forEach(pg => {
            if (window.location.href.includes(pg)) {
                this.isPdpPage = true;
                this.isPdpOrHome = true;
            }
        });
        if (window.location.href.endsWith('/s/')) {
            this.isPdpPage = false;
            this.isPdpOrHome = true;
        }
        this.initialize();
    }

    renderedCallback(){
        //console.log('$RECALLS: ownRecallsNotification renderedCallback');
    }

    //Imtiyaz - RECALLS Start
    get isFindPsp(){
        return window.location.pathname.includes('find-powersports');
    }
    get isFindPE(){
        return window.location.pathname.includes('find-powerequipment');
    }
    get isFindPspOrPE(){
        return this.isFindPsp || this.isFindPE;
    }
    get isSearchPSP(){
        let param = new URL(window.location.href).searchParams.get('brand');
        return param && param == 'powersports';
    }
    get isSearchPE(){
        let param = new URL(window.location.href).searchParams.get('brand');
        return param && param == 'powerequipment';
    }
    get isSearchPspOrPE(){
        return this.isSearchPSP || this.isSearchPE;
    }
    get isFindOrSearchPsp(){
        return this.isFindPsp || this.isSearchPSP;
    }
    get isFindOrSearchPsp_HasLabel1(){
        return this.isFindOrSearchPsp && (this.PSP_Banner_Text1 != 'BLANK' && this.PSP_Banner_Link1 != 'BLANK');
    }
    get isFindOrSearchPsp_HasLabel2(){
        return this.isFindOrSearchPsp && (this.PSP_Banner_Text2 != 'BLANK' && this.PSP_Banner_Link2 != 'BLANK');
    }
    get isFindOrSearchPE(){
        return this.isFindPE || this.isSearchPE;
    }
    get isFindOrSearchPE_HasLabel1(){
        return this.isFindOrSearchPE && (this.PE_Banner_Text1 != 'BLANK' && this.PE_Banner_Link1 != 'BLANK');
    }
    get isFindOrSearchPE_HasLabel2(){
        return this.isFindOrSearchPE && (this.PE_Banner_Text2 != 'BLANK' && this.PE_Banner_Link2 != 'BLANK');
    }
    get isFindOrSearchPspOrPE(){
        return this.isFindPspOrPE || this.isSearchPspOrPE;
    }
    //
    get isFindOrSearchPspOrPE_Label(){
        return (this.isFindOrSearchPsp_HasLabel1 || this.isFindOrSearchPsp_HasLabel2) || (this.isFindOrSearchPE_HasLabel1 || this.isFindOrSearchPE_HasLabel2);
    }
    handleClickHere(){
        if(this.isFindPsp)
            this.navigate('/recall-search?brand=powersports', {});
        else
            this.navigate('/recall-search?brand=powerequipment', {});
    }
    //Imtiyaz - RECALLS End

    initialize = async () => {

        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        if (this.context && this.context.product) {
            this.isAuto = this.context.product.division == 'Honda' || this.context.product.division == 'Acura' ? true : false;
            this.productName = this.context && this.context.product ? this.context.product.year + ' ' + this.context.product.model : '';
        }
        //console.log('OwnRecallsNotification: CONTEXT ', JSON.parse(JSON.stringify(this.context)));
        if (this.isPdpPage) {
            if (this.context && this.context.product && this.context.product.hasOwnProperty('recalls')) {
                //console.log('OwnRecallsNotification: HAS_RECALL_PROPERTY');
                this.recallsCount = this.context.product.recalls.length;
                //console.log('OwnRecallsNotification: recallsCount ', this.recallsCount);
            } else {
                //console.log('OwnRecallsNotification: NO_RECALL_PROPERTY');
                this.recallsCount = this.context.product.recallCount;
            }
            this.prepareBannerText();
        } else if (!this.isPdpPage) {
            getRecallsCount().then((result) => {
                //console.log('OwnRecallsNotification: result ', result);
                this.recallsCount = result;
                this.prepareBannerText();
            }).catch((err) => {
                //console.error(err);
                this.prepareBannerText();
            });
        }
    }

    prepareBannerText() {
        //console.log('OwnRecallsNotification: prepareBannerText');
        this.initialtext = this.recallsCount == 1 ? 'There is an active recall for your product. ' : 'There are ' + this.recallsCount + ' active recalls for your garage products. ';
        this.isrecallclosed = sessionStorage.getItem('isrecallclosed');
        //console.log('OwnRecallsNotification: isrecallclosed ', this.isrecallclosed);
        this.hasRecall = this.isrecallclosed || !this.recallsCount ? false : true;
        if (this.isPdpPage) {
            this.initialTextPdp = this.recallsCount > 1 ? 'There are ' + this.recallsCount + ' active recalls for your' : 'There is an active recall for your';
            if (this.isAuto) {
                // this.hasRecall = false;
            }
        }
        //console.log('OwnRecallsNotification: hasRecall ', this.hasRecall);
        //console.log('OwnRecallsNotification: isPdpPage ', this.isPdpPage);
        //console.log('OwnRecallsNotification: isPdpOrHome ', this.isPdpOrHome);
        //console.log('OwnRecallsNotification: recallsCount ', this.recallsCount);
    }

    handleViewRecall() {
        let divisionName = this.context.product.division == 'Powerequipment' ? 'Power Equipment' : this.context.product.division;
        let label = window.location.href.includes('service') ? divisionName + ': Service & Maintenance' : divisionName + ': Overview';
        let backLink = {
            label: label,
            url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
        };
        sessionStorage.setItem('backlink', JSON.stringify(backLink));
        
        this.navigate('/recalls-detail', {});
    }
    handleViewRecallAtHome() {
        localStorage.setItem('MessagesTab', 'Recalls');
        sessionStorage.setItem('recallstab', true);
        //console.log('DEFAULT: ', sessionStorage.getItem('recallstab'));
        this.navigate('/messages', {});
    }
    handleCloseRecall() {
        sessionStorage.setItem('isrecallclosed', true);
        this.hasRecall = false;
    }
}