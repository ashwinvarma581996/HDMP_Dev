import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';

export default class OwnCollisionGlossary extends OwnBaseElement {

    @api cmsTopic;
    itemCloseIcon = "utility:right";
    itemOpenIcon = "utility:down";
    @api collisionGlossaryTopic;
    @track contentData;
    @track pageSize = 50;
    @track managedContentType = '';
    @track accordinTestData;
    @track searchKey = '';
    @track showAccordins = true;
    @track showError = false;
    @track searchKeys = [];
    @track result;
    @track resultData = [];
    @track collisionGlossary;
    @api brand;
    @api contentId;
    previousSection;


    connectedCallback() {
        //console.log('this.contentId',this.contentId);
        this.getCMSContent();
        this.getCMSAccordionsContent();
    }
    async getCMSContent(){
        let content = await getManagedContentByTopicsAndContentKeys([this.contentId], null, this.pageSize, this.managedContentType);
        //console.log('this.content--->',content);
        
        if(content){
            this.collisionGlossary = {
                title : content[0].title ? this.htmlDecode(content[0].title.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : '',
                body : content[0].body ?this.htmlDecode(content[0].body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : '',
                placeholder : content[0].subTitle ?this.htmlDecode(content[0].subTitle.value) : ''
            }
        }
    }

    async getCMSAccordionsContent(){
        let topics = [this.collisionGlossaryTopic];
        this.contentData = await getManagedContentByTopicsAndContentKeys([], topics, this.pageSize, this.managedContentType);
        //console.log('this.contentData--',this.contentData);
        this.accordinTestData = JSON.parse(JSON.stringify(this.contentData));
        this.setAccordins();
        this.getSearchKeys();
    }

    handleSectionClick(event) {
        this.showAccordins = true;
        this.searchKey = '';
        event.preventDefault();
        let element = this.template.querySelector('.' + event.currentTarget.dataset.targetId);
        let targetId = event.currentTarget.dataset.targetId;
        this.accordinTestData.forEach(element => {
            if (element.key === targetId) {
                element.icon = this.itemOpenIcon;
            }
        });
        this.selectAccordin(element, targetId);
    }

    escapeRegExp(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    }

    replaceAll(str, term, replacement) {
        return str.replace(new RegExp(this.escapeRegExp(term), 'g'), replacement);
    }

    refreshComponent(event){
        console.log('refreshComponent');
        this.setAccordins();
        //this.getSearchKeys();
        //eval("$A.get('e.force:refreshView').fire();");
    }

   setAccordins() {
        let accordionData = JSON.parse(JSON.stringify(this.contentData));
            accordionData.forEach(element => {
            element.class = "slds-accordion__section " + element.key;
            if (element.body && element.body.value) {
                element.body.value = this.htmlDecode(element.body.value);
                element.body.value = element.body.value.replaceAll('<strong>','<b>');
                element.body.value = element.body.value.replaceAll('</strong>','</b>');
            } else {
                element.body = { value: 'N/A' };
            }
            element.icon = this.itemCloseIcon;
        });
        accordionData.sort(function (a, b) { return a.title.value.localeCompare(b.title.value) });
        this.showAccordins = accordionData.length > 0 ? true : false;
        this.accordinTestData = accordionData;

    }

    getSearchKeys() {
        let accordionData = this.accordinTestData;
        for (let sectionIndex = 0; sectionIndex < accordionData.length; sectionIndex++) {
            if (accordionData[sectionIndex].body.value != 'N/A') {
                let Accordin = String(accordionData[sectionIndex].body.value);
                while (Accordin.length > 0) {
                    Accordin = Accordin.replace('<h5><b>', '<t>');
                    Accordin = Accordin.replace('</b>', '</t>');
                    let paraEndIndex = Accordin.indexOf('</h5>\n') != -1 ? Accordin.indexOf('</h5>\n') : Accordin.length;
                    this.searchKeys.push({
                        key: Accordin.substring(Accordin.indexOf('<t>') + 3, Accordin.indexOf('</t>')),
                        paragraph: Accordin.substring(Accordin.indexOf('</t>' + 4), paraEndIndex),
                    })
                    //Accordin = Accordin.substring((paraEndIndex != Accordin.length ? paraEndIndex + 10 : Accordin.length), Accordin.length);
                    Accordin = Accordin.substring((paraEndIndex != Accordin.length ? Accordin.indexOf('</h5>')+5 : Accordin.length), Accordin.length);
                }
            }
        }
        //console.log('this.searchKeys-->',this.searchKeys);
    }

    toggleAccordionSection(event) {
        this.showAccordins = true;
        this.searchKey = '';
        event.preventDefault();
        let element = event.currentTarget;
        let targetId = element.dataset.targetId;
        this.selectAccordin(element, targetId);
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value;
        //console.log('handleSearchChange searched Key ' + this.searchKey.length);
        if(this.searchKey.length == 0){
            this.refreshComponent();
        }
    }

    handleSearch(event) {
        //console.log('handleSearch ',event);
        //console.log('searchLength---=-?>',this.searchKey.length);
        if (event.which == 13 || this.searchKey.length > 2) {
            this.searchKey = this.searchKey.trim();
            let searchLength = this.searchKey.length;
            if (searchLength === 0) {
                this.showAccordins = true;
                //console.log('searchLength---=-?>',searchLength);
                this.refreshComponent();
            } else if (searchLength < 3) {
                this.showAccordins = false;
                this.showError = true;
            } else {
                this.previousSection = null;
                this.showAccordins = false;
                let resultsFlag = false;
                this.result = new Map();
                this.resultData = [];
                this.searchKeys.forEach(para => {
                    if (para.key.toUpperCase().indexOf(this.searchKey.toUpperCase()) != -1 && !this.result.has(para.key)) {
                        //console.log('value1 = ', para.paragraph)
                        
                        let value = para.paragraph.substring(para.paragraph.indexOf('<t>'), para.paragraph.length);
                        value = this.replaceAll(value,'<t>','<p><b> ');
                        value = this.replaceAll(value,'</t>','</b>');
                        value = value.trim();
                        //console.log('value2 = ', value)
                        this.result.set(para.key, value);
                        this.resultData.push({data : value});
                        resultsFlag = true;
                    }
                });
                this.showError = !resultsFlag;
            }
         }
    }

    selectAccordin(element, targetId) {
        //console.log('this.previousSection : ', this.previousSection);
        if (this.previousSection) {
            this.previousSection.querySelector(".custom-icon").iconName = 'utility:right';
            this.previousSection.querySelector(".custom-span").innerHTML = this.previousSection.querySelector(".custom-span").innerText;
            this.previousSection.classList.remove('slds-is-open');
            this.previousSection.classList.remove('section-open');
            this.previousSection.childNodes[0].style.background = '#FFFFFF';
            this.previousSection.childNodes[1].classList.remove('custom-content');
        }
        //ownAddServiceRecord
        //console.log('this.accordion-large : ', this.template.querySelector(".accordion-large"));
        //console.log('this.accordion-small : ', this.template.querySelector(".accordion-small"));
        let orderedList = window.innerWidth > 600 ? this.template.querySelector(".accordion-large") : this.template.querySelector(".accordion-small");
        
        let section = orderedList.querySelector(`[data-id="${targetId}"]`);

        //console.log('Section contains : ', section.classList);
        if (!section.classList.contains('slds-is-open')) {
            element.querySelector('span').innerHTML = element.querySelector('span').innerText.bold();
            element.firstChild.iconName = 'utility:down';
            section.classList.add('slds-is-open');
            section.classList.add('section-open');
            section.childNodes[0].style.background = '#F5F5F5';
            section.childNodes[1].classList.add('custom-content');
        }

        this.previousSection = section;
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }
}