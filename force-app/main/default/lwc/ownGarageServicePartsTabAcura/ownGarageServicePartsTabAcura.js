import { LightningElement, track, api } from 'lwc';

export default class OwnGarageServicePartsTabAcura extends LightningElement {
    @api roadsideAssistanceCardContent;
    pageDetails = {
        value: 'Service & Parts',
        label: 'Service & Parts',
        type: '',
        url: window.location.href
    };
}