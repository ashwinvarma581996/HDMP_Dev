import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

import basePath from '@salesforce/community/basePath';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
export default class ownCollisionParts extends OwnBaseElement { 
    @api contentId; 
    //@api contentId1;  // No Option ContentId
    @track collisionPartsContent;
    //@track body;
    //@track content1;
    @api accordiansTopic;
    @track accordionData = [];
    @track topics;
    @track pageSize = null;
    @track managedContentType = '';
    @api brand;

    connectedCallback(){
        //console.log("child", this.contentId );
        this.getCMSContent(this.contentId);
        this.getAccordionContent();
        
    }
    async getAccordionContent(){
        let topics = [this.accordiansTopic];
        let content = await getManagedContentByTopicsAndContentKeys([], topics, this.pageSize, this.managedContentType);
        this.accordionData = [];
        
        content.forEach(element => {
        let accordionSection = JSON.parse(JSON.stringify(element));
        //console.log("accordionSection",accordionSection);
        accordionSection.body.value = accordionSection.body ? this.htmlDecode(accordionSection.body.value):'';
        accordionSection.key = element.key;
        this.accordionData.push(accordionSection); 
        });
         //console.log('This accordionData : ', JSON.stringify(this.accordionData));
        }

    async getCMSContent(contentId){
        let content = await getManagedContentByTopicsAndContentKeys([contentId], this.topics, this.pageSize, this.managedContentType);
        //console.log('CMS Content child 3------', JSON.parse(JSON.stringify(content)));
        if(content){
            this.collisionPartsContent = {
                title : content[0].title ? this.htmlDecode(content[0].title.value) : '',
                video1 : content[0].phoneNumber ?  this.htmlDecode(content[0].phoneNumber.value) : '',
                video2 : content[0].phone2Number ? this.htmlDecode(content[0].phone2Number.value) : '',
                body : content[0].body ? this.htmlDecode(content[0].body.value) : '',
                description : content[0].descriptionContent ? this.htmlDecode(content[0].descriptionContent.value) : '',
                description2 : content[0].description2Content ? this.htmlDecode(content[0].description2Content.value) : ''
            }
        }
               
    }

    onWatchVideo(event){
        //console.log('event', event);
        let url = event.target.dataset.url;
        //console.log('url', url);
        sessionStorage.setItem('frompage','collisionRepair');
        this.navigate('/video-detail-page' +'?key=' +this.contentId, {});
    }
    // async getContent1(contentId1){
    //     this.content1 = await getManagedContentByTopicsAndContentKeys([contentId1], null, null, '');
    //     console.log('CMS Content child 2------', JSON.parse(JSON.stringify(this.content1)));
        
    //     this.content1=this.htmlDecode(this.content1[0].body.value);
        
    // }
}