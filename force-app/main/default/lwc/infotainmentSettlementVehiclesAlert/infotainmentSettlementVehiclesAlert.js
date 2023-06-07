import { LightningElement,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getProductContext, getOrigin } from 'c/ownDataUtils';
import getInfotainmentSystemData from '@salesforce/apex/OwnRetriveCustomMetaData.getInfotainmentSystemData';
import ISOR from '@salesforce/resourceUrl/ISOR';

export default class InfotainmentSettlementVehiclesAlert extends OwnBaseElement {

    @track isPdpPage;
    @track context;
    year;
    model;
    trim;
    alert;
    hasIsorAlert=false;
    url;
    link;
    division;

    connectedCallback() {
        let pdpPages = ['/garage-acura', '/garage-honda'];
        pdpPages.forEach(pg => {
            if (window.location.href.includes(pg)) {
                this.isPdpPage = true;
            }
        });
        this.initialize();
    }

    initialize = async () => {

        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        if (this.context && this.context.product) {
            this.year=this.context.product.year
            this.model=this.context.product.model
            this.division = this.context.product.division;
            this.trim=this.context.product.trim;
            //console.log('@@##!'+this.year+this.model+'!!');
            await getInfotainmentSystemData().then((data) => {
                //console.log('@@r'+JSON.stringify(data));
                data.forEach(arrayIteam =>{
                    if(arrayIteam.Year__c == this.year && arrayIteam.Model__c == this.model && arrayIteam.Trims__c.split(";").includes(this.trim)){
                        this.alert=arrayIteam.Alert__c; 
                        this.link=arrayIteam.Link__c; 
                        this.hasIsorAlert=true;
                        
                    }
                });
                //console.log('@@s'+JSON.stringify(this.yearsArray));
         }).catch((error) => {
             //console.log('@@Error getting Data', error);
         });
        }
        
    }

    handleCloseRecall() {
        this.hasIsorAlert = false;
    }

    handleViewAlert(){
            this.url = window.location.origin+ISOR+'/ISOR/'+this.link;
           // window.open(this.url, "_blank");
            let isMobile = window.matchMedia("(max-width: 600px)").matches;
            if (isMobile) {
                window.open(this.url, "_blank");
            } else {
                let pdfLink = this.url;
                sessionStorage.setItem('pdflink', pdfLink);
                window.open(window.location.origin + window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/')) + '/pdf-document' + '?PDF=' + pdfLink.substring(pdfLink.lastIndexOf('/') + 1), "_blank");
            }

    }

}