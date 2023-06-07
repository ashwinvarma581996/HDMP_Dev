import { LightningElement,api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';
import getStatesInsuranceEligibility from '@salesforce/apex/ownProductSettingsController.getStatesInsuranceEligibility';
//import getEligibleVehicle from '@salesforce/apex/OwnAPIController.getEligibleVehicle';

const FIND_BUTTON_DISABLE_CLASS = 'slds-button slds-button_neutral custom-button custom-button-find disable ';
const FIND_BUTTON_ACTIVE_CLASS = 'slds-button slds-button_neutral custom-button custom-button-find active';

export default class OwnAutoLinkDriverFeedbackDetail extends OwnBaseElement {
    playStoreUrl;
    appStoreUrl;
    
    productImage = this.myGarageResource() + '/images/blue_link_button.png';
    appStoreIcon = this.myGarageResource() + '/images/app_store_black_icon.png';
    playStoreIcon = this.myGarageResource() + '/images/play_store_black_icon.png';

    @api contentId;
    @api contentId2;
    @api contentId3;
    @api getAppSectionTitle;
    @api featuresTitle;
    @api checkInsuranceTitle;
    @api askedQuestionTitle;

    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';

    @track section1Content ={};
    @track features = [];
    @track states;
    state;
    @track stateLabel = '';
    isFindButtonDisabled = true;
    @track showResult = false;
    @track insuranceData;
    @track eligibility;

    
    get buttonClass(){
        if(this.state){
            return FIND_BUTTON_ACTIVE_CLASS;
        }else{
            return FIND_BUTTON_DISABLE_CLASS;
        }
    }
    connectedCallback(){
        this.initialize();
        this.initializeFeaturesCard();
        this.initializeStates();
    }

    initialize = async () =>{
        //this.contentKeys = [this.contentId];
       // console.log('contentKeys', this.contentKeys);
        let result = await getManagedContentByTopicsAndContentKeys([this.contentId], this.topics, this.pageSize, this.managedContentType);
       // console.log('result', result);
        result.forEach( element =>{
            this.section1Content = {
                title :  element.title.value,
                description1 : element.body ? this.htmlDecode( element.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : '',
                description1Image : element.descriptionContent ?  this.htmlDecode(element.descriptionContent.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') :'',
                description2 : element.description2Content ? this.htmlDecode(element.description2Content.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : '',
                description2Image : element.description2Label ? this.htmlDecode(element.description2Label.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') :'',
                footerText : element.sectionContent ? this.htmlDecode(element.sectionContent.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') :'',
                insuranceLogo : element.image ?  `${basePath}/sfsites/c${element.image.url}` : ''
            };
            this.playStoreUrl = element.phoneLabel ? element.phoneLabel.value :'';
            this.appStoreUrl = element.phone2Label ? element.phone2Label.value :'';
        });
       // console.log('section1Content', this.section1Content);
    }

    initializeFeaturesCard = async () =>{
        this.contentKeys = [this.contentId3, this.contentId2];
       // console.log('contentKeys', this.contentKeys);
        let result = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        //console.log('result', result);
        result.forEach( element =>{
            this.features.push({
                title : element.title.value,
                body : element.body ? this.htmlDecode(element.body.value) :'',
                image :  element.image ? `${basePath}/sfsites/c${element.image.url}` : '',
            });
        });
        
        this.features.sort((a,b) =>{ 
            if(a.title < b.title){
                return -1;
            }
            if(a.title > b.title){
                return 1;
            }
            return 0;
        });
       // console.log('features', this.features);
    }

    initializeStates(){
        getStatesInsuranceEligibility()
        .then(result =>{
            this.insuranceData = result;
            this.states = [];
            for (const state in result) {
                this.states.push({'label' : state, 'value' :state});
              }
        })
        .catch(error =>{
           // console.log('error',error);
        })
    }


    handleNavigations(event){
        let navigationUrl = event.currentTarget.dataset.url;
        //console.log(' navigation URL : ', navigationUrl)
        this.navigate(navigationUrl, {});
    }

    handleStateChange(event){

        //console.log('event',event.target.value);
        this.state = event.target.value;
        //console.log('this.state',this.state);

        if(this.state){
            this.isFindButtonDisabled = false;
        }
        else{
            this.isFindButtonDisabled = true;
        }
    }

    handleFind(){
        this.stateLabel = this.state;
        this.eligibility = this.insuranceData[this.state];
        this.showResult = true;

    }


    handleAskedQuestion(event){
        if(document.title == 'AcuraLink Driver Feedback'){
            this.navigate('/help-center-acura?dc=AcuraLinkDriverFeedback', {});
        }else if(document.title == 'HondaLink Driver Feedback'){
            this.navigate('/help-center-honda?dc=HondaLinkDriverFeedback', {});
        }
    }
}