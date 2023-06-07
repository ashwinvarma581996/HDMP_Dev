import { LightningElement, track, api } from 'lwc';
import { getProductContext } from 'c/ownDataUtils';

const progressAutos = [
    { label: 'Get to know your Honda', value: 'Get_to_know_your_Honda', isActive: true },
    { label: 'Connect your Smartphone', value: 'Connect_your_Smartphone', isActive: false },
    { label: 'Personalize your Honda', value: 'Personalize_your_Honda', isActive: false },
    { label: 'Explore Payment Options', value: 'Explore_Payment_Options', isActive: false }
]

const progressMarine = [
    { label: 'Get to Know Your Motor', value: 'Get_to_Know_Your_Motor', isActive: true },
    { label: 'Taking Care of Your Motor', value: 'Taking_Care_of_Your_Motor', isActive: false },
    { label: 'Fueling Your Motor', value: 'Fueling_Your_Motor', isActive: false }
]

const PDP_PAGE_COLOR_CLASS = 'pdp-page-color';
const PDP_PAGE_CLOSE_ICON_CLASS = 'pdp-page-close-icon';
const PDP_PAGE_CLOSE_ICON_RIGHT_CLASS = 'slds-text-align_right';
export default class OwnQuickStartGuidePage extends LightningElement {

    @api contentId;
    @api sourceType;
    @api brandName;

    @track progressList;
    @track containerBodyName = 'Get_to_know_your_Honda';
    @track styleClass;
    @track iconStyle = PDP_PAGE_CLOSE_ICON_CLASS;
    @track productName = '';

    isFirstTime = true;

    connectedCallback() {
        this.initialize();
        if(this.sourceType == 'PDP') {
            this.styleClass = PDP_PAGE_COLOR_CLASS;
            this.iconStyle = PDP_PAGE_CLOSE_ICON_RIGHT_CLASS;
        }

        let sessionContext = JSON.parse(sessionStorage.getItem('quickStartContext'));
        //console.log('This is ownQuickStartGuidePage Division :',sessionContext.brand);
        if(sessionContext.brand == 'Honda') {
            this.progressList = progressAutos;
        } else if(sessionContext.brand  == 'Marine') {
            this.containerBodyName = 'Get_to_Know_Your_Motor';
            this.brandName = 'Marine';
            this.progressList = progressMarine;
        }
    }

    initialize = async () => {
        let origin = localStorage.getItem('origin');
        if (this.fb || origin == 'ProductChooser') {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        //console.log('this.context  :-  ', this.context);
        if(this.context && this.context.product){
            this.productName = '< ' + this.context.product.year + ' ' + this.context.product.model; 
        }
    }

    renderedCallback() {
        if (this.isFirstTime) {
            this.isFirstTime = false;
            let child = this.template.querySelector(`c-own-quick-start-guide-steps[data-value=Get_to_know_your_Honda]`);
            //console.log('test2  :-  ', child);
            child.setContainerBody(this.containerBodyName);
        }
    }

    navigateBack(){
        history.back();
    }

    handleActive(event) {
        let indicaterName = event.currentTarget.dataset.value;
        this.containerBodyName = event.currentTarget.dataset.value;
        let progress = [];
        this.progressList.forEach(element => {
            element.value == indicaterName ? element.isActive = true : element.isActive = false;
            progress.push(element);
        });
        this.progressList = progress;
    }

    handleAccourdion(event) {
        //console.log('test1  :-  ', event.currentTarget.dataset.value);
        let indicaterName = event.currentTarget.dataset.value;
        this.containerBodyName = event.currentTarget.dataset.value;
        let progress = [];
        this.progressList.forEach(element => {
            element.value == indicaterName ? element.isActive = true : element.isActive = false;
            progress.push(element);
        });
        this.progressList = progress;
        setTimeout((self) => {
            let child = this.template.querySelector(`c-own-quick-start-guide-steps[data-value=${this.containerBodyName}]`);
            //console.log('test2  :-  ', child);
            child.setContainerBody(this.containerBodyName);
        }, 1000).bind(this);
        
    }
}