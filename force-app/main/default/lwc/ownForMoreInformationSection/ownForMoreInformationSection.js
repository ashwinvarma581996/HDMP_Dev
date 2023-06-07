import { api, track, wire } from 'lwc';
import { ISGUEST, getOrigin, getContext,  getManagedContentByTopicsAndContentKeys, getDate} from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';
import basePath from '@salesforce/community/basePath';
export default class ownForMoreInformationSection extends OwnBaseElement {
    @api contentKey;
    @api noRecalls;
    @api divisionId;
    @api brand;
    @track pspAdditionalInfo = {};
    connectedCallback() {
        //console.log('$RECALLS: contentKey: ',this.contentKey);
        //console.log('$RECALLS: noRecalls: ',this.noRecalls);
        //console.log('$RECALLS: divisionId: ',this.divisionId);
        this.initialize();
    }
    initialize = async () => {
        let contentKeys = [this.contentKey];
        let results = await getManagedContentByTopicsAndContentKeys(contentKeys, this.topics, this.pageSize, this.managedContentType);
        //console.log('$RECALLS: results: ',results);
        results.forEach(r => {
            this.pspAdditionalInfo.title = r.title.value;
            this.pspAdditionalInfo.more_info = this.removeTags(this.htmlDecode(r.body.value));
            this.pspAdditionalInfo.more_info_link = this.removeTags(this.htmlDecode(r.descriptionContent.value));
            
            this.pspAdditionalInfo.sec_1_head = r.subTitle.value;
            this.pspAdditionalInfo.sec_1_phone = r.phoneNumber.value;
            this.pspAdditionalInfo.sec_1_phone_link = 'tel:' + r.phoneNumber.value;
            this.pspAdditionalInfo.sec_1_phone_label = r.phoneLabel.value;
            this.pspAdditionalInfo.sec_1_time_label = this.removeTags(this.htmlDecode(r.sectionContent.value));
            this.pspAdditionalInfo.sec_1_time = this.removeTags(this.htmlDecode(r.description2Content.value));

            this.pspAdditionalInfo.sec_2_head = r.descriptionLabel.value;
            this.pspAdditionalInfo.sec_2_content_text = r.description2Label.value;
            this.pspAdditionalInfo.sec_2_phone = r.phone2Number.value;
            this.pspAdditionalInfo.sec_2_phone_link = 'tel:' + r.phone2Number.value;
            this.pspAdditionalInfo.sec_2_phone_label = r.phone2Label.value;
            this.pspAdditionalInfo.sec_2_link = r.sectionLabel.value;

            this.pspAdditionalInfo.content_text = 'This website provides information about safety recalls announced in the past 15 calendar years; older recalls are not included.';
        });
        //console.log('$RECALLS: pspAdditionalInfo: ',JSON.parse(JSON.stringify(this.pspAdditionalInfo)));
    }
    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }
    removeTags = (text) => {
        return text.replace(/(<([^>]+)>)/ig, '');
    }
    async navigateToDealer(){
        this.publishToChannel({eventType: "click-event", eventMetadata: {action_type: "button", action_category: "body", action_label: "nearby dealers:More Dealers"} });
        sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: this.brand, divisionId: this.divisionId }));
        await this.sleep(2000);
        this.navigate('/find-a-dealer', {});
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}