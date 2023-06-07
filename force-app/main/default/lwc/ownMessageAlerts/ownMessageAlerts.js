import { LightningElement, track, api } from 'lwc';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';

const CSS_SLDS_IS_ACTIVE = 'slds-is-active';
const CSS_SLDS_SHOW = 'slds-show';
const CSS_SLDS_HIDE = 'slds-hide';

const MYMESSAGES_TABS = [{ 'name': 'All Messages', 'label': 'All Messages' },
{ 'name': 'Safety Alerts', 'label': 'Safety Alerts' },
{ 'name': 'Product Alerts', 'label': 'Product Alerts' }]

export default class OwnMessageAlerts extends OwnBaseElement {

    @api safetyAlertsTopic;
    @api productAlertsTopic;
    
    @track tabs = [];
    @track tab;
    showTabSet = true;
    @track messages = [];
    @track allMessages = [];
    @track recall = {};
    @track allSelectedTabRecords = [];
    @track trial = [];
    @track finance = [];
    @track news = [];
    @track recallData = [];
    @track messageDetail = false;
    @track sortValue;
    @track messageRead;

    @track safetyAlerts = [];
    @track productAlerts = [];

    get options() {
        return [
            // { label: 'Unread First', value: 'unreadFirst' },
            { label: 'Oldest First', value: 'oldestFirst' },
            { label: 'Newest First', value: 'newestFirst' },
        ];
    }
    get tabOptions() {
        return [{ label: 'All Messages', value: 'All Messages' },
        { label: 'Safety Alerts', value: 'Safety Alerts' },
        { label: 'Product Alerts', value: 'Product Alerts' }]

    }

    connectedCallback() {
        // this.sortValue = "Unread First";
         this.getTabs();
        this.initialize();
       
    }

    initialize = async () => {
        // this.garage = await getGarage('', '');
        // this.myProducts = await getMyProducts('', '');
        await this.getSaftyCMSContent();
        await this.getProductCMSContent();
        this.messages = this.allMessages;
        //console.log('allmessages', this.allMessages);
    }

    async getSaftyCMSContent(){
        let topics = [this.safetyAlertsTopic];
        let content = await getManagedContentByTopicsAndContentKeys([], topics, this.pageSize, this.managedContentType);
        //this.safetyAlerts = JSON.parse(JSON.stringify(content));
        content.forEach( r =>{
            this.safetyAlerts.push({
                key : r.key,
                title : r.title ? r.title.value : '',
                link :  r.downloadLink ? r.downloadLink.value :'',
                date : r.publishedDate//this.handleDate(r.publishedDate)
                });
        });
        this.allMessages.push(...this.safetyAlerts);// = [...this.safetyAlerts];
        //console.log(' this.safetyAlerts-->', this.safetyAlerts);
    }

    async getProductCMSContent(){
        let topics = [this.productAlertsTopic];
        let content = await getManagedContentByTopicsAndContentKeys([], topics, this.pageSize, this.managedContentType);
        //this.productAlerts = JSON.parse(JSON.stringify(content));
        content.forEach( r =>{
            let i = 11;
            this.productAlerts.push({
                key : r.key,
                title : r.title ? r.title.value : '',
                link :  r.downloadLink ? r.downloadLink.value :'',
                date : r.publishedDate//this.handleDate(r.publishedDate)
                });
            i++;
        });
        this.allMessages.push(...this.productAlerts);
        //this.allMessages = [...this.productAlerts];
        //console.log(' this.productAlerts-->', this.productAlerts);
    }

    // //Make change to the date format and 'today' condition 
    // handleDate(date) {
    //     let recordDate = date.split('T')[0];
    //     // let Rdate = Number(recordDate.split('-')[2]).toString();
    //     // let Rmonth = Number(recordDate.split('-')[1]).toString();
    //     // let Ryear = recordDate.split('-')[0].slice(2);
    //     let newDate = Number(recordDate.split('-')[1]).toString() + '/' + Number(recordDate.split('-')[2]).toString() + '/' + recordDate.split('-')[0].slice(2);
    //     let today = new Date();
    //     let todayDate = (today.getMonth() + 1) + '/' + today.getDate() + '/' + today.getFullYear().toString().slice(2);
    //     console.log('for loop date', newDate, todayDate)
    //     return newDate == todayDate ? 'Today' : newDate;
    // }
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
    // sortUnreadFirst(a, b) {
    //     // return a.Is_Read__c > b.Is_Read__c ? 1 : -1;
    //     if (a.readStatus < b.readStatus) {
    //         return -1;
    //     } else if (a.readStatus > b.readStatus) {
    //         return 1;
    //     } else {
    //         return 0;
    //     }
    // }
    getTabs() {
        //console.log('getTabs=======>',);
        const tabs = [];
        let deafulTab = 0;
        // let deafulTab = sessionStorage.getItem('Safetytab') ? 1 : 0;
        // if(deafulTab > 0)
        //     sessionStorage.removeItem('Safetytab');
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
        //console.log('tabs=======>',tabs);
        this.tabs = tabs;
    }
   

    handleActive(event) {
        this.messageDetail = false;
        //console.log('value Active', event.currentTarget.dataset.value);
        if (event.currentTarget.dataset.value == "All Messages") {
            this.messages = this.allMessages;
            //console.log('this.messages', this.messages);
            //console.log('this.allMessages', this.allMessages);
        }
        else if (event.currentTarget.dataset.value == "Safety Alerts") {
            this.messages = this.safetyAlerts;
            this.allSelectedTabRecords =  this.safetyAlerts;
            //console.log('this.messages', this.messages);
            //console.log('this.allMessages', this.safetyAlerts);
        }
        else if (event.currentTarget.dataset.value == "Product Alerts") {
            this.messages = this.productAlerts;
            this.allSelectedTabRecords =  this.productAlerts;
            //console.log('this.messages', this.messages);
            //console.log('this.allMessages', this.productAlerts);
        }


        this.tab = event.currentTarget.dataset.value;
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
        if (event.detail.value == "All Messages") {
            this.messages = this.allMessages;
            //console.log('this.allMessages',this.allMessages);
            //console.log(' this.messages',this.messages);
        }
        else if (event.detail.value == "Safety Alerts") {
            this.messages = this.safetyAlerts;
            this.allSelectedTabRecords =  this.safetyAlerts;
            //console.log(' this.messages',this.messages);
            //console.log('this.safetyAlertss',this.safetyAlerts);
        }
        else if (event.detail.value == "Product Alerts") {
            this.messages = this.productAlerts;
            this.allSelectedTabRecords =  this.productAlerts;
            //console.log(' this.messages',this.messages);
            //console.log('this.productAlerts',this.productAlerts);
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

   
    handleSort(event) {
        this.sortValue = event.detail.value;
       
        //console.log(' this.allMessages', JSON.parse(JSON.stringify(this.allMessages)));
        //console.log(' this.allSelectedTabRecords', this.allSelectedTabRecords)
        if (this.sortValue === 'oldestFirst') {
            //console.log(this.sortValue)
            this.allMessages.sort(this.sortOldestFirst);
            this.allSelectedTabRecords.sort(this.sortOldestFirst);
        }
        if (this.sortValue === 'newestFirst') {
            //console.log(this.sortValue)
            this.allMessages.sort(this.sortNewestFirst);
            this.allSelectedTabRecords.sort(this.sortNewestFirst);
        }
        // if (this.sortValue === 'unreadFirst') {
        //     this.allMessages.sort(this.sortUnreadFirst);
        //     this.allSelectedTabRecords.sort(this.sortUnreadFirst);
        // }
        //console.log(' this.allMessages', JSON.parse(JSON.stringify(this.allMessages)));
    }


    handleClick(event) {
        //console.log("clicked")
        //console.log("inbox", event.currentTarget.dataset.url)
        let url = event.currentTarget.dataset.url;
        this.navigate(url, {}); 
    }

    // get allMessages() { return this.tab === 'All Messages'; }
    // get SafetyAndProductAlerts() { return this.tab === 'Safety Alerts'; }
    // get financeAndAccount() { return this.tab === 'Product Alerts'; }

}