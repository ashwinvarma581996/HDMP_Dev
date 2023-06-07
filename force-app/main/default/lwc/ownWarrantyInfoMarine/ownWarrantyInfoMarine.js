import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
export default class ownWarrantyInfoMarine extends OwnBaseElement {
    @api contentIdMarinePage;
    @track contentBody;
    @track contentTitle;
    @api context;
    connectedCallback(){
        this.initialize();
    }
    initialize = async () => {
        //console.log('$ownWarrantyInfoMarine context - ',JSON.parse(JSON.stringify(this.context)));
        this.results = await getManagedContentByTopicsAndContentKeys([this.contentIdMarinePage], null, null, '');
        //console.log('$ownWarrantyInfoMarine CMS - ',JSON.parse(JSON.stringify(this.results)));
        this.results.forEach(r => {
            this.contentBody = this.htmlDecode(r.body.value);
            if(window.location.search == '?help=marine'){
                this.contentTitle = this.htmlDecode(r.title.value);
            }else{
                this.contentTitle = this.context && this.context.product && this.context.product.model + ' ' + this.htmlDecode(r.title.value);
            }
        });
    }
}