import { track, api } from 'lwc';
import { ISGUEST, getManagedContentByTopicsAndContentKeys} from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';

import getCases from '@salesforce/apex/OwnSendAnEmailFormController.getCases';
export default class ownMyCases extends OwnBaseElement {
    @api disclaimer;
    @api title;
    @api body;
    @track cases = [];
    @track allCases = [];
    @track allCases_clone = [];
    @track allCasesMap = new Map();
    @track breadCrumbLabel = 'Home';
    @track breadCrumbUrl = '/';
    @track brand = 'Honda';
    @track hideSpinner;
    @track showCaseDetail;
    @track showingLabel = 'Showing 0 to 0 of 0 entries';
    connectedCallback(){
        this.initialize();
        this.filterBycolums.pop();
        this.initialize_getCases();
        
    }
    
    initialize_getCases = async () => {
        if(!ISGUEST){
            getCases().then((result) => {
                //console.log('$CRRS: getCases-result: ',result);
                this.cases = JSON.parse(JSON.stringify(result));
                this.cases.forEach(val => {
                    val.CreatedDate__c = Intl.DateTimeFormat('en-US', {year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit'}).format(new Date(val.CreatedDate__c));
                });
                this.hideSpinner = true;
                
                this.allCases = [...this.cases];
                this.allCases_clone = [...this.cases];
                //console.log('$Name-allCases: ',JSON.parse(JSON.stringify(this.allCases)));
                this.initializeMap();
                if(sessionStorage.getItem('caseNumberDetail')){
                    this.handleViewCase({
                        target: {
                            dataset: {
                                number: sessionStorage.getItem('caseNumberDetail')
                            }
                        }
                    });
                    sessionStorage.removeItem('caseNumberDetail')
                }
            }).catch((error) => {
                //console.error('$CRRS: getCases-error: ',error);
                this.hideSpinner = true;
            });
        }
    }
    
    initialize = async () => {
        this.results = await getManagedContentByTopicsAndContentKeys([this.disclaimer], null, null, '');
        //console.log('$CRRS: results: ',JSON.parse(JSON.stringify(this.results)));
        this.results.forEach(r => {
            this.title = r.phoneLabel && r.phoneLabel.value ? r.phoneLabel.value : this.title;
            this.body = this.removeTags(this.htmlDecode(r.body.value));
        });
    }
    
    initializeMap(){
        let i = 0;
        let mapIndex = 1;
        let cases_chunk = [];
        this.allCasesMap = new Map();
        for(let val of this.allCases) {
            if(i == this.selectedPageSize){
                this.allCasesMap.set(mapIndex, cases_chunk);
                cases_chunk = [];
                cases_chunk.push(JSON.parse(JSON.stringify(val)));
                i = 1;
                mapIndex++;
            }else{
                cases_chunk.push(JSON.parse(JSON.stringify(val)));
                i++;
            }
        }
        if(cases_chunk.length){
            this.allCasesMap.set(mapIndex, cases_chunk);
        }
        this.cases = this.allCasesMap.get(this.currentPage);
        let min = 0;
        let max = 0;
        for(let i = 1 ; i <=  this.currentPage ; i++){
            //console.log('$i: ',i);
            max += this.allCasesMap.get(i).length;
            min = max - this.allCasesMap.get(i).length;
            min++;
        }
        //console.log('$min: ',min);
        //console.log('$max: ',max);
        this.showingLabel = 'Showing ' + min + ' to ' + max + ' of ' + this.allCases.length + ' entries';
    }

    @track selectedPageSize = 10;
    @track pageSizeList = [
        {
            value: 3,
            defaultSelected : false
        },
        {
            value: 5,
            defaultSelected : false
        },
        {
            value: 10,
            defaultSelected : true
        },
        {
            value: 15,
            defaultSelected : false
        },
        {
            value: 20,
            defaultSelected : false
        },
        {
            value: 25,
            defaultSelected : false
        },
        {
            value: 50,
            defaultSelected : false
        },
        {
            value: 100,
            defaultSelected : false
        }
    ];
    handlePageSelect(event){
        //console.log('called: ' +  event.target.value);
        this.selectedPageSize = parseInt(event.target.value);
        //console.log(this.selectedPageSize); 
        this.currentPage = 1;
        this.initializeMap([...this.allCases]);
        if(this.template.querySelector('.inp-search')){
            this.handleSearch({target: {value: this.template.querySelector('.inp-search').value}});
        }
    }
    
    @track colums = [
        {
            label: "Case Number",
            apiName: "CaseNumber__c",
            class: 'th Case-Number',
            defaultSelected : false
        },
        {
            label: "Subject",
            apiName: "Subject__c",
            class: 'th Subject',
            defaultSelected : false
        },
        {
            label: "Status",
            apiName: "Status__c",
            class: 'th Status',
            defaultSelected : false
        },
        {
            label: "Make",
            apiName: "WebtoCase_Make_c__c",
            class: 'th Make',
            defaultSelected : false
        },
        {
            label: "VIN / Serial Number",
            apiName: "VIN_Text_c__c",
            class: 'th VIN-Serial-Number',
            defaultSelected : false
        },
        /* {
            label: "Description",
            apiName: "Description__c",
            class: 'th Description',
            defaultSelected : false
        }, */
        {
            label: "Created Date",
            apiName: "CreatedDate__c",
            class: 'th Created-Date',
            defaultSelected : false
        },
        {
            label: "",
            apiName: "",
            class: 'th',
            defaultSelected : false
        }
    ];

    handleSearch(event){
        try {	
            this.currentPage = 1;
            this.initializeMap();
        }catch(error) {}
        let value = event.target.value;
        //console.log('$value: ',value);
        if(value){
            if(this.filterBycolumValue == 'All'){
                let sub_cases = [];
                for(let cs of [...this.allCases_clone]){
                    let value_found = false;
                    for(let col of this.colums){
                        if(!value_found){
                            if(cs[col.apiName]){
                                value_found = ("" + cs[col.apiName].toLowerCase()).includes(value.toLowerCase());
                            }
                        }else{
                            break;
                        }
                    }
                    if(value_found)
                        sub_cases.push(JSON.parse(JSON.stringify(cs)));
                }
                this.allCases = [...sub_cases];
                if(!this.allCases.length){
                    this.showingLabel = 'Showing 0 to 0 of ' + this.allCases.length + ' entries';
                }
                this.initializeMap();
            }else{
                let element = this.colums.find(col => {
                    return col.label == this.filterBycolumValue;
                });
                let sub_cases = [];
                for(let cs of [...this.allCases_clone]){
                    let value_found = false;
                    if(cs[element.apiName]){
                        value_found = ("" + cs[element.apiName].toLowerCase()).includes(value.toLowerCase());
                    }
                    if(value_found)
                        sub_cases.push(JSON.parse(JSON.stringify(cs)));
                }
                this.allCases = [...sub_cases];
                if(!this.allCases.length){
                    this.showingLabel = 'Showing 0 to 0 of ' + this.allCases.length + ' entries';
                }
                this.initializeMap();
            }
        }else{
            this.allCases = [...this.allCases_clone];
            this.initializeMap();
        }
    }

    @track filterBycolumValue = "All";
    @track filterBycolums = [
        {
            label: "All",
            apiName: "All",
            defaultSelected : true
        }, ...this.colums
    ];
    handleFilterByColumn(event){
        //console.log('called: ' +  event.target.value);
        this.filterBycolumValue = event.target.value;
        //console.log(this.filterBycolumValue);
        if(this.template.querySelector('.inp-search')){
            this.handleSearch({target: {value: this.template.querySelector('.inp-search').value}});
        }
    }

    @track currentPage = 1;

    onNavigationButtonClick(event){
        if(event.target.dataset.btn == 'first'){
            this.currentPage = 1;
            this.initializeMap();
        }else if(event.target.dataset.btn == 'previous'){
            if(this.currentPage > 1){
                this.currentPage --;
                this.initializeMap();
            }
        }else if(event.target.dataset.btn == 'next'){
            if(this.currentPage <= this.allCasesMap.size - 1){
                this.currentPage ++;
                this.initializeMap();
            }
        }else if(event.target.dataset.btn == 'last'){
            this.currentPage = this.allCasesMap.size;
            this.initializeMap();
        }
    }

    handleViewCase(event){
        let number = event.target.dataset.number;
        //console.log('$CRRS: number: ',number);
        sessionStorage.setItem('caseNumber', number);
        // this.navigate('/case-detail?number=' + number, {});
        // this.navigate('/case-detail', {});
        this.showCaseDetail = true;
    }
    @api
    hideCaseDetail(){
        this.showCaseDetail = false;
        this.currentPage = 1;
        //console.log('$CRRS: hideCaseDetail: ',this.showCaseDetail);
        this.initialize_getCases();
        this.template.querySelector('c-own-case-detail').refreshComp();
    }

    @api
    updateStatus(event){
    //    console.log('$updateStatus event.detail: ', event.detail);
       let csNumber = event.detail;
       this.cases.forEach(val => {
           if(val.CaseNumber__c == csNumber){
                val.Status__c = 'Re-opened';
           }
       });
       this.allCases.forEach(val => {
           if(val.CaseNumber__c == csNumber){
                val.Status__c = 'Re-opened';
           }
       });
       
    }

    handleOnNavigate(){
        this.showCaseDetail = false;
    }
    htmlDecode(input) {
        if(!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
    removeTags = (text) => {
        return text.replace(/(<([^>]+)>)/ig, '');
    }
}