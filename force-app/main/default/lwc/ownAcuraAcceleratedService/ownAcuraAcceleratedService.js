import { LightningElement, track, wire,api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getMaintenanceMinder from '@salesforce/apex/ownMaintenanceMinderController.getMaintenanceMindersList';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { getProductContext, ISGUEST, getOrigin, getContext } from 'c/ownDataUtils';
import Id from '@salesforce/user/Id';

export default class OwnAcuraAcceleratedService extends OwnBaseElement {

    @track accelratedServices =[];
    @track context;
    @api contentId;
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track contentKeys = [];
    @track results;
    @track pageContent;
    @track isGuest = ISGUEST;
    @api acceleratedContents;
    @track showData = false;
    @track icon;
    @track sectionTitle;
    @track maintenanceMinderData;
    @track isMaintenanceMinder = false;
    @track subheadingText;
    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/recall-overview.svg';
        this.initialize();
        if(this.isGuest){
            this.getTableCMSData();
        }
        
    }

    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getContext('');
        }
        if (this.context && this.context.product) {
            this.sectionTitle = 'Maintenance Minders for Your '+ (this.context.product.year ?? '') + ' ' + (this.context.product.model ?? '') + ' ' + (this.context.product.trim ?? '');
        }
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, null, this.pageSize, this.managedContentType);
        
        if(this.results){
            this.pageContent = {
                title : this.htmlDecode(this.results[0].title.value) ?? '',
                body : this.htmlDecode(this.results[0].body.value) ?? '',
                footerContent : this.htmlDecode(this.results[0].subTitle.value) ?? ''
            };
        }
        if(!this.isGuest && this.context && this.context.product && this.context.product.productId && this.context.product.ownershipId){
            this.maintenanceMinderData = [];
            getMaintenanceMinder({ ownershipId: this.context.product.ownershipId, productId :this.context.product.productId })//a0y01000005RfXsAAK
            .then((data) => {
               // console.log('data  :-  ', data);
                data.forEach( (element, index) =>{
                    if(index ==0)
                        this.subheadingText = element.Maintenance_Code__c;
                    else 
                        this.subheadingText = this.subheadingText + ', ' + element.Maintenance_Code__c;
                });
                this.maintenanceMinderData = JSON.parse(JSON.stringify(data));
                if(!this.maintenanceMinderData || this.maintenanceMinderData.length == 0){
                    this.isGuest = true;
                    this.isMaintenanceMinder= false;
                }else{
                    this.isMaintenanceMinder = true;
                }
                
              //  console.log('this.maintenanceMinderData  :-  ', this.maintenanceMinderData);
            }).catch((error) => {
               // console.error('Error:', error);
            });
            this.showData = true;
            this.getTableCMSData();
        }else{
           
            await this.getTableCMSData();
            this.showData = true;
        }
        
    }

    getTableCMSData = async () =>{
        this.accelratedServices =[];
        this.topics = this.acceleratedContents;
        let content = JSON.parse(JSON.stringify(await getManagedContentByTopicsAndContentKeys([], this.topics, this.pageSize, this.managedContentType)));
       // console.log('content--->',content);

        content.sort((a, b) => {
            const A = a.title.value.toUpperCase(); 
            const B = b.title.value.toUpperCase(); 
            if (A < B) {
                return -1;
            }
            if (A > B) {
                return 1;
            }
            return 0;
        });
        content.forEach( element => {
            this.accelratedServices.push({
                ServicePreText : element.body ? this.htmlDecode(element.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : '',
                ServiceBody : element.descriptionContent ? this.htmlDecode(element.descriptionContent.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : '',
            })
        })
        if(this.accelratedServices){
            this.showData = true;
        }
       // console.log('this.accelratedServices  :-  ', this.accelratedServices);
    }
}