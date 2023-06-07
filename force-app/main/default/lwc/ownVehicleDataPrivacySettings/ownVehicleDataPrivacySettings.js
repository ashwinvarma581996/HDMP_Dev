import { api, wire, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import basePath from '@salesforce/community/basePath';
import { CurrentPageReference } from 'lightning/navigation';
import { getManagedContentByTopicsAndContentKeys, getProductContext } from 'c/ownDataUtils';
export default class OwnVehicleDataPrivacySettings extends OwnBaseElement {
    @api contentId1;
    @api contentId2;
    @api questionContentIdAcuraMy23;
    @api resultContentIdAcura;
    @api resultContentIdHonda;
    @api questionContentIdAcura;
    @api questionContentIdHonda;
    @track questionPageContent;
    @track resultPageContent;
    @track brand;
    @track divisionId;

    connectedCallback(){
        if(this.urlStateParameters.brand == 'honda'){
            this.brand = 'Honda';
        }
        if(this.urlStateParameters.brand == 'acura'){
            this.brand = 'Acura';
        }
    }

    @wire(CurrentPageReference)
    getPageParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.displayViewBasedOnUrl();
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.divisionId = this.urlStateParameters.divisionid || null;
    }

    async displayViewBasedOnUrl() {
        let context;
        let origin = localStorage.getItem('origin');
        if (this.urlStateParameters.fb == 'true' || origin == 'ProductChooser') {
            context = await getProductContext('', true);
        } else {
            context = await getProductContext('', false);
        }
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
            if(this.urlStateParameters.page == 'question'){
                if(isAcura){
                    if(this.urlStateParameters.platform == 'MY21'){
                        this.initialize(this.questionContentIdAcuraMy23, this.urlStateParameters.page);
                    }else{
                        this.initialize(this.questionContentIdAcura, this.urlStateParameters.page);
                    }
                }else{
                    this.initialize(this.questionContentIdHonda, this.urlStateParameters.page);
                }
            }else if(this.urlStateParameters.page == 'result'){
                if(isAcura)
                    this.initialize(this.resultContentIdAcura, this.urlStateParameters.page);
                else
                    this.initialize(this.resultContentIdHonda, this.urlStateParameters.page);
            }
        }     
    }

    initialize = async (contentId, page) => {
        this.cmsResults = await getManagedContentByTopicsAndContentKeys([contentId], null, null, '');
        if(page == 'question'){
            this.questionPageContent = {
                image : this.htmlDecode(this.cmsResults[0].body.value),
                title : this.htmlDecode(this.cmsResults[0].subTitle.value),
                subTitle : this.htmlDecode(this.cmsResults[0].descriptionLabel.value)
            };
        }else if(page == 'result'){
            this.resultPageContent = {
                titleUS : this.htmlDecode(this.cmsResults[0].subTitle.value),
                titleCanada : this.htmlDecode(this.cmsResults[0].descriptionLabel.value),
                content : this.htmlDecode(this.cmsResults[0].body.value),
                phone : this.htmlDecode(this.cmsResults[0].phoneNumber.value),
                phone_href : 'tel:' + this.htmlDecode(this.cmsResults[0].phoneNumber.value),
                phoneLabel : this.htmlDecode(this.cmsResults[0].phoneLabel.value),
                learnMoreText : this.htmlDecode(this.cmsResults[0].sectionLabel.value),
                learnMoreLink : this.removeTags(this.htmlDecode(this.cmsResults[0].sectionContent.value)),
                learnMoreTextLine : this.removeTags(this.htmlDecode(this.cmsResults[0].descriptionContent.value)),
                learnMoreTextLink : this.htmlDecode(this.cmsResults[0].description2Label.value),
                pdfLink : this.cmsResults[0].phone2Label.value
            };
        }
    };

    htmlDecode = (input) => {
        if(!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }

    removeTags = (text) => {
        return text.replace( /(<([^>]+)>)/ig, '');
    }
    
    handleClick(event){
        let fromFb = this.urlStateParameters.from ? '&fb=true' : '';
        let platform = this.urlStateParameters.platform ? '&platform=' + this.urlStateParameters.platform : '';
        let brand = this.urlStateParameters.brand ? '&brand=' + this.urlStateParameters.brand : '';
        let divisionId = this.divisionId ? '&divisionid=' + this.divisionId : '';
        this.navigate('/vehicle-data-privacy-settings-result?result=' + event.target.value + fromFb + platform + brand + divisionId, {});
        let pageValue = this.urlStateParameters.from ? 'Vehicle Data Privacy : Find Vehicle' : 'Vehicle Data Privacy';
        sessionStorage.setItem('frompage',pageValue);
    }
    handleClickHere(event){
        let pageValue = this.urlStateParameters.from ? 'Vehicle Data Privacy : Find Vehicle' : 'Vehicle Data Privacy';
        let divisionId = this.divisionId ? '&divisionid=' + this.divisionId : '';
        sessionStorage.setItem('frompage',pageValue);
        this.navigate('/vehicle-data-privacy-settings-result?result=' +event.target.value + divisionId, {});
    }
}