import { track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
export default class ownSendAnEmailFormFile extends OwnBaseElement {
    @api label = 'File';
    @track slected_file;
    @api required = false;
    @api showRequiredLabel = false;
    @api requiredLabel = 'Required File.';
    handleUploadFinished(event) {
        let uploadedFiles = event.detail.files;
        let file = {...uploadedFiles[0]};
        console.log('$CRRS: uploadedFiles: ', file);
        this.slected_file = file.name;
        const cusEvent = new CustomEvent('fileupload',{detail : {
            file : file,
            label : this.label,
            required : this.required,
        }});
        this.dispatchEvent(cusEvent);
    }
    renderedCallback() {
        if(this.template.querySelector('lightning-file-upload')){
            let ss = this.template.querySelector('lightning-file-upload');
            console.log('$ss: ',ss.innerText);
            const style = document.createElement('style');
            style.innerText = `
                .slds-file-selector__body{
                    border: 1px solid #E42525;
                }
                .slds-file-selector__text {
                    color: #E42525;
                    display: none;
                    font-size: 16px;
                }
                .slds-file-selector__button {
                    background-color: white;
                    color: #E42525;
                    font-size: 16px;
                    border-radius: 0px;
                }
                .slds-form-element__label {
                    color: black;
                    font-weight: bold;
                }
                .slds-file-selector__dropzone {
                    border: 0px solid #E42525;
                    padding: 0px;
                }
                .slds-file-selector__button:hover {
                    background-color: #E42525;
                    color: white;
                }
                .slds-file-selector__button.slds-button.slds-button_neutral {
                    font-size: 0;
                }
                .slds-file-selector__button.slds-button.slds-button_neutral:after{
                    content: 'Choose File ';
                    color: #E42525;
                    font-size: 16px;
                }
                .slds-file-selector__button.slds-button.slds-button_neutral:hover:after{
                    color: white;
                    font-size: 16px;
                }
            `;
            this.template.querySelector('lightning-file-upload').appendChild(style);
        }
    }
    @api
    showErrorText(ms){
        if(this.template.querySelector('.required-file')){
            this.template.querySelector('.required-file').classList.add('shake');
            setTimeout( () => {
                this.template.querySelector('.required-file').classList.remove('shake');
            }, ms);
        }
    }
}