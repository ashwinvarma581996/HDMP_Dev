//============================================================================
// Title:    Honda MyGarage Experience - Promotional Hero
//
// Summary:  This is the Subscription Card html seen at the page of the Honda MyGarage Community 
//
// Details: Subscription Card for pages
//
// History:
// December 20, 2021 Ravindar Ravindra (Wipro) Original Author 
//=========================================================================== -->
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';

export default class OwnSubscriptionCard extends OwnBaseElement {
	@api contentIdMain;
	@api contentIdLinks;
	@api brand;
	@api icon;
	@api title;
	@api titlecolor;
	@api headerlink;
	@api showforwardicon;
	@api showfooter;
	@track contentKeys = [];
	@track topics = null;
	@track pageSize = null;
	@track managedContentType = '';
	@track results;
	@track body;
	@track phoneFields = [];
	@track phoneLabel;
	@track phoneNumber;
	@track phoneLink;
	@track phone2Label;
	@track phone2Number;
	@track phone2Link;
	@track phone3Label;
	@track phone3Number;
	@track phone3Link;
	@track phone4Label;
	@track phone4Number;
	@track phone4Link;
	get bodyClass() {
		return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body';
	}

	get titleClass() {
		return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
	}

	get iconClass() {
		return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
	}
	connectedCallback() {
		this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
		this.initialize();
	}

	initialize = async () => {
		this.contentKeys.push(this.contentIdMain);
		this.contentKeys.push(this.contentIdLinks);

		//this.contentKeys.push(this.contentIdB);
		this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
		this.results.forEach(r => {
			if (r.title.value.toLowerCase().includes('main')) {
				this.title = this.title ? this.title : this.htmlDecode(r.title.value);
				this.body = r.body ? this.htmlDecode(r.body.value) : false;
				this.phoneLabel = r.phoneLabel ? this.htmlDecode(r.phoneLabel.value) : false;
				this.phoneNumber = r.phoneNumber ? r.phoneNumber.value : false;
				this.phone2Label = r.phone2Label ? this.htmlDecode(r.phone2Label.value) : false;
				this.phone2Number = r.phone2Number ? r.phone2Number.value : false;
				this.phone3Label = r.phone3Label ? this.htmlDecode(r.phone3Label.value) : false;
				this.phone3Number = r.phone3Number ? r.phone3Number.value : false;
				this.phone4Label = r.phone4Label ? this.htmlDecode(r.phone4Label.value) : false;
				this.phone4Number = r.phone4Number ? r.phone4Number.value : false;
			}else{
				this.phoneLink = r.phoneNumber ? r.phoneNumber.value : false;
				this.phone2Link = r.phone2Number ? r.phone2Number.value : false;
				this.phone3Link = r.phone3Number ? r.phone3Number.value : false;
				this.phone4Link = r.phone4Number ? r.phone4Number.value : false;
			}
		});
		//let contentKey2 = [];
		//contentKey2.push(this.contentIdLinks);
		//let results2 = await getManagedContentByTopicsAndContentKeys(this.contentKey2, this.topics, this.pageSize, this.managedContentType);
		// results2.forEach(r => {
		// this.phoneLink = results2[0].phoneNumber ? results2[0].phoneNumber.value : false;
		// this.phone2Link = results2[0].phone2Number ? results2[0].phone2Number.value : false;
		// this.phone3Link = results2[0].phone3Number ? results2[0].phone3Number.value : false;
		// this.phone4Link = results2[0].phone4Number ? results2[0].phone4Number.value : false;
		// });


		this.pushPhoneInfo(this.phoneLabel, this.phoneNumber, this.phoneLink);
		this.pushPhoneInfo(this.phone2Label, this.phone2Number, this.phone2Link);
		this.pushPhoneInfo(this.phone3Label, this.phone3Number, this.phone3Link);
		this.pushPhoneInfo(this.phone4Label, this.phone4Number, this.phone4Link);

	};

	pushPhoneInfo(label, number, link) {
		if (label || number || link) {
			this.phoneFields.push({
				label: label,
				value: number,
				link: link,
				readonly: label ? label.toLowerCase().includes('fax') ? true : false : false,
			});
		}
	}

	handleClickHeader() {
		this.navigate(this.headerlink, {});
	}

	//DOE-4594 Ravindra Ravindra (Wipro)
	handlePhoneLinkClick(event) {
		let url = event.currentTarget.dataset.link;
		url = url.includes('https://') || url.includes('http://') ? url : 'https://' + url;
		window.open(url, "_blank");

	}

	handleClickFooter() {

	}
	htmlDecode(input) {
		if (!input) return '';
		let doc = new DOMParser().parseFromString(input, "text/html");
		return doc.documentElement.textContent;
	}

}