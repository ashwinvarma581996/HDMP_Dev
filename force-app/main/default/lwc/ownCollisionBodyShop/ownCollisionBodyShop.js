import { LightningElement, api, track } from 'lwc';
import commonResources from "@salesforce/resourceUrl/MyGarage";
import { OwnBaseElement } from 'c/ownBaseElement';
import basePath from '@salesforce/community/basePath';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';

export default class OwnCollisionBodyShop extends OwnBaseElement {
    @api contentId;
    @api brand;
    @track collisionBodyShopData;
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    connectedCallback(){
        //console.log('brand',this.brand);
        //console.log("contentid", this.contentId);
        this.getCMSContent(this.contentId);
    }

    async getCMSContent(contentId){
        let content = await getManagedContentByTopicsAndContentKeys([contentId], this.topics, this.pageSize, this.managedContentType);
        //console.log('CMS Content------', JSON.parse(JSON.stringify(content)));
        //console.log('CMS Content------',content);
        if(content && content[0]){
            this.collisionBodyShopData = {
                title : content[0].title ? content[0].title.value : '',
                desktopImage : content[0].sectionContent ?  this.htmlDecode(content[0].sectionContent.value) : '',
                mobileImage : content[0].description2Content ? this.htmlDecode(content[0].description2Content.value) : '',
                body : content[0].body ? this.htmlDecode(content[0].body.value) : '',
                description : content[0].descriptionContent ? this.htmlDecode(content[0].descriptionContent.value) : ''
            };
        }
        //console.log('CMS Content wnCollisionBodyShop', this.collisionBodyShopData);
    }
}