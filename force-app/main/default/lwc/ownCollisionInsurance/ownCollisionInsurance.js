import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/MyGarage";
import basePath from '@salesforce/community/basePath';
import { getManagedContentByTopicsAndContentKeys, ISGUEST } from 'c/ownDataUtils';
import getMarketplaceURL from '@salesforce/apex/OwnGarageController.getCustomMetadataTypes';

export default class ownCollisionInsurance extends OwnBaseElement { 
    @api contentId;
   
    @api findDealer;  
    @api genuineAccessories; 
    @api genuineParts; 
    @api icon = "chat.svg"; // For Cards chat Icon
    
    @track collisionInsuranceContent;
    @track accordionData = [];
    @api insuranceaccordion; 
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @api brand;
    @track accessoriesLink;
    @track partsLink;
    @track isGuest = ISGUEST;
    @track findDealerLink;

    async connectedCallback(){
        this.findDealerLink = '/find-a-dealer?brand='+this.brand.toLowerCase();
        this.getCMSContent();
        this.getCMSAccordions();
        this.initHandler();
    }

    async initHandler(){
        //console.log('marketplaceData--->');
        let marketplaceData = await getMarketplaceURL();
        //console.log('marketplaceData--->',marketplaceData);
        if(marketplaceData){
            let marketPlaceURL = marketplaceData.filter(element =>
                                    element.DeveloperName.toLowerCase() == this.brand.toLowerCase()
                                );
            //console.log('marketPlaceURL--->',marketPlaceURL);
            if(marketPlaceURL && marketPlaceURL.length >0){
                this.accessoriesLink = this.isGuest ? marketPlaceURL[0].Accessories_Logged_Out_URL__c : marketPlaceURL[0].Accessories_Logged_In_URL__c;
                this.partsLink = this.isGuest ? marketPlaceURL[0].Parts_Logged_Out_URL__c : marketPlaceURL[0].Parts_Logged_In_URL__c
            }
        }
    }

    async getCMSAccordions(){
        this.accordionData = [];
        let topics = [this.insuranceaccordion];
        let content = await getManagedContentByTopicsAndContentKeys([], topics, this.pageSize, this.managedContentType);
        content.forEach(element => {
            let accordionSection = JSON.parse(JSON.stringify(element));
            //console.log("accordionSection",accordionSection);
            accordionSection.body.value = accordionSection.body ? this.htmlDecode(accordionSection.body.value):'';
            accordionSection.key = element.key;
            this.accordionData.push(accordionSection); 
        });
         //console.log('This accordionData : ', JSON.parse(JSON.stringify(this.accordionData)));
        }
    
    async getCMSContent(){
        let content = await getManagedContentByTopicsAndContentKeys([this.contentId], null, null, '');
        //console.log('CMS Content child 4------', JSON.parse(JSON.stringify(content)));
        this.collisionInsuranceContent = {
            title : content[0].title ? this.htmlDecode(content[0].title.value) : '',
            video1 : content[0].phoneNumber ?  this.htmlDecode(content[0].phoneNumber.value) : '',
            body : content[0].body ? this.htmlDecode(content[0].body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : '',
            description : content[0].descriptionContent ? this.htmlDecode(content[0].descriptionContent.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : '',
            description2 : content[0].description2Content ? this.htmlDecode(content[0].description2Content.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : ''
        }
        
    }
    
    }