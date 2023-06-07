import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/MyGarage";

const CSS_SLDS_IS_ACTIVE = 'slds-is-active';
const CSS_SLDS_SHOW = 'slds-show';
const CSS_SLDS_HIDE = 'slds-hide';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
export default class OwnCollisionRepair extends OwnBaseElement {

    @api brand;
    @track collisionTabs = [];

    @api contentId;
    @api contentId1;
    @api contentId2;
    @api contentId3;
    @api contentId4;
    @api contentId5;
    @api contentId6;
    @api contentId7;
    @api contentId8;
    @api contentId9;
    @api contentId10;
    @api contentId99;
    @api contentId98;
    @api contentId97;
    @api contentId96;
    //cards for Collision Insurance 
    @api findDealer;
    @api genuineAccessories;
    @api genuineParts;
    // End
    // cards for safety Commitment  
    @api safetyCard1;
    @api safetyCard2;
    @api safetyCard3;
    @api safetyCard4;
    @api safetyCard5;
    @api safetyCard6;
    @api safetyCard7;
    @api safetyCard8;
    // End 
    @api collisionparts;
    @api collisioninsurance;  //accordian;
    @api collisionGlossary; // topic String for Collision Glossary Accordians

    @track rightArrow = this.ownerResource() + '/Icons/right_arrow.svg';
    @track tabs = [];
    @track tab;
    showTabSet = true;
    @api collisionTVTopic;

    connectedCallback() {
        //console.log("contentId", this.brand);
        //console.log('collisionTabs' + this.collisionTabs);
        this.collisionTabs.push({ 'name': `${this.brand} Certified Body Shop`, 'label': `${this.brand} Certified Body Shop` },
            { 'name': 'Repairs & Parts', 'label': 'Repairs & Parts' },
            { 'name': 'Insurance', 'label': 'Insurance' },
            { 'name': 'Collision TV', 'label': 'Collision TV' },
            { 'name': 'Safety Commitment', 'label': 'Safety Commitment' },
            { 'name': 'Collision Glossary', 'label': 'Collision Glossary' });
        this.getTabs();
    }

    getTabs() {
        const tabs = [];
        for (let i = 0; i < this.collisionTabs.length; i++) {
            if (i === 0) {
                this.tab = this.collisionTabs[i].label;
            }
            tabs.push({
                value: `${this.collisionTabs[i].name}`,
                label: `${this.collisionTabs[i].label}`,
                id: `${i}___item`,
                control: `tab-${i}`,
                content: `Tab Content ${i}`,
                ariaselected: i === 0 ? true : false,
                tabindex: i === 0 ? 0 : -1,
                itemclass: i === 0 ? 'slds-vertical-tabs__nav-item ' + CSS_SLDS_IS_ACTIVE : 'slds-vertical-tabs__nav-item',
                contentclass: i === 0 ? 'slds-p-horizontal_large slds-vertical-tabs__content ' + CSS_SLDS_SHOW : 'slds-p-horizontal_large slds-vertical-tabs__content ' + CSS_SLDS_HIDE,
            });
        }
        this.tabs = tabs;
    }

    handleActive(event) {
        this.tab = event.currentTarget.dataset.value;
        let page = { sub_section2: event.currentTarget.dataset.value };
        let message = { eventType: DATALAYER_EVENT_TYPE.LOAD, page: page };
        this.publishToChannel(message);
        this.template.querySelectorAll(".tabs li").forEach(li => {
            li.classList.remove(CSS_SLDS_IS_ACTIVE);
            li.firstChild.setAttribute('aria-selected', 'false');
            li.firstChild.setAttribute('tabindex', '-1');
            if (li.dataset.id === event.currentTarget.dataset.id) {
                li.classList.add(CSS_SLDS_IS_ACTIVE);
                li.firstChild.setAttribute('aria-selected', 'true');
                li.firstChild.setAttribute('tabindex', '0');
            }
        });
        /* this.template.querySelectorAll(".tabs .slds-vertical-tabs__content").forEach(div => {
             div.classList.remove(CSS_SLDS_SHOW);
             div.classList.add(CSS_SLDS_HIDE);
             if(div.dataset.id === event.currentTarget.dataset.id){
                 div.classList.add(CSS_SLDS_SHOW);
                 div.classList.remove(CSS_SLDS_HIDE);
             }
         });*/
    }

    handleSelect(event) {
        this.tab = event.currentTarget.dataset.value;
        let page = { sub_section2: event.currentTarget.dataset.value };
        let message = { eventType: DATALAYER_EVENT_TYPE.LOAD, page: page };
        this.publishToChannel(message);
        this.showTabSet = false;
        sessionStorage.setItem('collisionMobile', true);
    }

    backToTabs() {
        this.showTabSet = true;
    }

    handleHideTab(event) {
        //console.log('MYACCOUNT_TAB before change : ', this.collisionTabs);
        const tabs = [];
        for (let i = 0; i < this.collisionTabs.length; i++) {
            if (this.collisionTabs[i].name == event.detail) {
                continue;
            }
            if (i === 0) {
                this.tab = this.collisionTabs[i].label;
            }
            tabs.push({
                value: `${this.collisionTabs[i].name}`,
                label: `${this.collisionTabs[i].label}`,
                id: `${i}___item`,
                control: `tab-${i}`,
                content: `Tab Content ${i}`,
                ariaselected: i === 0 ? true : false,
                tabindex: i === 0 ? 0 : -1,
                itemclass: i === 0 ? 'slds-vertical-tabs__nav-item ' + CSS_SLDS_IS_ACTIVE : 'slds-vertical-tabs__nav-item',
                contentclass: i === 0 ? 'slds-p-horizontal_large slds-vertical-tabs__content ' + CSS_SLDS_SHOW : 'slds-p-horizontal_large slds-vertical-tabs__content ' + CSS_SLDS_HIDE,
            });
        }
        this.tabs = tabs;
        //collisionTabs.splice(collisionTabs.indexOf(collisionTabs.find(element => element.name == event.detail),1));
        //console.log('MYACCOUNT_TAB after change : ',collisionTabs);
    }

    get isCertifiedBodyShop() { return this.tab === `${this.brand} Certified Body Shop`; }
    get isRepairsAndParts() { return this.tab === 'Repairs & Parts'; }
    get isInsurance() { return this.tab === 'Insurance'; }
    get isCollisionTv() { return this.tab === 'Collision TV'; }
    get isSafetyCommitment() { return this.tab === 'Safety Commitment'; }
    get isCollisionGlossary() { return this.tab === 'Collision Glossary'; }
}