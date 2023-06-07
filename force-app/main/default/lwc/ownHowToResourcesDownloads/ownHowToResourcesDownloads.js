import { LightningElement, track } from 'lwc';
import { ISGUEST, getProductContext, getContext, getOrigin } from 'c/ownDataUtils';
import getCompleteDetails from '@salesforce/apex/OwnAPIController.getCompleteDetails';
import { OwnBaseElement } from 'c/ownBaseElement';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnHowToResourcesDownloads extends OwnBaseElement {
    @track icon = this.myGarageResource() + '/ahmicons/download-how-to-guide.svg';
    @track titlecolor = 'Honda Red';
    @track showFooter = false;
    @track brandSlot = 'Honda';
    @track hideBodySection = true;
    @track headerClickable = true;

    @track categoriesData = [];
    @track allCategoriesData = [];
    @track divisionId;
    @track isError = false;
    @track isLoading = true;
    @track errorMessage;

    connectedCallback() {
        this.initialize();
    }

    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        let context;
        if (fromProductChooser) {
            context = await getProductContext('', true);
        } else {
            context = await getProductContext('', false);
        }
        //console.log('How To Guides context-->', context);
        if (sessionStorage.getItem('R&Dhowtoguides') && sessionStorage.getItem('R&Dallhowtoguides')) {
            this.categoriesData = JSON.parse(sessionStorage.getItem('R&Dhowtoguides'));
            this.allCategoriesData = JSON.parse(sessionStorage.getItem('R&Dallhowtoguides'));
            //console.log('categoriesData,allCategoriesData', this.categoriesData, this.allCategoriesData)
        }
        this.isLoading = false;
        // if (context && context.product) {
        //     this.divisionId = context.product.divisionId;
        //     let response = await getCompleteDetails({ divisionId: context.product.divisionId, modelYear: context.product.year, model: context.product.model });
        //     console.log('response-->', response);
        //     if (response && response.error) {
        //         this.isError = true;
        //         this.errorMessage = 'Data Unavailable';
        //         this.isLoading = false;
        //     } else {
        //         // response.feature.forEach(element => {
        //         //     let t = element.title.toLowerCase();
        //         //     let category = '';
        //         //     console.log('response1-->', t);
        //         //     this.categories.some(e => {
        //         //         if (t.includes(e)) {
        //         //             category = e;
        //         //             console.log('response2-->', element.title);
        //         //             console.log('response3-->', this.categories.some(element => t.includes(element)));
        //         //             element.view = element.view.filter(ele => ele.data);
        //         //             element.view.forEach(viewEle => {
        //         //                 if (!viewEle.title) {
        //         //                     viewEle.title = element.title;
        //         //                 }
        //         //             });
        //         //             let categoryData = {};
        //         //             categoryData.title = element.title;
        //         //             categoryData.categoryTitle = category;
        //         //             this.categoriesData.push(categoryData);
        //         //             this.allCategoriesData.push({
        //         //                 title: element.title,
        //         //                 features: element.view
        //         //             });
        //         //         }
        //         //     });
        //         // })
        //         for (let i = 0; i < (response.feature.length >= 4 ? 4 : response.feature.length); i++) {
        //             let element = response.feature[i];
        //             console.log('response 1-->>>', element)
        //             element.view = element.view.filter(ele => ele.data);
        //             element.view.forEach(viewEle => {
        //                 if (!viewEle.title) {
        //                     viewEle.title = element.title;
        //                 }
        //             });
        //             let categoryTitle = element.title;
        //             this.categoriesData.push(categoryTitle);
        //             this.allCategoriesData.push({
        //                 title: element.title,
        //                 features: element.view
        //             });
        //         }
        //     }
        // }
        // if (this.categoriesData.length === 0) {
        //     this.errorMessage = 'How-to guides not available for this product';
        //     this.isError = true;
        // }
        // this.isLoading = false;
        //console.log(' this.categoriesData-->', this.categoriesData);
    }
    async handleHeader(event) {
        //console.log('event-->', event.currentTarget.dataset.title);
        let category = event.currentTarget.dataset.title
        let categoryDataArray = this.allCategoriesData.filter(element => element.title == category);
        //console.log(' this.categoryObj-->', JSON.parse(JSON.stringify(categoryDataArray[0])));
        let fromPage = 'resource & downloads';
        sessionStorage.setItem('frompage', fromPage);
        if (categoryDataArray) {
            sessionStorage.setItem('howtoguides', JSON.stringify(categoryDataArray[0]));
            let data = categoryDataArray[0];
            sessionStorage.setItem('howtoguides', JSON.stringify(data));
            let breadcrumbData = {
                label: 'Resources & Downloads',
                url: '/how-to-guides',
                subTitle: data.title ? data.title + ' How-to Guides' : 'How-to Guides',
            }
            let breadcrumbArr = [];
            if (sessionStorage.getItem('fromhowtoguides')) {
                breadcrumbArr = JSON.parse(sessionStorage.getItem('fromhowtoguides'));
            }
            breadcrumbArr.push(breadcrumbData);
            sessionStorage.setItem('fromhowtoguides', JSON.stringify(breadcrumbArr));
        }
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.convertToPlain(category)
        };
        let message = this.buildAdobeMessage('/how-to-category', eventMetadata);
        this.publishToChannel(message);
        await this.sleep(2000);
        this.navigate('/how-to-category', {});
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    convertToPlain(html) {
        let tempDivElement = document.createElement("div");
        tempDivElement.innerHTML = html;
        return tempDivElement.textContent || tempDivElement.innerText || "";
    }
}