//============================================================================
// Title:    Honda MyGarage Experience - Help FAQ Article Card
//
// Summary:  This is the Help FAQ Article Card html seen at the page of the Honda MyGarage Community
//
// Details:  Help FAQ Article Card for pages
//
// History:
// October 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getKnowledgeArticles, getProductContext } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

const BRAND_MAP = new Map();
BRAND_MAP.set('acura', { 'label': 'Acura Autos', 'category': 'AcuraAutos' });
BRAND_MAP.set('honda', { 'label': 'Honda Autos', 'category': 'HondaAutos' });
BRAND_MAP.set('powersports', { 'label': 'Honda Powersports', 'category': 'HondaPowersports' });
BRAND_MAP.set('powerequipment', { 'label': 'Honda Power Equipment', 'category': 'HondaPowerEquipment' });
BRAND_MAP.set('marine', { 'label': 'Honda Marine', 'category': 'HondaMarine' });

export default class OwnHelpFAQArticleCard extends OwnBaseElement {
    @api category;
    @api icon;
    @api title;
    @api titlecolor;
    @api actionbuttonlabel;
    @api description;
    @api maxresults;
    @track results;
    @track brand;
    @track mainCardClass = 'custom-column';
    cardBodyClass;
    @track showCard;

    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        if (document.title == 'HondaLink Features' || document.title == 'Acuralink Connected Features') {
            this.mainCardClass = 'custom-column connected-features-tab-div';
        }
        this.cardBodyClass = 'slds-card__body_inner card-body';
        if (document.title == 'HondaLink'
            || document.title == 'AcuraLink'
            || document.title == 'HondaLink Vehicle Compatibility'
            || document.title == 'AcuraLink Vehicle Compatibility Results') {
            this.cardBodyClass = 'slds-card__body_inner card-body card-height';
        }

        this.initialize();
    }

    initialize = async () => {
        this.results = await getKnowledgeArticles(this.category, this.maxresults);
        if(this.results){
            this.showCard = this.results.length > 0 ? true : false;
        }
        if (this.category == 'HondaLinkLegalTerms' || this.category == 'AcuraLinkLegalTerms') {
            if (!this.results) this.results = [];
            this.results.push({ title: 'Vehicle Data Choice', id: '1' });
            this.results.push({ title: 'Vehicle Data Privacy', id: '2' });
        }

        //console.log('This is knowledgeArticlesResult : ', this.results);
        this.context = await getProductContext('', false);
        // Alexander Dzhitenov (Wipro) - changed brand logic to be based on the page, rather than last visited product
        /* if(this.context){
            if(this.context.product.divisionId === 'A'){
                this.brand = 'honda';
            }
            if(this.context.product.divisionId === 'B'){
                this.brand = 'acura';
            }
        } */
        let url = window.location.href;
        let urlPath = url.substring(url.indexOf("/s"), url.length - 1);
        //console.log(urlPath);
        urlPath = urlPath.toLowerCase();
        if (urlPath.includes('honda')) {
            this.brand = 'honda';
        } else if (urlPath.includes('acura')) {
            this.brand = 'acura';
        } else if (urlPath.includes('powersports')) {
            this.brand = 'powersports';
        } else if (urlPath.includes('powerequipment')) {
            this.brand = 'powerequipment';
        } else if (urlPath.includes('marine')) {
            this.brand = 'marine';
        }
    };

    async handleClickAction() {
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: this.title+(this.actionbuttonlabel ? ':'+this.actionbuttonlabel :'')
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        await this.sleep(2000);
        this.navigate('/help-center-' + this.brand, {});
    }

    async handleArticleClick(event) {
        let id = event.currentTarget.dataset.id;
        let urlName = event.currentTarget.dataset.urlname;
        let articleTitle = event.currentTarget.dataset.value;
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: articleTitle
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        await this.sleep(2000);
        if (articleTitle == 'Vehicle Data Choice') {
            this.navigate('/vehicle-data-privacy-settings?page=question', {});
        } else if (articleTitle == 'Vehicle Data Privacy') {
            this.navigate('https://www.honda.com/privacy/connected-product-privacy-policy.pdf', {});
        } else {
            this.navigate('/article/' + urlName + '?' + 'brand=' + BRAND_MAP.get(this.brand).category, {});
        }
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}