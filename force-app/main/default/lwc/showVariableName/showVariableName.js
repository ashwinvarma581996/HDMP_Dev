import { LightningElement,api,wire,track } from 'lwc';
import getVariableList from '@salesforce/apex/showVariableNames.getVariableList';
import getboilerVariableList from '@salesforce/apex/showVariableNames.getboilerVariableList';
export default class ShowVariableName extends LightningElement {

 @track columns = [{
            label: 'Variable Name',
            fieldName: 'Variable_Name__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Corresponding Field',
            fieldName: 'Format__c',
            type: 'text',
            sortable: true
        }
    ];

    @api recordId;
   @api isShowModal = false;
  @track error;
    @track varList ;
    @track objectName;
    @track noData=false;
    @track dataArray=[];
    @api offertype;
    @api brand;
    @track sortedBy; 
    @track sortedDirection = "asc";
  @api showModalBox() {  
        
        this.isShowModal = true;
        getVariableList({ recordID: this.recordId})
            .then((result) => {
                this.varList = result;
                this.error = undefined;


                this.dataArray=result;

               
             
                if(this.dataArray.length<0){
                    console.log('No Data');
                    this.noData =true;
                }

            })
            .catch((error) => {
                this.error = error;
                this.contacts = undefined;
            });
    }

    @api boilerplateModal(){
        this.isShowModal = true;
        getboilerVariableList({ offerBrand: this.brand, offerType: this.offertype})
            .then((result) => {
                this.varList = result;
                this.error = undefined;


                this.dataArray=result;
               
                if(this.dataArray.length<0){
                    console.log('No Data');
                    this.noData =true;
                }

            })
            .catch((error) => {
                this.error = error;
                this.contacts = undefined;
            });
    }

    hideModalBox() {  
        this.isShowModal = false;
    }
    // connectedCallback(){

    //     // setTimeout(() => {
    //     //    this.handleSortData();
    //     // }, 100);
    // }

    handleSortData(event) {
            const { fieldName: sortedBy, sortDirection: sortedDirection } = event.detail;
            const cloneData = [...this.varList];
            cloneData.sort((a, b) => {
              if (a[sortedBy] > b[sortedBy]) {
                return sortedDirection === "asc" ? 1 : -1;
              } else if (a[sortedBy] < b[sortedBy]) {
                return sortedDirection === "asc" ? -1 : 1;
              } else {
                return 0;
              }
            });
            this.varList = cloneData;
            this.sortedBy = sortedBy;
            this.sortedDirection = sortedDirection;
          }

 





}