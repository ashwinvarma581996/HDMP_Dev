import { api,LightningElement,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getVehicleHealthReport from '@salesforce/apex/ownMaintenanceMinderController.getVehicleHealthReport';
import { viewProduct, getOrigin, setOrigin, addProduct, getGarageURL, getContext, setProductContextUser, getProductContext } from 'c/ownDataUtils';
import getVehicleHealthSubCategoryList from '@salesforce/apex/ownMaintenanceMinderController.getVehicleHealthSubCategoryList';

export default class OwnChildVehicleHealthDetail extends OwnBaseElement {
    @api vehicleCategory;
    @track title = 'VEHICLE HEALTH & MAINTENANCE MINDERS';
    @track titlecolor;
    @track icon;
    @track brand = 'default';
    @track showFooter = true;
    @track actiontitle = 'VIEW HEALTH REPORT';
    @track recall = {};
    @track date;
    @track division;
    
    @track noRecalls;
    @track vehiclestautsubscategory ;
    @track cardDivClass = '';

    connectedCallback() {
        if(document.title == 'Garage' || document.title == 'Garage'){
           // this.cardDivClass = 'overview-tab-class';
           // console.log('Document title ::: ', document.title);
        }
        this.initialize();
    }
    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            //this.context = await getProductContext('', false);
            //this.context = await getContext('');
            this.context = await getProductContext('', false);
            //console.log('context from server - ',JSON.parse(JSON.stringify(this.context)));
        }
        //console.log('context-------->', this.context);
        //console.log('context-----divisionId--->', this.context.product.divisionId);
        
        this.getVehicleHeathStatusSubCategory();
      //  this.getRecalls('Model');
        
    }
    getVehicleHeathStatusSubCategory(){
        getVehicleHealthSubCategoryList({ ownershipId: this.context.product.ownershipId, productId: this.context.product.productId, vehicleCategory: this.vehicleCategory }).then((result) => {
            result = JSON.parse(JSON.stringify(result));
            result.forEach(res => {
                res.hasIcon = false;
                if(res.Health_Status_Indicator__c){
                    if(res.Health_Status_Indicator__c.toLowerCase() == 'on'){
                        res.iconClass = 'fa fa-lg fa-wrench wrench_icon';
                        res.hasIcon = true;
                    }else if(res.Health_Status_Indicator__c.toLowerCase() == 'off'){
                        res.iconClass = 'fa fa-lg fa-check check_icon';
                        res.hasIcon = true;
                    }
                }
            });
            //console.log('getVehicleHealthSubCategoryList',result);
            this.vehiclestautsubscategory = result ;
            }).catch(error => { 
                //console.log('health report error', error); 
            })

    }
}