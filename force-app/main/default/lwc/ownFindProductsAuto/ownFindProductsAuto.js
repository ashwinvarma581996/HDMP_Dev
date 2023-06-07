import { api, LightningElement, track, wire } from 'lwc';
import {OwnBaseElement} from 'c/ownBaseElement';
import { viewProduct, setOrigin, getOrigin } from 'c/ownDataUtils';
//import getDivisionHonda from '@salesforce/apex/FindProductsController'
import getYears from '@salesforce/apex/FindProductController.getYears';
import getModels from '@salesforce/apex/FindProductController.getModels';
import getTrims from '@salesforce/apex/FindProductController.getTrims';
//import getProductChooserValues from '@salesforce/apex/FindProductController.getProductChooserValues'
//import getValidVINHonda from '@salesforce/apex/FindProductsController.getValidVINHonda';

// Commented out - methods currently do not exist
import getProductByYearModel from '@salesforce/apex/OwnGarageController.getProductByYearModel';
import getProductByVIN from '@salesforce/apex/OwnGarageController.getProductByVIN';

import commonResources from "@salesforce/resourceUrl/Owners";

import {ISGUEST} from 'c/ownDataUtils';

import {CurrentPageReference} from 'lightning/navigation';


const MODEL = 'model';
const VIN = 'vin';
const FIND_BRAND_BUTTON_ACTIVE = 'find-brand-button-active';
const FIND_BRAND_BUTTON_DISABLED = 'find-brand-button-disabled';
const FIND_BRAND_SECTION_BUTTON_ACTIVE = 'find-brand-section-button-active';
const FIND_BRAND_SECTION_BUTTON_DISABLED = 'find-brand-section-button-disabled';

const VIN_ERROR_TEXT = "Incorrect VIN entered.";

const PREFERRED_VIN_IMAGE_TYPE = "IMGMIDSIZE";


export default class OwnFindProductsAuto extends OwnBaseElement {

    @api division = "Honda"; 
    @track divisionName = 'Honda';
    @track divisionId = 'A';

    @track isGuest = ISGUEST;

    @track showModelSection = true;
    @track showVinSection = true;
    @track modelFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
    @track vinFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
    @track modelSectionButtonClass = FIND_BRAND_SECTION_BUTTON_ACTIVE;
    @track vinSectionButtonClass = FIND_BRAND_SECTION_BUTTON_DISABLED;
    @track years;
    @track year;
    @track models;
    @track model;
    @track modelLabel;
    @track trims;
    @track trim;
    @track modelId;
    @track vin;
    @track incorrectVINLength=false;
    @track correctVINLength=false;
    @track modelSelectionDisabled=true;
    @track trimSelectionDisabled=true;
    @track displayVINError=false;
    @track vinInputVal = "";

    vinErrorText = VIN_ERROR_TEXT;

    vinHelpIcon = commonResources + '/Icons/garage_questionmark.png';

    @wire(CurrentPageReference) pageref;

    connectedCallback(){

        //console.log(this.divisionName);
        //console.log(this.divisionId);

       // getProductChooserValues().then(result=>{}).catch(error=>{});

        this.divisionName = this.division;

        if (this.divisionName === "Honda")
            this.divisionId = "A";
        else if (this.divisionName === "Acura")
            this.divisionId = "B";
        else
            this.divisionId = "A";
    }
    
    @wire(getYears, { divisionId : '$divisionId'})
    wiredGetYearsHonda({ error, data }){
        if (data) {
            this.years = data;
        } else if (error) {
            this.showToast_error(error);
            this.years = undefined;
            this.year = undefined;
        }
    }

    @wire(getModels, { divisionId : '$divisionId', year : '$year'})
    wiredGetModelsHonda({ error, data }){
        if (data) {
            this.models = data;
        } else if (error) {
            this.showToast_error(error);
            this.models = undefined;
            this.model = undefined;
        }
    }

    @wire(getTrims, { divisionId : '$divisionId', year : '$year', modelName : '$model'})
    wiredGetTrimsHonda({ error, data }){
        if (data) {
            this.trims = data;
        } else if (error) {
            this.showToast_error(error);
            this.trims = undefined;
            this.trim = undefined;
            this.modelId = undefined;
        }
    }

    handleYearChange(event){
        // Handles onchange event for Year input field
        this.year = event.detail.value;
        this.model = undefined;
        this.trim = undefined;
        this.modelId = undefined;
        this.vin = undefined;
        this.vinInputVal = "";
        this.clearVINIcons();
        this.handleFindAndSection(this.year, this.model, this. trim, this.vin, MODEL);
    }

    handleModelChange(event){
        // Handles onchange event for Model input field
        this.model = event.detail.value;
        this.trim = undefined;
        this.modelId = undefined;
        this.vin = undefined;
        this.vinInputVal = "";
        this.clearVINIcons();
        this.handleFindAndSection(this.year, this.model, this.trim, this.vin, MODEL);
    }

    handleTrimChange(event){
        // Handles onchange event for Trim input field
        //console.log('test event1' ,event);
        //console.log('test event2' ,event.detail.value);
        this.modelId = event.detail.value;
        this.trims.forEach(element => { 
            if(element.value === this.modelId){ 
                this.trim = element.label;
            }
        });

        this.vin = undefined;
        this.vinInputVal = "";
        this.clearVINIcons();
        this.handleFindAndSection(this.year, this.model, this.trim, this.vin, MODEL);
    }
    
    handleVINChange(event){
        // Handles onchange event for VIN input field

        // VIN Validation:
        // character length validation: Once 17 characters entered, display green check
        // < 17 characters & find pressed: display error message + cross
        // 17 characters, but is not valid VIN: server-side validation against database
        this.vin = event.target.value;
        this.vinInputVal = this.vin; // Note: the input field will display 'undefined' instead of placeholder text if its value is set to 'undefined'
        this.year = undefined;
        this.model = undefined;
        this.trim = undefined;
        this.modelId = undefined;
        if (this.vin && this.vin.length === 17){
            this.correctVINLength = true;
            this.incorrectVINLength = false;
            this.displayVINError = false;
            this.handleFindAndSection(this.year, this.model, this.trim, this.vin, VIN);
        }else{
            this.correctVINLength = false;
            this.handleFindAndSection(this.year, this.model, this.trim, undefined, VIN);
        }
    }

    handleVINHelp(){
        // Runs when VIN help button is pressed
/*         console.log('NAVIGATE');
        let origin = 'ProductChooser';
        setOrigin('ProductChooser'); */
        localStorage.setItem('VINHelpBreadcrumb', 'FindProduct' + this.divisionName);
        //console.log(this.divisionName);
        this.navigate('/vin-help/?division=' + this.divisionName, {});
        //articleId: 'ka00200000018WqAAI', brand: 'Honda', year: this.year, modelName: this.model, trim: this.trim
    }

    clearVINIcons(){
        this.correctVINLength = false;
        this.incorrectVINLength = false;
        this.displayVINError = false;
    }

    handleSectionClick(event){
        // Controls Year/Model/Trim and VIN sections in the mobile version of the page
        const section = event.currentTarget.dataset.section;
        this.year = undefined;
        this.model = undefined;
        this.vin = undefined;
        this.trim = undefined;
        this.modelId = undefined;
        this.modelSelectionDisabled = true;
        this.trimSelectionDisabled = true;
        this.clearVINIcons();

        if (section === MODEL){
            this.showModelSection = true;
            this.showVinSection = false;
        }else if (section === VIN){
            this.showModelSection = false;
            this.showVinSection = true;
        }

        this.handleFindAndSection(this.year, this.model, this.trim, this.vin, VIN);
    }

    handleFindAndSection(year, model, trim, vin, section){
        // 
        // Updates 'Find' button classes according to whether or not all required fields have been filled out
        if (year && model){
            this.modelSelectionDisabled = false;
            this.trimSelectionDisabled = false;
        }
        else if (year){
            this.modelSelectionDisabled = false;
            this.trimSelectionDisabled = true;
        }
        else{
            this.modelSelectionDisabled = true;
            this.trimSelectionDisabled = true;
        }

        if (year && model && trim){
            this.modelFindButtonClass = FIND_BRAND_BUTTON_ACTIVE;
        }
        else{
            this.modelFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
        }
        if (vin){
            this.vinFindButtonClass = FIND_BRAND_BUTTON_ACTIVE;
        }
        else{
            this.vinFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
        }
        if (this.showModelSection){
            this.modelSectionButtonClass = FIND_BRAND_SECTION_BUTTON_ACTIVE;
        }
        else{
            this.modelSectionButtonClass = FIND_BRAND_SECTION_BUTTON_DISABLED;
        }
        if (this.showVinSection){
            this.vinSectionButtonClass = FIND_BRAND_SECTION_BUTTON_ACTIVE;
        }
        else{
            this.vinSectionButtonClass = FIND_BRAND_SECTION_BUTTON_DISABLED;
        }
    }

    resetGarage(){
        localStorage.removeItem('garage');
    }

    handleFindByYearModel(event){
        //console.log('divisionId:' + this.divisionId + ' ' + this.modelId);
        var test = getProductByYearModel({divisionId : this.divisionId, modelId : this.modelId});

        getProductByYearModel({divisionId : this.divisionId, modelId : this.modelId})
        .then(result => {
            //console.log('test result:' , result);

            let divisionLogo;
            if (this.divisionName === 'Honda'){
                divisionLogo = '/resource/MyGarage/images/thumbnail_honda.png'; //'/cms/delivery/media/MCYYDI357BSZDS5FXGPSPN5AH4AQ';
            }
            else if (this.divisionName === 'Acura'){
                divisionLogo = '/resource/MyGarage/images/thumbnail_acura.png'; //'/cms/delivery/media/MCZYP2ZIWGIJCNTB5TO4LRLE4TFY';
            }
            else if (this.divisionName === 'Motorcycle/Powersports'){
                divisionLogo = '/resource/MyGarage/images/thumbnail_powersports.png'; //'/cms/delivery/media/MCQJUU7MKCERCYBL77NG7CTXBDQU';
            }
            else if (this.divisionName === 'Powerequipment'){
                divisionLogo = '/resource/MyGarage/images/thumbnail_powerequipment.png'; //'/cms/delivery/media/MCMFYJERXT4ZD6XDGL6HZ7GGNZ4U';
            }
            else if (this.divisionName === 'Marine'){
                divisionLogo = '/resource/MyGarage/images/thumbnail_marine.png'; //'/cms/delivery/media/MCRIYJTYRG7FB23N4324ABJESWL4';
            }

            let prod = result[0];
            let prodct = {    'divisionId': this.divisionId, 'division': this.divisionName,
                                'year': prod.Year__c.toString(), 'model': prod.Model__c, 'trim': prod.Trim__c,
                                'modelId' : this.modelId,
                                'vin': '-',
                                //'nickname': prod.Year__c + ' ' + prod.Model__c + ' ' + prod.Trim__c,
                                'image': divisionLogo,
                               'exteriorColor' : prod.Exterior_Color__c ? prod.Exterior_Color__c : '-'
                        };
            //console.log('prod1  :-  ', prodct);
            
            let origin = 'ProductChooser';
           localStorage.setItem('origin', origin);
            setOrigin('ProductChooser');
            
            //console.log(this.isGuest);
            if (!this.isGuest){
                this.resetGarage();
            }

            viewProduct(prodct);
        })
        .catch(error => {
            //console.log('error :: ',error);
        });

    }

    handleFindByVIN(event){
        //console.log('event: ',event);
        if (this.vin.length != 17){
            //console.log('IF:');
            this.correctVINLength = false;
            this.incorrectVINLength = true;
            this.displayVINError = true;
        }
        else{
            //console.log('Else:');

            getProductByVIN({divisionId : this.divisionId, vin : this.vin})
                .then(result => {
                    //console.log('Apex callback');
                    //console.log('result: ', result);
                    // redirect using URL obtained
                    let prod = JSON.parse(result);

                    if(!prod.isError){
                        this.correctVINLength = true;
                        this.incorrectVINLength = false;
                        this.displayVINError = false;
                        //console.log('result ModelDetail: ', result['modelDetail']);
                        //console.log(prod.modelDetail);
                        //console.log(JSON.stringify(prod.modelDetail));
    
                        const prodct = {'divisionId': this.divisionId, 'division': this.divisionName,
                                        'year': prod.modelDetail.year ? prod.modelDetail.year : '',
                                        'model': prod.modelDetail.modelGroupName ? prod.modelDetail.modelGroupName : 
                                                (prod.modelDetail.modelName ? prod.modelDetail.modelName : '-'),
                                        'trim': prod.modelDetail.trim ? prod.modelDetail.trim : '',
                                        'modelId' : prod.modelDetail.modelId ? prod.modelDetail.modelId : '',
                                        'make' : prod.modelDetail.make ? prod.modelDetail.make : '-',
                                        'vin' : this.vin,
                                        'color' : prod.modelDetail.color ? prod.modelDetail.color : '-',
                                        'exteriorColor' : prod.modelDetail.color.name ? prod.modelDetail.color.name : '-',
                                        'image' : this.selectImageFromVINAPI(prod.modelDetail.assets),
                                        'telematicsFlag' : prod.modelDetail.telematicsFlag ? prod.modelDetail.telematicsFlag : 'N', //DOE 2701 Ravindra Ravindra(wipro)
                                        'enrollment' : prod.modelDetail.enrollment ? prod.modelDetail.enrollment : 'N',
                                        };
                        //console.log('prod1  :-  ', JSON.stringify(prodct));

                        if (!this.isGuest){
                            this.resetGarage();
                        }
                        let origin = 'ProductChooser';
                        localStorage.setItem('origin', origin);
                        setOrigin('ProductChooser');            
                        viewProduct(prodct);
                    }
                    else{
                        this.correctVINLength = false;
                        this.incorrectVINLength = true;
                        this.displayVINError = true;
                    }
                })
                .catch(error => {
                    //console.log('getProductByVIN: error');
                    //console.log('error: ',error);
                });
        }
    }

    selectImageFromVINAPI(vinImageSet){
        // Pass 'assets' from VIN API result to select the correct image
        // Find an 'IMGMIDSIZE' image if possible; if not, use the first available image
        let selectedImage='';

        if (vinImageSet){
            vinImageSet.find(element => {
                if (element.assetType === PREFERRED_VIN_IMAGE_TYPE){
                    selectedImage = element.imagePath;
                }
            });
            if (!selectedImage){
                vinImageSet.find(element => {
                    if (element.imagePath){
                        selectedImage = element.imagePath;
                    }
                })
            }
        }

        return selectedImage;
    }
}