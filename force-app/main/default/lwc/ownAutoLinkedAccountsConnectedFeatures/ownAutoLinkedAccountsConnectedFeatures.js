import { track } from 'lwc';
import { getMyProducts, nonConnectedPlatformMap } from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';
// import getFeatureListByModelInformation from '@salesforce/apex/OwnAPIController.getFeatureListByModelInformation';
import getFeatureListByProductIdentifier from '@salesforce/apex/OwnAPIController.getFeatureListByProductIdentifier';
export default class OwnAutoLinkedAccountsConnectedFeatures extends OwnBaseElement {
    
    connectedCallback(){
        this.initialize();
    }
    
    initialize = async () => {
        let myProducts = await getMyProducts('');
        let products = JSON.parse(JSON.stringify(myProducts.products));
        //console.table(products);
        products = products.sort(function(a, b){return parseInt(b.year) - parseInt(a.year)});
        products.forEach(prod => { prod.image = prod.productDefaultImage && prod.productDefaultImage != '' ? prod.productDefaultImage : prod.image; });
        products = products.filter(prod => { return prod.division == 'Acura' || prod.division == 'Honda'; });
        //console.table(products);
        products.forEach(product => {
            product.image = product.customerUploadedImage ? product.customerUploadedImage : product.productDefaultImage ? product.productDefaultImage : product.image.includes('motorcycle/') ? product.image.replace('motorcycle/','') : product.image;;
            if(product.productIdentifier){
                getFeatureListByProductIdentifier({productIdentifier: product.productIdentifier, divisionId: product.divisionId}).then((result) => {
                    //console.log(result);
                    let telemeticsplatform = result && result.vehicle ? result.vehicle.telematicsPlatform : '';
                    telemeticsplatform = telemeticsplatform && telemeticsplatform == 'LEGACY' ? 'Legacy' : telemeticsplatform;
                    if(!nonConnectedPlatformMap.includes(telemeticsplatform)){
                       // console.log('Connected Platform--',telemeticsplatform)
                        if(result && result.feature && result.feature.length > 0)
                            this.prepareListData(result.feature, product);
                    }else{
                        //console.log('Non Connected Platform--',telemeticsplatform);
                    }
                }).catch((err) => {
                    //console.error('Component.OwnAutoLinkedAccountsConnectedFeatures: line 35', err);
                });
            }/*else{
                let model = product.model.includes(' ') ? product.model.trim().replaceAll(' ','%20') : product.model;
                getFeatureListByModelInformation({ year : product.year, model : model, modelId: product.modelId, divisionId: product.divisionId }).then((result) => {
                    console.log('result ym: ',result);
                    if(result && result.feature && result.feature.length > 0)
                        this.prepareListData(result.feature, product);
                }).catch((err) => {
                    console.log('err ym:',err);
                });
            }*/
        });
    };
    // @track prodcutList = {products : [], availableFeatures : []};
    @track prodcutList = {products : [], availableFeatures : ["Amazon Alexa", "Driver Feedback"]};
    prepareListData(features_data, prod){
        features_data = JSON.parse(JSON.stringify(features_data));
        let flag = false;
        features_data.forEach(featr => {
            if(!flag)
                flag = featr.status != 'Not Available' ? true : false;
            featr.statusiconclass = featr.status == 'Data Unavailable' ? 'status-icon-color' : '';
        });
        if(flag){

            //AMSMG-6
            if(features_data.length >= 3){
                if (features_data[0].featureDisplayName == features_data[1].featureDisplayName){
                    features_data.shift();
                    console.log('shift');
                }
            }
            //AMSMG-6

            prod.features = features_data;
            this.prodcutList.products.push(prod);
        }
        /*features_data.forEach(feature => {
            if(!this.prodcutList.availableFeatures.includes(feature.featureDisplayName))
                this.prodcutList.availableFeatures.push(feature.featureDisplayName);
        });
        let features = [];
        let hasAtleastOneFeature = false;
        this.prodcutList.availableFeatures.forEach(featureDisplayName => {
            let featr = features_data.find(val => featureDisplayName == val.featureDisplayName);
            featr = featr ? {...featr, ...{hasCurrentFeature : true}} : {hasCurrentFeature: false, featureDisplayName: '', icon : ''};
            hasAtleastOneFeature = featr.hasCurrentFeature ? true : false;
            features.push(featr);
        });

        prod.features = features;
        if(hasAtleastOneFeature) this.prodcutList.products.push(prod);
        console.log('server response... : ',JSON.parse(JSON.stringify(this.prodcutList)));
        console.table(features_data);*/
    }

    handleLinkClick(event){

        if((event.target.dataset.linklabel == 'Edit on Amazon' || event.target.dataset.linklabel == 'Get Started On Amazon') || event.target.dataset.featurename == 'Amazon Alexa' && event.target.dataset.linklabel == 'Sign-up'){
            // let navigationUrl = event.target.dataset.division == 'Acura' ? '/acuralink-amazon-alexa' : '/hondalink-amazon-alexa';
            // this.navigate(navigationUrl, {});
            window.open('https://www.amazon.com/dp/B08K879WHF/ref=redir_mobile_desktop?encoding=UTF8&pi=AC_SX236_SY340_QL65&qid=1601255382&ref=mp_s_a_1_53&sr=1-53', '_blank');
        }else{
            let navigationUrl = event.target.dataset.division == 'Acura' ? '/acuralink-driver-feedback' : '/hondalink-driver-feedback';
            this.navigate(navigationUrl, {});
        }
    }
}