import { LightningElement, track, wire } from 'lwc';
import { ISGUEST, getProductContext, getContext, getOrigin } from 'c/ownDataUtils';
import getCompleteDetails from '@salesforce/apex/OwnAPIController.getCompleteDetails';
import { OwnBaseElement } from 'c/ownBaseElement';
import { CurrentPageReference } from 'lightning/navigation';

export default class OwnHowToGuides extends OwnBaseElement {
    @track categoriesData =[];
    @track allCategoriesData =[];
    @track divisionId;
    @track isError = false;
    @track isLoading = true;
    currentPageReference = null;
    urlStateParameters = null;
    @track year;
    @track model;
    
    connectedCallback(){
        
        this.initialize();
    }
    
    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        let context;
        if (fromProductChooser) {
            context = await getProductContext('', true);
        } else {
            context = await getProductContext('', false);
        }
        if(context && context.product && !this.divisionId && !this.year && !this.model){
            this.divisionId = context.product.divisionId;
            this.year = context.product.year;
            this.model = context.product.model;
        }
        if (this.divisionId && this.year && this.model){
            await getCompleteDetails({divisionId : this.divisionId, modelYear : this.year, model:this.model})
            .then((data) => {
                //console.log('data-->', JSON.parse(JSON.stringify(data)));
                if(data && data.error){
                    this.isError = true;
                }else{
                    data.feature.forEach( element =>{
                        element.view = element.view.filter(ele => ele.type);
                        element.view.forEach( viewEle => {
                            viewEle.category = element.title;
                            if(!viewEle.title){
                                viewEle.title = element.title;
                            }
                        });
                        this.categoriesData.push({
                            title : element.title,
                            features : element.view.slice(0, 3)
                        });
                        this.allCategoriesData.push({
                            title : element.title,
                            features : element.view
                        });
                    })
                }
                this.isLoading = false;
            })
            .catch((error) =>{
                //console.log('error--->',error);
                this.isError = true;
                this.isLoading = false;
            })           
        }
        
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.divisionId = this.urlStateParameters.divisionid || null;
        this.year = this.urlStateParameters.year || null;
        this.model = this.urlStateParameters.model || null;
    }

    handleClickAll(event){
        let category = event.currentTarget.dataset.title
        let categoryDataArray = this.allCategoriesData.filter( element => element.title == category);
        if(categoryDataArray){
            let data = categoryDataArray[0];
            sessionStorage.setItem('howtoguides',JSON.stringify(data));
            let breadcrumbData ={
                label :'How-to Guides',
                url : '/how-to-guides',
                subTitle : data.title ? data.title + ' How-to Guides' : 'How-to Guides',
            }
            let breadcrumbArr = [];
            if (sessionStorage.getItem('fromhowtoguides')) {
                breadcrumbArr = JSON.parse(sessionStorage.getItem('fromhowtoguides'));
            }
            breadcrumbArr.push(breadcrumbData);
            sessionStorage.setItem('fromhowtoguides', JSON.stringify(breadcrumbArr));
        }
        this.navigate('/how-to-category',{});
    }
}