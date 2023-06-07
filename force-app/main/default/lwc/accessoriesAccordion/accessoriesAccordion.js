import { api, track, LightningElement } from 'lwc';

export default class AccessoriesAccordion extends LightningElement {
    @api accessories;
    @api division;
    @track categories;
   @track allcategories; //added by Yashika for R2 story accessory search 
    
    @track showSubCategory = false;
    value = [];
    //options = [];
    lastValue;
    connectedCallback() {
        let tempCategories = {};
        //console.log('AccessoriesAccordion Division : ', this.division);
        if(this.division == 1){
            tempCategories = [{ section: 'All' }, { section: 'Interior' }, { section: 'Exterior' }, { section: 'Electrical' }];
        }else if(this.division == 2){
            tempCategories = [{ section: 'All' }, { section: 'Interior' }, { section: 'Exterior' }];
        }      
        let categoriesData = [];
        tempCategories.forEach(element => {
            if (element.section == 'Interior') {
                element.subCategories = this.accessories.Accessory.filter(item => item.displaygroups == 'Interior');
            } else if (element.section == 'Exterior') {
                element.subCategories = this.accessories.Accessory.filter(item => item.displaygroups == 'Exterior');
            } else if (element.section == 'Electrical') {
                element.subCategories = this.accessories.Accessory.filter(item => item.displaygroups == 'Electrical');
            }else if(element.section == 'All'){
                element.subCategories = this.accessories.Accessory;
                element.checked = true;
            }
            element.chevron = 'utility:chevronright';
            categoriesData.push(element);
        });
        this.categories = categoriesData;
        this.allcategories= categoriesData;//added by Yashika for R2 story accessory search
        //console.log('this.categories on accord: ', JSON.stringify(this.categories));
    }

    //added by Yashika for R2 story: accessory search 5307
//start
    @api filtercategory(filtercat){
      this.categories= this.allcategories.filter(elm=> filtercat.includes(elm.section));
    }
 // ends here

    handleOptionChange(e) {
        this.value = e.target.value;
        let tempCategories = this.categories;
        let dispatchData;
        if(this.value.length > 0){
            dispatchData = { mode: 'open', category: tempCategories[this.value].section };
            this.lastValue = this.value;
        }else if(this.value.length <= 0){
            dispatchData = { mode: 'close', category: tempCategories[this.lastValue].section };
        }
        this.notifyParentOnSelectCategory(dispatchData);
    }
    clearFilter(event){
        let tempCategories = this.categories;
        let dispatchData;
        let val = parseInt(event.target.value);
        const boxes = this.template.querySelectorAll('lightning-input');
        boxes.forEach(box => {           
            if(box.checked && this.lastValue.length > 0 && this.lastValue == val){
                this.template.querySelectorAll('lightning-input')[val].checked = false;
                dispatchData = { mode: 'close', category: tempCategories[this.lastValue].section };
                this.notifyParentOnSelectCategory(dispatchData);
                setTimeout(() => { this.lastValue = []; }, 100);
            }
        });
    }

    //added by Yashika for R2 story: accessory search
//start
    @api
    clearAccordion(){
        const boxes = this.template.querySelectorAll('lightning-input');
        boxes.forEach(box => {
            if(box.label == 'All'){
                box.checked = true;
            }else {
            box.checked = false;
            }
            
        });
        this.value = [];
        this.lastValue = [];
    } //ends here
    showCollapseData(event) {
        let index = event.currentTarget.dataset.index;
        let tempCategories = this.categories;
        this.categories.forEach(item => {
            item.chevron = 'utility:chevronright';
        });
        if (!event.currentTarget.parentElement.classList.contains('slds-is-open')) {
            tempCategories[index].chevron = 'utility:chevrondown';
            this.closeAllCategory();
            event.currentTarget.parentElement.classList.add('slds-is-open');
            let dispatchData = { mode: 'open', category: tempCategories[index].section };
            this.notifyParentOnSelectCategory(dispatchData);
        } else {
            tempCategories[index].chevron = 'utility:chevronright';
            event.currentTarget.parentElement.classList.remove('slds-is-open');
            let dispatchData = { mode: 'close', category: tempCategories[index].section };
            this.notifyParentOnSelectCategory(dispatchData);
        }
        this.categories = tempCategories;
    }

    // This method is used to notify parent on the select of the category.
    notifyParentOnSelectCategory(dispatchData) {
        this.dispatchEvent(new CustomEvent('clickcategory', { detail: dispatchData }));
    }

    // This method is call when user's select sub category.
    handleOnSelectSubCategory(event) {
        let subCategoryId = event.currentTarget.dataset.id;
        if (subCategoryId) {
            this.deselectAllSubCategory();
            event.currentTarget.classList.add('subcategoryselected');
            this.notifyParentOnSelectCategory(subCategoryId);
        }
    }

    // method is used to deselect all sub category
    deselectAllSubCategory() {
        [...this.template.querySelectorAll('.subcategory')].forEach(subCategoryNode => {
            if (subCategoryNode && subCategoryNode.classList && subCategoryNode.classList.contains('subcategoryselected'))
                subCategoryNode.classList.remove('subcategoryselected')
        });
    }

    // This method is used to close all category
    closeAllCategory() {
        self = this;
        let listItems = [...this.template.querySelectorAll('.slds-accordion__section')];
        if (listItems) {
            listItems.forEach(function(currentItem, index) {
                if (currentItem && currentItem.classList && currentItem.classList.contains('slds-is-open')) {
                    currentItem.classList.remove('slds-is-open');
                }
            });
        }
    }
}