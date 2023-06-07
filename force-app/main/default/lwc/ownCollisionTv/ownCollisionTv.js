import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getMarketplaceURL from '@salesforce/apex/OwnGarageController.getCustomMetadataTypes';
import { ISGUEST } from 'c/ownDataUtils';

export default class OwnCollisionTv extends OwnBaseElement {
    
    @api titlecolor = 'Honda Red';
    @api icon = "chat.svg"; // For Cards chat Icon
    @api icon1 = "play.svg"; // For Video Play Icon
    @api contentid1 ;
    @api contentid2;
    @api contentid3;
    @api contentid4;
    @api brand;
    @api findDealer;  
    @api genuineAccessories; 
    @api genuineParts; 
    @api facilities;
    @track title;
    @track certifiedLink;
    @track accessoriesLink;
    @track partsLink;
    @track findDealerLink;
    @track isGuest = ISGUEST;
    connectedCallback(){
        //console.log('ownCollisionTV--->');
        this.title = this.brand + ' Collision TV';
        this.certifiedLink = '/'+ this.brand.toLowerCase() + '-collision-repair';
        this.findDealerLink = '/find-a-dealer?brand='+this.brand.toLowerCase();
        //console.log('await getMarketplaceURL()', getMarketplaceURL());
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

    handleVideo(event) {
        //console.log('handleVideo->', event.currentTarget.contentId);
        let contentId = event.currentTarget.contentId;
        let videoIds = {
            videos : [this.contentid1, this.contentid2, this.contentid3, this.contentid4],
            brand : this.brand
        };
        sessionStorage.setItem('frompage','collisionRepair');
        sessionStorage.setItem("collisionVideos", JSON.stringify(videoIds));
      
        this.navigate('/video-detail-page' +'?key=' +contentId, {});
    }
    
}