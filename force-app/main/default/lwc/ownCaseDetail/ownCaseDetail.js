import { track, wire, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCase from '@salesforce/apex/OwnSendAnEmailFormController.getCase';
import reOpenCase from '@salesforce/apex/OwnSendAnEmailFormController.reOpenCase';
import createFeedItem from '@salesforce/apex/OwnSendAnEmailFormController.createFeedItem';
import getCaseComments from '@salesforce/apex/OwnSendAnEmailFormController.getCaseComments';
import getAttachmentBody from '@salesforce/apex/OwnSendAnEmailFormController.getAttachmentBody';
import addMoreAttachment from '@salesforce/apex/OwnSendAnEmailFormController.addMoreAttachment';
import getCaseAttachments from '@salesforce/apex/OwnSendAnEmailFormController.getCaseAttachments';
import getAttachmentUrl from '@salesforce/apex/OwnSendAnEmailFormController.getAttachmentUrl';
export default class ownCaseDetail extends OwnBaseElement {
    @track pageLoaded;
    @track hideSpinner;
    @track retryCount = 0;
    @track attachmentTitle;
    @track caseExternalId;
    @track showCommentBox;
    @track brand = 'Honda';
    @track caseRecord = {};
    @track caseNumber = '-';
    @track showCancelButton;
    @track isFileDownloading;
    @track currentCasesCount;
    @track commentValue = '';
    @track fetchingAttachment;
    @track caseComments;
    @track caseComment_index = 1;
    @track caseComments_all = [{}];
    @track caseComment_initial_count = 3;
    @track caseComments_all_map = new Map();
    @track caseComments_show_load_more = false;
    @track showCommentSaveSpinner;
    @track showAttachmentErrorBox;
    @track caseAttachments = [{}];
    @track caseDetailsDataArray = [];
    @track breadCrumbUrl = '/my-cases';
    @track breadCrumbLabel = 'My Support Cases';
    @track addCommentButtonLabel = 'Add Comment';
    @track loadMoreCommentsLabel = 'Load More Comments...';

    @track icons = {
        png: this.myGarageResource() + '/ahmicons/image.svg',
        jpg: this.myGarageResource() + '/ahmicons/image.svg',
        jpeg: this.myGarageResource() + '/ahmicons/image.svg',
        pdf: this.myGarageResource() + '/ahmicons/adobe-pdf.svg',
        doc: this.myGarageResource() + '/ahmicons/document.svg',
        docx: this.myGarageResource() + '/ahmicons/document.svg',
        file: this.myGarageResource() + '/ahmicons/download-how-to-guide.svg'
    };

    @wire(getAttachmentBody, { caseExternalId: '$caseExternalId' })
    wiredData({error, data}){
        if(data){
            ////console.log('$Data', data);
            try{
                const byteCharacters = atob(data);
                const byteNumbers = new Array(byteCharacters.length);
                for (let i = 0; i < byteCharacters.length; i++){
                    byteNumbers[i] = byteCharacters.charCodeAt(i);
                }
                const byteArray = new Uint8Array(byteNumbers);
                const fileUrl = URL.createObjectURL(new Blob([byteArray], { type: "application/octet-stream" }));
                const link = document.createElement('a');
                link.href = fileUrl;
                link.download = this.attachmentTitle;
                link.click();
                this.isFileDownloading = false;

                /* const pdfData = data;
                const byteCharacters = atob(pdfData);
                const byteArrays = [];
                for (let offset = 0; offset < byteCharacters.length; offset += 512) {
                    const slice = byteCharacters.slice(offset, offset + 512);

                    const byteNumbers = new Array(slice.length);
                    for (let i = 0; i < slice.length; i++) {
                        byteNumbers[i] = slice.charCodeAt(i);
                    }

                    const byteArray = new Uint8Array(byteNumbers);
                    byteArrays.push(byteArray);
                }
                const blob = new Blob(byteArrays, { type: 'application/pdf' });
                // const blob = new Blob(byteArrays, { type: 'image/png' });

                const pdfUrl = URL.createObjectURL(blob);
                const anchor = document.createElement('a');
                anchor.href = pdfUrl;
                anchor.target = '_blank';

                anchor.dispatchEvent(new MouseEvent('click'));

                URL.revokeObjectURL(pdfUrl);

                this.isFileDownloading = false; */

            }catch(error){
               //console.error('$error: ', error);
               const event = new ShowToastEvent({
                   title : 'Error',
                   variant : 'error',
                   message : 'Unexpected error occured.'
               });
               this.dispatchEvent(event);
               this.isFileDownloading = false;
            }
        }else if(error){
            //console.error('$Error:', error);
            const event = new ShowToastEvent({
                title : error.body.exceptionType,
                variant : 'error',
                message : error.body.message
            });
            this.dispatchEvent(event);
            this.isFileDownloading = false;
        }
    }

    onAttachmentClick(event){
        let c_title = event.target.dataset.c_title;
        let c_ext_id = event.target.dataset.c_ext_id;
        let c_doc_id = event.target.dataset.c_doc_id;
        let c_size = parseInt(event.target.dataset.c_size);
        //console.log('$c_title: ',c_title);
        //console.log('$c_ext_id: ',c_ext_id);
        //console.log('$c_doc_id: ',c_doc_id);
        //console.log('$c_size: ',c_size);

        const fileSizeInMB = c_size / (1024 * 1024);
        //console.log('$fileSizeInMB: ',fileSizeInMB);
        if (fileSizeInMB > 5.5) {
            //console.log("File size is more than 6 MB.");
            this.isFileDownloading = true;
            getAttachmentUrl({documentId: c_doc_id}).then((result) => {
                //console.log('$getAttachmentUrl-result: ',result);
                let publicURL = result.PublicURL;
                //console.log('$publicURL: ',publicURL);
                const link = document.createElement('a');
                link.href = publicURL;
                link.download = c_title;
                link.click();
                this.isFileDownloading = false;
            }).catch((error) => {
                //console.error('$getAttachmentUrl-error: ',error);
                const event = new ShowToastEvent({
                    title : error.body.exceptionType,
                    variant : 'error',
                    message : error.body.message
                });
                this.dispatchEvent(event);
                this.isFileDownloading = false;
            });
        }else {
            this.isFileDownloading = true;
            this.attachmentTitle = c_title;
            this.caseExternalId = c_ext_id;
        }

    }
    
    connectedCallback() {
        this.initialize();
    }
    @track isAcura = false;
    @track isHonda = false;
    @track isPSP = false;
    @track isPE = false;
    @track isMarine = false;
    @track isPEOrMarine = false;
    initialize = async () => {
        let url = new URL(window.location.href);
        let number = url.searchParams.get('number');
        //console.log('$number: ',number);

        // let case_number = sessionStorage.getItem('caseNumber');
        let case_number = number ? number : sessionStorage.getItem('caseNumber');
        //console.log('$CRRS: case_number: ',case_number);
        // case_number = '12636342';
        // case_number = '12636434';
        //case_number = '12636435';
        if(case_number){
            getCase({caseNumber: case_number}).then((result) => {
                //console.log('$CRRS: getCase-result: ',result);
                this.caseRecord = JSON.parse(JSON.stringify(result));

                this.isAcura = this.caseRecord.WebtoCase_Make_c__c == 'Acura';
                this.isHonda = this.caseRecord.WebtoCase_Make_c__c == 'Honda';
                this.isPSP = this.caseRecord.WebtoCase_Make_c__c == 'Motorcycle';
                this.isPE = this.caseRecord.WebtoCase_Make_c__c == 'Power Equipment';
                this.isMarine = this.caseRecord.WebtoCase_Make_c__c == 'Marine';
                this.isPEOrMarine = this.caseRecord.WebtoCase_Make_c__c == 'Marine' || this.caseRecord.WebtoCase_Make_c__c == 'Power Equipment';

                //console.log('$isAcura: ',this.isAcura);
                //console.log('$isHonda: ',this.isHonda);
                //console.log('$isPSP: ',this.isPSP);
                //console.log('$isPE: ',this.isPE);
                //console.log('$isMarine: ',this.isMarine);
                //console.log('$isPEOrMarine: ',this.isPEOrMarine);

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

                //Get Attachments
                this.initializeAttachments();
                this.initializeComments();
            }).catch((error) => {
                //console.error('$CRRS: getCase-error: ',error);
                this.hideSpinner = true;
            });
        }
    }
    initializeMap(){
        let i = 0;
        let mapIndex = 1;
        let tabledata_chunk = [];
        this.caseComment_index = 1;
        this.caseComments_all_map = new Map();
        for(let val of this.caseComments_all) {
            if(i == this.caseComment_initial_count){
                this.caseComments_all_map.set(mapIndex, tabledata_chunk);
                tabledata_chunk = [];
                tabledata_chunk.push({ ...val });
                i = 1;
                mapIndex++;
            }else{
                tabledata_chunk.push({ ...val });
                i++;
            }
        }
        if(tabledata_chunk.length){
            this.caseComments_all_map.set(mapIndex, tabledata_chunk);
        }
        this.caseComments = this.caseComments_all_map.get(this.caseComment_index);
        if(this.caseComments_all.length > this.caseComment_initial_count){
            this.caseComments_show_load_more = true;
        }
    }
    handleLoadMore(){

        if(this.loadMoreCommentsLabel == 'Show Less Comments...'){
            this.loadMoreCommentsLabel = 'Load More Comments...';
            this.initializeMap();
            this.scroll(this.template.querySelector('.comm-heading'));
            // this.template.querySelector('.comm-heading').scrollIntoView({ behavior: "auto", block: "center", inline: "nearest" });
            return;
        }

        this.caseComment_index ++;
        if(this.caseComments_all_map.has(this.caseComment_index)){
            this.caseComments = [...this.caseComments, ...this.caseComments_all_map.get(this.caseComment_index)];
            //console.log('$CRRS: caseComments: ',JSON.parse(JSON.stringify(this.caseComments)));
            if(this.caseComments_all_map.size == this.caseComment_index){
                // this.caseComments_show_load_more = false;
                this.loadMoreCommentsLabel = 'Show Less Comments...';
            }else{
                // this.template.querySelector('.load-more-div').scrollIntoView();
            }
        }else{
            this.caseComment_index --;
        }
    }
    async initializeComments(){
        await getCaseComments({caseExternalId: this.caseRecord.ExternalId}).then((result) => {
            //console.log('$CRRS: getCaseComments-result: ',result);
            if(result.length){
                let data = JSON.parse(JSON.stringify(result));
                data.forEach(val => {
                    val.class = val.UserName == 'Customer Relations' ? 'comment-avatar gray-avatar' : 'comment-avatar';
                    val.SmallPhotoUrl = val.UserName == 'Customer Relations' ? this.ownerResource() + '/Icons/user.svg' : val.SmallPhotoUrl;
                    val.CreatedDate = Intl.DateTimeFormat('en-US', {year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit'}).format(new Date(val.CreatedDate));
                });
                this.caseComments_all = [...data];
                this.initializeMap();
                //console.log('$CRRS: caseComments_all_map: ',this.caseComments_all_map);
                //console.log('$CRRS: caseComments: ',JSON.parse(JSON.stringify(this.caseComments)));
                //console.log('$CRRS: caseComments_all: ',JSON.parse(JSON.stringify(this.caseComments_all)));
            }
        }).catch((error) => {
            console.error('$CRRS: getCaseComments-error: ',error);
            const event = new ShowToastEvent({
                title : error.body.exceptionType,
                variant : 'error',
                message : error.body.message
            });
            this.dispatchEvent(event);
        });
    }

    handleCommentValue(event){
        let value = event.target.value;
        //console.log('$value: ',value);
        this.commentValue = value;
        //console.log('$CRRS: commentValue: ',this.commentValue);
    }

    async initializeAttachments(){
        this.fetchingAttachment = true;
        // getCaseAttachments({caseExternalId: '500760000030JQHAA2'}).then((attachment) => {
        await getCaseAttachments({caseExternalId: this.caseRecord.ExternalId}).then((attachment) => {
            //console.log('$CRRS: getCaseAttachments-attachment: ',attachment);
            this.caseAttachments = JSON.parse(JSON.stringify(attachment));

            this.caseAttachments.forEach(val => {
                val.icon = this.icons[val.FileExtension__c] ? this.icons[val.FileExtension__c] : this.icons['file'];
                val.Title__c = val.Title__c + '.' + val.FileExtension__c;
                val.CreatedDate__c = Intl.DateTimeFormat('en-US', {year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit'}).format(new Date(val.DisplayUrl));
            });

            //console.log('$CRRS: caseAttachments: ',JSON.parse(JSON.stringify(this.caseAttachments)));
            if(!this.pageLoaded){
                this.fetchingAttachment = false;
                this.currentCasesCount = this.caseAttachments.length;
                //console.log('$CRRS: currentCasesCount: ',this.currentCasesCount);
            }
        }).catch((error) => {
            //console.error('$CRRS: getCaseAttachments-error: ',error);
            this.fetchingAttachment = false;
            const event = new ShowToastEvent({
                title : error.body.exceptionType,
                variant : 'error',
                message : error.body.message
            });
            this.dispatchEvent(event);
        });
    }

    handleOnNavigate(){
        const cusEvent = new CustomEvent('navigate',{detail : ''});
        this.dispatchEvent(cusEvent);
    }

    get attLength(){
        return this.caseAttachments && this.caseAttachments.length ? this.caseAttachments.length : 0;
    }


    async handleOnfileupload(event){
        this.pageLoaded = true;
        this.fetchingAttachment = true;
        this.showAttachmentErrorBox = false;
        let file = [JSON.parse(JSON.stringify(event.detail))];
        //console.log('$CRRS: handleOnfileupload: ', file);
        addMoreAttachment({fileData_json: JSON.stringify(file), caseId: this.caseRecord.Id}).then(async (result) => {
            //console.log('$CRRS: addMoreAttachment-result: ',result);
            
            for(let i = 1; i <= 60; i++){
                await new Promise(resolve => setTimeout(resolve, 3000));
                await this.initializeAttachments();
                if(this.currentCasesCount != this.caseAttachments.length){
                    this.fetchingAttachment = false;
                    this.currentCasesCount = this.caseAttachments.length;
                    //console.log('$ATTEMPTS: ', i);
                    break;
                }

                if(i == 60){
                    if(this.currentCasesCount == this.caseAttachments.length){
                        this.showAttachmentErrorBox = true;
                        this.fetchingAttachment = false;
                    }
                }
            }

        }).catch((error) => {
            //console.error('$CRRS: addMoreAttachment-error: ',error);
            const event = new ShowToastEvent({
                title : error.body.exceptionType,
                variant : 'error',
                message : error.body.message
            });
            this.dispatchEvent(event);
        });
    }

    async addComment(){

        if(this.addCommentButtonLabel == 'Add'){
            if(this.commentValue){
                if(this.caseRecord.Status__c == 'Closed'){
                    this.showCommentSaveSpinner = true;
                    await reOpenCase({caseRecord: {Id: this.caseRecord.Id, Status__c: 'Re-opened'}}).then((result) => {
                        //console.log('$reOpenCase-result: ',result);
                        this.caseRecord.Status__c = 'Re-opened';
                        const cusEvent = new CustomEvent('updatestatus',{detail : this.caseRecord.CaseNumber__c});
                        this.dispatchEvent(cusEvent);
                    }).catch((error) => {
                        //console.error('$reOpenCase-error: ',error);
                        const event = new ShowToastEvent({
                            title : 'Unable to re-open case',
                            variant : 'error',
                            message : error.body.message
                        });
                        this.dispatchEvent(event);
                    });
                }

                this.showCommentSaveSpinner = true;
                //console.log('$CRRS: commentValue: ',this.commentValue);
                createFeedItem({parentId: this.caseRecord.ExternalId, messageBody: this.commentValue, visibilityValue: 'AllUsers'}).then(async (result) => {
                    //console.log('$CRRS: createFeedItem-result: ',result);
                    await this.initializeComments();
                    this.showCommentBox = false;
                    this.addCommentButtonLabel = 'Add Comment';
                    this.showCancelButton = false;
                    this.commentValue = '';
                    this.showCommentSaveSpinner = false;
                }).catch((error) => {
                    //console.error('$CRRS: createFeedItem-error: ',error);
                    const event = new ShowToastEvent({
                        title : error.body.exceptionType,
                        variant : 'error',
                        message : error.body.message
                    });
                    this.dispatchEvent(event);
                    this.showCommentSaveSpinner = false;
                });
            }
        }else{
            this.showCommentBox = true;
            this.addCommentButtonLabel = 'Add';
            this.showCancelButton = true;
        }

    }
    cancelComment(){
        this.showCommentBox = false;
        this.addCommentButtonLabel = 'Add Comment';
        this.showCancelButton = false;
    }

    renderedCallback() {
        if(this.template.querySelector('.loading-acc-div') && this.pageLoaded){
            this.scroll(this.template.querySelector('.loading-acc-div'));
        }
        if(this.template.querySelector('c-own-send-an-email-form-file')){
            const style = document.createElement('style');
            style.innerText = `
                .file-name{
                    color: black;
                    font-weight: normal;
                }
                .inp-file-label{
                    font-weight: 500;
                }
            `;
            this.template.querySelector('c-own-send-an-email-form-file').appendChild(style);
        }
        if(this.template.querySelector('lightning-tabset')){
            const style = document.createElement('style');
            style.innerText = `
                .custom-tab .slds-tabs_default__item.slds-is-active:after{
                    background-color: transparent;
                }
                .custom-tab .slds-tabs_default__nav{
                    pointer-events: none;
                }
                .custom-tab .slds-tabs_default__item:hover:after{
                    background-color: transparent;
                }
                .custom-tab .slds-tabs_default__link{
                    color: black;
                    font-size: 15px;
                    font-weight: 500 !important;
                }
            `;
            this.template.querySelector('lightning-tabset').appendChild(style);
        }
    }

    @api
    refreshComp(){
        //console.log('$refreshComp');
    }

    scroll(element) {
        element.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
    }
}