import { LightningElement, track, api} from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys, ISGUEST } from 'c/ownDataUtils';
// import basePath from '@salesforce/community/basePath';
// import getEligibleVehicle from '@salesforce/apex/OwnAPIController.getEligibleVehicle';

export default class OwnAutoLinkConvenientFeatureDetail extends OwnBaseElement {
    productImage = this.myGarageResource() + '/images/blue_link_button.png';

    @api contentId;
    @api contentId2;
    @api contentId3;
    @api contentId4;

    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track amazonAlexaRecords =[];
    @track eligibleVehicles =[];
    @track pageContent;
    @track isGuest = ISGUEST;
    connectedCallback(){
        this.initialize();
        this.initializePageContent();
    }

    initialize = async () =>{
        this.contentKeys = [this.contentId, this.contentId2, this.contentId3];
        //console.log('contentKeys', this.contentKeys);
        let result = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
       // console.log('result', result);
        let alexaRecords = []
        result.forEach( (element, index) =>{
            let alexaObj = {};
            alexaObj.serialNumber =  element.phone4Number ? element.phone4Number.value:'';
            alexaObj.title = element.title.value;
            alexaObj.body = element.body ? this.htmlDecode(element.body.value) :'';
            // if(this.isGuest || element.phone4Number.value != 1){
            //     alexaObj.body = element.body ? this.htmlDecode(element.body.value) :'';
            // }
            alexaRecords.push(alexaObj);
        });
        this.amazonAlexaRecords = alexaRecords;
        //console.log('amazonAlexaRecords', JSON.parse(JSON.stringify(this.amazonAlexaRecords)));
        this.amazonAlexaRecords.sort((a, b) => {
            return a.serialNumber - b.serialNumber;
        });
        //console.log('amazonAlexaRecords1', JSON.parse(JSON.stringify(this.amazonAlexaRecords)));
        //this.getEligibleVehicle();
    }

    initializePageContent = async () =>{
     
        let cmsContent = await getManagedContentByTopicsAndContentKeys([this.contentId4], this.topics, this.pageSize, this.managedContentType);
        //console.log('cmsContent',cmsContent);
        if(cmsContent && cmsContent[0]){
                this.pageContent = {
                    enableAlexaButton : cmsContent[0].descriptionContent ? this.htmlDecode(cmsContent[0].descriptionContent.value) : '',
                    footerContent : cmsContent[0].sectionContent ? this.htmlDecode(cmsContent[0].sectionContent.value) : ''
                }
        }
    }

    // getEligibleVehicle(){
    //     let divisionId = document.title.toLowerCase().includes('hondalink') ? 'A' : 'B';
    //    getEligibleVehicle({divisionId : divisionId})
    //    .then(result =>{
    //         console.log('result',result);
    //         let imageURL;
    //         if(result && result.vehicleInfo){
    //             result.vehicleInfo.forEach( (element, index)=>{
    //                 if(element.modelYear && element.modelGroupNameFriendly && element.thirdPartyEligibilityStatus == 'ELIGIBLE' && !this.eligibleVehicles.includes(element.modelYear +' '+ element.modelGroupNameFriendly) && !this.eligibleVehicles.includes(element.modelYear +' '+ element.modelGroupNameFriendly+' '+element.modelTrimTypeCode)){
    //                     if(element.modelGroupNameFriendly !== element.modelTrimTypeCode){
    //                         this.eligibleVehicles.push(element.modelYear +' '+ element.modelGroupNameFriendly +' '+ element.modelTrimTypeCode);
    //                     }else{
    //                         this.eligibleVehicles.push(element.modelYear +' '+ element.modelGroupNameFriendly);
    //                     }
    //                     if(!imageURL){
    //                         imageURL = element.asset34FrontPath;
    //                     }
    //                 }
    //             })
    //         }
    //         this.amazonAlexaRecords.forEach( element =>{
    //             if(element.serialNumber == 1){
    //                 element.eligibleVehicles = this.eligibleVehicles;
    //                 element.image = imageURL;
    //             }
    //         })
    //         console.log('amazonAlexaRecords', this.amazonAlexaRecords);
    //    })
    //    .catch(error =>{
    //         console.log('error',error);
    //    })
    // }
}