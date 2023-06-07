import { track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getCase from '@salesforce/apex/OwnSendAnEmailFormController.getCase';
export default class ownCaseDetailClone extends OwnBaseElement {
    @track caseRecord = {};
    @track hideSpinner;
    @track showCommentBox;
    @track brand = 'Honda';
    @track caseNumber = '-';
    @track caseDetailsDataArray = [];
    @track breadCrumbUrl = '/my-cases';
    @track breadCrumbLabel = 'My Support Cases';
    @track addCommentButtonLabel = 'Add comment';

    @track icons = {
        png: this.myGarageResource() + '/ahmicons/image.svg',
        jpg: this.myGarageResource() + '/ahmicons/image.svg',
        jpeg: this.myGarageResource() + '/ahmicons/image.svg',
        pdf: this.myGarageResource() + '/ahmicons/adobe-pdf.svg',
        doc: this.myGarageResource() + '/ahmicons/document.svg',
        docx: this.myGarageResource() + '/ahmicons/document.svg'
    };

    connectedCallback() {
        let case_number = sessionStorage.getItem('caseNumber');
       // console.log('$CRRS: case_number: ',case_number);
        // case_number = '12636342';
        // case_number = '12636434';
        case_number = '12636435';
        if(case_number){
            getCase({caseNumber: case_number}).then((result) => {
               // console.log('$CRRS: getCase-result: ',result);
                this.caseRecord = JSON.parse(JSON.stringify(result));
                this.caseNumber = this.caseRecord.CaseNumber__c;
                this.caseRecord.CreatedOn = Intl.DateTimeFormat('en-US', {year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit'}).format(new Date(this.caseRecord.CreatedDate__c));
                this.caseRecord.CreatedDate__c = Intl.DateTimeFormat('en-US', {year: 'numeric', month: '2-digit', day: '2-digit'/*, hour: '2-digit', minute: '2-digit', second: '2-digit'*/}).format(new Date(this.caseRecord.CreatedDate__c));
                
                this.caseRecord.Topic_c__c = this.caseRecord.Topic_c__c ? this.caseRecord.Topic_c__c : this.caseRecord.WebToCase_Power_Equip_Product_Line_c__c ? this.caseRecord.WebToCase_Power_Equip_Product_Line_c__c : this.caseRecord.WebToCase_Marine_What_Engine_Size_c__c;
                this.caseRecord.Sub_topic_c__c = this.caseRecord.Sub_topic_c__c ? this.caseRecord.Sub_topic_c__c : this.caseRecord.WebToCase_Marine_do_you_need_help_with_c__c ? this.caseRecord.WebToCase_Marine_do_you_need_help_with_c__c : this.caseRecord.WebToCase_Marine_do_you_need_help_with_c__c;


                this.caseRecord.VIN_Text_c__c = this.caseRecord.VIN_Text_c__c ?? '-';
                this.caseRecord.Model_Manual_c__c = this.caseRecord.Model_Manual_c__c ?? '-';
                this.caseRecord.Year_manual_c__c = this.caseRecord.Year_manual_c__c ?? '-';
                this.caseRecord.Miles_c__c = this.caseRecord.Miles_c__c ?? '-';
                
                this.hideSpinner = true;
            }).catch((error) => {
                //console.error('$CRRS: getCase-error: ',error);
                this.hideSpinner = true;
            });
        }
    }
    addComment(){
        this.showCommentBox = true;
        this.addCommentButtonLabel = 'Add';
    }
    cancelComment(){
        this.showCommentBox = false;
        this.addCommentButtonLabel = 'Add comment';
    }
}