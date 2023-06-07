import { api, LightningElement,wire, track } from 'lwc';
import getChildCategories from '@salesforce/apex/categoryNavigation.getChildCategories';
import { NavigationMixin } from 'lightning/navigation';



export default class CategoryNavigation extends LightningElement {

    listCategories;
    error;

    @api categoryid;
    _categoryId;

    @track
    categoryId;

   

    get categoryId(){
        if( this.categoryId ===''||this.categoryId === null || this.categoryId === undefined|| typeof this.categoryId === 'undefined'){
            this._categoryId = this.categoryid;
    }

    return this._categoryId
}

    
    @wire(getChildCategories, { catId:'$categoryid' })
    wiredChildCategories({ error, data }) {
        if (data) {
            //console.log(data);
            this.listCategories = data;
        } else if (error) {
            this.error = error;
            //console.log(error);
        }
    }

    clickCategory(event) {
        //console.log(this.categoryid);
        const selectedRecordId = event.target.name.substring(0,15);
        //console.log(selectedRecordId);
        //console.log('Hello::');
        this._categoryId = selectedRecordId;
       this.categoryId = selectedRecordId;
       getChildCategories({
        catId:selectedRecordId
    })
    .then((result) => {
        this.listCategories = result;
        this.dispatchEvent(new CustomEvent('nextt'));
        //this.dispatchEvent(new CustomEvent('categoryChange'));
        const catEvent = new CustomEvent('categorychange', {
            bubbles: true,
            composed: true,
            // detail contains only primitives
            detail: {selectedCategory:selectedRecordId}
            });
            this.dispatchEvent(catEvent);

    })
    .catch((e) => {
        //console.log(e);
    });

  
    }






}