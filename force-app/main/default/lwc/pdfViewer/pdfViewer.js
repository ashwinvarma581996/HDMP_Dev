import { LightningElement, track } from 'lwc';

export default class pdfViewer extends LightningElement {
    @track pdfSrc;
    connectedCallback(){
        let srcLink = sessionStorage.getItem('pdflink');
        document.title = srcLink.substring(srcLink.lastIndexOf('/') + 1);
        console.log('srcLink: ',srcLink);
        this.pdfSrc = srcLink;
    }
}