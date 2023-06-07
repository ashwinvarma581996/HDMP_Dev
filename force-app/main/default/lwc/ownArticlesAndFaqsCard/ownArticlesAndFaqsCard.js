//======================================================================================================
// Title: 01 - "Articles And Faqs" Card for Honda Owners Community
//
// Summary: This Lightning Card enables the following Designer Properties:
//          a) Brand:  {Default | Honda Auto | Acura Auto | Powersports | Power Equipment | Marine}
//          b) Title: Any String
//          c) Icon: ex: (today) utility:connected_apps. (future) icon from Static Resources utility:connected_apps
//          d) Text Color: {Black | Honda Red}
//
//  Use:  1) drag this card (e.g.: "ownArticleAndFaqs") onto a Community Page
//        2) set the Designer Properties as appropriate
//
//Modification Log :
// Jul 03, 2021 Harshavardhan initial coding / doc
//======================================================================================================
/* eslint-disable no-unused-vars */

import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getPopularKnowledgeArticles } from 'c/ownDataUtils';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

const BRAND_MAP = new Map();
BRAND_MAP.set('acura', { 'label': 'Acura Autos', 'category': 'AcuraAutos', 'url': '/help-center-acura' });
BRAND_MAP.set('honda', { 'label': 'Honda Autos', 'category': 'HondaAutos', 'url': '/help-center-honda' });
BRAND_MAP.set('powersports', { 'label': 'Honda Powersports', 'category': 'HondaPowersports', 'url': '/help-center-powersports' });
BRAND_MAP.set('powerequipment', { 'label': 'Honda Power Equipment', 'category': 'HondaPowerEquipment', 'url': '/help-center-powerequipment' });
BRAND_MAP.set('marine', { 'label': 'Honda Marine', 'category': 'HondaMarine', 'url': '/help-center-marine' });

export default class OwnArticlesAndFaqsCard extends OwnBaseElement {
    @track localIcon = 'utility:question_mark';
    @api contentId;
    @api brand;
    @api icon;
    @api title;
    @api titlecolor;
    @api headerlink;
    @api actionbuttonlabel;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track cmsResults;
    @track body;

    @track maxResults = 4;
    @track results;
    @track category;

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.brand = this.brand.toLowerCase();
        this.category = BRAND_MAP.get(this.brand).category;
        this.initialize();
    }

    initialize = async () => {
        this.results = await getPopularKnowledgeArticles(this.category, this.maxResults);
        this.contentKeys.push(this.contentId);
        this.cmsResults = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.cmsResults.forEach(r => {
            this.title = !this.title ? this.htmlDecode(r.title.value) : this.title;
            this.body = r.body ? this.htmlDecode(r.body.value).trim() : '';
        });
    };

    handleArticleClick(event) {
        let id = event.currentTarget.dataset.id;
        let urlName = event.currentTarget.dataset.urlname;
        this.navigate('/article/' + urlName + '?' + 'brand=' + BRAND_MAP.get(this.brand).category, {});
    }

    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : this.titlecolor === 'Black' ? 'slds-text-heading_small title black' : 'slds-text-heading_small title';
    }

    get headerClass() {
        return this.titlecolor === 'Honda Red' ? 'card-styles card-styles-red' : this.titlecolor === 'Black' ? 'card-styles card-styles-black' : 'card-styles';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    async handleBrowseClick() {
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: this.title + (this.actionbuttonlabel ? ':' + this.actionbuttonlabel : '')
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        await this.sleep(2000);
        this.navigate(BRAND_MAP.get(this.brand).url, {});
    }

    handleBrowseAllClick() {
        this.navigate(BRAND_MAP.get(this.brand).url, {});
    }

    async handleClickHeader() {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        await this.sleep(2000);
        this.navigate(this.headerlink, {});
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}