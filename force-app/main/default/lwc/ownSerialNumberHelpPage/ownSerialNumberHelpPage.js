import { LightningElement,api,track,wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { getOrigin, getContext, getProductContext ,ISGUEST} from 'c/ownDataUtils';
import { CurrentPageReference } from 'lightning/navigation';

export default class OwnSerialNumberHelpPage extends OwnBaseElement {
    isguest=ISGUEST;
    activeSectionMessage = '';
    @api SerialNumberRetrievalHelp;
    @api AudioUnitSerialNumberRetrieval;
    @api RetrieveSerialNumberFromDeviceDisplay;
    @api RetrievalSerialNumberFromNavigationUnit;
    serialNumberRetrievalHelpBody;
    audioUnitSerialNumberRetrievalBody;
    retrieveSerialNumberFromDeviceDisplayBody;
    retrievalSerialNumberFromNavigationUnitBody;

    @api acuraSerialNumberRetrievalHelp;
    @api acuraAudioUnitSerialNumberRetrieval;
    @api acuraRetrieveSerialNumberFromDeviceDisplay;
    @api acuraRetrievalSerialNumberFromNavigationUnit;
    acuraSerialNumberRetrievalHelpBody;
    acuraAudioUnitSerialNumberRetrievalBody;
    acuraRetrieveSerialNumberFromDeviceDisplayBody;
    acuraRetrievalSerialNumberFromNavigationUnitBody;

    isHonda;
    divisionName;
    @track breadcrumb = {label: '', url: ''};
    currentPageReference = null;
    urlStateParameters = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        //console.log('currentPageReference', currentPageReference);
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            //console.log('this.urlStateParameters', this.urlStateParameters);
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.fb = this.urlStateParameters.fb || null;
        this.brand = this.urlStateParameters.brand || null;
    }

    connectedCallback(){
        this.initialize();
        this.getSerialNumberRetrievalHelp(this.SerialNumberRetrievalHelp);
        this.getAudioUnitSerialNumberRetrieval(this.AudioUnitSerialNumberRetrieval);
        this.getRetrieveSerialNumberFromDeviceDisplay(this.RetrieveSerialNumberFromDeviceDisplay);
        this.getRetrievalSerialNumberFromNavigationUnit(this.RetrievalSerialNumberFromNavigationUnit);

        this.getAcuraSerialNumberRetrievalHelp(this.acuraSerialNumberRetrievalHelp);
        this.getAcuraAudioUnitSerialNumberRetrieval(this.acuraAudioUnitSerialNumberRetrieval);
        this.getAcuraRetrieveSerialNumberFromDeviceDisplay(this.acuraRetrieveSerialNumberFromDeviceDisplay);
        this.getAcuraRetrievalSerialNumberFromNavigationUnit(this.acuraRetrievalSerialNumberFromNavigationUnit);
    }
    
    initialize = async () => {
        this.fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('fromProductChooser==>>', this.fromProductChooser);
        let garageProducts = JSON.parse(localStorage.getItem('garage'));
        //console.log('garageProducts==>>', garageProducts);
        if (this.fromProductChooser || ISGUEST) {
            this.context = await getProductContext('', true);
            //console.log('context==>>', JSON.stringify(this.context));
        } else {
            this.context = await getContext('');
            //console.log('context=else=>>', JSON.stringify(this.context));
        }
        this.divisionName = this.fromProductChooser ? garageProducts.products[0].division : this.context.product.division;
        //console.log('divisionName==>>'+this.divisionName);
        if(this.brand != null){
            if (this.brand.includes('Acura')) {
                this.isHonda =false;
            } else {
                this.isHonda=true;
            }
        }else{
            this.isHonda = this.divisionName ==='Honda' ? true :false;
        }
        
        //console.log('isHonda==>>'+this.isHonda);
        this.breadcrumb.label = '< Back';
        this.breadcrumb.url = '/radio-nav-code';
    }
    handleBreadcrumb(){
        history.back();
    }

    handleToggleSection(event) {
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
    }

    async getSerialNumberRetrievalHelp(SerialNumberRetrievalHelp){
        let content = await getManagedContentByTopicsAndContentKeys([SerialNumberRetrievalHelp], this.topics, this.pageSize, this.managedContentType);
        if(content){
            this.serialNumberRetrievalHelpBody = {
                body : content[0].body ? this.htmlDecode(content[0].body.value) : '',
            }
        }
    }
    async getAudioUnitSerialNumberRetrieval(AudioUnitSerialNumberRetrieval){
        let content = await getManagedContentByTopicsAndContentKeys([AudioUnitSerialNumberRetrieval], this.topics, this.pageSize, this.managedContentType);
        if(content){
            this.audioUnitSerialNumberRetrievalBody = {
                body : content[0].body ? this.htmlDecode(content[0].body.value) : '',
            }
        }
    }
    async getRetrieveSerialNumberFromDeviceDisplay(RetrieveSerialNumberFromDeviceDisplay){
        let content = await getManagedContentByTopicsAndContentKeys([RetrieveSerialNumberFromDeviceDisplay], this.topics, this.pageSize, this.managedContentType);
        if(content){
            this.retrieveSerialNumberFromDeviceDisplayBody = {
                body : content[0].body ? this.htmlDecode(content[0].body.value) : '',
            }
        }
    }
    async getRetrievalSerialNumberFromNavigationUnit(RetrievalSerialNumberFromNavigationUnit){
        let content = await getManagedContentByTopicsAndContentKeys([RetrievalSerialNumberFromNavigationUnit], this.topics, this.pageSize, this.managedContentType);
        if(content){
            this.retrievalSerialNumberFromNavigationUnitBody = {
                body : content[0].body ? this.htmlDecode(content[0].body.value) : '',
            }
        }
        //this.retrievalSerialNumberFromNavigationUnitBody =this.htmlDecode(this.retrievalSerialNumberFromNavigationUnitBody.body);
    }

    async getAcuraSerialNumberRetrievalHelp(acuraSerialNumberRetrievalHelp){
        let content = await getManagedContentByTopicsAndContentKeys([acuraSerialNumberRetrievalHelp], this.topics, this.pageSize, this.managedContentType);
        if(content){
            this.acuraSerialNumberRetrievalHelpBody = {
                body : content[0].body ? this.htmlDecode(content[0].body.value) : '',
            }
        }
    }
    async getAcuraAudioUnitSerialNumberRetrieval(acuraAudioUnitSerialNumberRetrieval){
        let content = await getManagedContentByTopicsAndContentKeys([acuraAudioUnitSerialNumberRetrieval], this.topics, this.pageSize, this.managedContentType);
        if(content){
            this.acuraAudioUnitSerialNumberRetrievalBody = {
                body : content[0].body ? this.htmlDecode(content[0].body.value) : '',
            }
        }
    }
    async getAcuraRetrieveSerialNumberFromDeviceDisplay(acuraRetrieveSerialNumberFromDeviceDisplay){
        let content = await getManagedContentByTopicsAndContentKeys([acuraRetrieveSerialNumberFromDeviceDisplay], this.topics, this.pageSize, this.managedContentType);
        if(content){
            this.acuraRetrieveSerialNumberFromDeviceDisplayBody = {
                body : content[0].body ? this.htmlDecode(content[0].body.value) : '',
            }
        }
    }
    async getAcuraRetrievalSerialNumberFromNavigationUnit(acuraRetrievalSerialNumberFromNavigationUnit){
        let content = await getManagedContentByTopicsAndContentKeys([acuraRetrievalSerialNumberFromNavigationUnit], this.topics, this.pageSize, this.managedContentType);
        if(content){
            this.acuraRetrievalSerialNumberFromNavigationUnitBody = {
                body : content[0].body ? this.htmlDecode(content[0].body.value) : '',
            }
        }
    }
}