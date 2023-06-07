import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from "lightning/navigation";
import Id from '@salesforce/user/Id';
import FIRST_NAME_FIELD from '@salesforce/schema/User.FirstName';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PROFILE_PHOTO_FIELD from '@salesforce/schema/User.FullPhotoUrl';
import CIAM_USER_ID_FIELD from '@salesforce/schema/User.CIAM_User_ID__c';
/*
import STREET_FIELD from '@salesforce/schema/Account.BillingStreet';
import CITY_FIELD from '@salesforce/schema/Account.BillingCity';
import STATE_FIELD from '@salesforce/schema/Account.BillingState';
import ZIP_CODE_FIELD from '@salesforce/schema/Account.BillingPostalCode';
*/
import STREET_FIELD from '@salesforce/schema/Account.PersonMailingStreet';
import CITY_FIELD from '@salesforce/schema/Account.PersonMailingCity';
import STATE_FIELD from '@salesforce/schema/Account.PersonMailingState';
import ZIP_CODE_FIELD from '@salesforce/schema/Account.PersonMailingPostalCode';
import commonResources from "@salesforce/resourceUrl/Owners";
import getCIAMConfig from '@salesforce/apex/OwnUserHandler.getCIAMConfig';
import getExternalLoginDetails from '@salesforce/apex/OwnAccountInformationController.getExternalLoginDetails';
import saveImage from '@salesforce/apex/OwnAccountInformationController.saveImage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnAccountInformation extends OwnBaseElement {
    userId = Id;
    camera_icon = commonResources + '/Icons/garage_camera.svg';

    @api accountId;
    @track accountInfo;
    @track customImage = {};
    @track image;
    @track editUrl;
    @track appId;
    @track warningicon;
    @track showImageError;
    @track uploadImageError = 'Image should be JPG, GIF or PNG File. Maximum file size is 3 MB';
    @track savingData = false;
    @api playStoreURL;
    @api appStoreURL;
    @api acuraPlayStoreURL;
    @api acuraAppStoreURL;
    @api subscriptionsLoaded;
    
    user;
    @wire(getRecord, { recordId: '$userId', fields: [FIRST_NAME_FIELD, NAME_FIELD, EMAIL_FIELD, PROFILE_PHOTO_FIELD, CIAM_USER_ID_FIELD] })
    loadUserDetails({ data, error }) {
        if (data) {
            this.user = data;
            this.image = getFieldValue(data, PROFILE_PHOTO_FIELD);
        }
    };

    @wire(getRecord, { recordId: '$accountId', fields: [STREET_FIELD, CITY_FIELD, STATE_FIELD, ZIP_CODE_FIELD] })
    account;

    @wire(getExternalLoginDetails)
    externalLoginDetails;

    get buttonLabel() {
        return this.isAddressPresents ? "EDIT" : "ADD";
    }

    get uploadPhotoButtonLabel() {
        return this.image ? "Choose File button" : "Add Photo";
    }

    get isAddressPresents() {
        return this.street || this.city || this.state || this.zipcode;
    }

    get street() {
        return getFieldValue(this.account.data, STREET_FIELD);
    }

    get city() {
        return getFieldValue(this.account.data, CITY_FIELD);
    }

    get state() {
        return getFieldValue(this.account.data, STATE_FIELD);
    }

    get zipCode() {
        return getFieldValue(this.account.data, ZIP_CODE_FIELD);
    }

    get firstName() {
        return getFieldValue(this.user, FIRST_NAME_FIELD);
    }

    get Name() {
        return getFieldValue(this.user, NAME_FIELD);
    }

    get email() {
        return getFieldValue(this.user, EMAIL_FIELD);
    }

    // @api isVINImage = false;

    get imgCls() {
        // if (this.isVINImage){
        return "slds-align_absolute-center vehicle-image-round img-cover";
        // }
        // else{
        //    return "slds-align_absolute-center vehicle-image-round img-contain";
        // }
    }

    renderedCallback() {
        // console.log("inside render callback line 6" + this.accountInfo);
        this.accountInfo = true;
        this.warningicon = this.myGarageResource() + '/ahmicons/warning.png';
        // console.log("inside render callback line 8" + this.accountInfo);
        refreshApex(this.account);

       /*if(this.showImageError){
            setTimeout(() => {
                this.showImageError = false;
            }, 6000);
        }*/
    }

    connectedCallback() {
        this.getCIAMdetails();
    }
    getCIAMdetails = async () => {
        getCIAMConfig().then(result => {
            this.appId = result.Application_Id__c;
            this.editUrl = result.Ciam_Edit_Url__c;
          //  console.log('Custom editUrl :', this.editUrl);
        })

    }

    get uName() {
        var fName = "Rose";
        var lName = "Merry";
        var uName = fName + ' ' + lName;
        return uName;
    }
    get uEmail() {
        var uEmailId = "rosemerry@gmail.com";
        return uEmailId;
    }

    handleOnEditUserNameAndPassword() {
        sessionStorage.setItem("RelayState", window.location.href);

        // const config = {
        //     type: 'standard__webPage',

        //     attributes: {
        //         //<<Domain Name>>/hondaowners/s/profile/<<User SF CIAM ID>>?app=<<App ID>>&RelayState=<<Relay State, if applicable>>

        //     }
        // };
        let url = `${this.externalLoginDetails.data.Ciam_Edit_Url__c}${getFieldValue(this.user, CIAM_USER_ID_FIELD)}?app=${this.externalLoginDetails.data.Application_Id__c}&RelayState=${window.location.href}`
     //   console.log('url2', this.editUrl + getFieldValue(this.user, CIAM_USER_ID_FIELD) + '?app=' + this.appId + '&RelayState=' + window.location.href);
      //  console.log('url ::: ', url);
        window.open(url, '_self');
        // this[NavigationMixin.GenerateUrl](config)
        //     .then(url => {
        //         window.open(url, '_self');
        //     });
    }

    handleOnHomeAddressEdit() {
        this.dispatchEvent(new CustomEvent("editaddress"));
    }

    handleUserImageUpload(event) {
        this.showImageError = false;
        const customImageUpload = event.target.files[0];

        this.customImage.name = customImageUpload.name;
        this.customImage.type = customImageUpload.type;
        this.customImage.size = customImageUpload.size;

    //    console.log('TYPE: ' + this.customImage.type);

        let imgReaderURL = new FileReader();
      //  console.log('imgReaderURL', imgReaderURL);
        this.savingData = true;
        imgReaderURL.onload = (event => {
            if(this.customImage.type.includes('image')){
                this.customImage.dataURL = event.target.result;
            //    console.log('this.customImage.dataURL : ', this.customImage.dataURL);
                saveImage({ userId: this.userId, imageName: this.customImage.name, imageURL: this.customImage.dataURL, imageType: this.customImage.type })
                    .then(result => {
                        this.image = event.target.result;
                    //    console.log('this.image : ', this.image);
                
                    //    console.log('Image Upload Success');
                        this.savingData = false;
                        let message = {profileImageUpdate: true};
                        this.publishToChannel(message);

                        //window.location.reload();
                    })
                    .catch(error => {
                        this.savingData = false;
                     //   console.log(error);
                        if (error) {
                            /*const toastAlert = new ShowToastEvent({
                                title: 'Error!',
                                message: 'Image should be JPG, GIF or PNG File. Maximum file size is 16 MB',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(toastAlert);*/
                            this.showImageError = true;
                        }
                    });
            }else{
                this.showImageError = true;
                this.savingData = false;
            }
        });
        imgReaderURL.onerror = (event => {
            this.savingData = false;
         //   console.log('URL reader error: ' + JSON.stringify(event.target.error));
            /*const toastAlert = new ShowToastEvent({
                title: 'Error!!',
                message: 'Image should be JPG, GIF or PNG File. Maximum file size is 3 MB',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(toastAlert);*/
            this.showImageError = true;
        });

        imgReaderURL.readAsDataURL(customImageUpload);
    }

    handleErrorClose(){
        this.showImageError = false;
    }
}