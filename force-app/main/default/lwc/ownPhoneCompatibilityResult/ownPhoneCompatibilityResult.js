import { api, LightningElement, track, wire } from 'lwc';
import getFeaturesByPhone from '@salesforce/apex/OwnAPIController.getFeaturesByPhone';
import { ISGUEST, getProductContext, getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';

const FIRST_COLUMN = ['Basic Features', 'Advanced Features', 'HondaLink', 'SMS/Text Messaging']
export default class OwnPhoneCompatibilityResult extends OwnBaseElement {

	@track firstColumnFeatures;
	@track secondColumnFeatures;
	@track modelId;// = 'FC3B3GJW';
	@track carrierId;// = '107';
	@track manufacturerId;// = '130';
	@track phoneId;// = '5473358';
	@track divisionId;// = 'A';
	@api hondaContentId;
	@api acuraContentId;
	@track errorLogo;
	@track isDataLoading = true;
    @track hasDataExist = false;
	contentKeys = [];
	@track disclaimer;

	connectedCallback() {
		this.initialize();
		this.errorLogo = this.myGarageResource() + '/ahmicons/warning.png';
	}

	initialize = async () => {
		try{
		this.context = await getProductContext('', true);
		if (this.context) {
			this.divisionId = this.context.product.divisionId;
			this.modelId = this.context.product.modelId;
			this.carrierId = this.context.product.phoneCarrierId;
			this.manufacturerId = this.context.product.manufacturerId;
			this.phoneId = this.context.product.phoneModelId;

			if (this.divisionId == 'A') {
				this.contentKeys.push(this.hondaContentId);
			} else {
				this.contentKeys.push(this.acuraContentId);
			}

			let results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
			this.disclaimer = this.htmlDecode(results[0].body.value);

			getFeaturesByPhone({ modelId: this.modelId, carrierId: this.carrierId, manufacturerId: this.manufacturerId, phoneId: this.phoneId, divisionId: this.divisionId })
				.then((result) => {
					//console.log('data  :-  ', result);
					if (result.hasData) {
						var data = result.featurecategory;
						this.firstColumnFeatures = [];
						this.secondColumnFeatures = [];
						data.forEach(element => {
							let topFeature = JSON.parse(JSON.stringify(element));
							if (topFeature.feature) {
								topFeature.feature = topFeature.feature.sort((a, b) => parseInt(a.sortOrder) - parseInt(b.sortOrder));
							}
							//console.log('topFeature  :-  ', topFeature);
							if (FIRST_COLUMN.includes(element.name)) {
								this.firstColumnFeatures = [...this.firstColumnFeatures, topFeature];
							} else {
								this.secondColumnFeatures = [...this.secondColumnFeatures, topFeature];
							}
                        this.hasDataExist = true;
						});
					} else {
						//console.log('No Data Found');
					}
					this.isDataLoading = false;
				}).catch((error) => {
					//console.error('Error:', error);
					this.isDataLoading = false;
					this.hasDataExist = false;
				});
		}
	}
	catch (err) {
		//console.log('error'+err);
		this.isDataLoading = false;
		this.hasDataExist = false;
	}
	};

	htmlDecode(input) {
		if (!input) return '';
		let doc = new DOMParser().parseFromString(input, "text/html");
		return doc.documentElement.textContent;
	}
}