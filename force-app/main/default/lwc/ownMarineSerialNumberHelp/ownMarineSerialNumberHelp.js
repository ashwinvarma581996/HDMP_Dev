import { LightningElement, track, api } from 'lwc';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';
import basePath from '@salesforce/community/basePath';
export default class OwnMarineSerialNumberHelp extends OwnBaseElement {
    @api contentId;
    @track body;
    @track s;
    connectedCallback() {
        this.initialize();
    }

    initialize = async () => {
        let contentKeys = [this.contentId];
        let results = await getManagedContentByTopicsAndContentKeys(contentKeys, this.topics, this.pageSize, this.managedContentType);
        //console.log('result', this.image1)
        results.forEach(r => {
            if (r.body) {
                this.body = this.htmlDecode(r.body.value);
            }
        });
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }
    handleFindDealer() {
        sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: "Marine", divisionId: 'P' }));
        this.navigate('/find-a-dealer?brand=marine', {});
    }
}