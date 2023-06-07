//============================================================================
// Title:    Honda MyGarage Experience - Auto Link Feature Card
//
// Summary:  This is the Auto Link Feature Card html seen at the page of the Honda MyGarage Community
//
// Details:  Auto Link Feature Card for pages
//
// History:
// October 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, wire, track } from 'lwc';
import {ISGUEST, getProductContext} from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';
import getFeatureListByModelInformation from '@salesforce/apex/OwnAPIController.getFeatureListByModelInformation';
import getFeatureListByProductIdentifier from '@salesforce/apex/OwnAPIController.getFeatureListByProductIdentifier';
export default class OwnAutoLinkFeatureCard extends OwnBaseElement {
    @api icon;
    @api title;
    @api titlecolor;
    @track features;
    @track isGuest = ISGUEST;
    @track buttonLabel;
    @track hideErrorOnOverviewTab;
    @api actionbuttonlabel;
    @track mainCardClass = '';
    warningicon;
    showMessage;
    context;
    get titleClass(){
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    connectedCallback(){
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        if(document.title == 'HondaLink Features' || document.title == 'Acuralink Connected Features'){
          this.mainCardClass = 'connected-features-tab-div';
        }
        if (document.title == 'Garage' || document.title == 'Garage'){
          this.mainCardClass = 'overview-tab-class';
         // console.log('Document title ::: ', document.title);
        }
        this.buttonLabel = this.isGuest ? 'GET STARTED' : 'LEARN MORE';
        this.warningicon = this.myGarageResource() + '/ahmicons/warning.png';
        this.hideErrorOnOverviewTab = document.URL.includes('garage-honda') || document.URL.includes('garage-acura');
        this.initialize();
    }

    initialize = async () => {
      let origin = localStorage.getItem('origin');
      if(origin == 'ProductChooser'){  
          this.context = await getProductContext('', true);
      }else{
          this.context = await getProductContext('', false);
      }
        this.getFeatureList();
    };
    
    getFeatureList(){
      if(this.context){
       // console.table(this.context.product);
        if(this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-')){
              let vin = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
              getFeatureListByProductIdentifier({productIdentifier: vin, divisionId: this.context.product.divisionId}).then((result) => {
                this.features = this.getModifiedFeatures(result.feature);

                //AMSMG-5
                if(this.features.length >= 3){
                  if (this.features[0].featureDisplayName == this.features[1].featureDisplayName){
                    this.features.shift();
                    console.log('shift');
                  }
                }
                //AMSMG-5

               // console.log('result::',JSON.parse(JSON.stringify(result)));
               // console.log('feature-card - ',JSON.parse(JSON.stringify(this.features)));
            }).catch((err) => {
               // console.log('err-vin ',err );
            });
        }else{
          this.showMessage = true;
        }
      }
    }

    getModifiedFeatures(feature){
      let features = feature && feature.length > 0 ? JSON.parse(JSON.stringify(feature)) : [];
      features.forEach(featr => {
        featr.featureIcon = this.myGarageResource() + '/ahmicons/' + featr.featureIcon;
        this.showMessage = featr.hasAmazonFeature || featr.hasDriverFeedbackFeature ? false : true;
        featr.statusiconclass = featr.status == 'Data Unavailable' ? 'status-icon-color' : '';
      });
      features = features.filter(featr => {
        return featr.hasAmazonFeature || featr.hasDriverFeedbackFeature;
      });
      return features;
    }

    handleViewVehicleCompatibilityClick(){
        if(this.context){
          let navigationPath = this.context.product.divisionId == 'A' ? '/honda-product-compatibility-result' : '/acura-product-compatibility-result';
          this.navigate(navigationPath, {});
        }
    }

    handleClick(event){
      let featureTitle = event.target.value.toLowerCase();
      if(this.context && featureTitle == 'driver feedback'){
          localStorage.setItem('frompage', 'FeatureCard'); //DOE-4842
          let navigationUrl = this.context.product.division == 'Acura' ? '/acuralink-driver-feedback' : '/hondalink-driver-feedback';
          this.navigate(navigationUrl, {});
      }else if(this.context && featureTitle == 'amazon alexa'){
        let navigationUrl = this.context.product.division == 'Acura' ? '/acuralink-amazon-alexa' : '/hondalink-amazon-alexa';
        this.navigate(navigationUrl, {});
      }
    }

    handleFooterLinkClick(){
      if(this.context){
        // let navigationUrl = this.context.product.division == 'Acura' ? '/acuralink-amazon-alexa' : '/hondalink-amazon-alexa';
        // this.navigate(navigationUrl, {});
        window.open('https://www.amazon.com/dp/B08K879WHF/ref=redir_mobile_desktop?encoding=UTF8&pi=AC_SX236_SY340_QL65&qid=1601255382&ref=mp_s_a_1_53&sr=1-53', '_blank');
      }
    }
}