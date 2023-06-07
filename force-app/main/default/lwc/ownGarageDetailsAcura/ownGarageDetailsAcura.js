//============================================================================
// Title:    Honda Owners Experience - Footer
//
// Summary:  Owners Garage Find - Honda Auto Body logic of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the own garage find honda body component for all community pages.
//
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api,LightningElement,track } from 'lwc';
import { getContext } from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';
import { ISGUEST , getOrigin} from 'c/ownDataUtils';
import { getCMSContent } from 'c/ownCMSContent';
export default class OwnGarageDetailsAcura extends OwnBaseElement {
    @track context;
    @track viewMode = true;
    @track editMode = false;
    @track isGuest = ISGUEST;
    
    @api roadsideAssistanceCardTopic;
    @api browseFAQsContentId;
    @api hondaHelpCenterContentId;
    
    @track roadsideAssistanceData = {
        "title": "",
        "iconImage": this.ownerResource() + '/Icons/chat.png',
        "titlecolor": "Honda Red",
        "mainContent": "",
        "contactNumbers": [],
        "findOutMore": false,
        "showCard":false
    };

    @track browseFAQsData = {
        'contentId' : '',
        "title": "BROWSE FAQ's",
        "icon": 'chat.png',
        "Brand" : 'Acura',
        "titlecolor": "Honda Red",
        "headerLink" : '/help-center-acura',
    };

    @track hondaHelpCenterData = {
        'contentId' : this.hondaHelpCenterContentId,
        "title": "Honda Help Center",
        "iconImage": 'chat.png',
        "titlecolor": "Honda Red",
        "headerLink" : '/help-center',
    };

    initialize = async () => {
        this.context = await getContext('');
        //console.log('$$CONTEXT-ACURA: ',JSON.parse(JSON.stringify(this.context)));
    };

    async connectedCallback() {
        await this.initialize();
        this.subscribeToChannel((message) => {
            this.handleMessage(message);
        });
        let fromProductChooser = getOrigin() === 'ProductChooser';
        //console.log('$$fromProductChooser: ',fromProductChooser);
        if(this.isGuest){
            if(parseInt(this.context.product.year) >= 2015){
                this.getContents(await getCMSContent([this.roadsideAssistanceCardTopic]));
            }else{
                this.roadsideAssistanceData.showCard = false;
            }
        }else{
            if(fromProductChooser){
                let prdct = JSON.parse(localStorage.getItem('garage'));
                //console.log('Garage -------',prdct);
                if(parseInt(prdct.products[0].year) >= 2015){
                    this.getContents(await getCMSContent([this.roadsideAssistanceCardTopic]));
                }else{
                    this.roadsideAssistanceData.showCard = false; 
                }
            }else{
                if(parseInt(this.context.product.year) >= 2015){
                    this.getContents(await getCMSContent([this.roadsideAssistanceCardTopic]));
                }else{
                    this.roadsideAssistanceData.showCard = false;
                }
            }
        }
    }
    getContents(content) {
        let contents = JSON.parse(JSON.stringify(content[0].contentNodes));
        //console.log('content roadside : ',contents);
        this.roadsideAssistanceData.showCard = true;
        this.roadsideAssistanceData.title = contents.title.value.toUpperCase();
        if (contents.body) this.roadsideAssistanceData.mainContent = this.htmlDecode(contents.body.value);
        if (contents.phone_number) {
            this.roadsideAssistanceData.findOutMore = true;
            this.roadsideAssistanceData.contactNumbers.push({
                "phoneHeading": contents.phone_label.value,
                "phoneNumber": contents.phone_number.value
            });
        }
        if (contents.phone2_number) {
            this.roadsideAssistanceData.contactNumbers.push({
                "phoneHeading": contents.phone2_label.value,
                "phoneNumber": contents.phone2_number.value
            });
        }
        if (contents.phone3_number) {
            this.roadsideAssistanceData.contactNumbers.push({
                "phoneHeading": contents.phone3_label.value,
                "phoneNumber": contents.phone3_number.value
            });
        }
        //console.log(this.roadsideAssistanceData);
    }
    handleMessage(message) {
        if (message.type === 'product') {
            this.context.product = message.result.product;
            this.setViewMode();
        }
    }

    handleMode(event) {
        if (event.detail.mode === 'edit') {
            this.setEditMode();
        }
        if (event.detail.mode === 'view') {
            this.setViewMode();
        }
    }

    setViewMode() {
        this.editMode = false;
        this.viewMode = true;
    }

    setEditMode() {
        this.editMode = true;
        this.viewMode = false;
    }
    htmlDecode(input) {
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
}