import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import basePath from '@salesforce/community/basePath';
import { CurrentPageReference } from 'lightning/navigation';
import { getManagedContentByTopicsAndContentKeys, getProductContext } from 'c/ownDataUtils';
export default class OwnVehicleDataPrivacySettingsResult extends OwnBaseElement {
    @api contentId1;
    @api contentId2;
    @api contentYesAcura;
    @api contentNoAcura;
    @api contentYesHonda;
    @api contentNoHonda;
    @api contentYesAcuraMy23;
    @api contentNoAcuraMy23;
    @track content;
    @track isAcuraBrand;
    @track yesOptionContent = {};
    @track noOptionContent = {};
    currentPageReference = null;
    isResultYes = false;
    stepsImages;
    @track brand;
    @track divisionId;

    connectedCallback() {
        this.stepsImages = {
            step1: this.myGarageResource() + '/images/step1.png',
            step2: this.myGarageResource() + '/images/step2.png',
            step3: this.myGarageResource() + '/images/Step3.png',
            step4: this.myGarageResource() + '/images/Step4.png',
            step5: this.myGarageResource() + '/images/Step5.png'
        };
        this.initialize();
        if(this.urlStateParameters.brand == 'honda'){
            this.brand = 'Honda';
            this.isAcuraBrand = false;
        }
        if(this.urlStateParameters.brand == 'acura'){
            this.brand = 'Acura';
            this.isAcuraBrand = true;
        }
    }

    initialize = async () => {
        let context = await getProductContext('', false);
        //console.log(context);
        this.isAcuraBrand = context && context.product && context.product.division == 'Acura' ? true : false;
        if(this.urlStateParameters.brand == 'honda'){
            this.brand = 'Honda';
            this.isAcuraBrand = false;
        }
        if(this.urlStateParameters.brand == 'acura'){
            this.brand = 'Acura';
            this.isAcuraBrand = true;
        }
    };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }
    async setParametersBasedOnUrl() {
        this.divisionId = this.urlStateParameters.divisionid || null;
        let context = await getProductContext('', false);
        let isAcura = context && context.product && context.product.division == 'Acura' ? true : false;
        if(this.urlStateParameters.brand == 'honda'){
            isAcura = false;
        }
        if(this.urlStateParameters.brand == 'acura'){
            isAcura = true;
        }
        if(this.divisionId){
            isAcura = this.divisionId == 'B' ? true : false;
        }
        if(this.urlStateParameters){
            if(this.urlStateParameters.result == 'yes'){
                if(isAcura){
                    if(this.urlStateParameters.platform == 'MY21'){
                        this.getContent(this.contentYesAcuraMy23, this.urlStateParameters.result);
                    }else{
                        this.getContent(this.contentYesAcura, this.urlStateParameters.result);
                    }
                }else{
                    this.getContent(this.contentYesHonda, this.urlStateParameters.result);
                }
                this.isResultYes = true;
            }else if(this.urlStateParameters.result == 'no'){
                if(isAcura){
                    if(this.urlStateParameters.platform == 'MY21'){
                        this.getContent(this.contentNoAcuraMy23, this.urlStateParameters.result);
                    }else{
                        this.getContent(this.contentNoAcura, this.urlStateParameters.result);
                    }
                }else{
                    this.getContent(this.contentNoHonda, this.urlStateParameters.result);
                }
                this.isResultYes = false;
            }
        }
        
    }

    async getContent(contentId, result){
        this.content = await getManagedContentByTopicsAndContentKeys([contentId], null, null, '');
        if(result == 'yes'){
            this.yesOptionContent = {
                body : this.htmlDecode(this.content[0].body.value),
                section1Content : this.content[0].descriptionContent ? this.htmlDecode(this.content[0].descriptionContent.value).replaceAll('&lt;','<').replaceAll('&gt;', '>') : '',
                section2Content : this.content[0].description2Content ? this.htmlDecode(this.content[0].description2Content.value).replaceAll('&lt;','<').replaceAll('&gt;', '>') : '',
                section3Content : this.content[0].sectionContent ? this.htmlDecode(this.content[0].sectionContent.value).replaceAll('&lt;','<').replaceAll('&gt;', '>') : ''
            };
        }else{
            this.noOptionContent = {
                body : this.content[0].body ? this.htmlDecode(this.content[0].body.value).replaceAll('&lt;','<').replaceAll('&gt;', '>') : '',
                section1Content : this.content[0].descriptionContent ? this.htmlDecode(this.content[0].descriptionContent.value).replaceAll('&lt;','<').replaceAll('&gt;', '>') : '',
                section2Content : this.content[0].description2Content ? this.htmlDecode(this.content[0].description2Content.value).replaceAll('&lt;','<').replaceAll('&gt;', '>') : ''
            };
        }
        
    }

    async handleRedirect(){
        let context = await getProductContext('', true);
        if(context.product && context.product.divisionId == 'B'){
            this.navigate('/help-acura', {});
        }else{
            this.navigate('/help-honda', {});
        }
    }

    htmlDecode(input) {
        if(!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }
}