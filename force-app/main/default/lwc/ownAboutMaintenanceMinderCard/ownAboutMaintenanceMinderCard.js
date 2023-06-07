import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';

export default class ownAboutMaintenanceMinderCard extends OwnBaseElement {
    @api contentId; 
    @track aboutMaintenanceMinder;
    @api accordiansTopic;
    @track accordionData = [];
    @track topics;
    @track pageSize = null;
    @api isGuest;
    @api context;
    @track managedContentType = '';
    
    connectedCallback(){
        //console.log('ownAboutMaintenanceMinderCard: CONTEXT-', JSON.parse(JSON.stringify(this.context)));
        this.getCMSContent(this.contentId);
        
    }

    async getCMSContent(contentId){
        let content = await getManagedContentByTopicsAndContentKeys([contentId], this.topics, this.pageSize, this.managedContentType);
       // console.log('CMS Content child 3------', JSON.parse(JSON.stringify(content)));
       // console.log('test',content[0].video);
        if(content){
            this.aboutMaintenanceMinder = {
                title : content[0].title ? this.htmlDecode(content[0].title.value) : '',
                video1 : content[0].phoneNumber ?  this.htmlDecode(content[0].phoneNumber.value) : '',
                //video1 : content[0].phoneNumber ?  this.htmlDecode(content[0].video.value) : '',
                body : content[0].body ? this.htmlDecode(content[0].body.value) : '',
                descriptionContent : content[0].body ? this.htmlDecode(content[0].descriptionContent.value) : '',
            }
        }
               
    }
}