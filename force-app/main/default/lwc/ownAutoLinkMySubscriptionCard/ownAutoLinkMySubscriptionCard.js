//============================================================================
// Title:    Honda MyGarage Experience - Auto Link Subscription Card
//
// Summary:  This is the Auto Link Subscription Card html seen at the page of the Honda MyGarage Community
//
// Details:  Auto Link Subscription Card for pages
//
// History:
// October 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getProductContext, getOrigin } from 'c/ownDataUtils';
import getManageSubscriptions from '@salesforce/apex/OwnAPIController.getManageSubscriptions';
import getSSPSSOAcuralink from '@salesforce/apex/OwnAPIController.getSSPSSOAcuralink';
import getSSPSSOHondalink from '@salesforce/apex/OwnAPIController.getSSPSSOHondalink';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
import getSSO from '@salesforce/apex/OwnAPIController.getSSO';
import getTrialEligibility from '@salesforce/apex/OwnAPIController.getTrialEligibility';
export default class OwnAutoLinkMySubscriptionCard extends OwnBaseElement {
  @api icon;
  @api title;
  @api titlecolor;
  @api actionbuttonlabel;
  @api description;
  @track subscriptions;
  @track error;
  @api androidAppLink;
  @api iosAppLink;
  @track showMessage = false;
  isConnectedPrimaryDriver = true;
  loading = true;
  context;
  warningicon;
  @track vehicleInfos;
  @track mainCardClass = '';
  isFreeTrailEligible =false;

  @track showPopup = false;
  @api playStoreURL;
  @api appStoreURL;
  @api acuraPlayStoreURL;
  @api acuraAppStoreURL;
  popupAppStoreIcon = this.myGarageResource() + '/images/appstoreicon.png';
  popupPlayStoreIcon = this.myGarageResource() + '/images/playstoreicon.png';

  get titleClass() {
    return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
  }

  connectedCallback() {
    this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
    if (document.title == 'HondaLink Features' || document.title == 'Acuralink Connected Features') {
      this.mainCardClass = 'connected-features-tab-div';
    }
    if (document.title == 'Garage' || document.title == 'Garage') {
      this.mainCardClass = 'overview-tab-class';
      //console.log('Document title ::: ', document.title);
    }
    this.warningicon = this.myGarageResource() + '/ahmicons/warning.png';
    this.initialize();
  }

  initialize = async () => {
    let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
    //console.log('From Product Chooser ----', fromProductChooser);
    if (fromProductChooser) {
      this.context = await getProductContext('', true);
    } else {
      this.context = await getProductContext('', false);
    }
    // console.log('Context----------------',this.context);
    if (this.context.product.productIdentifier || this.context.product.vin) {
      this.getSubscriptions();
    } else {
      this.isConnectedPrimaryDriver = false;
      this.error = 'Unable to get Subscriptions, VIN not present!!'
    }
  };

  getSubscriptions() {
    getManageSubscriptions({ productIdentifier: this.context.product.productIdentifier ?? this.context.product.vin, divisionId: this.context.product.divisionId }).then(result => {
      //console.log('getMySubscriptions: ', result);
      this.subscriptions = JSON.parse(JSON.stringify(result.packages));
      if (this.subscriptions.length == 0) {
        this.showMessage = true;
      }
      // if (Object.keys(result.manageSubscriptions).length > 0 && result.manageSubscriptions.vehicleInfo && result.manageSubscriptions.vehicleInfo[0]) {
      //   this.vehicleInfos = JSON.parse(JSON.stringify(result.manageSubscriptions.vehicleInfo[0]));
      //   console.log('::::: vehicle infos ::::: ', this.vehicleInfos);
      // }
      if(result.vehicleFeature && result.vehicleFeature.vehicle){
        this.vehicleInfos = result.vehicleFeature.vehicle;
        //console.log('::::: vehicle infos ::::: ', this.vehicleInfos);
      }
      // This Loop is used to change the order of packages as per figma 
      for (let i = 0; i < this.subscriptions.length; i++) {
        if (this.subscriptions[i].packageName == 'Error') {
          this.error = this.subscriptions[i].status;
          this.isConnectedPrimaryDriver = false;
          this.loading = false;
          return;
        }
      }
      this.loading = false;
    }).catch(error => {
      this.loading = false;
     // console.log(error);
    })
  }

  async handleClickLink(event) {
   // console.log(event.target.value);
    let eventMetadata = {
      action_type: 'button',
      action_category: 'body',
      action_label: this.title + ':' + this.actionbuttonlabel
    };
    let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
    this.publishToChannel(message);

    //console.log('::::: vehicle infos ::::: ', this.vehicleInfos);
    let url;
    if (event.target.value == 'AccountManage') {
      url = '/my-account?tab=subscription';
      await this.sleep(2000);
      this.navigate(url, {});
    } else if (event.target.value == 'Learn More' && this.context) {
      url = this.context.product.divisionId == 'A' ? '/honda-product-compatibility-result' : '/acura-product-compatibility-result';
      await this.sleep(2000);
      this.navigate(url, {});
    } else if ((event.target.value == 'Sign Up' || event.target.value == 'Manage') && this.context && this.vehicleInfos) {
      let product = this.vehicleInfos;
      let brand;
      if (product.divisionCode == 'A') {
        brand = 'honda';
      } else if (product.divisionCode == 'B') {
        brand = 'acura';
      }
      let dataPack = event.currentTarget.dataset.pack;
      //console.log('dataPack : ', dataPack);
      await getTrialEligibility({ productIdentifier: product.VIN, divisionId: product.divisionCode})
      .then((data) => {
          //console.log('isFreeTrailEligibleData : ', JSON.stringify(data.responseBody));
          let vehicleEligibility = data.responseBody;
          if (vehicleEligibility) {
              let currentVehicleEligibility = JSON.parse(JSON.stringify(vehicleEligibility));
              //console.log('This is this.vehicleEligibility', JSON.stringify(vehicleEligibility));
              if (currentVehicleEligibility && currentVehicleEligibility.eligibilityFlag && currentVehicleEligibility.eligibleProducts) {
                  for (const eligibilityProduct of currentVehicleEligibility.eligibleProducts) {
                      if (eligibilityProduct.productName.toLowerCase().includes(dataPack.toLowerCase())) {
                          this.isFreeTrailEligible=true;
                          //console.log('@@isFreeTrailEligible'+this.isFreeTrailEligible);
                          break;
                      }
                  }
              }
          }

      }).catch((error) => {
         // console.log('Error : ', error);
      });
      //Added New If For DOE-5069 By ABHISHEK SALECHA
      // if (dataPack == 'Remote' && brand == 'acura' && product.telematicsUnit == 'Y' && product.telematicsPlatform == 'MY21') {
      //   this.showPopup = true;
      // }
      // else 
      if (dataPack == 'Security' || dataPack == 'Remote' || dataPack == 'Concierge') {
        if (brand == 'acura' || brand == 'honda') {
          if ((product.telematicsPlatform == 'MY17' || product.telematicsPlatform == 'MY21' || product.telematicsPlatform == 'MY23') && product.telematicsUnit == 'Y') {
            if(product.enrollment === 'N' && product.ownership === 'N'){
              this.showPopup = true;
            }else if(product.telematicsPlatform == 'MY17' && product.telematicsUnit == 'Y' && this.isFreeTrailEligible == true){
              this.showPopup = true;
            }else{
              this.singleSingOnToSXM(product);
            }
          }
        }
      }
      else if ((dataPack == 'Standard' || dataPack == 'Connect' || dataPack == 'Premium') && brand == 'acura') {
        if (product.telematicsPlatform == 'MY13') {
          await this.sleep(2000);
          this.navigate('/sxm-phone-info', {}); //'sirius-xm-phone-info'
        }
      }
      else if (dataPack == 'Link') {
        let deviceDetails = navigator.userAgent.toLowerCase();
        let navigationURL = deviceDetails.indexOf("android") > -1 ? this.androidAppLink : this.iosAppLink;
        //console.log('This is navigation URL : ', navigationURL);
        if (brand == 'honda' && (product.telematicsPlatform == 'MY16' || product.telematicsPlatform == 'MY17' || product.telematicsPlatform == 'MY21' || product.telematicsPlatform == 'MY23' || product.telematicsPlatform == '2ZS')) {
          await this.sleep(2000);
          this.navigate(navigationURL, {});
        }
        if (brand == 'acura' && (product.telematicsPlatform == 'MY17' || product.telematicsPlatform == 'MY23')) {
          await this.sleep(2000);
          this.navigate(navigationURL, {});
        }
      }
      //url = '/my-account';
      // this.navigate(url, {});
    }
  }

  singleSingOnToSXM(product) {
    getSSO({ productIdentifier: product.VIN })
      .then((data) => {
        //console.log('Data : ', typeof (data));
        if (data.statusCode === 200) {
          if(this.isJSON(data.response)){
            let jsonResponse = JSON.parse(data.response);
            if(jsonResponse && jsonResponse.body && jsonResponse.body.status === 'success'){
              this.navigate(jsonResponse.body.url, {});
            }else{
              this.showPopup = true;
            }
          }else{
            let ssoDiv = this.template.querySelector(`[data-id="sso"]`);
            ssoDiv.innerHTML = data.response;
            //console.log('this querySelector : ', this.template.querySelector('form'));
            this.template.querySelector('form').submit();
          }
        } else {
          this.showPopup = true;
        }
      })
      .catch((error) => {
        //console.log('Error : ', error);
        this.showPopup = true;
      });

    // if (product.divisionCode == 'B') {
    //   getSSPSSOAcuralink({ productIdentifier: product.VIN, divisionId: product.divisionCode })
    //     .then((data) => {
    //       console.log('Data : ', typeof (data));
    //       if (data.statusCode === 200) {
    //         let ssoDiv = this.template.querySelector(`[data-id="sso"]`);
    //         ssoDiv.innerHTML = data.response;
    //         console.log('this querySelector : ', this.template.querySelector('form'));
    //         this.template.querySelector('form').submit();
    //       } else {
    //         this.showPopup = true;
    //       }
    //     })
    //     .catch((error) => {
    //       console.log('Error : ', error);
    //       this.showPopup = true;
    //     });
    // }
    // if (product.divisionCode == 'A') {
    //   getSSPSSOHondalink({ productIdentifier: product.VIN, divisionId: product.divisionCode })
    //     .then((data) => {
    //       if (data.statusCode === 200) {
    //         let ssoDiv = this.template.querySelector(`[data-id="sso"]`);
    //         ssoDiv.innerHTML = data.response;
    //         console.log('this querySelector : ', this.template.querySelector('form'));
    //         this.template.querySelector('form').submit();
    //       } else {
    //         this.showPopup = true;
    //       }
    //     })
    //     .catch((error) => {
    //       console.log('Error : ', error);
    //       this.showPopup = true;
    //     });
    // }
  }

  isJSON(str) {
      try {
          return (JSON.parse(str) && !!str);
      } catch (e) {
          return false;
      }
  }

  get popupText() {
    if (this.context.product.divisionId === 'A') {
      return 'DOWNLOAD THE HONDALINK APP AND PAIR WITH YOUR HONDA TO START USING THESE FEATURES TODAY';
    } else {
      return 'DOWNLOAD THE ACURALINK APP AND PAIR WITH YOUR ACURA TO START USING THESE FEATURES TODAY';
    }
  }

  closePopup() {
    this.showPopup = false;
  }

  handleNavigations(event) {
    this.showPopup = false;
    let navigationUrl;
    let product = this.vehicleInfos;
    if (product.divisionCode == 'A') {
      navigationUrl = event.currentTarget.dataset.hondaurl;
    } else if (product.divisionCode == 'B') {
      navigationUrl = event.currentTarget.dataset.acuraurl;
    }
    this.navigate(navigationUrl, {});
  }

  handleClickAction() {

  }

  handleClickHeader() {

  }
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}