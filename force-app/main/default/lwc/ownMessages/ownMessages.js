import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/MyGarage";
import getRecallsByProductIdentifier from '@salesforce/apex/OwnAPIController.getRecallsByProductIdentifier';
import getAllMessages from '@salesforce/apex/ownMessageController.getAllMessages';
import getAllRecalls from '@salesforce/apex/ownMessageController.getAllRecalls';
import getRecallsByModel from '@salesforce/apex/OwnAPIController.getRecallsByModel';
import { getGarage, getMyProducts, ISGUEST } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

const CSS_SLDS_IS_ACTIVE = 'slds-is-active';
const CSS_SLDS_SHOW = 'slds-show';
const CSS_SLDS_HIDE = 'slds-hide';

const MYMESSAGES_TABS_LOGGEDIN = [{ 'name': 'All Messages', 'label': 'All Messages' },
{ 'name': 'Recalls', 'label': 'Recalls' },
{ 'name': 'Product Alerts', 'label': 'Product Alerts' },
{ 'name': 'Safety Alerts', 'label': 'Safety Alerts' },
{ 'name': 'Finance & Account', 'label': 'Finance & Account' },
{ 'name': 'News & Offers', 'label': 'News & Offers' }];

const MYMESSAGES_TABS_GUEST = [{ 'name': 'All Messages', 'label': 'All Messages' },
{ 'name': 'Product Alerts', 'label': 'Product Alerts' },
{ 'name': 'Safety Alerts', 'label': 'Safety Alerts' },
{ 'name': 'Finance & Account', 'label': 'Finance & Account' },
{ 'name': 'News & Offers', 'label': 'News & Offers' }];

const MYMESSAGES_TABS = ISGUEST ? MYMESSAGES_TABS_GUEST : MYMESSAGES_TABS_LOGGEDIN;

const MESSAGE_TAB_MAP = new Map();
MESSAGE_TAB_MAP.set('Recall', 'Recalls');
MESSAGE_TAB_MAP.set('Product Alert', 'Product Alerts');
MESSAGE_TAB_MAP.set('Safety Alert', 'Safety Alerts');
//MESSAGE_TAB_MAP.set('Safety Alert', 'Finance & Account');
//MESSAGE_TAB_MAP.set('Safety Alert', 'News & Offers');


export default class OwnMessages extends OwnBaseElement {

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
    // cards for Collision Insurance 
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

    // @track rightArrow = this.ownerResource() + '/Icons/right_arrow.svg';

    @track isGuest = ISGUEST;

    @track tabs = [];
    @track tab;
    showTabSet = true;
    @track messages = [];
    @track allMessages = [];
    @track recall = {};
    @track recalls = [];
    @track productAlerts = [];
    @track safetyAlerts = [];
    @track trial = [];
    @track finance = [];
    @track news = [];
    @track recallData = [];
    @track messageDetail = false;
    @track sortValue;
    @track messageRead;

    //Imtiyaz - RECALLS Start
    @api contentMoreInfoA;
    @api contentMoreInfoH;
    @api contentMoreInfoP;
    //Imtiyaz - RECALLS End

    get options() {
        return [
            { label: 'Unread First', value: 'unreadFirst' },
            { label: 'Oldest First', value: 'oldestFirst' },
            { label: 'Newest First', value: 'newestFirst' },
        ];
    }
    get tabOptions() {

        let tabs = [];
        MYMESSAGES_TABS.forEach(element => {
            tabs.push({ label: element.name, value: element.label });
        })

        return tabs;

        /* return [{ label: 'All Messages', value: 'All Messages' },
        { label: 'Recalls & Product Alerts', value: 'Recalls & Product Alerts' },
        { label: 'Finance & Account', value: 'Finance & Account' },
        { label: 'News & Offers', value: 'News & Offers' }] */

    }

    connectedCallback() {
        //console.log('$RECALLS: contentMoreInfoA: ',this.contentMoreInfoA);
        //console.log('$RECALLS: contentMoreInfoH: ',this.contentMoreInfoH);
        //console.log('$RECALLS: contentMoreInfoP: ',this.contentMoreInfoP);
        this.sortValue = "Unread First";
        this.getTabs();
        this.initialize();
    }
    initialize = async () => {
        this.garage = await getGarage('', '');
        this.myProducts = await getMyProducts('', '');
        //console.log('myProducts-------->', this.myProducts);
        //console.log('garage-------->', this.garage);
        //this.getRecalls('Model');
        await this.getAllMessagesFromObj();
        await this.getAllRecallsFromObj();
        this.allMessages.sort(this.sortUnreadFirst);
        this.recalls.sort(this.sortUnreadFirst);
        //this.allMessages = await getAllMessages();
        if (this.tab === 'Recalls') {
            this.messages = this.recalls;
        }
        else {
            this.messages = this.allMessages;
        }
        //console.log('allmessages', this.allMessages);
        //Imtiyaz - CRRS Start
        sessionStorage.removeItem('ActiveTab');
        //Imtiyaz - CRRS End
    }
    getAllMessagesFromObj = async () => {
        //console.log('for loop entered getAllMessagesFromObj');
        // Alexander Dzhitenov (Wipro) DOE-5893: Included general Messages (i.e with no corresponding Owner Message, to be displayed to all users) in Apex callout results
        let inbox = await getAllMessages();
        //console.log('@@ inbox: ' + JSON.stringify(inbox));
        //console.log('$RECALLS: ownMessages inbox: ',inbox);
        //messages = await getAllMessages();
        //console.log('@@ messages'+messages);
        inbox.ownerMessages.forEach(element => {
            let message = {};
            message = {
                msgType: inbox.recordTypeMap[element.Message__r.RecordTypeId],
                id: element.Id,
                title: element.Message__r.Subject__c,
                body: element.Message__r.Body__c,
                class: element.Is_Read__c === false ? "slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item unread" : "slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item ",
                date: this.handleDate(element.Message__r.CreatedDate),
                readStatus: element.Is_Read__c,
                //Imtiyaz - RECALLS Start
                divisionId: element.Message__r.Brand__c,
                vin: element.Message__r.Product_Identifier__c ? element.Message__r.Product_Identifier__c : '',
                //Imtiyaz - RECALLS End
            }
            this.allMessages.push(message);
            //console.log('***' + message.body + ' ' + message.msgType);
            if (message.msgType === 'Finance') {
                this.finance.push(message);
            }
            else if (message.msgType === 'News & Offers') {
                this.news.push(message);
            } else if (message.msgType === 'OTA') {
                this.productAlerts.push(message);
            }
            //console.log('for loop', message);
            //console.log('for loop all', this.allMessages);
        });
        inbox.generalMessages.forEach(element => {
            let message = {};
            message = {
                msgType: inbox.recordTypeMap[element.RecordTypeId],
                id: element.Id,
                title: element.Subject__c,
                body: element.Body__c,
                class: "slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item",
                date: this.handleDate(element.CreatedDate),
                readStatus: true
            }
            this.allMessages.push(message);
            if (message.msgType === 'Product Alert' || message.msgType === 'OTA') {
                this.productAlerts.push(message);
            }
            else if (message.msgType === 'Safety Alert') {
                this.safetyAlerts.push(message);
            }
            else if (message.msgType === 'Finance') {
                this.finance.push(message);
            }
            else if (message.msgType === 'News & Offers') {
                this.news.push(message);
            }
            //console.log('***' + message.body + ' ' + message.msgType);
            //console.log('***Product Alerts: ' + JSON.stringify(this.productAlerts));
            //console.log('***Safety Alerts: ' + JSON.stringify(this.safetyAlerts));
            //console.log('for loop', message)
            //console.log('for loop all', this.allMessages)
        });
    }
    getAllRecallsFromObj = async () => {
        //console.log('for loop entered getAllMessagesFromObj')
        let messages = [];
        messages = await getAllRecalls();
        //console.log('@@recall messages' , messages);
        //console.log('$RECALLS: messages: ',messages);
        messages.forEach(element => {
            let message = {};
            message = {
                msgType: 'Recalls',
                id: element.Id,
                title: element.Message__r.Subject__c,
                body: element.Message__r.Body__c,
                class: element.Is_Read__c === false ? "slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item unread" : "slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item ",
                date: this.handleDate(element.Message__r.CreatedDate),
                readStatus: element.Is_Read__c,
                //Imtiyaz - RECALLS Start
                divisionId: element.Message__r.Brand__c,
                vin: element.Message__r.Product_Identifier__c ? element.Message__r.Product_Identifier__c : '',
                contentKey: element.Message__r.Brand__c == 'A' ? this.contentMoreInfoH : element.Message__r.Brand__c == 'B' ? this.contentMoreInfoA : this.contentMoreInfoP,
                //Imtiyaz - RECALLS End
            }
            this.recalls.push(message);
            //console.log('for loop recalls', message)
            //console.log('for loop all recalls', this.recalls)
        });
        //console.log('$RECALLS: recallsAll: ',JSON.parse(JSON.stringify(this.recalls)));
        //Imtiyaz - RECALLS Start
        localStorage.setItem('getAllRecallsFromObj', JSON.stringify(this.recalls));
        //Imtiyaz - RECALLS End
    }

    updateRecords(id, msgType) {
        if (msgType == "All Messages") {
            let newAllMessagesRecord = this.allMessages.find(object => object.id == id)
            /*    console.log('newAllMessagesRecord', newAllMessagesRecord)
                newAllMessagesRecord.readStatus = true;
                newAllMessagesRecord.class = "slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item"
                if (this.sortValue === 'unreadFirst') {
                    this.allMessages.sort(this.sortUnreadFirst);
                }
                let newRecallRecord = this.recalls.find(object => object.id == id)
                newRecallRecord.readStatus = true;
                newRecallRecord.class = "slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item"
                if (this.sortValue === 'unreadFirst') {
                    this.recalls.sort(this.sortUnreadFirst);
                }*/
        }
        else if (msgType == "Recalls") {
            let newRecallRecord = this.recalls.find(object => object.id == id);
            newRecallRecord.readStatus = true;
            newRecallRecord.class = "slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item";
            if (this.sortValue === 'unreadFirst') {
                this.recalls.sort(this.sortUnreadFirst);
            }
        }
        // Alexander Dzhitenov (Wipro) : Do not mark general messages as read; always display general messages as 'read' instead.
        /* else if (msgType == "Product Alert") {
            let message = this.productAlerts.find(object => object.id == id);
            message.readStatus = true;
            message.class = "slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item";
            if (this.sortValue === 'unreadFirst') {
                this.productAlerts.sort(this.sortUnreadFirst);
            }
        }
        else if (msgType == "Safety Alert") {
            let message = this.safetyAlerts.find(object => object.id == id);
            message.readStatus = true;
            message.class = "slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item";
            if (this.sortValue === 'unreadFirst') {
                this.safetyAlerts.sort(this.sortUnreadFirst);
            }
        } */
        else if (msgType == "Finance & Account") {

        }
        else if (msgType == "News & Offers") {

        }

        //console.log('id123', id)

    }

    //Make change to the date format and 'today' condition 
    handleDate(date) {
        let recordDate = date.split('T')[0];
        // let Rdate = Number(recordDate.split('-')[2]).toString();
        // let Rmonth = Number(recordDate.split('-')[1]).toString();
        // let Ryear = recordDate.split('-')[0].slice(2);
        let newDate = Number(recordDate.split('-')[1]).toString() + '/' + Number(recordDate.split('-')[2]).toString() + '/' + recordDate.split('-')[0].slice(2);
        let today = new Date();
        let todayDate = (today.getMonth() + 1) + '/' + today.getDate() + '/' + today.getFullYear().toString().slice(2);
        //console.log('for loop date', newDate, todayDate)
        return newDate == todayDate ? 'Today' : newDate;
    }
    sortOldestFirst(a, b) {
        let today = new Date();
        let todayDate = (today.getMonth() + 1) + '/' + today.getDate() + '/' + today.getFullYear().toString().slice(2);
        var dateA = a.date == 'Today' ? new Date(todayDate).getTime() : new Date(a.date).getTime();
        var dateB = b.date == 'Today' ? new Date(todayDate).getTime() : new Date(b.date).getTime();
        return dateA > dateB ? 1 : -1;
    };
    sortNewestFirst(a, b) {
        let today = new Date();
        let todayDate = (today.getMonth() + 1) + '/' + today.getDate() + '/' + today.getFullYear().toString().slice(2);
        var dateA = a.date == 'Today' ? new Date(todayDate).getTime() : new Date(a.date).getTime();
        var dateB = b.date == 'Today' ? new Date(todayDate).getTime() : new Date(b.date).getTime();
        return dateA > dateB ? -1 : 1;
    };
    sortUnreadFirst(a, b) {
        // return a.Is_Read__c > b.Is_Read__c ? 1 : -1;
        if (a.readStatus < b.readStatus) {
            return -1;
        } else if (a.readStatus > b.readStatus) {
            return 1;
        } else {
            return 0;
        }
    }
    getTabs() {
        const tabs = [];
        let deafulTab = sessionStorage.getItem('recallstab') ? 1 : 0;
        if (deafulTab > 0) {
            //console.log('***RECALLSTAB');
            sessionStorage.removeItem('recallstab');
        }
        for (let i = 0; i < MYMESSAGES_TABS.length; i++) {
            if (i === deafulTab) {
                this.tab = MYMESSAGES_TABS[i].label;
            }
            tabs.push({
                value: `${MYMESSAGES_TABS[i].name}`,
                label: `${MYMESSAGES_TABS[i].label}`,
                id: `${i}___item`,
                control: `tab-${i}`,
                content: `Tab Content ${i}`,
                ariaselected: i === deafulTab ? true : false,
                tabindex: i === deafulTab ? deafulTab : -1,
                itemclass: i === deafulTab ? 'slds-vertical-tabs__nav-item ' + CSS_SLDS_IS_ACTIVE : 'slds-vertical-tabs__nav-item',
                contentclass: i === deafulTab ? 'slds-p-horizontal_large slds-vertical-tabs__content ' + CSS_SLDS_SHOW : 'slds-p-horizontal_large slds-vertical-tabs__content ' + CSS_SLDS_HIDE,
            });
        }
        this.tabs = tabs;
    }
    getRecalls(search) {
        //console.log('entered')
        if (search == 'ProductIdentifier') {
            //VIN - JHMBA4132JC011294 Division - A
            getRecallsByProductIdentifier({ productIdentifier: this.context.product.vin, divisionId: this.context.product.divisionId }).then((res) => {
                if (!res.response.recalls_response.response.recall.campaignType.campaign) {
                    this.noRecalls = true;
                    return;
                }
                let result = JSON.parse(JSON.stringify(res.response.recalls_response.response.recall.campaignType.campaign));
                this.displayRecalls(result);
                //console.log('Recalls Data By VIN---------', this.recallData, this.recallData.length);
            }).catch(err => {
                //console.log(err);
            });
        } else {
            //console.log('entered model')
            getRecallsByModel({ year: '2015', model: '', modelId: '10', divisionId: 'A' }).then((res => {
                //console.log('Recalls Data by model****', res.response.recalls_response.response.recall.campaignType.campaign);

                let r = res.response.recalls_response.response.recall.campaignType.campaign;
                //console.log('response', r)
                for (let i = 0; i < r.length; i++) {
                    let recall = {};
                    recall = {
                        recallNo: r[i].campaignBulletinID,
                        campaignID: r[i].campaignID,
                        campaignDescription: r[i].campaignDescription,
                        date: r[i].recallDate,
                        recallStatus: r[i].mfrRecallStatus.value,
                        summary: r[i].recallDescription,
                        safetyRisk: r[i].safetyRiskDescription,
                        remedy: r[i].remedyDescription,
                        class: "slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item unread"
                    }
                    //console.log('each  recall', recall)

                    this.recalls.push(recall);
                }
                //console.log('recalltest', this.recalls)
                //console.log('recalltest1', this.recalls[1].summary)

                //console.log('recalltest sorted', this.recalls)
            })).catch(err => {
                //console.log(err);
            });
        }

    }

    handleActive(event) {
        this.messageDetail = false;
        //console.log('value Active', event.currentTarget.dataset.value);
        //Imtiyaz - CRRS Start
        //console.log('$CRRS: TAB: ',event.currentTarget.dataset.value);
        sessionStorage.setItem('ActiveTab', event.currentTarget.dataset.value);
        //Imtiyaz - CRRS End
        if (event.currentTarget.dataset.value == "All Messages") {
            this.messages = this.allMessages;
        }
        else if (event.currentTarget.dataset.value == "Recalls") {
            this.messages = this.recalls;
        }
        else if (event.currentTarget.dataset.value == "Product Alerts") {
            this.messages = this.productAlerts;
        }
        else if (event.currentTarget.dataset.value == "Safety Alerts") {
            this.messages = this.safetyAlerts;
        }
        else if (event.currentTarget.dataset.value == "Finance & Account") {
            this.messages = this.finance;
        }
        else if (event.currentTarget.dataset.value == "News & Offers") {
            this.messages = this.news;
        }



        this.tab = event.currentTarget.dataset.value;
        let page = { sub_section2: event.currentTarget.dataset.value, pageName: 'messages' };
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
        this.tab = event.detail.value;
        let page = { sub_section2: event.currentTarget.dataset.value, pageName: 'messages' };
        let message = { eventType: DATALAYER_EVENT_TYPE.LOAD, page: page };
        this.publishToChannel(message);
        if (event.detail.value == "All Messages") {
            this.messages = this.allMessages;
        }
        else if (event.detail.value == "Recalls") {
            this.messages = this.recalls;
        }
        else if (event.detail.value == "Product Alerts") {
            this.messages = this.productAlerts;
        }
        else if (event.detail.value == "Safety Alerts") {
            this.messages = this.safetyAlerts;
        }
        else if (event.detail.value == "Finance & Account") {
            this.messages = this.finance;
        }
        else if (event.detail.value == "News & Offers") {
            this.messages = this.news;
        }

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
        this.showTabSet = false;

    }

    backToTabs() {
        this.showTabSet = true;
    }

    handleHideTab(event) {
        //console.log('MYMESSAGES_TAB before change : ', MYMESSAGES_TABS);
        const tabs = [];
        for (let i = 0; i < MYMESSAGES_TABS.length; i++) {
            if (MYMESSAGES_TABS[i].name == event.detail) {
                continue;
            }
            if (i === 0) {
                this.tab = MYMESSAGES_TABS[i].label;
            }
            tabs.push({
                value: `${MYMESSAGES_TABS[i].name}`,
                label: `${MYMESSAGES_TABS[i].label}`,
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
        //MYMESSAGES_TABS.splice(MYMESSAGES_TABS.indexOf(MYMESSAGES_TABS.find(element => element.name == event.detail),1));
        //console.log('MYMESSAGES_TAB after change : ',MYMESSAGES_TABS);
    }
    handleBreadCrump = async () => {
        this.messageDetail = false;
        //console.log("clicked breadcrumb")
        //console.log('all new message', this.allMessages)
    }
    handleEvent(event) {
        try {
            //console.log('msgType', event.detail.msgType)
            this.messageDetail = event.detail.messageDetail;
            this.updateRecords(event.detail.id, event.detail.msgType);
            //console.log('handleevent test')
            //console.log('new message detail', this.messageDetail)
            //console.log('event id', event.detail.id)
            this.messageRead = event.detail.id;
            if (event.detail.id) {
                for (var i in this.recalls) {
                    if (this.recalls[i].id == event.detail.id) {
                        this.recalls[i].class = 'slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item ';
                        this.recalls[i].readStatus = true;
                    }
                }
                for (var i in this.allMessages) {
                    //console.log('value Active', this.allMessages[i].id);
                    if (this.allMessages[i].id == event.detail.id) {
                        this.allMessages[i].class = 'slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item ';
                        this.allMessages[i].readStatus = true;
                    }
                }
                for (var i in this.finance) {
                    //console.log('value Active', this.finance[i].id);
                    if (this.finance[i].id == event.detail.id) {
                        this.finance[i].class = 'slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item ';
                        this.finance[i].readStatus = true;
                    }
                }
                for (var i in this.news) {
                    //console.log('value Active', this.news[i].id);
                    if (this.news[i].id == event.detail.id) {
                        this.news[i].class = 'slds-grid slds-grid_align-spread slds-grid_vertical-align-center message-list-item ';
                        this.news[i].readStatus = true;
                    }
                }
                this.recalls.sort(this.sortUnreadFirst);
                this.allMessages.sort(this.sortUnreadFirst);
            }
        } catch (err) {
            //console.log(err);
        }

    }
    handleSort(event) {
        this.sortValue = event.detail.value;
        //console.log(this.sortValue)
        if (this.sortValue === 'oldestFirst') {
            this.allMessages.sort(this.sortOldestFirst);
            this.recalls.sort(this.sortOldestFirst);
            this.productAlerts.sort(this.sortOldestFirst);
            this.safetyAlerts.sort(this.sortOldestFirst);
            this.finance.sort(this.sortOldestFirst);
            this.news.sort(this.sortOldestFirst);
        }
        if (this.sortValue === 'newestFirst') {
            this.allMessages.sort(this.sortNewestFirst);
            this.recalls.sort(this.sortNewestFirst);
            this.productAlerts.sort(this.sortNewestFirst);
            this.safetyAlerts.sort(this.sortNewestFirst);
            this.finance.sort(this.sortNewestFirst);
            this.news.sort(this.sortNewestFirst);
        }
        if (this.sortValue === 'unreadFirst') {
            this.allMessages.sort(this.sortUnreadFirst);
            this.recalls.sort(this.sortUnreadFirst);
            this.productAlerts.sort(this.sortUnreadFirst);
            this.safetyAlerts.sort(this.sortUnreadFirst);
            this.finance.sort(this.sortUnreadFirst);
            this.news.sort(this.sortUnreadFirst);
        }
    }

    get allMessages() { return this.tab === 'All Messages'; }
    get recallsAndProductAlerts() { return this.tab === 'Recalls & Product Alerts'; }
    get financeAndAccount() { return this.tab === 'Finance & Account'; }
    get newsAndOffers() { return this.tab === 'News & Offers'; }


}