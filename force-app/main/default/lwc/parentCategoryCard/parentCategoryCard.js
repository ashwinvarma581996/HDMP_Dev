import { api, LightningElement, track, wire } from 'lwc';
import { getCurrentDealerId } from 'c/utils';
import PartialSearchbyProduct from '@salesforce/apex/B2B_INSystemIntegration.PartialSearchbyProduct';
import getProduct from '@salesforce/apex/B2BGuestUserController.getProduct';

export default class ParentCategoryCard extends LightningElement {
	@track subCategories;
	@track isMainCategory = true;
	@track isSubCategory = false;
	@api categories;
	@api subcategoriesdata;
	@api getSubCategory(data) {
		if (data) {
			this.subCategories = data;
			this.isSubCategory = true;
			this.isMainCategory = false;
			window.scrollTo(0, 0);
			console.log('OUTPUT subCategories : ', this.subCategories);
			this.filterSubcategoriesSEO();
		}
	}

	@api closeSubCategory(data) {
		if (data == 'Close') {
			this.isMainCategory = true;
			this.isSubCategory = false;
		}
	}

	connectedCallback() {
		if (this.subcategoriesdata) {
			this.isMainCategory = false;
			this.subCategories = this.subcategoriesdata;
			this.isSubCategory = true;
		} else if (this.subcategoriesdata === null) {
			this.isMainCategory = true;
			this.isSubCategory = false;
		}
	}

	// method to open sub categories
	openSubCategories(event) {
		let index = event.currentTarget.dataset.index;
		let maintenanceCategory = event.currentTarget.dataset.name;
		const  isMaintenanceCategory = maintenanceCategory == 'MAINTENANCE' ? true : false;
		let sectionId = this.categories && this.categories.Sections  && this.categories.Sections[index].ID ? this.categories.Sections[index].ID : '';
		let ProductCategoryId = this.categories.ProductCategories[0].ID;
		let ProductId = this.categories &&  this.categories.Products &&  this.categories.Products.length && this.categories.Products[0].ID ? this.categories.Products[0].ID : '';
		let doorId = this.categories.Doors && this.categories.Doors.length ? this.categories.Doors[0].ID : '';
		let YearId = this.categories.Years && this.categories.Years.length ? this.categories.Years[0].ID: '';
		let catalogID = this.categories.Catalogs && this.categories.Catalogs.length ?  this.categories.Catalogs[0].CatalogID : '';
		let OriginId = this.categories.Origins && this.categories.Origins.length &&  this.categories.Origins[0].ID ? this.categories.Origins[0].ID : '';
		let AreaId = this.categories.Areas && this.categories.Areas.length  && this.categories.Areas[0].ID ? this.categories.Areas[0].ID : '';
		let GradeId = this.categories.Grades && this.categories.Grades.length ? this.categories.Grades[0].ID : '';
		let TransmissionId = this.categories.Transmissions && this.categories.Transmissions.length && this.categories.Transmissions[0].ID ? this.categories.Transmissions[0].ID : 0;
		let ColorLabelId = this.categories && this.categories.ColorLabels && this.categories.ColorLabels.length ? this.categories.ColorLabels[0].ID : '';
		let ColorNameId = this.categories && this.categories.ColorNames && this.categories.ColorNames.length ? this.categories.ColorNames[0].ID : '';
		let req = {
			"RegionID": 1, "DivisionID": 1, "LanguageID": 0, "ProductCategoryID": ProductCategoryId, "ProductID": ProductId,
			"DoorID": doorId, "YearID": YearId, "GradeID": GradeId, "CatalogID": catalogID, "AreaID": AreaId,
			"OriginID": OriginId, "TransmissionID": TransmissionId,"isMaintenanceCategory" : isMaintenanceCategory , "ColorLabelID": ColorLabelId, "ColorNameID": ColorNameId, "SectionID": sectionId
		};
		if (!ColorLabelId) {
			delete (req["ColorLabelID"]);
		}
		if (!ColorNameId) {
			delete (req["ColorNameID"]);
		}
		// Dispatches the event.
		const selectedEvent = new CustomEvent('opencategory', { detail: req });
		this.dispatchEvent(selectedEvent);
	}

	openPLPComponent(event) {
		let index = event.currentTarget.dataset.index;
		let illustration = this.subCategories.IllustrationGroups[index];
		//console.log('index : ',index);
		//console.log('illustration : ',illustration);
		/*let request = {
		"RegionID": 1,
		"DivisionID": 1,
		"LanguageID": 0,
		"ProductCategoryID": this.categories && this.categories.ProductCategories && this.categories.ProductCategories.length ? this.categories.ProductCategories[0].ID : '',
		"ProductID": this.categories.Products &&  this.categories.Products.length && this.categories.Products[0].ID ? this.categories.Products[0].ID : '',
		"DoorID": this.categories.Doors && this.categories.Doors.length ? this.categories.Doors[0].ID : '',
		"YearID": this.categories.Years && this.categories.Years.length ? this.categories.Years[0].ID: '',
		"GradeID": this.categories.Grades && this.categories.Grades.length ? this.categories.Grades[0].ID : '',
		"CatalogID": this.categories.Catalogs && this.categories.Catalogs.length ?  this.categories.Catalogs[0].CatalogID : '',
		"AreaID": this.categories.Areas && this.categories.Areas.length  && this.categories.Areas[0].ID ? this.categories.Areas[0].ID : '',
		"OriginID": this.categories.Origins && this.categories.Origins.length &&  this.categories.Origins[0].ID ? this.categories.Origins[0].ID : '' ,
		"TransmissionID": this.categories.Transmissions && this.categories.Transmissions.length && this.categories.Transmissions[0].ID ? this.categories.Transmissions[0].ID : 0,
		"ColorLabelID": this.categories.ColorLabels && this.categories.ColorLabels.length && this.categories.ColorLabels[0].ID ? this.categories.ColorLabels[0].ID : '',
		"ColorNameID": this.categories.ColorNames && this.categories.ColorNames.length && this.categories.ColorNames[0].ID ? this.categories.ColorNames[0].ID: '',
		"SectionID": illustration &&  illustration.SectionID ? illustration.SectionID : '',
		"IllustrationGroupID": illustration &&  illustration.ID ?  illustration.ID : '',
		"IllustrationGroupImageID": illustration &&  illustration.IllustrationGroupImageID ? illustration.IllustrationGroupImageID : ''}*/
		let request = {
			"RegionID": 1,
			"DivisionID": 1,
			"LanguageID": 0,
			"ProductCategoryID": this.categories.ProductCategories[0].ID,
			"ProductID": this.categories.Products[0].ID,
			"DoorID": this.categories.Doors[0].ID,
			"YearID": this.categories.Years[0].ID,
			"GradeID": this.categories.Grades[0].ID,
			"CatalogID": this.categories.Catalogs[0].CatalogID,
			"AreaID": this.categories.Areas[0].ID,
			"OriginID": this.categories.Origins[0].ID,
			// "TransmissionID": this.categories &&  this.categories.Transmissions && this.categories.Transmissions[0].ID ? this.categories.Transmissions[0].ID: 0,
			"TransmissionID": this.categories.Transmissions[0].ID,
			"ColorLabelID": this.categories && this.categories.ColorLabels && this.categories.ColorLabels.length ? this.categories.ColorLabels[0].ID : '',
			"ColorNameID": this.categories && this.categories.ColorNames && this.categories.ColorNames.length ? this.categories.ColorNames[0].ID : '',
			"SectionID": illustration.SectionID,
			"IllustrationGroupID": illustration.ID,
			"IllustrationGroupImageID": illustration.IllustrationGroupImageID
		   }
		if (!(this.categories.ColorLabels && this.categories.ColorLabels.length && this.categories.ColorLabels[0].ID)) {
			delete (request["ColorLabelID"]);
		}
		if (!(this.categories.ColorNames && this.categories.ColorNames.length && this.categories.ColorNames[0].ID)) {
			delete (request["ColorNameID"]);
		}
		sessionStorage.setItem('category', JSON.stringify({ 'division': 1, 'sectionId': illustration.SectionID, 'illustrationId': illustration.ID, 'illustrationGroupImageId': illustration.IllustrationGroupImageID }));
		// Dispatches the event.
		const selectedEvent = new CustomEvent('opensubcategory', { detail: request });
		this.dispatchEvent(selectedEvent);
	}

	filterSubcategoriesSEO(){
		console.log('subCategories: ',JSON.parse(JSON.stringify(this.subCategories)));
		if(sessionStorage.getItem('SEO_SectionId') && sessionStorage.getItem('SEO_SectionId') != null){
			if(sessionStorage.getItem('SEO_MegaCategory') && sessionStorage.getItem('SEO_MegaCategory') != null){
				if(sessionStorage.getItem('SEO_Sku') && sessionStorage.getItem('SEO_Sku') != null){
					PartialSearchbyProduct({ division: 1, year: this.categories.Years[0].ID, productId: this.categories.Products[0].ID,
						doorId: this.categories.Doors[0].ID, gradeId: this.categories.Grades[0].ID, catalogId: this.categories.Catalogs[0].CatalogID, 
						transmissionID: this.categories.Transmissions[0].ID, sectionID: 0, illustrationGroupID: 0, 
						illustrationGroupImageID: 0, searchCodeTypeID: 0, searchCodeContains: 0, searchstring: sessionStorage.getItem('SEO_Sku')
					}).then(result => {
						if (result) {
							let data = JSON.parse(result);
							console.log('$resuldata: ',data);
							if(data.IllustrationGroups && data.IllustrationGroups.length > 1 && data.Parts.length == 0){
								this.subCategories.IllustrationGroups = data.IllustrationGroups;
							}else if(data.IllustrationGroups && data.IllustrationGroups.length == 1 && data.Parts.length){
								let selectedPart = data.Parts.filter(element => {
									return element.PartNumber.includes(sessionStorage.getItem('SEO_Sku')) && element.IsMatched.includes('true');
								});
								selectedPart = selectedPart[0] ? selectedPart[0] : selectedPart;
								console.log('OUTPUT : ',selectedPart);
								console.log('OUTPUTPartNumber : ',selectedPart.PartNumber);
								sessionStorage.removeItem('fromcart');
								sessionStorage.setItem('fromPLP', 'true');
								sessionStorage.removeItem('fromWhichPageUserHasRefresh');
								let partNumber = selectedPart.PartNumber;
								sessionStorage.setItem('SelectedPart', JSON.stringify(selectedPart));
								if (selectedPart && selectedPart.IllustrationReferenceCode) {
									this.createCookie('ProductNumber', parseInt(selectedPart.IllustrationReferenceCode, 10), 1);
								}
								if(data.ImageIllustrationGroupDetails && data.ImageIllustrationGroupDetails[0].IllustrationURL){
									console.log('OUTPUT-IMG : ',data.ImageIllustrationGroupDetails[0].IllustrationURL);
									sessionStorage.setItem('SubCategoryImageURL', data.ImageIllustrationGroupDetails[0].IllustrationURL);	
								}
								let description = '';
								if (data.IllustrationGroups && data.IllustrationGroups.length && data.IllustrationGroups[0].Description) {
									description = data.IllustrationGroups[0].Description;
								}
								getProduct({productId: partNumber}).then(result => {
									if (result) {
										console.log('OUTPUTres : ',result);
										console.log('OUTPUTee2 : ',new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))));
										let breadcrumbsElements = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
										console.log('OUTPUTmp : ',breadcrumbsElements);
										breadcrumbsElements.push({
											label: description,
											name: 'subcategory',
											href: window.location.href,
											isCurrentPage: false,
											categoryURL: window.location.href
										});
										let brand = sessionStorage.getItem('vehicleBrand');
										let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
										breadcrumbsMap.set(brand, JSON.parse(JSON.stringify(breadcrumbsElements)));
										sessionStorage.setItem('breadcrumbsMap', JSON.stringify([...breadcrumbsMap]));
										window.location.href = '/s/product/' + result.Id;
									}
								}).catch(error => {
									console.log('Error : ', error);
								});
							}
						}
					}).catch(error => {
						console.log('$error: ',error);
					});
				}else{
					let subArray = this.subCategories.IllustrationGroups.filter(element => {
						return element.Description.includes(sessionStorage.getItem('SEO_MegaCategory').toUpperCase());
					});
					console.log('subArray : ',subArray);
					if(subArray && subArray.length > 1){
						this.subCategories.IllustrationGroups = subArray;
						sessionStorage.removeItem('SEO_SectionId');
						sessionStorage.removeItem('SEO_MegaCategory');
					}else if(subArray && subArray.length == 1){
						let index1 = this.subCategories.IllustrationGroups.findIndex(element => element.Description.includes(sessionStorage.getItem('SEO_MegaCategory').toUpperCase()));
						console.log('illustrationIndex : ',index1);
						this.openPLPComponent({currentTarget:{dataset:{index: index1}}});
					}					
				}
			}else{
				sessionStorage.removeItem('SEO_SectionId');
			}
		}
	}

	createCookie(name, value, days) {
        var expires;
        if (days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 100));
            expires = ";expires=" + date.toGMTString();
        } else {
            expires = "";
        }
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
    }
}