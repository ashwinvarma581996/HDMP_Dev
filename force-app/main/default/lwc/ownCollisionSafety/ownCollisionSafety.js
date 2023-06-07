import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

import basePath from '@salesforce/community/basePath';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
export default class ownCollisionSafety extends OwnBaseElement { 
     @api contentId; 
    //  Cards 
     @api safetyCard1;
     @api safetyCard2;
     @api safetyCard3;
     @api safetyCard4;
     @api safetyCard5;
     @api safetyCard6;
     @api safetyCard7;
     @api safetyCard8;
    // End 

    @api icon = "adobe-pdf.svg";
    @api titlecolor='Honda Red';
    @api showforwardicon;
    //@api body='PDF Description';

    @track collisionSafty;
    
    connectedCallback(){
        //console.log("child", this.contentId );
        this.getCMSContent();
        // this.getContent98(this.contentId98);
        // this.getContent97(this.contentId97); 
        // this.getContent96(this.contentId96); 
    }

   
    async getCMSContent(){
      let content = await getManagedContentByTopicsAndContentKeys([this.contentId], null, null, '');
        this.collisionSafty = {
            title : content[0].title ? this.htmlDecode(content[0].title.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : '',
            body : content[0].body ?this.htmlDecode(content[0].body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : ''
        }
        
    }
    // async getContent98(contentId98){
    //     this.content98 = await getManagedContentByTopicsAndContentKeys([contentId98], null, null, '');
    //     console.log('CMS collision safety 2------', JSON.parse(JSON.stringify(this.content98)));
        
    //     this.content98=this.htmlDecode(this.content98[0].body.value);
        
    // }
    // async getContent97(contentId97){
    //     this.content97 = await getManagedContentByTopicsAndContentKeys([contentId97], null, null, '');
    //     console.log('CMS collision safety 3------', JSON.parse(JSON.stringify(this.content97)));
        
    //     this.content97=this.htmlDecode(this.content97[0].body.value);
        
    // }
    // async getContent96(contentId96){
    //     this.content96 = await getManagedContentByTopicsAndContentKeys([contentId96], null, null, '');
    //     console.log('CMS collision safety 4------', JSON.parse(JSON.stringify(this.content96)));
        
    //     this.content96=this.htmlDecode(this.content96[0].body.value);
        
    // }
    // htmlDecode(input) {
    //     if(!input) return '';
    //     let doc = new DOMParser().parseFromString(input, "text/html");
    //     return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    // }
}