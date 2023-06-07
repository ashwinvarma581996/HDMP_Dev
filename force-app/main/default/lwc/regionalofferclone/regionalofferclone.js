import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Regionalofferclone extends NavigationMixin (LightningElement) {
    @api recordId;
    stopRender;
    connectedCallback(){
        if(this.stopRender==true){
        console.log('@@@this.recordId -'+this.recordId);
        }
        window.clearTimeout(this.delayTimeout);

        this.delayTimeout =setTimeout(() => {
            const config = {
                type: "standard__recordPage",
                attributes: {
                  recordId: this.recordId,
                  objectApiName: "Offers__c",
                  actionName: "clone"
                }
              };
              this[NavigationMixin.Navigate](config);

        },10)
        this.stopRender =false;
    }
}