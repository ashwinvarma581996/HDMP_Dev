/*******************************************************************************
Name			:	ParentCategoryAccordion
Business Unit	:	<Insert business unit here>
Created Date	:	10/23/2021
Developer		:	
Description		:	LWC is created to display CATEGORIES of products on the UI for HDM org.
*******************************************************************************
MODIFICATIONS – Date | Dev Name     | Method | User Story

					 | 				| 		 | 
*******************************************************************************/
import { LightningElement, track, api } from 'lwc';
import { getCurrentDealerId } from 'c/utils';
const EXPEND = 'EXPEND';
export default class ParentCategoryAccordion extends LightningElement {

	@api categoryList;
	@api subCategories(data, selectedSectionId) {
		if (data) {
			this.subCategoryList = data;
			let subCategory_Clone = JSON.parse(JSON.stringify(data));
			let IllustrationGroups_Clone = [];
			subCategory_Clone.IllustrationGroups.forEach(currentItem => {
				currentItem.myCustomClass = 'slds-m-left_small subcategory';
				IllustrationGroups_Clone.push(currentItem);
			});
			if(sessionStorage.getItem('SEO_SectionId') && sessionStorage.getItem('SEO_SectionId') != null){
				if(sessionStorage.getItem('SEO_MegaCategory') && sessionStorage.getItem('SEO_MegaCategory') != null){
					let subArray = IllustrationGroups_Clone.filter(element => {
						return element.Description.includes(sessionStorage.getItem('SEO_MegaCategory').toUpperCase());
					});
					console.log('subArray : ',subArray);
					if(subArray && subArray.length > 1){
						IllustrationGroups_Clone = subArray;
					}
				}
			}
			subCategory_Clone.IllustrationGroups = IllustrationGroups_Clone;
			this.subCategoryList = subCategory_Clone;
			this.showSubCategory = true;
			this.showLoader = false;
			//console.log('data ==>', data);
			//console.log('OUTPUT : ', selectedSectionId);
			this.openSelectedCategory(selectedSectionId);
		}
	}

	@track showSubCategory = false;
	@track subCategoryList;

	showLoader = false;
	@track activeSections = [];

	showCollapseData(event) {
		//console.log('### Called showCollapseData');
		let self = this;
		let sectionId = event.currentTarget.dataset.id;
		let index = event.currentTarget.dataset.index;
		//Added by Bhawesh R2 story 5492 fast moving item 
		let maintenanceCategory = event.currentTarget.dataset.name;
        console.log('name', maintenanceCategory);
        const isMaintenanceCategory = maintenanceCategory == 'MAINTENANCE' ? true : false;
		//End
		if (!event.currentTarget.parentElement.classList.contains('slds-is-open')) {
			this.showLoader = true;
			this.closeAllCategory();
			this.setCollapseIconForAll();
			event.currentTarget.parentElement.classList.add('slds-is-open');
			self.setAccordioIcon(index, EXPEND, self);
			// fecting sub category list
			let req = this.createRequest(sectionId, '', 'showCollapseData');

			this.notifyParentOnSelectCategory(req, isMaintenanceCategory);//Added by Bhawesh R2 story 5492 fast moving item 
			//window.scrollTo(0, 0);


		} else {
			event.currentTarget.parentElement.classList.remove('slds-is-open');
			this.setAccordioIcon(index, 'COLLAPSE', this);
			this.notifyOnCloseCategory();
		}
	}

	createRequest(sectionId, illustration, methodName) {
		let ProductCategoryId = this.categoryList && this.categoryList.ProductCategories && this.categoryList.ProductCategories.length ? this.categoryList.ProductCategories[0].ID : '';
		let ProductId = this.categoryList.Products && this.categoryList.Products.length && this.categoryList.Products[0].ID ? this.categoryList.Products[0].ID : '';
		let doorId = this.categoryList && this.categoryList.Doors && this.categoryList.Doors[0].ID ? this.categoryList.Doors[0].ID: '';
		let YearId = this.categoryList && this.categoryList.Years &&  this.categoryList.Years[0].ID ? this.categoryList.Years[0].ID : '' ;
		let catalogID = this.categoryList && this.categoryList.Catalogs.length && this.categoryList.Catalogs[0].CatalogID ? this.categoryList.Catalogs[0].CatalogID : '';
		let OriginId = this.categoryList && this.categoryList.Origins.length && this.categoryList.Origins[0].ID ? this.categoryList.Origins[0].ID : '';
		let AreaId = this.categoryList && this.categoryList.Areas && this.categoryList.Areas.length && this.categoryList.Areas[0].ID ? this.categoryList.Areas[0].ID : '';
		let GradeId = this.categoryList && this.categoryList.Grades && this.categoryList.Grades.length && this.categoryList.Grades[0].ID ? this.categoryList.Grades[0].ID : '';
		let TransmissionId = this.categoryList && this.categoryList.Transmissions && this.categoryList.Transmissions.length && this.categoryList.Transmissions[0].ID ? this.categoryList.Transmissions[0].ID : 0;
		let ColorLabelId = this.categoryList && this.categoryList.ColorLabels && this.categoryList.ColorLabels.length &&  this.categoryList.ColorLabels[0].ID ? this.categoryList.ColorLabels[0].ID : '';
		let ColorNameId = this.categoryList && this.categoryList.ColorNames &&  this.categoryList.ColorNames.length &&  this.categoryList.ColorNames[0].ID ? this.categoryList.ColorNames[0].ID : '';
		let req;
		if (methodName == 'showCollapseData') {
			req = {
				"RegionID": 1, "DivisionID": 1, "LanguageID": 0, "ProductCategoryID": ProductCategoryId, "ProductID": ProductId,
				"DoorID": doorId, "YearID": YearId, "GradeID": GradeId, "CatalogID": catalogID, "AreaID": AreaId,
				"OriginID": OriginId, "TransmissionID": TransmissionId, "ColorLabelID": ColorLabelId, "ColorNameID": ColorNameId, "SectionID": sectionId
			};

			//console.log('req ###################### accordion 1 : ', JSON.stringify(req));
			if (!ColorLabelId) {
				delete (req["ColorLabelID"]);
			}
			if (!ColorNameId) {
				delete (req["ColorNameID"]);
			}

		} else if (methodName == 'handleOnSelectSubCategory') {

			req = {
				"RegionID": 1,
				"DivisionID": 1,
				"LanguageID": 0,
				"ProductCategoryID": ProductCategoryId,
				"ProductID": ProductId,
				"DoorID": doorId,
				"YearID": YearId,
				"GradeID": GradeId,
				"CatalogID": catalogID,
				"AreaID": AreaId,
				"OriginID": OriginId,
				"TransmissionID": TransmissionId,
				"ColorLabelID": ColorLabelId,
				"ColorNameID": ColorNameId,
				"SectionID": illustration[0].SectionID,
				"IllustrationGroupID": illustration[0].ID,
				"IllustrationGroupImageID": illustration[0].IllustrationGroupImageID
			}

			//console.log('req ###################### accordion 2 : ', JSON.stringify(req));
			if (!ColorLabelId) {
				delete (req["ColorLabelID"]);
			}
			if (!ColorNameId) {
				delete (req["ColorNameID"]);
			}

		}
		return req;
	}
	// This method is used to notify parent on the select of the category.
	//Added by Bhawesh R2 story 5492 fast moving item 
	notifyParentOnSelectCategory(req, isMaintenanceCategory) {
        req = Object.assign(req, { 'isMaintenanceCategory': isMaintenanceCategory });
		this.subCategoryList = [];
		this.dispatchEvent(new CustomEvent('opencategory', { detail: req }));
	}
	//End

	// This method is used to notify parent on the close of category.
	notifyOnCloseCategory() {
		this.dispatchEvent(new CustomEvent('closecategory', {}));
	}

	// This method is used to close all category
	@api
	closeAllCategory() {
		//console.log('### Called closeAllCategory');
		self = this;
		let listItems = [...this.template.querySelectorAll('.slds-accordion__section')];
		if (listItems) {
			listItems.forEach(function (currentItem, index) {
				if (currentItem && currentItem.classList && currentItem.classList.contains('slds-is-open')) {
					currentItem.classList.remove('slds-is-open');
				}
			});
		}
	}

	// This method is used to expend sub category list for the selected category.
	openSelectedCategory(selectedCategoryId) {
		//console.log('### Called openSelectedCategory');
		if (selectedCategoryId) {
			this.closeAllCategory();
			let self = this;
			self.categoryList.Sections.forEach(function (category, index) {
				if (category.ID == selectedCategoryId) {
					let allCategoryNodes = [...self.template.querySelectorAll('.slds-accordion__section')];
					if (allCategoryNodes && allCategoryNodes[index] && allCategoryNodes[index].classList){
						allCategoryNodes[index].classList.add('slds-is-open');
						//Added by Bhawesh R2 story 5492 fast moving item 
						if (index && self.template.querySelectorAll('.arrowicon')[index]) {
							let arrowRightElement = self.template.querySelectorAll('.arrowicon')[index];
							arrowRightElement.iconName = 'utility:chevrondown';
						}
						//End
					}
				}
			});
		}
	}

	@api
    openSelectedCategoryFromParent(selectedCategoryId) {
        this.openSelectedCategory(selectedCategoryId);
        this.setAccordioIcon(0, EXPEND, this);
        this.showLoader = false;
    }
	// This method is call when user's select sub category.
	handleOnSelectSubCategory(event) {
		let subCategoryId = event.currentTarget.dataset.id;
		if (subCategoryId) {
			this.deselectAllSubCategory();
			//console.log('OUTPUT : ', subCategoryId);
			let selectedSubCategory = this.subCategoryList.IllustrationGroups.filter(subCategory => {
				return subCategory.ID == subCategoryId;
			});

			event.currentTarget.classList.add('subcategoryselected');
			if (selectedSubCategory && selectedSubCategory.length) {
				let req = this.createRequest('', selectedSubCategory, 'handleOnSelectSubCategory');
				this.notifyParentOnSelectSubCategory(req);
				//window.scrollTo(0, 0);
				//this.notifyParentOnSelectSubCategory(1, selectedSubCategory[0].SectionID, selectedSubCategory[0].ID, selectedSubCategory[0].IllustrationGroupImageID);
			}
		}
	}

	// This method is used to notify parent on the select of sub category.
	notifyParentOnSelectSubCategory(req) {
		sessionStorage.setItem('category', JSON.stringify({'division': req.DivisionID, 'sectionId': req.SectionID, 'illustrationId': req.IllustrationGroupID, 'illustrationGroupImageId': req.IllustrationGroupImageID}));
		this.dispatchEvent(new CustomEvent('selectsubcategory', { detail: req }));
	}

	// method is used to deselect all sub category
	deselectAllSubCategory() {
		[...this.template.querySelectorAll('.subcategory')].forEach(subCategoryNode => {
			if (subCategoryNode && subCategoryNode.classList && subCategoryNode.classList.contains('subcategoryselected'))
				subCategoryNode.classList.remove('subcategoryselected')
		});
	}

	// method is used to EXPEND or COLLAPSE
	setAccordioIcon(index, expendORCallaps, self) {
		if (index >= 0 && self.template.querySelectorAll('.arrowicon')[index]) {
			let arrowRightElement = self.template.querySelectorAll('.arrowicon')[index];
			arrowRightElement.iconName = expendORCallaps == EXPEND ? 'utility:chevrondown' : 'utility:chevronright';
		}
	}
	//Added by Bhawesh R2 story 5492 fast moving item 
	@api
	setAccordioIconForMaintenance() {
		if (this.template.querySelectorAll('.arrowicon')[0]) {
			let arrowRightElement = this.template.querySelectorAll('.arrowicon')[0];
			arrowRightElement.iconName = 'utility:chevrondown';
			let allCategoryNodes = [...this.template.querySelectorAll('.slds-accordion__section')];
			if (allCategoryNodes && allCategoryNodes[0] && allCategoryNodes[0].classList){
				allCategoryNodes[0].classList.add('slds-is-open');
			}
		}
	}
	//End

	@api
	setCollapseIconForAll() {
		let allNodes = this.template.querySelectorAll('.arrowicon');
		if (allNodes) {
			allNodes.forEach(node => {
				node.iconName = 'utility:chevronright';
			});
		}
	}

	handleSectionToggle(event) {
		if (event.detail.openSections) {
			let hasNotExist = false;
			let sectionId;
			event.detail.openSections.forEach(section => {
				if (!this.activeSections.includes(section) && !hasNotExist) {
					this.activeSections.push(section);
					sectionId = section;
					hasNotExist = true;
				}
			})
			if (sectionId) { 
				this.activeSections = [sectionId];
				let req = this.createRequest(sectionId, '', 'showCollapseData');
				this.notifyParentOnSelectCategory(req, false);
			}
		}
	}
	@api
	markSubCategoryAsSelected(subCategoryId) {
		if (subCategoryId) {
			this.subCategoryList.IllustrationGroups.forEach(function (currentItem, index) {
				if (currentItem.ID == subCategoryId) {
					currentItem.myCustomClass = 'slds-m-left_small subcategory subcategoryselected';
				}
				else {
					currentItem.myCustomClass = 'slds-m-left_small subcategory';
				}
			});
		}
	}

	// // Added By Bhawesh 17-01-2022 Stroy R2 5084 start
	@api
	openIconWithSubCategory(categoryID, categoryIndex){
		 this.openSelectedCategory(categoryID);
        this.setAccordioIcon(categoryIndex, EXPEND, this);
	}
	//End
}