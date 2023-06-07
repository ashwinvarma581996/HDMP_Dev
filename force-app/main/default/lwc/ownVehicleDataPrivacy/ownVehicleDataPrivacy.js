import { OwnBaseElement } from 'c/ownBaseElement';
import { getMyProducts } from 'c/ownDataUtils';
import getFeatureListByModelInformation from '@salesforce/apex/OwnAPIController.getFeatureListByModelInformation';
import productIdentifierLookUp from '@salesforce/apex/OwnAPIController.productIdentifierLookUp';
import setProductContextUser from '@salesforce/apex/OwnContextController.setProductContextUser';
import { track } from 'lwc';
export default class OwnVehicleDataPrivacy extends OwnBaseElement {
    products;
    @track productMap = new Map();

    connectedCallback() {
        this.initialize();
    }
    initialize = async () => {
        let myProducts = await getMyProducts('');
        this.products = JSON.parse(JSON.stringify(myProducts.products));
        this.products = this.products.filter(product => { return product.divisionId === 'A' || product.divisionId === 'B'; });
        //console.log('getMyProducts: ', this.products);
        this.products = this.products.sort(function (a, b) { return parseInt(b.year) - parseInt(a.year) });
        this.products.forEach(product => {
            product.image = product.customerUploadedImage ? product.customerUploadedImage : product.productDefaultImage ? product.productDefaultImage : product.image.includes('motorcycle/') ? product.image.replace('motorcycle/', '') : product.image;;
            this.productMap.set(product.productId, product);
        });

        // this.products = this.products.filter(product => {
        //     return product.productIdentifier && product.productIdentifier != '';
        // });
    };

    handleAction(event) {
        let productId = event.target.value;
        let product = this.productMap.get(productId);
        //console.log('VehicleDataPrivacyProduct', product)
        // localStorage.setItem('AdobeVehicleDataPrivacyProduct', product.division);
        //console.table(product);
        if (product) {
            if (product.productIdentifier) {
                productIdentifierLookUp({ productIdentifier: product.productIdentifier, divisionId: product.divisionId }).then((result) => {
                    //console.log('result vinlookup: ', result);
                    let telematicsPlatform = result.vehicle && result.vehicle.telematicsPlatform ? result.vehicle.telematicsPlatform : '';
                    let telematicsUnit = result.vehicle && result.vehicle.telematicsUnit ? result.vehicle.telematicsUnit : '';
                    //console.log('TELEMATICS_PI: ', telematicsPlatform);
                    //Changes Done For DOE-5069 By ABHISHEK SALECHA
                    let url = '';
                    let yesOrNo = telematicsUnit == 'Y' ? 'yes' : 'no';
                    if (telematicsPlatform == 'MY21' && product.divisionId == 'B') {
                        url = '/vehicle-data-privacy-settings-result?result=' + yesOrNo + '&platform=MY21';
                    } else if (telematicsPlatform == 'MY17') {
                        url = '/vehicle-data-privacy-settings-result?result=' + yesOrNo;
                    } else {
                        url = '/vehicle-data-privacy-settings?page=result';
                    }
                    this.setProductContext(productId, url);
                }).catch((err) => {
                    //console.log('err vinlookup ', err);
                    this.setProductContext(productId, null);
                    this.navigateToResultPage();
                });
            } else if (product.year && product.modelId) {
                let modelName = '';
                if (product.model) {
                    modelName = product.model.trim().replaceAll(' ', '%20');
                }
                //product.model = product.model.includes(' ') ? product.model.trim().replaceAll(' ','%20') : product.model;
                getFeatureListByModelInformation({
                    year: product.year,
                    model: modelName,
                    modelId: product.modelId,
                    divisionId: product.divisionId
                }).then((result) => {
                    //console.log('result ym: ', result);
                    //Changes Done For DOE-5069 By ABHISHEK SALECHA
                    let url = '';
                    if (result && result.model && result.model.telematicsPlatform) {
                        if (result.model.telematicsPlatform == 'MY21' && product.divisionId == 'B') {
                            url = '/vehicle-data-privacy-settings?page=question&platform=MY21';
                        } else if (result.model.telematicsPlatform == 'MY17') {
                            url = '/vehicle-data-privacy-settings?page=question';
                        } else {
                            url = '/vehicle-data-privacy-settings?page=result';
                        }
                    } else {
                        url = '/vehicle-data-privacy-settings?page=result';
                    }
                    this.setProductContext(productId, url);
                }).catch((error) => {
                    //console.log('err ym: ', error);
                    this.setProductContext(productId, null);
                    this.navigateToResultPage();
                });
            } else {
                this.navigateToResultPage();
            }
        }
    }
    navigateToResultPage = () => {
        sessionStorage.setItem('frompage', 'Vehicle Data Privacy');
        sessionStorage.setItem('defaulttab', 'Vehicle Data Privacy');
        localStorage.removeItem('origin');
        if(document.location.pathname.includes('my-account')){
            sessionStorage.setItem('from-page', 'my-account');
            sessionStorage.setItem('to-page', url);
        }
        this.navigate('/vehicle-data-privacy-settings?page=result', {});
    }

    setProductContext(productId, url) {
        setProductContextUser({ context: { 'productId': productId, 'productTab': 'Overview' } }).then((result) => {
            sessionStorage.setItem('frompage', 'Vehicle Data Privacy');
            sessionStorage.setItem('defaulttab', 'Vehicle Data Privacy');
            localStorage.removeItem('origin');
            if (url){
                if(document.location.pathname.includes('my-account')){
                    sessionStorage.setItem('from-page', 'my-account');
                    sessionStorage.setItem('to-page', url);
                }
                this.navigate(url, {});
            }
            console.log('This is setProductContextUser');
        }).catch((err) => { 
            //console.log('err context update - ', err); this.navigateToResultPage(); 
        });
    }
}