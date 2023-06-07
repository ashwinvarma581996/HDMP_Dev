import { LightningElement, api,wire,track } from 'lwc';

import getFAQ from '@salesforce/apex/B2B_GetFAQdetail.getFAQ';

export default class faqObject extends LightningElement {
        @api recordId;
        @track orderId;
        @track error;
          @track mylists;
        
        
    
    
   
    @wire(getFAQ)
    wiredgetFAQ({ error, data }) {
        if (data) {
             //console.log('#in data')
            //console.log('#data',data)
            this.mylists = data;
              //console.log('## this.mylists', this.mylists);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.mylists = undefined;
        }
    }
    
    
}