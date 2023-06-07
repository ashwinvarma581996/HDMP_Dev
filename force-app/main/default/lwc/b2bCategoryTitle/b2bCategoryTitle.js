import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import PAGE_TITLE from '@salesforce/schema/ProductCategory.Category_Title__c';
import PAGE_DESCRIPTION from '@salesforce/schema/ProductCategory.Category_Description__c';

const FIELDS = [PAGE_TITLE, PAGE_DESCRIPTION];

export default class B2bCategoryTitle extends LightningElement {
    @api record;

    @api titleSize;

    @api titleColor;

    @api descriptionSize;

    @api descriptionColor;

    @api get titleStyles() {
        let resultCSS = [];
        if (this.titleColor) {
            resultCSS.push(`color: ${this.titleColor}`);
        }
        if (this.titleSize) {
            var titleSizeEm = this.titleSize;
            switch (titleSizeEm) {
                case 'Large':
                    titleSizeEm='1.4em'
                    break;
                case 'Medium':
                    titleSizeEm='1em'
                    break;
                case 'Small':
                    titleSizeEm='.8em'
                    break;
              }
            resultCSS.push(`font-size: ${titleSizeEm}`);
        }
        return resultCSS.join('; ');
    }

    @api get descripitionSyles() {
        let resultCSS = [];
        if (this.descriptionColor) {
            resultCSS.push(`color: ${this.descriptionColor}`);
        }
        if (this.descriptionSize) {
            resultCSS.push(`font-size: ${this.descriptionSize}`);
        }
        return resultCSS.join('; ');
    }
    
    @wire(getRecord, { recordId: '$record', fields: FIELDS })
    recordData;

    get pageTitle() {
        return getFieldValue(this.recordData.data, PAGE_TITLE);
    }

    get pageDescription() {
        return getFieldValue(this.recordData.data, PAGE_DESCRIPTION);
    }
}