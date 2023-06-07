import { LightningElement,api,wire,track } from 'lwc';
import searchBoilerPlate from '@salesforce/apex/BoilerplateDetails.searchBoilerPlate'

export default class Customlookup extends LightningElement {
    @api childObjectApiName ; //Contact is the default value
    @api targetFieldApiName ; //AccountId is the default value
    @api fieldLabel ;
    @api disabled = false;
    @api value;
    @api required = false;
    @api offer;
    @track records = ['1','Test 1', 'Test 2'];
    @api searchPlaceholder='Search Boilerplates';
    @track searchName;
    @track records;
    @track isValueSelected = false;
    @track selectedName;
    @track selectedId;
    @track searchedRecords;
    @track searchTerm;
    @api recordId;
    @track showErrorData = true;
    @track showRequired = true;

    @track selectBoilerplateOption = [];

    picklistOrdered;
    searchResults;
    selectedSearchResult;
    @track oldvalue;


    handleValueChange() {
        // Creates the event

        const selectedEvent = new CustomEvent('valueselected', {
            detail:{
                value:this.selectedId
            } 
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    } /*
    searchBoilerPlate(){
        searchBoilerPlate({offerId : this.offer, searchName : this.searchName})
        .then((result) => {
            console.log('printing delete',result);
            this.records = result;
            this.searchedRecords = result;
            if(this.value != null && this.value != '' && this.value != undefined){
                for(let i= 0; i<this.records.length;i++){
                    if(this.records[i].Id === this.value){
                        this.isValueSelected = true;
                        this.selectedName = this.records[i].Name;
                    }
                }
            }
            
        })
        .catch(error => {
          this.error = error;
        })
    }
*/

searchBoilerPlate(){
    searchBoilerPlate({offerId : this.offer, searchName : this.searchName})
    .then((result) => {
        if(result.length > 0){
            this.showErrorData = false;
        }
        console.log('printing boilerplate',result);
        this.records = result;
        for(const list of  this.records){
            const option = {
                label: list.Name,
                value: list.Name
            };
            this.selectBoilerplateOption = [ ...this.selectBoilerplateOption, option ];

            console.log('printing options',this.selectBoilerplateOption);

            if(list.Id === this.value){
                this.selectedName = list.Name;
            }
            
            
        }
        
    })
    .catch(error => {
      this.error = error;
    })
}
handleChangeBoierplate(event){
    this.selectedName = event.target.value;
    for(const list of  this.records){
        if(list.Name === this.selectedName){
            this.selectedId = list.Id;
        }
    }
    this.handleValueChange();

}
    @api isValid() {
        if (this.required) {
           // this.template.querySelector('lightning-input-field').reportValidity();
        }
    }   

    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        this.selectedId = selectedId;
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
        console.log('printing delected Id',selectedName);
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        this.handleValueChange();
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }
    handleRemovePill() {
        this.isValueSelected = false;
    }
    onSelectOption(event){

    }

    handleClick(event) {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
        this.searchTerm = event.target.value;
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }
    connectedCallback(){
        console.log('printing value',this.value);
        this.searchBoilerPlate();
    }

    onChange(event) {
        this.searchedRecords = [];
        this.searchTerm = event.target.value;
        for(const list of  this.records){
            if(list.Name.includes(this.searchName)){
                this.searchedRecords.add(list);
            }
        }

    }

    
  get selectedValue() {
    return this.selectedSearchResult ? this.selectedSearchResult.label : null;
  }

  /*connectedCallback() {
    getValuesFromTable().then((result) => {
        this.picklistOrdered = result.map(({value: label, key: value}) => ({ label,value}))
        this.picklistOrdered = this.picklistOrdered.sort((a,b)=>{
            if(a.label < b.label){
                return -1
            }
        })
    })
  }*/

  search(event) {
    if(event.target.value === '' || event.target.value === null || event.target.value === undefined){
        this.selectedName = '';
        this.selectedId = '';
        this.handleValueChange();
        console.log('inside handle change');
    }
    //this.selectedName = event.detail.value;
    const input = event.detail.value.toLowerCase();
    const result = this.selectBoilerplateOption.filter((picklistOption) =>
      picklistOption.label.toLowerCase().includes(input)
    );
    this.searchResults = result;
  }

  selectSearchResult(event) {
    this.oldvalue = this.selectedName;
    this.selectedName = event.currentTarget.dataset.value;
    this.showRequired = false;
    const selectedValue = event.currentTarget.dataset.value;
    console.log('@@@ oldvalue',this.oldvalue);
    console.log('@@printing selected Name',this.selectedName);

      for(const list of this.records){
        if(list.Name === selectedValue){
            this.selectedId = list.Id;
            console.log('@@@ id ',list.Id);
            }
    }
    if(this.oldvalue !== this.selectedName){
        this.handleValueChange();
    }
    this.clearSearchResults();
  }

  clearSearchResults() {
    this.searchResults = null;
  }

  showPicklistOptions() {
    //console.log('inside Focus',This.selectedName +' ', this.selectedId);
    if (!this.searchResults) {
      this.searchResults = this.selectBoilerplateOption;
    }
  }


}