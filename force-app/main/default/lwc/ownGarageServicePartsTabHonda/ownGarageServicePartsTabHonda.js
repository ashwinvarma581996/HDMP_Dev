import {
    LightningElement,
    track,
    api
} from 'lwc';

export default class OwnGarageServicePartsTabHonda extends LightningElement {
    //static Jason  for roadside assistance card (waiting for cms content mapping)
    @api roadsideAssistanceCardContent;
    pageDetails = {
        value: 'Service & Parts',
        label: 'Service & Parts',
        type: '',
        url: window.location.href
    };
}