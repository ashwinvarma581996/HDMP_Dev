import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import CATEGORY_IMAGE from '@salesforce/schema/ProductCategory.Category_Image__c';
import CATEGORY_IMAGE_DEFAULT from '@salesforce/schema/ProductCategory.Category_Image_Default__c';
import CATEGORY_IMAGE_TITLE from '@salesforce/schema/ProductCategory.Category_Image_Title__c';
import CATEGORY_IMAGE_ALT_TEXT from '@salesforce/schema/ProductCategory.Category_Image_Alt_Text__c';

const FIELDS = [CATEGORY_IMAGE, CATEGORY_IMAGE_DEFAULT, CATEGORY_IMAGE_TITLE, CATEGORY_IMAGE_ALT_TEXT];

import categoryDefaultImageAltText from '@salesforce/label/c.B2B_Default_Category_Image_Alt_Text';
import categoryDefaultImageTitle from '@salesforce/label/c.B2B_Default_Category_Image_Title';


export default class B2bCategoryImage extends LightningElement {
    @api record;

    @wire(getRecord, { recordId: '$record', fields: FIELDS })
    recordData;

    get bannerImage() {
        return getFieldValue(this.recordData.data, CATEGORY_IMAGE);
    }

    get bannerImageDefault() {
        return getFieldValue(this.recordData.data, CATEGORY_IMAGE_DEFAULT);
    }

    get bannerImageTitle() {
        var imgTitle = getFieldValue(this.recordData.data, CATEGORY_IMAGE_TITLE);
        if (imgTitle == null){
            return categoryDefaultImageTitle;
        } else {
            return imgTitle;
        }
    }

    get bannerImageAltText() {
        var imgAltText = getFieldValue(this.recordData.data, CATEGORY_IMAGE_ALT_TEXT);
        if (imgAltText == null){
            return categoryDefaultImageAltText;
        } else {
            return imgAltText;
        }
    }
}