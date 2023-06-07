import { track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import basePath from '@salesforce/community/basePath';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
export default class OwnMaintenanceMinderHondaCard extends OwnBaseElement {
    @track title;
    @api isGuest;
    @api contentIdMM;
		@api contentIdMA;
		@api contentIdMB;
		@api contentIdM1;
		@api contentIdM2;
		@api contentIdM3;
		@api contentIdM4;
		@api contentIdM5;
		@api contentIdM6;
    @api context;
    @track maintenanceMinders;
		@track minders;
		@track data;
    connectedCallback() {
        //console.log('ownMaintenanceMinderHondaCard: CONTEXT-', JSON.parse(JSON.stringify(this.context)));
        this.initialize();
    }
    initialize = async () => {
        if (this.context && this.context.product) {
            //console.log('CONTEXT: ',JSON.parse(JSON.stringify(this.context)));
            this.title = (this.context.product.year ?? '') + ' ' + (this.context.product.model ?? '') + ' ' + (this.context.product.trim ?? '');
        }
        let content = await getManagedContentByTopicsAndContentKeys([this.contentIdMM], this.topics, this.pageSize, this.managedContentType);
        //console.log('OwnMaintenanceMinderHondaCard: cms-', JSON.parse(JSON.stringify(content)));
        if(content){
            this.data = {
                title : content[0].phoneLabel ? this.htmlDecode(content[0].phoneLabel.value) : '',
								minders : content[0].body ? this.htmlDecode(content[0].body.value) : '',
								subtitle : content[0].phone2Label ? this.htmlDecode(content[0].phone2Label.value) : ''
            }
        }
				//console.log('OwnMaintenanceMinderHondaCard: this.data-',JSON.parse(JSON.stringify(this.data)));
				
				let allMindersCms = await getManagedContentByTopicsAndContentKeys([this.contentIdMA, this.contentIdMB, this.contentIdM1, this.contentIdM2, this.contentIdM3, this.contentIdM4, this.contentIdM5, this.contentIdM6], this.topics, this.pageSize, this.managedContentType);
				//console.log('OwnMaintenanceMinderHondaCard: cms-1-', JSON.parse(JSON.stringify(allMindersCms)));
				if(allMindersCms){
          this.minders = [];
          allMindersCms.forEach(minder => {
            this.minders.push(
              {
                mainCode : minder.phoneLabel ? this.htmlDecode(minder.phoneLabel.value) : '',
                whatWeDo : minder.body ? this.htmlDecode(minder.body.value) : '',
                order : minder.phoneNumber ? this.htmlDecode(minder.phoneNumber.value) : ''
              }
            );
          });
          this.minders = this.minders.sort(function(a, b){return parseInt(a.order) - parseInt(b.order)});
          //console.log('OwnMaintenanceMinderHondaCard: minders-', JSON.parse(JSON.stringify(this.minders)));
        }
    }
		htmlDecode(input) { 
        if(!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }
}