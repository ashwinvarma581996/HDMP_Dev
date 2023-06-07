import {  api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import {
    getManagedContentByTopicsAndContentKeys,
} from 'c/ownDataUtils';

export default class OwnExploreCard extends OwnBaseElement {
    @api brand = 'Acura';
    @api desktopImageId;
    @api mobileImageId;
    @api imageLink;
    @api imageLabel;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @track desktopImage;
    @track mobileImage;
    
    connectedCallback() {
        this.initialize();
    }

    initialize = async () => {
        let urlString = window.location.href;
        let  baseURL = urlString.substring(0, urlString.indexOf("/s"));
        this.contentKeys.push(this.desktopImageId);
        this.contentKeys.push(this.mobileImageId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            let title = (r.title.value).toUpperCase();
            if(title.includes('DESKTOP')){
                this.desktopImage = baseURL + r.image.unauthenticatedUrl;
            }else{
                this.mobileImage = baseURL +  r.image.unauthenticatedUrl;
            }
        });
    }
   
    handleClick(){
       this.navigate(this.imageLink, {});
    }   
}