import { LightningElement, api, track, wire } from 'lwc';
import img from '@salesforce/resourceUrl/Owners';
import { ISGUEST, getGarageURL, getProductContext, getContext, setOrigin, getManagedContentByTopicsAndContentKeys, getMyProducts, getOrigin } from 'c/ownDataUtils';
import addProduct from '@salesforce/apex/OwnGarageController.addProduct';
import addProductByVin from '@salesforce/apex/OwnGarageController.addProductByVin';
import getCIAMConfig from '@salesforce/apex/OwnUserHandler.getCIAMConfig';
import { OwnBaseElement } from 'c/ownBaseElement';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
import basePath from '@salesforce/community/basePath';

export default class ownSaveToMyGarage extends OwnBaseElement {

    @api contentId;
    @api noPadding;
    @api noBanner;
    @api atPageHeader;
    @track isguest = ISGUEST;
    @track body;
    @track hideBanner;
    @track titleSectonDesktop;
    @track titleSectonMobile;
    signupURL;
    loginURL;
    products;
    context;
    urlString = window.location.href;
    baseURL = this.urlString.substring(0, this.urlString.indexOf("/s"));
    connectedCallback() {
        this.intialize();
        // if (sessionStorage.getItem('originAddProduct')) {
        //     this.handleAddProduct();
        // }
    }

    intialize = async () => {
        if (this.isguest) {
            this.getCIAMdetails();
        }
        if (!this.isguest) {
            let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
            if (fromProductChooser) {
                this.context = await getProductContext('', true);
            } else {
                this.context = await getProductContext('', false);
            }

            let myProducts = await getMyProducts('');
            this.products = JSON.parse(JSON.stringify(myProducts.products));
            //console.log('CONTEXT: ----------', JSON.parse(JSON.stringify(this.context)));
            //console.log('GET_MY_PRODUCTS: ----------', this.products);

            this.products.forEach(prod => {
                if (prod.modelId && prod.modelId == this.context.product.modelId && !this.hideBanner) {
                    this.hideBanner = true;
                }
            });
            //console.log('HIDE_BANNER: ----------', this.hideBanner);
        }

        // getCIAMConfig()
        //     .then(result => {
        //         console.log('getCIAMConfig Data', result);
        //         this.signupURL = result.Ciam_SignUp_Url__c;
        //         this.loginURL = result.Ciam_Login_Url__c;;
        //     })
        //     .catch(error => {
        //         console.log('getCIAMConfig error: ' + JSON.stringify(error));
        //     });

        let contentKeys = [this.contentId];
        let results = await getManagedContentByTopicsAndContentKeys(contentKeys, this.topics, this.pageSize, this.managedContentType);
        //console.log('results  :-  ', results);
        results.forEach(r => {
            this.body = this.isguest ? this.htmlDecode(r.body.value) : this.htmlDecode(r.sectionLabel.value);
            this.body = this.noBanner ? this.removeTags(this.body) : this.body;
            this.titleSectonDesktop = this.htmlDecode(r.descriptionContent.value);
            this.titleSectonMobile = this.htmlDecode(r.description2Content.value);
        });
    }
    getCIAMdetails = async () => {
        getCIAMConfig().then(result => {
            this.loginUrl = result.Ciam_Login_Url__c;
        })

    }
    get paddingclass() {
        return this.noPadding ? '' : 'slds-p-around_large';
    }

    get bodyColumn() {
        let isPdpPage = document.location.pathname.includes('warranty-info') || document.location.pathname.includes('recalls-detail') || document.location.pathname.includes('product-registration') ? false : true;
        //console.log('isPdpPage  :-  ', isPdpPage);
        //console.log('isPdpPage  :-  ', document.location.pathname);
        return isPdpPage ? '8' : '12'
    }

    get buttonColumn() {
        let isPdpPage = document.location.pathname.includes('warranty-info') || document.location.pathname.includes('recalls-detail') || document.location.pathname.includes('product-registration') ? false : true;
        return isPdpPage ? '4' : '12'
    }

    get buttonCss() {
        let isPdpPage = document.location.pathname.includes('warranty-info') || document.location.pathname.includes('recalls-detail') || document.location.pathname.includes('product-registration') ? false : true;;
        return isPdpPage ? 'save-button' : ''
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }

    removeTags = (text) => {
        return text.replace(/(<([^>]+)>)/ig, '');
    }

    // handleAddProduct() {
    //     console.log('Clicked');
    //     let garageProducts = JSON.parse(localStorage.getItem('garage'));
    //     const product = garageProducts.products[0];
    //     console.log(JSON.stringify(product));
    //     if (sessionStorage.getItem('originAddProduct')) {
    //         sessionStorage.removeItem('originAddProduct');
    //     }
    //     console.log('product.vin  :-  ', product);
    //     if (this.isguest) {
    //         sessionStorage.setItem('originAddProduct', product.division);
    //         let url = `${this.loginURL}&RelayState=${window.location.href}`
    //         window.open(url, '_self');
    //     } /* else if (product.vin && product.vin != '-') {
    //         setOrigin(' ');

    //         console.log(JSON.stringify(product));
    //         addProductByVin({ product: product })
    //             .then(result => {
    //                 console.log('Success');
    //                 window.location.reload();
    //                 //this.navigate(getGarageURL(product.division), {});
    //             })
    //             .catch(error => {
    //                 console.log('error: ' + JSON.stringify(error));
    //                 if (error.body.isUserDefinedException) {
    //                     this.showToast_error(error.body.message);
    //                 }
    //                 else {
    //                     this.showToast_error('An error has occurred.');
    //                 }
    //             });
    //     } */ // Alexander Dzhitenov (Wipro): Commented out since addProduct handles both products with and without a VIN
    //     else {
    //         //const prod = { 'divisionId': product.divisionId, 'division': product.division, 'year': product.year, 'model': product.model };
    //         const prod = product;
    //         setOrigin(' ');
    //         console.log('added product  :-  ', prod);
    //         addProduct(prod);
    //         this.navigate(getGarageURL(product.division));
    //     }
    // }
    handleAddProduct() {
        console.log('handleAdd called');
        /* let garageProducts = JSON.parse(localStorage.getItem('garage'));
        console.log('HANDLEADD: garageProducts: ' + JSON.stringify(garageProducts));
        const product = garageProducts.products[0]; */

        let eventMetadata = {
            action_category: 'body',
            action_label: 'add to my garage'
        };
        if (this.noBanner && !this.hideBanner) { eventMetadata.action_type = 'link' }
        else if (!this.noBanner && !this.atPageHeader && !this.hideBanner) { eventMetadata.action_type = 'button' }
        else { eventMetadata.action_type = 'link' }
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        const context = JSON.parse(localStorage.getItem('context'));
        //console.log('/////PDP LOCAL CONTEXT: ' + JSON.stringify(context));
        let product = context.product;
        //console.log(product.vin);
        //console.log('PDP PRODUCT - HANDLEADD %%%% ' + JSON.stringify(product));
        if (this.isguest) {
            sessionStorage.setItem('originAddProduct', product.division);
            sessionStorage.setItem('redirectMsg', 'originAdd');
            let redirectUrl = this.baseURL + '/s/in-progress'
            let url = this.loginUrl + `&RelayState=${redirectUrl}`;
            window.open(url, "_self");

        } else /* if (product.vin && product.vin != '-') */ {
            setOrigin(' ');
            product.image = product.vin && product.vin != '-' ? product.image : '';
            //console.log(JSON.stringify(product));
            addProduct({
                product: product
            })
                .then(result => {
                    if (result.isSuccess) {
                        //console.log('Success');
                        sessionStorage.setItem('firstItemIndex', 0);
                        if (product.divisionId != 'P') {
                            window.location.reload();
                        }
                        else {
                            sessionStorage.setItem('addingPEMProduct', true);
                            this.navigate('/product-registration', {});
                        }
                    } else if (!result.isSuccess && result.message) {
                        //console.log('error in result ', result);
                        this.showToast_error(result.message);
                    } else {
                        this.showToast_error('An error has occurred.');
                    }
                    //this.navigate(getGarageURL(product.division), {});
                })
                .catch(error => {
                    //console.log('error: ' + JSON.stringify(error));
                    if (error.body.isUserDefinedException) {
                        this.showToast_error(error.body.message);
                    } else {
                        this.showToast_error('An error has occurred.');
                    }
                });
        }
    }
    handleAddtoMygarageclick() {
        console.log('CLICKED');
    }
}