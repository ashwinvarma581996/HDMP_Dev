import { LightningElement, track, wire, api } from 'lwc';
import GetModelByVinDecoder from '@salesforce/apex/B2B_INSystemIntegration.GetModelByVinDecoder';
import GetIllustrationBySectionID from '@salesforce/apex/B2B_INSystemIntegration.GetIllustrationBySectionID';
import GetPartsByIllustrationID from '@salesforce/apex/B2B_INSystemIntegration.GetPartsByIllustrationID';
import SearchbyProduct from '@salesforce/apex/B2B_INSystemIntegration.SearchbyProduct';
import callVinDecoderService from '@salesforce/apex/B2B_EconfigIntegration.callVinDecoderService';
import getCompleteDetail from '@salesforce/apex/B2B_EconfigIntegration.getCompleteDetail';
import b2b_Akamai_Accessory_URL from '@salesforce/label/c.b2b_Akamai_Accessory_URL';
import maintainenceProduct from '@salesforce/apex/B2B_INSystemIntegration.maintainenceProduct';
import PartialSearchbyProduct from '@salesforce/apex/B2B_INSystemIntegration.PartialSearchbyProduct';
import { NavigationMixin } from 'lightning/navigation';
import { getCurrentDealerId, getCurrentVehicle, getCurrentDealer } from 'c/utils';
import GetDealerPrice from '@salesforce/apex/B2B_INSystemIntegration.GetDealerPrice';
import id from '@salesforce/user/Id';
import { CurrentPageReference } from 'lightning/navigation';
import MinimumPartSearch from '@salesforce/label/c.B2B_Minimum_Part_Search_character';
import MaintenanceImages from '@salesforce/resourceUrl/MaintenanceImages';
import ISGUEST from '@salesforce/user/isGuest';
import getUserDetails from '@salesforce/apex/B2B_ShoppingSelectionController.getUserDetails';
import USER_ID from '@salesforce/user/Id';
import { publish, MessageContext } from 'lightning/messageService';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils'; // for adobe
import logAPIDataError from '@salesforce/apex/B2B_DataErrorLogger.logAPIDataError';// Added by vivek for 18899
const BREADCRUMB_TYPE = {
    BRAND: 'brand',
    PRODUCTTYPE: 'producttype',
    CATEGORY: 'category',
    SUBCATEGORY: 'subcategory',
    PRODUCT: 'product',
    SEARCH: 'search'
}
const SEARCH_OPTIONS = [
    { label: 'Filter by Keyword', value: 'keyword' },
    { label: 'Filter by Part No.', value: 'partNumber' }
];
const SEARCH_OPTIONS_ACCESSORIES = [
    { label: 'Filter by Keyword', value: 'keyword' },
    { label: 'Filter by Accessory No.', value: 'partNumber' } //for 7656
];
const SEARCH_ACC = {
    KEY: 'keyword',
    PART: 'partNumber'
}
const STORAGE = {
    SEARCHED_TERM: 'searchedTerm',
    CHOSEN_FILTER: 'chosenFilter',
    FROM_PDP: 'FromPDP',
    CLICKED_BACK_TO_RESULT: 'clickedBackToResult',
    YES: 'yes',
    NO: 'no',
    CLOSE: 'close'
}
const ACC_CATEGORIES = {
    ALL: 'All',
    INTERIOR: 'Interior',
    EXTERIOR: 'Exterior',
    ELECTRICAL: 'Electrical',
    ACCESSORIES: 'Accessories',
    ACCESSORY: 'Accessory'
} //ends
const KEYWORD_PART_NUM = 'partNumber';// Added by Pradeep Singh for HDMP-7136
export default class ParentCategory extends NavigationMixin(LightningElement) {
    @track isErrorSearch = false;
    @track catelogs;
    @track vinNumber;
    @track subCategories;
    @track productList;
    @track showCategoryCard = false;
    @track showPLP = false;
    @track division;
    @track priceType = 'MSRP';
    @track errorDescription;
    @track showAccordion = false;
    @track selectedPartOrAccessories = 'Parts';
    @track showAccessories = false;
    @track accessoriesList = [];
    @track filteredcategory = [];
    @track accessoriesListOrg; //ends
    @track isLoading = false;
    @track showErrorMessage = false;
    @track searchBoxValue = '';
    @track vehicle = getCurrentVehicle();
    @track searchOptions = SEARCH_OPTIONS_ACCESSORIES;
    @track partSearchOptions = SEARCH_OPTIONS;
    @track selectedPartSearchMethod = 'keyword';
    @track partSearchedResult;
    @track displaySearchPage = false;
    @track partSearchValue = '';
    @track cloneCategoryData;
    @track clone_PartSearchResult;
    @track searchedApplied = false;
    myBreadcrumbs = [];
    productType = '';
    breadCrumbsMap = {
        parent: 'https://dev-hondamarketplace.cs17.force.com/s/',
        child: 'https://www.google.com/',
    };
    @track brandName;
    @track breadcrumbs = [];
    @track subcategoriesdata;
    @track fromBreadcrumb = false;
    @track fromWhichPageSearched;
    @track nonFilteredProductList;
    @track selectedSectionId;
    @track selectedSubCategoryId;
    @track disablepartsAndAccessories = true;
    currentPageReference = null;
    urlStateParameters = null;
    hondaPLPImage = MaintenanceImages + '/MaintenanceImages/Honda/Thumbnail.jpg';
    acuraPLPImage = MaintenanceImages + '/MaintenanceImages/Acura/Thumbnail.jpg';
    maintenanceImagePC;
    @track isGuestUser;
    @track shoppingBrand;
	dataErrorMessage = ''; //Added by Vivek for HDMP-18899
    @wire(MessageContext)
    messageContext;
    currentPage_Adobe;//for adobe bug-08
    @track pageParams;
    @track isDealerAPiErr = false; // Added by Aditya LTIM for 18865
    get partsAndAccessories() {
        return [
            { label: 'Parts', value: 'Parts' },
            { label: 'Accessories', value: 'Accessories' },
        ];
    }
    constructor() {
        super();
    }
    connectedCallback() {
        this.isLoading = true;
        if (USER_ID) {
            getUserDetails({ userId: USER_ID }).then((result) => {
                if (result && result.Name && result.Name.toLowerCase().includes('guest')) {
                    this.isGuestUser = 'True';
                } else {
                    this.isGuestUser = 'False';
                }
            }).catch((error) => { });
        }
        this.doInit();
        this.catelogs = undefined;
        setTimeout(() => { this.handleFilterOnLoad() }, 5000);
    }
    async doInit() {
        this.showPLP = false;
        this.partSearchValue = '';
        this.createCookie('ProductFromCart', false, 1);
        this.createCookie('ProductTypeForCart', '', 1);
        this.brandName = sessionStorage.getItem('vehicleBrand');
        this.vehicle = getCurrentVehicle();
        sessionStorage.removeItem('fromcart');
        this.productType = this.vehicle.productType;
        this.selectedPartOrAccessories = this.productType;
        sessionStorage.setItem('ProductType', this.selectedPartOrAccessories);
        sessionStorage.removeItem('fromCartForBreadcrumbs');
        this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
        this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, true);
        let oldLocation = location;
        var marketPlaceURL = 'https://dev-hondamarketplace.cs17.force.com/s/';
        this.myBreadcrumbs.push({ label: this.brandName, name: this.marketPlaceURL, id: this.brandName });
        oldLocation = location;
        this.myBreadcrumbs.push({ label: this.productType, name: this.marketPlaceURL, id: this.productType });
        this.vinNumber = this.vehicle.vin; // this.getCookie('Vin');
        this.division = this.vehicle.iNDivisionID__c; //this.getCookie('Division');
        let year = this.vehicle.year; //this.getCookie('YearId');
        let model = this.vehicle.model; //this.getCookie('ModelId');
        let trim = this.vehicle.trim; //this.getCookie('TrimId');
        let vin = this.vehicle.vin; //this.vinNumber;
        let partsCatalog = sessionStorage.getItem('partsCatalog');
        if (this.myBreadcrumbs[0].label) {
            this.maintenanceImagePC = this.myBreadcrumbs[0].label == 'Honda' ? this.hondaPLPImage : this.myBreadcrumbs[0].label == 'Acura' ? this.acuraPLPImage : '';
        }
        if (this.vehicle && this.vehicle.productType == 'Accessories') {
            this.handleShowAccessoriesORParts();
        } else if (this.vehicle && this.vehicle.productType == 'Parts') {
            if (vin != 'undefined' && vin && partsCatalog != 'undefined' && partsCatalog) {
                partsCatalog = JSON.parse(partsCatalog);
                this.shoppingBrand = parseInt(this.division) && parseInt(this.division) == 1 ? 'Honda' : parseInt(this.division) == 2 ? 'Acura' : '';
                this.getPartsData(parseInt(this.division), parseInt(partsCatalog.year_id), parseInt(partsCatalog.model_id), parseInt(partsCatalog.door_id), parseInt(partsCatalog.grade_id), parseInt(partsCatalog.catalog_id), parseInt(partsCatalog.transmission_id));
            } else if (this.division && year && model && trim) {
                let vehicalObj = this.vehicle;
                let transmId = vehicalObj && vehicalObj.iNTransmissionID__c ? vehicalObj.iNTransmissionID__c : 0;
                this.shoppingBrand = vehicalObj.iNDivisionID__c && vehicalObj.iNDivisionID__c == 1 ? 'Honda' : vehicalObj.iNDivisionID__c == 2 ? 'Acura' : '';
                this.getPartsData(vehicalObj.iNDivisionID__c, vehicalObj.iNYearID__c, vehicalObj.iNModelID__c, vehicalObj.iNDoorID__c, vehicalObj.iNGradeID__c, vehicalObj.iNCatalogID__c, transmId);

            }
        }
        let backToResult = sessionStorage.getItem('backToResult');
        let searchPDP = localStorage.getItem('SearchClickPDP');
        if ((backToResult == 'true') && localStorage.getItem('partSerachValue') && localStorage.getItem('filteredProductData')) {
            sessionStorage.setItem('backToResult', false);
            this.partSearchValue = localStorage.getItem('partSerachValue');
            this.selectedPartSearchMethod = localStorage.getItem('selectedPartSearchMethod');
            this.productList = JSON.parse(localStorage.getItem('filteredProductData'));
            this.catelogs = JSON.parse(localStorage.getItem('filterCatLogs'));
            let fillterSubCategoryList = this.catelogs.IllustrationGroups.filter(subCategory => {
                return subCategory.SectionID == this.productList.IllustrationGroups[0].SectionID;
            });
            this.showCategoryCard = false;// Added by Bhawesh on 22-03-2022 for HDMP-8473 
            this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
        }
        else if (/*searchPDP=='true' && */localStorage.getItem('partSerachValue')) {
            localStorage.setItem('SearchClickPDP', false);
            this.partSearchValue = localStorage.getItem('partSerachValue');
            this.selectedPartSearchMethod = localStorage.getItem('selectedPartSearchMethod');
            this.productList = JSON.parse(localStorage.getItem('filteredProductData'));
            this.catelogs = JSON.parse(localStorage.getItem('filterCatLogs'));
            setTimeout(() => {
                this.handleOnPartSearch();
            }, 50);
            if (localStorage.getItem('CategSearch') == 'true') {
                this.template.querySelector('c-parent-category-accordion').closeSubCategory();
                this.template.querySelector('c-parent-category-accordion').setCollapseIconForAll();
                localStorage.setItem('CategSearch', false);
            }
        } //ends: 5300
        else {
            sessionStorage.setItem('backToResult', false);
            localStorage.setItem('SearchClickPDP', false);
            this.partSearchValue = localStorage.getItem('partSerachValue');
            this.selectedPartSearchMethod = localStorage.getItem('selectedPartSearchMethod');
            if (localStorage.getItem('selectedPartSearchMethod') == null) {
                this.selectedPartSearchMethod = 'keyword';
            }
            this.productList = JSON.parse(localStorage.getItem('filteredProductData'));
            this.catelogs = JSON.parse(localStorage.getItem('filterCatLogs'));
            if (this.catelogs && this.catelogs.IllustrationGroups) {
                let fillterSubCategoryList = this.catelogs.IllustrationGroups.filter(subCategory => {
                    return subCategory.SectionID == this.productList.IllustrationGroups[0].SectionID;
                });
            }
            this.showCategoryCard = false;
            if (sessionStorage.getItem('continueShoppingVar')) {
                this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
                sessionStorage.setItem('continueShoppingVar', false);
            }
        }
    }

    //Added by Faraz on 15/06/2022 for best practice
    async getPartsData(partDivision, partYear, partProductId, partDoorId, partGradeId, partCatalogId, partTransmissionID) {
        try {
            let vehicalObj = getCurrentVehicle();
            await SearchbyProduct({
                division: partDivision,
                year: partYear,
                productId: partProductId,
                doorId: partDoorId,
                gradeId: partGradeId,
                catalogId: partCatalogId,
                TransmissionID: partTransmissionID
            }).then(result => {
                if (result) {
                    let data = JSON.parse(result);
                    this.showErrorMessage = false;
                    if (data.Sections) {
                        if (data.Sections.length == 0 && vehicalObj.productType == 'Parts') {
                            this.showErrorMessage = true;
                            this.isLoading = false;
                            //for adobe bug-15:starts
                            let breadcrumbs_adobe = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                            if (this.currentPage_Adobe == undefined || this.currentPage_Adobe != breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label) {
                                this.currentPage_Adobe = breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label;
                                const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
                                publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                            }
                            //for adobe bug-15:ends
                            return;
                        } else if (data.Sections.length > 0) {
                            this.showErrorMessage = false;
                            //Added by Bhawesh R2 story 5492 fast moving item 
                            data.Sections.unshift({
                                SectionURL: this.maintenanceImagePC,
                                ImageSize: 0,
                                ID: 'maint001',
                                Description: 'MAINTENANCE'
                            })
                        }
                    }
                    if (this.partSearchValue && this.partSearchValue.length) {
                        this.catelogs = JSON.parse(localStorage.getItem('filterCatLogs'));
                        this.cloneCategoryData = JSON.parse(localStorage.getItem('filterCatLogs'));
                    }
                    else {
                        this.catelogs = Object.assign({}, data);
                        let catalogDataObj = {};
                        catalogDataObj[sessionStorage.getItem('vehicleBrand')] = this.catelogs;
                        sessionStorage.setItem('CatLogsData', JSON.stringify(catalogDataObj));
                        this.cloneCategoryData = Object.assign({}, data);
                    }
                    //End
                    this.filterYearModelTrim(vehicalObj);
                    this.showAccordion = true;
                    this.handleShowAccessoriesORParts();
                    this.setParametersBasedOnUrl();
                    // multiple tab issue3 starts here
                    // let backToResultFlag = localStorage.getItem('backToResult'); // Added by shalini this backToResultFlag for bug HDMP-7584
                    let backToResultFlag = sessionStorage.getItem('backToResult');
                    // multiple tab issue3 ends here
                    if (!this.fromBreadcrumb && this.vehicle.productType == 'Parts') { // Added by shalini this backToResultFlag for bug HDMP-7584
                        this.handleShowParts();
                    }
                    //added by Yashika for 8534
                    else if (!this.fromBreadcrumb && this.vehicle.productType == 'Parts' && backToResultFlag == 'true' && !localStorage.getItem('partSerachValue')) {
                        this.handleShowParts();
                    } //ends:8534
                    // Added by Bhawesh on 09-02-2022 start
                    else if (sessionStorage.getItem('fromWhichPageUserHasRefresh') == 'SUBCATEGORY') {
                        if (this.breadcrumbs.length > 2 && this.breadcrumbs[2].label && this.breadcrumbs[2].label != undefined && this.breadcrumbs[2].label == 'MAINTENANCE') {
                            if (getCurrentDealerId()) {
                                this.getDealerPriceForMaintenance();
                            } else {
                                this.showCategoryCard = false;
                                this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
                            }
                        } else {
                            this.subcategoriesdata = JSON.parse(sessionStorage.getItem('subCategories'));
                            this.subCategories = this.subcategoriesdata;
                            this.showCategoryCard = true;
                            this.showPLP = false;
                            setTimeout(() => {
                                this.template.querySelector('c-parent-category-accordion').subCategories(this.subcategoriesdata, this.subcategoriesdata.IllustrationGroups[0].SectionID);
                            }, 50);
                        }
                    } else if (sessionStorage.getItem('fromWhichPageUserHasRefresh') == 'PLP') {
                        this.handleShowParts();
                    } else if (vehicalObj.productType == 'Parts' && backToResultFlag == 'false') { // Added by shalini this backToResultFlag for bug HDMP-7584
                        this.showCategoryCard = true;
                        this.showPLP = false;
                    }
                    // End
                    this.handleSubcategorySEO();
                }
            }).catch(error => {
                console.log('error :: ' + error);
            });
        } catch (error) {
            console.log('error :: ' + error);
        }
        this.isLoading = false;
    }
    //Added by Faraz on 15/06/2022 - End

    handleSubcategorySEO() {
        if ((sessionStorage.getItem('SEO_SectionId') && sessionStorage.getItem('SEO_SectionId') != null) ||
            (sessionStorage.getItem('SEO_Maintenence') && sessionStorage.getItem('SEO_Maintenence') == 'true'))
        {
            let ProductCategoryId = this.catelogs.ProductCategories[0].ID;
            let ProductId = this.catelogs && this.catelogs.Products && this.catelogs.Products.length && this.catelogs.Products[0].ID ? this.catelogs.Products[0].ID : '';
            let doorId = this.catelogs.Doors && this.catelogs.Doors.length ? this.catelogs.Doors[0].ID : '';
            let YearId = this.catelogs.Years && this.catelogs.Years.length ? this.catelogs.Years[0].ID : '';
            let catalogID = this.catelogs.Catalogs && this.catelogs.Catalogs.length ? this.catelogs.Catalogs[0].CatalogID : '';
            let OriginId = this.catelogs.Origins && this.catelogs.Origins.length && this.catelogs.Origins[0].ID ? this.catelogs.Origins[0].ID : '';
            let AreaId = this.catelogs.Areas && this.catelogs.Areas.length && this.catelogs.Areas[0].ID ? this.catelogs.Areas[0].ID : '';
            let GradeId = this.catelogs.Grades && this.catelogs.Grades.length ? this.catelogs.Grades[0].ID : '';
            let TransmissionId = this.catelogs.Transmissions && this.catelogs.Transmissions.length && this.catelogs.Transmissions[0].ID ? this.catelogs.Transmissions[0].ID : 0;
            let ColorLabelId = this.catelogs && this.catelogs.ColorLabels && this.catelogs.ColorLabels.length ? this.catelogs.ColorLabels[0].ID : '';
            let ColorNameId = this.catelogs && this.catelogs.ColorNames && this.catelogs.ColorNames.length ? this.catelogs.ColorNames[0].ID : '';
            let req = {
                "RegionID": 1, "DivisionID": this.division, "LanguageID": 0, "ProductCategoryID": ProductCategoryId, "ProductID": ProductId, "DoorID": doorId,
                "YearID": YearId, "GradeID": GradeId, "CatalogID": catalogID, "AreaID": AreaId, "OriginID": OriginId, "TransmissionID": TransmissionId,
                "isMaintenanceCategory": false, "ColorLabelID": ColorLabelId, "ColorNameID": ColorNameId, "SectionID": sessionStorage.getItem('SEO_SectionId')
            };
            if (!ColorLabelId.length) {
                delete (req["ColorLabelID"]);
            }
            if (!ColorNameId.length) {
                delete (req["ColorNameID"]);
            }
            if(sessionStorage.getItem('SEO_Maintenence') && sessionStorage.getItem('SEO_Maintenence') == 'true'){
                req.isMaintenanceCategory = true;
                req.SectionID = 'maint001';
            }
            let eve = { detail: req };
            this.handleSubCategories(eve);
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
        }
    }
    @track searchedText;
    setParametersBasedOnUrl() {
        let relayStatePage = sessionStorage.getItem('relayStatePage');
        if (relayStatePage && this.isGuestUser && this.isGuestUser.includes('True')) {
            let page = relayStatePage;
            sessionStorage.removeItem('relayStatePage');
            page = page.replaceAll('usp', ' ').replaceAll('usl', '/').replaceAll('uopb', '(').replaceAll('uclb', ')').split('_');
            let type = page[0];
            let categorylabel = page[1];
            let label = page[2];
            let searchText = '';
            if (page[3]) {
                searchText = page[3];
            }
            let pageParamsObject = {
                type: type,
                categorylabel: categorylabel,
                label: label
            };
            if (searchText) {
                pageParamsObject['searchText'] = searchText;
            }
            this.pageParams = pageParamsObject;

            if (type === 'category') {
                this.fromBreadcrumb = true;
                this.subCategories = JSON.parse(sessionStorage.getItem('subCategories'));
            } else {
                this.fromBreadcrumb = false;
            }
            let event = {
                currentTarget: {
                    dataset: {
                        type: type,
                        categorylabel: categorylabel,
                        label: label
                    }
                }
            };
            if (!pageParamsObject.searchText)
                this.handleBreadcrumbClick(event);
        } else {
            if (this.urlStateParameters.type === 'producttype' || this.fromAccessories) {
                this.fromBreadcrumb = true;
            } else if (this.urlStateParameters.type === 'subcategory') {
                this.fromBreadcrumb = false;
                let event = {
                    currentTarget: {
                        dataset: {
                            type: this.urlStateParameters.type,
                            categorylabel: this.urlStateParameters.categorylabel,
                            label: this.urlStateParameters.label
                        }
                    }
                };
                this.handleBreadcrumbClick(event);
            } else if (this.urlStateParameters.type) {
                this.fromBreadcrumb = true;
                if (this.urlStateParameters.type === 'category') {
                    this.subCategories = JSON.parse(sessionStorage.getItem('subCategories'));
                }
                let event = {
                    currentTarget: {
                        dataset: {
                            type: this.urlStateParameters.type,
                            categorylabel: this.urlStateParameters.categorylabel,
                            label: this.urlStateParameters.label
                        }
                    }
                };
                this.handleBreadcrumbClick(event);
            }
            // Added by Bhawesh on 11-02-2022 for HDMP-6887 start
            else if (this.urlStateParameters && !this.urlStateParameters.type) {
                this.fromBreadcrumb = true;
            }
            //End
        }
    }
    buildEffectiveVehicleAndDealer() {
        let baseurl = window.location.href;
        if (baseurl.split('/').includes('honda')) {
            sessionStorage.setItem('brand', 'Honda');
        } else if (baseurl.split('/').includes('acura')) {
            sessionStorage.setItem('brand', 'Acura');
        }
    }
    fromAccessories = false;
    handleSelectOnPartOrAccessories(event) {
        this.catelogs = undefined;
        this.fromAccessories = true;
        sessionStorage.setItem('category', '');
        this.buildEffectiveVehicleAndDealer();
        this.vehicle = getCurrentVehicle();
        this.selectedPartOrAccessories = event.detail.value;
        this.productType = this.selectedPartOrAccessories;
        this.breadcrumbs = [];
        this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
        this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, true);
        this.myBreadcrumbs = [];
        var oldLocation = location;
        var marketPlaceURL = 'https://dev-hondamarketplace.cs17.force.com/s/';
        this.myBreadcrumbs.push({ label: this.brandName, name: this.marketPlaceURL, id: this.brandName });
        this.myBreadcrumbs.push({ label: this.productType, name: this.marketPlaceURL, id: this.productType });
        //Added Shalini soni 23 June 2021 - START
        //this.createCookie('ProductType', this.selectedPartOrAccessories, 1);
        sessionStorage.setItem('ProductType', this.selectedPartOrAccessories);
        this.buildEffectiveVehicle();
        if (this.selectedPartOrAccessories == 'Parts') {
            this.showAccessories = false;
            this.partSearchValue = '';
            this.selectedPartSearchMethod = 'keyword';
            //Added by Faraz on 15/06/2022 for best practice
            if (this.catelogs == undefined) {
                this.showCategoryCard = true;
                this.showPLP = false;
                this.catelogs = this.cloneCategoryData;
                this.getPartsData(this.vehicle.iNDivisionID__c, this.vehicle.iNYearID__c, this.vehicle.iNModelID__c, this.vehicle.iNDoorID__c, this.vehicle.iNGradeID__c, this.vehicle.iNCatalogID__c, this.vehicle.iNTransmissionID__c);
            }
            else {
                this.showAccordion = true;
                this.showCategoryCard = true;
                this.showPLP = false;
                this.catelogs = this.cloneCategoryData;
                this.showErrorMessage = this.catelogs && this.catelogs != undefined && this.catelogs.Sections.length > 0 ? false : true;
            }
            //Added by Faraz on 15/06/2022 - End
            this.subcategoriesdata = null;
        } else if (this.selectedPartOrAccessories == 'Accessories') {
            this.showErrorMessage = false;
            this.showCategoryCard = false;
            this.showPLP = false;
            this.showAccordion = false;
            // Added by Bhawesh 11-01-2022 for hide sub category page of part search.
            this.displaySearchPage = false;
            if (!this.accessoriesList.length) {
                let vehicalObj = this.vehicle; //JSON.parse(this.getCookie('vehicle'));
                let poiType = this.division == 1 ? 'A' : 'B';
                if (this.vinNumber && this.vinNumber != 'undefined' && poiType) { // getting accessories by using VIN Number
                    this.getModelId(this.vinNumber, poiType);
                } else if (vehicalObj && vehicalObj.Model_Id__c) { // getting accessories by using Year Model and Trim
                    this.isLoading = true;
                    this.getAccessoriesByModelId(vehicalObj.Model_Id__c, poiType);
                }
            } else {
                this.showAccessories = true;
            }
        }
        //for adobe analytics:starts
        let breadcrumbs_adobe = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));//for adobe bug-08
        if (this.currentPage_Adobe == undefined || this.currentPage_Adobe != breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label) {
            this.currentPage_Adobe = breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label;
            const message = { refreshComponent: true, message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        } else {
            const message = { refreshComponent: true };
            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        }
        //for adobe analytics:ends
        // }.bind(this), 2000);
    }
    buildEffectiveVehicle() {
        //let productType = this.getCookie('ProductType');
        let productType = sessionStorage.getItem('ProductType');
        let brand = sessionStorage.getItem('vehicleBrand');
        let brands = [];
        if (localStorage.getItem("effectiveVehicle")) {
            brands = JSON.parse(localStorage.getItem("effectiveVehicle"))['brands'];
            let hasExist = false;
            if (brands) {
                brands.forEach(element => {
                    if (brand === element.brand) {
                        element.productType = productType;
                        hasExist = true;
                    }
                });
                if (hasExist) {
                    localStorage.setItem("effectiveVehicle", JSON.stringify({ 'brands': brands }));
                }
            }
        }
    }
    async getModelId(vinNumber, poiType) {
        if (vinNumber && poiType) {
            this.isLoading = true;
            await callVinDecoderService({ vinNumber: vinNumber, poiType: poiType })
                .then(modelData => {
                    let modelInfo = JSON.parse(modelData);
                    if (modelInfo && modelInfo.selectorDetail && modelInfo.selectorDetail.modelId) {
                        let modelId = modelInfo.selectorDetail.modelId;
                        this.getAccessoriesByModelId(modelId, poiType);
                    } else {
                        this.isLoading = false;
                        this.showErrorMessage = true;
                    }
                })
                .catch(error => {
                });
        }
    }
    async getAccessoriesByModelId(modelId, poiType) {
        if (modelId) {
            await getCompleteDetail({ modelId: modelId, poiType: poiType })
                .then(result => {
                    if (result) {
                        let response = JSON.parse(result);
                        if (!response.isError) {
                            let accessoriesDetail = JSON.parse(response.accessoryResult);
                            this.shoppingBrand = accessoriesDetail.Division && accessoriesDetail.Division == 'A' ? 'Honda' : accessoriesDetail.Division == 'B' ? 'Acura' : '';
                            let allAccessories = [];
                            accessoriesDetail.Accessories.forEach(item => {
                                allAccessories.push(item);
                            });
                            if (getCurrentDealerId()) {
                                let opCodeList = []; //Added By Bhawesh 17-02-2022 for BubNo. DPS-46
                                let partNumberList = [];
                                let accessoriesList = [];
                                let dealer = getCurrentDealer();
                                //Added By Bhawesh 17-02-2022 for BubNo. DPS-46 start
                                allAccessories.forEach(accessory => {
                                    if (accessory.op_cd) {
                                        opCodeList.push(accessory.op_cd);
                                    }
                                });
                                //End
                                let uniquePartNumberList = partNumberList.filter(function (item, index, inputArray) {
                                    return inputArray.indexOf(item) == index;
                                });
                                //Added By Bhawesh 17-02-2022 for BubNo. DPS-46 start
                                let uniqueOpCodeList = opCodeList.filter(function (item, index, inputArray) {
                                    return inputArray.indexOf(item) == index;
                                });
                                //End
                                if (uniquePartNumberList.length > 0 || uniqueOpCodeList.length > 0) {
                                    GetDealerPrice({
                                        dealerNo: dealer.dealerNo,
                                        divisionId: this.vehicle.iNDivisionID__c,
                                        partNumbers: JSON.stringify(uniquePartNumberList),
                                        accessories: JSON.stringify(uniqueOpCodeList) // Update By Bhawesh 17-02-2022 for BugNo. DPS-46 
                                    }).then(result => {
                                        if (result) {
                                            let dealerPriceResult = JSON.parse(result);
                                            //Added By Bhawesh 17-02-2022 for BubNo. DPS-46 start
                                            let dealerPriceMap = new Map();
                                            if (dealerPriceResult.Accessories) {
                                                dealerPriceResult.Accessories.forEach(singleAcc => {
                                                    dealerPriceMap.set(singleAcc.OpCode, singleAcc);
                                                });
                                            }
                                            dealerPriceMap.forEach(currentItem => {
                                            });

                                            allAccessories.forEach(item => {
                                                if (item.Colors && item.Colors.length > 1) {
                                                    item.Colors.forEach(objColor => {
                                                        objColor.price = dealerPriceMap.get(objColor.op_cd) && dealerPriceMap.get(objColor.op_cd).DIYPrice ? dealerPriceMap.get(objColor.op_cd).DIYPrice : item.msrp;
                                                    });
                                                } else if (item.Colors && item.Colors.length == 1) {
                                                    item.msrp = dealerPriceMap.get(item.op_cd) && dealerPriceMap.get(item.op_cd).DIYPrice ? dealerPriceMap.get(item.op_cd).DIYPrice : item.msrp;
                                                    item.partNumber = item.Colors[0].part_number;
                                                }
                                            });
                                            accessoriesDetail.Accessory = allAccessories;
                                            this.accessoriesList = accessoriesDetail;
                                            this.accessoriesListOrg = { ...accessoriesDetail }; //added by Yashika for R2 story: accessory search
                                            this.isLoading = false;
                                            this.showAccessories = true;
                                            this.priceType = 'Dealer Price';
                                            sessionStorage.setItem('accessories', JSON.stringify(this.accessoriesList));
                                            //added by Yashika for R2 story accessory search & 8391
                                            let fromPDP = sessionStorage.getItem(STORAGE.CLICKED_BACK_TO_RESULT);
                                            if (fromPDP == STORAGE.YES) {
                                                let filterValue = sessionStorage.getItem(STORAGE.CHOSEN_FILTER);
                                                let searchTextValue = sessionStorage.getItem(STORAGE.SEARCHED_TERM);
                                                this.filterValue = filterValue;
                                                this.searchBoxValue = searchTextValue; // Added by deepak mali for R2 story: accessory search
                                                sessionStorage.setItem(STORAGE.CLICKED_BACK_TO_RESULT, STORAGE.NO);
                                                this.searchAccessories(filterValue, searchTextValue);
                                            } //ends
                                        }
                                    }).catch(error => {
                                    });
                                }
                            } else {
                                allAccessories.forEach(item => {
                                    item.Colors.forEach(objColor => {
                                        objColor.price = item.msrp;
                                    });
                                });
                                accessoriesDetail.Accessory = allAccessories;
                                this.accessoriesList = accessoriesDetail;
                                this.accessoriesListOrg = { ...accessoriesDetail }; //added by Yashika for R2 story: accessory search
                                this.isLoading = false;
                                this.showAccessories = true;
                                sessionStorage.setItem('accessories', JSON.stringify(this.accessoriesList));
                                //added by Yashika for R2 story accessory search & 8391
                                let fromPDP = sessionStorage.getItem(STORAGE.CLICKED_BACK_TO_RESULT);
                                const FROM_LOGIN = localStorage.getItem('fromlogin');
                                if (fromPDP == STORAGE.YES || FROM_LOGIN) {
                                    let filterValue = sessionStorage.getItem(STORAGE.CHOSEN_FILTER);
                                    let searchTextValue = sessionStorage.getItem(STORAGE.SEARCHED_TERM);
                                    this.filterValue = filterValue;
                                    this.searchBoxValue = searchTextValue; // Added by deepak mali for R2 story: accessory search
                                    sessionStorage.setItem(STORAGE.CLICKED_BACK_TO_RESULT, STORAGE.NO);
                                    this.searchAccessories(filterValue, searchTextValue);
                                    if (FROM_LOGIN) {
                                        localStorage.removeItem('fromlogin');
                                    }
                                } //ends
                            }
                        } else {
                            this.accessoriesList = [];
                            this.errorDescription = response.errorMessage;
                            this.isLoading = false;
                            this.showErrorMessage = true;
                            sessionStorage.setItem('accessories', JSON.stringify(this.accessoriesList));
                        }
                    }
                })
                .catch(error => {
                    this.isLoading = false;
                })
                .finally(() => this.isLoading = false);
        }
    }
    filterYearModelTrim(vehicalObj) {
        let cat = JSON.parse(JSON.stringify(this.catelogs));
        if (cat && cat.Years && vehicalObj.iNYearID__c) {
            let newYearObj = JSON.parse(JSON.stringify(cat.Years)).filter((yearObj) => {
                return yearObj.ID == vehicalObj.iNYearID__c;
            })
            cat.Years = JSON.parse(JSON.stringify(newYearObj));
        }
        if (cat && cat.Doors && vehicalObj.iNDoorID__c) {
            let newYearObj = JSON.parse(JSON.stringify(cat.Doors)).filter((doorObj) => {
                return doorObj.ID == vehicalObj.iNDoorID__c;
            })
            cat.Doors = JSON.parse(JSON.stringify(newYearObj));
        }
        if (cat && cat.Products && vehicalObj.iNModelID__c) {
            let newYearObj = JSON.parse(JSON.stringify(cat.Products)).filter((productObj) => {
                return productObj.ID == vehicalObj.iNModelID__c;
            })
            cat.Products = JSON.parse(JSON.stringify(newYearObj));
        }
        if (cat && cat.Grades && vehicalObj.iNGradeID__c) {
            let newYearObj = JSON.parse(JSON.stringify(cat.Grades)).filter((gradObj) => {
                return gradObj.ID == vehicalObj.iNGradeID__c;
            })
            cat.Grades = JSON.parse(JSON.stringify(newYearObj));
        }
        this.catelogs = JSON.parse(JSON.stringify(cat));
    }
    openSubAccessories(event) {
        let data = event.detail;
        if (data.mode) {
            this.template.querySelector('c-accessories').filteredAccessories(data.mode, data.category);
        } else {
            this.template.querySelector('c-accessories').filterWithSubAccessrories(data);
        }

    }
    handleSubCategories(event) {
        //IllustrationGroups
        this.showCategoryCard = true;
        this.showPLP = false;
        let req = event.detail;
        req.DivisionID = this.division;
        //  Added by Bhawesh 07-02-2022 bug - HDMP-7078
        this.selectedSectionId = req.SectionID;
        this.selectedSubCategoryId = '';
        // End
        let selectedCategory = JSON.parse(JSON.stringify(this.catelogs.Sections)).find((category) => {
            return category.ID == req.SectionID;
        })
        this.breadcrumbs = [];
        this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
        this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, false);
        //Added By Bhawesh 21-01-2022
        if (this.partSearchValue) {
            this.buildBreadcrumbs('Search', BREADCRUMB_TYPE.SEARCH, true);
        }
        //End
        this.buildBreadcrumbs(selectedCategory.Description, BREADCRUMB_TYPE.CATEGORY, true);
        this.myBreadcrumbs = [];
        var oldLocation = location, url = window.location.href;//url variable is introduced for 3520.
        var marketPlaceURL = 'https://dev-hondamarketplace.cs17.force.com/s/';
        this.myBreadcrumbs.push({ label: this.brandName, name: this.marketPlaceURL, id: this.brandName });
        this.myBreadcrumbs.push({ label: this.productType, name: this.marketPlaceURL, id: this.productType });
        //url = window.location.href; //url variable is introduced for 3520.
        this.myBreadcrumbs.push({ label: selectedCategory.Description, name: url, id: selectedCategory.Description });
        //Added by Bhawesh R2 story 5492 fast moving item
        if (req.isMaintenanceCategory) {
            this.fetchMaintenanceParts(req);
            return;
        }
        //End
        //Added By Bhawesh for R2 5084 start
        if (this.partSearchValue && this.partSearchValue.length && this.clone_PartSearchResult && this.clone_PartSearchResult.IllustrationGroups) {
            let fillterSubCategoryList = this.clone_PartSearchResult.IllustrationGroups.filter(subCategory => {
                //this.buildDataLayer(); for adobe bug-49(2):commented
                return subCategory.SectionID == req.SectionID;
            });
            this.partSearchedResult.IllustrationGroups = fillterSubCategoryList;
            this.displaySearchPage = true;
            this.template.querySelector('c-parent-category-accordion').subCategories(this.partSearchedResult, req.SectionID);
            this.buildDataLayer();//for adobe bug-49
            return;
        }
        // HDMP-11504 starts here
        else if (this.partSearchValue && this.partSearchValue.length) {
            this.partSearchedResult = JSON.parse(localStorage.getItem('filteredProductData'));
            let fillterSubCategoryList = JSON.parse(localStorage.getItem('filterCatLogs')).IllustrationGroups.filter(subCategory => {
                //this.buildDataLayer(); for adobe bug-49(2):commented
                return subCategory.SectionID == req.SectionID;
            });
            this.partSearchedResult.IllustrationGroups = fillterSubCategoryList;
            this.displaySearchPage = true;
            this.template.querySelector('c-parent-category-accordion').subCategories(this.partSearchedResult, req.SectionID);
            this.buildDataLayer();//for adobe bug-49
            return;
        }
        // HDMP-11504 ends here
        //End
        GetIllustrationBySectionID({ reqBody: JSON.stringify(req) }).then(result => {
            if (result && result.isError && sessionStorage.getItem('SEO_SectionId') && sessionStorage.getItem('SEO_SectionId') != null) {
                this.subcategoriesdata = null;
            } else if (result) {
                let data = JSON.parse(result);
                console.log('OUTPUTdata : ', data);
                this.subCategories = Object.assign({}, data);
                if (this.subCategories && this.subCategories.IllustrationGroups && this.subCategories.IllustrationGroups.length) {
                    this.template.querySelector('c-parent-category-accordion').subCategories(this.subCategories, req.SectionID);
                    this.template.querySelector('c-parent-category-card').getSubCategory(this.subCategories);
                    sessionStorage.setItem('subCategories', JSON.stringify(this.subCategories));
                    sessionStorage.setItem('subCategoriesId', req.SectionID);
                    sessionStorage.setItem(selectedCategory.Description, JSON.stringify(this.subCategories));
                    sessionStorage.setItem('fromWhichPageUserHasRefresh', 'SUBCATEGORY');
                } else {
                    this.showCategoryCard = false;
                    this.showAccordion = false;
                    this.showErrorMessage = true;
                }
            }
        }).catch(error => {
            console.log('ErrorG : ', error);
        });
        //for adobe analytics:starts
        let breadcrumbs_adobe = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));//for adobe bug-08
        if (this.currentPage_Adobe == undefined || this.currentPage_Adobe != breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label) {
            this.currentPage_Adobe = breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label;
            const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        }
        //for adobe analytics:ends

    }
    //Added by Bhawesh R2 story 5492 fast moving item
    fetchMaintenanceParts(req) {
        this.isLoading = true;
        if (req) {
            maintainenceProduct({ division: parseInt(req.DivisionID), year: parseInt(req.YearID), productId: parseInt(req.ProductID), doorId: parseInt(req.DoorID), gradeId: parseInt(req.GradeID), catalogId: parseInt(req.CatalogID), TransmissionID: parseInt(req.TransmissionID) })
                .then(result => {
                    let maintenanceParts = JSON.parse(result);
                    if (maintenanceParts && maintenanceParts.isError) {
                        this.showErrorMessage = true;
                        this.isLoading = false;
                    } else if (maintenanceParts && !maintenanceParts.isError) {
                        sessionStorage.setItem('category', JSON.stringify({ 'division': this.division, 'sectionId': null, 'illustrationId': null, 'illustrationGroupImageId': null }));
                        this.showErrorMessage = false;
                        let maintainencePartsList = JSON.parse(result);
                        this.productList = maintainencePartsList;
                        if (getCurrentDealerId()) {
                            this.getDealerPriceForMaintenance();
                        } else {
                            this.showCategoryCard = false;
                            this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
                            this.isLoading = false;
                            sessionStorage.setItem('products', JSON.stringify(this.productList));
                        }
                        if (this.template.querySelector('c-parent-category-accordion'))
                            localStorage.setItem('openedSection', req.SectionID);
                        this.template.querySelector('c-parent-category-accordion').openSelectedCategoryFromParent(req.SectionID);
                    }
                    //for adobe analytics:starts
                    let breadcrumbs_adobe = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));//for adobe bug
                    if (this.currentPage_Adobe == undefined || this.currentPage_Adobe != breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label) {
                        this.currentPage_Adobe = breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label;
                        const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
                        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                    }
                    //for adobe analytics:ends
                })
                .catch(error => {
                    sessionStorage.setItem('products', JSON.stringify(this.productList));
                });
        }
    }
    //End
    //Added by faraz on 16March for 8389 
    getDealerPriceForMaintenance() {
        if (getCurrentDealerId() && this.productList && this.productList.Parts) {
            let dealer = getCurrentDealer();
            this.vehicle = getCurrentVehicle();
            let partNumberList = [];
            let accessories = [];
            this.productList.Parts.forEach(part => {
                partNumberList.push(part.PartNumber);
            });
            let uniquePartNumberList = partNumberList.filter(function (item, index, inputArray) {
                return inputArray.indexOf(item) == index;
            });
            if (uniquePartNumberList.length > 0 || accessories.length > 0) {
                GetDealerPrice({
                    dealerNo: dealer.dealerNo,
                    divisionId: this.vehicle.iNDivisionID__c,
                    partNumbers: JSON.stringify(uniquePartNumberList),
                    accessories: JSON.stringify(accessories)
                }).then(result => {
                    if (result) {
                        let dealerPriceResult = JSON.parse(result);
                        // Saravanan LTIM for 18865 !dealerPriceResult.isError
                        if (dealerPriceResult.Parts && !dealerPriceResult.isError ) {
                            dealerPriceResult.Parts.forEach(pdp => {
                                this.productList.Parts.forEach(product => {
                                    if (pdp.PartNumber === product.PartNumber) {
                                        product.DealerNetPriceAmount = pdp.DIYPrice;
                                        product.SuggestedRetailPriceAmount = pdp.DIYPrice;
                                    }
                                });
                            });
                            this.productList = { ...this.productList };
                            this.priceType = 'Dealer Price';
                            sessionStorage.setItem('products', JSON.stringify(this.productList));
                            this.showCategoryCard = false;
                            this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
                            this.isLoading = false;
                        }else{
                            // Saravanan LTIM Added for 18865'
                            console.log('Dealer API Failed---');

                            this.productList.Parts.forEach(part => {
                                
                                part.disableAddToCart = true; 
                            });
                        }

                    }
                }).catch(error => {
                    this.showCategoryCard = false;
                    //this.showPLP = true;
                    this.isLoading = false;
                });
            }
        }
    }
    //End
    handleOnSelectSubCategory(event) {
        debugger;
        // Added By Bhawesh 12-01-2022 story 5084 start
        const subCategoryInfo = JSON.parse(JSON.stringify(event.detail));
        let req = event.detail;
        req.DivisionID = this.division;
        let subCatId = req.IllustrationGroupID;
        // Added by Bhawesh 07-02-2022 bug - HDMP-7078
        this.selectedSubCategoryId = req.IllustrationGroupID;
        // End
        if (this.partSearchValue && this.partSearchedResult) {
            if (this.partSearchedResult.Parts.length == 0) {
                //Lakshman Breadcrumb Fix for Search parts Starts
                if (this.partSearchValue) {
                    let selectedCategory = this.catelogs.IllustrationGroups.find((subCategory) => {
                        return subCategory.ID == req.IllustrationGroupID;
                    })
                    if (selectedCategory.Description) {
                        this.buildBreadcrumbs(selectedCategory.Description, BREADCRUMB_TYPE.SUBCATEGORY, true);
                        this.buildDataLayer();//for adobe bug-49
                    }
                }
                //Lakshman Breadcrumb Fix for Search parts Ends
                this.isLoading = true;
                this.fetchPartialSearchProduct(subCategoryInfo.SectionID, subCategoryInfo.IllustrationGroupID, subCategoryInfo.IllustrationGroupImageID, this.partSearchValue);
            } else {
                this.productList = this.partSearchedResult;
                //Added By Bhawesh 24-01-2022 start BugNo 6880
                localStorage.setItem('filteredProductData', JSON.stringify(this.productList));
                //End
                //Added By Lakshman 01-02-2022 HDMP-6887
                if (this.partSearchValue) {
                    let selectedCategory = this.catelogs.IllustrationGroups.find((subCategory) => {
                        return subCategory.ID == req.IllustrationGroupID;
                    })
                    if (selectedCategory.Description) {
                        this.buildBreadcrumbs(selectedCategory.Description, BREADCRUMB_TYPE.SUBCATEGORY, true);
                        this.buildDataLayer();//for adobe bug-49
                    }

                }
                //Lakshman Breadcrumb Fix for Search parts Ends
                this.displaySearchPage = false;
                this.showCategoryCard = false;
                this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
                this.buildDataLayer();//for adobe bug-49
                if (this.showPLP) {
                    window.scrollTo(0, 0);
                }
                return;
            }
        }
        // End
        this.template.querySelector('c-parent-category-accordion').markSubCategoryAsSelected(subCatId);
        let selectedCategory = JSON.parse(JSON.stringify(this.subCategories.IllustrationGroups)).find((subCategory) => {
            return subCategory.ID == req.IllustrationGroupID;
        })

        this.buildBreadcrumbs(selectedCategory.Description, BREADCRUMB_TYPE.SUBCATEGORY, true);
        this.buildDataLayer();//for adobe bug-49

        let breadcrumbs_Copy = [];
        if (this.myBreadcrumbs && this.myBreadcrumbs.length >= 2) {
            breadcrumbs_Copy.push(this.myBreadcrumbs[0]);
            breadcrumbs_Copy.push(this.myBreadcrumbs[1]);
            breadcrumbs_Copy.push(this.myBreadcrumbs[2]);
        }
        var oldLocation = location;
        breadcrumbs_Copy.push({
            label: selectedCategory.Description,
            name: oldLocation,
            id: selectedCategory.Description
        });
        this.myBreadcrumbs = breadcrumbs_Copy;
        this.isLoading = true;
		this.dataErrorMessage='';//Added by vivek M for HDMP-18899
        if (req.SectionID && req.SectionID != null && req.IllustrationGroupID && req.IllustrationGroupID != null && req.IllustrationGroupImageID && req.IllustrationGroupImageID != null) {
            GetPartsByIllustrationID({ reqBody: JSON.stringify(req) }).then(result => {
                if (result) {
                    let data = JSON.parse(result);
                    //Added by vivek M for HDMP-19409
                    if(data.Parts){
                        this.checkMSRPreturnedAsZeroOrNull(data.Parts);
                    }
                    //End of changes by vivek M for HDMP-19409
                    if (getCurrentDealerId()) {
                        if (data) {
                            let partNumberList = [];
                            let accessoriesList = [];
                            let dealer = getCurrentDealer();
                            data.Parts.forEach(part => {
                                partNumberList.push(part.PartNumber);
                            });
                            let uniquePartNumberList = partNumberList.filter(function (item, index, inputArray) {
                                //this.buildDataLayer(); for adobe bug-49(2):commented
                                return inputArray.indexOf(item) == index;
                            });
                            this.buildDataLayer();//for adobe bug-49
                            if (uniquePartNumberList.length > 0 || accessoriesList.length > 0) {
                                debugger;
                                GetDealerPrice({
                                    dealerNo: dealer.dealerNo,
                                    divisionId: this.vehicle.iNDivisionID__c,
                                    partNumbers: JSON.stringify(uniquePartNumberList),
                                    accessories: JSON.stringify(accessoriesList)
                                }).then(result => {
                                    if (result) {
                                        debugger;
                                        let dealerPriceResult = JSON.parse(result);
                                        if (dealerPriceResult.Parts) {
                                            dealerPriceResult.Parts.forEach(pdp => {
                                                data.Parts.forEach(product => {
                                                    if (pdp.PartNumber === product.PartNumber) {
                                                        product.DealerNetPriceAmount = pdp.DIYPrice;
                                                        product.SuggestedRetailPriceAmount = pdp.DIYPrice;
														//Added by vivek M for HDMP-18899
                                                    if (product.CoreCostAmount!=0 &&(pdp.DIYPrice <= 0 || pdp.DIYPrice == null)) {
                                                        this.dataErrorMessage += '\nERROR: On PLP Page Dealer pricing API returned DIYPrice="' + pdp.DIYPrice + '" for part ' + pdp.PartNumber ;
                                                    }
                                                    //End of changes by vivek M for HDMP-18899
                                                    }
                                                });
                                            });
                                        }
										//Added by vivek M for HDMP-18899
                                        else {
                                            data.Parts.forEach(product => {
                                                product.DealerNetPriceAmount = 0;
                                                product.SuggestedRetailPriceAmount = 0;
                                            });
                                            console.log('Debug Data ' + JSON.stringify(data));
                                        }
                                        //End of changes by vivek M for HDMP-18865
                                    if (this.dataErrorMessage) {
                                        console.log('Errors to log ' + this.dataErrorMessage);
                                        logAPIDataError({ errorMessage: this.dataErrorMessage, messageType: 'Dealer pricing API Data erorr' })
                                        .then(errId => {
                                            console.log('Error logged in Table ' + errId);
                                            this.dataErrorMessage='';                                     
                                        }).catch(error => console.log('Error log update failure' + JSON.stringify(error)));
                                    }
                                    //End of changes by vivek M for HDMP-18899
                                        this.productList = Object.assign({}, data);
                                        this.nonFilteredProductList = this.partSearchedResult;
                                        this.priceType = 'Dealer Price';
                                        sessionStorage.setItem('products', JSON.stringify(this.productList));
                                    }
                                }).catch(error => {
                                    
                                });
                            }
                        }
                    } else {
                        this.productList = Object.assign({}, data);
                        this.nonFilteredProductList = this.productList;
                        sessionStorage.setItem('products', JSON.stringify(this.productList));
                    }
                    this.showCategoryCard = false;
                    this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
                    setTimeout(() => {
                        if (this.showPLP) {
                            window.scrollTo(0, 0);
                        }
                        this.isLoading = false;
                    }, 500);
                    sessionStorage.setItem('fromWhichPageUserHasRefresh', 'PLP');
                } else {
                    this.isLoading = false;
                }
            }).catch(error => {
                this.isLoading = false;
            });

            this.buildDataLayer();//for adobe bug-49
        } else {
            console.error('Request body is not valid : ', JSON.stringify(req));
        }
    }
    closeSubCategory() {
        this.selectedSectionId = '';
        this.selectedSubCategoryId = '';

        sessionStorage.setItem('fromWhichPageUserHasRefresh', 'CATEGORY');
        this.breadcrumbs = [];
        this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
        this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, true);
        this.myBreadcrumbs = [];
        var oldLocation = location;
        this.myBreadcrumbs.push({ label: this.productType, name: oldLocation, id: this.productType });
        this.showCategoryCard = true;
        this.showPLP = false;
        this.subcategoriesdata = null;
        if (this.partSearchedResult && this.partSearchValue.length && this.partSearchedResult.IllustrationGroups) {
            this.partSearchedResult.IllustrationGroups = this.clone_PartSearchResult.IllustrationGroups;
            this.displaySearchPage = true;
            this.buildDataLayer();//for adobe bug-49
            return;
        }
        this.template.querySelector('c-parent-category-card').closeSubCategory('Close');
        this.buildDataLayer();//for adobe bug-49
    }
    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);
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
    async handleShowAccessoriesORParts() {
        this.buildEffectiveVehicleAndDealer();
        this.vehicle = getCurrentVehicle();
        this.selectedPartOrAccessories = this.vehicle.productType;
        if (this.selectedPartOrAccessories == 'Parts') {
            this.showAccessories = false;
            this.showAccordion = true;
            this.showCategoryCard = true;
            this.showPLP = false;
            this.showErrorMessage = this.catelogs && this.catelogs != undefined ? false : true;
        } else if (this.selectedPartOrAccessories == 'Accessories') {
            this.showAccordion = false;
            this.showCategoryCard = false;
            this.showPLP = false;
            if (!this.accessoriesList.length) {
                let vehicalObj = this.vehicle; // JSON.parse(this.getCookie('vehicle'));
                let poiType = this.division == 1 ? 'A' : 'B';
                if (this.vinNumber && this.vinNumber != 'undefined' && poiType) { // getting accessories by using VIN Number
                    this.getModelId(this.vinNumber, poiType);
                } else if (vehicalObj && vehicalObj.Model_Id__c) { // getting accessories by using Year Model and Trim
                    this.getAccessoriesByModelId(vehicalObj.Model_Id__c, poiType);
                }
            } else {
                this.showAccessories = true;
            }
        }
        await this.sleep(3000);
        //for adobe analytics:starts
        let breadcrumbs_adobe = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));//for adobe bug-08
        if (this.currentPage_Adobe == undefined || this.currentPage_Adobe != breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label) {
            this.currentPage_Adobe = breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label;
            const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        }
        //for adobe analytics:ends
    }
    //for adobe analytics: starts
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    //ends
    async handleShowParts() {
        let url_string = this.fromAccessories ? window.location.origin : window.location.href;
        let url = new URL(url_string);
        let label = url.searchParams.get("label");
        let categorylabel = url.searchParams.get("categorylabel");
        let category = undefined;
        let subCategoryObj = undefined;
        let typefromURL = url.searchParams.get("type");
        if ((label && categorylabel) || typefromURL == 'producttype' /*&& localStorage.getItem('isPLPPage') == 'true'*/) {
            localStorage.setItem('isPLPPage', 'false');
            let subcategoriesdata = JSON.parse(sessionStorage.getItem(categorylabel));
            if (subcategoriesdata && subcategoriesdata != null && subcategoriesdata.IllustrationGroups) {
                subCategoryObj = subcategoriesdata.IllustrationGroups.filter((subCat) => {
                    return subCat.Description == label;
                });
            }
            if (subCategoryObj[0] && subCategoryObj[0].SectionID) {
                category = JSON.parse(JSON.stringify({ 'division': 1, 'sectionId': subCategoryObj[0].SectionID, 'illustrationId': subCategoryObj[0].ID, 'illustrationGroupImageId': subCategoryObj[0].IllustrationGroupImageID }));
            }
        } else {
            category = sessionStorage.getItem('category') ? JSON.parse(sessionStorage.getItem('category')) : undefined;
        }
        if (category) {
            let sectionId = category.sectionId;
            let illustrationId = category.illustrationId;
            let illustrationGroupImageId = category.illustrationGroupImageId;
            let request = {
                "RegionID": 1,
                "DivisionID": this.vehicle.iNDivisionID__c,
                "LanguageID": 0,
                "ProductCategoryID": this.catelogs.ProductCategories[0].ID,
                "ProductID": this.catelogs.Products[0].ID,
                "DoorID": this.catelogs.Doors[0].ID,
                "YearID": this.catelogs.Years[0].ID,
                "GradeID": this.catelogs.Grades[0].ID,
                "CatalogID": this.catelogs.Catalogs[0].CatalogID,
                "AreaID": this.catelogs.Areas[0].ID,
                "OriginID": this.catelogs.Origins[0].ID,
                //"TransmissionID": this.catelogs.Transmissions[0].ID,
                "TransmissionID": this.catelogs.Transmissions[0] == null ? null : this.catelogs.Transmissions[0].ID,
                "ColorLabelID": this.catelogs.ColorLabels[0].ID,
                "ColorNameID": this.catelogs.ColorNames[0].ID,
                "SectionID": sectionId,
                "IllustrationGroupID": illustrationId,
                "IllustrationGroupImageID": illustrationGroupImageId
            }
            let req = request;
            req.DivisionID = this.division;
            if (req.SectionID && req.SectionID != null && req.IllustrationGroupID && req.IllustrationGroupID != null && req.IllustrationGroupImageID && req.IllustrationGroupImageID != null) {
                await GetPartsByIllustrationID({ reqBody: JSON.stringify(req) }).then(result => {
                    if (result) {
                        let data = JSON.parse(result);
                        //Added by vivek M for HDMP-19409
                        if(data.Parts){
                            this.checkMSRPreturnedAsZeroOrNull(data.Parts);
                        }
                        //End of changes by vivek M for HDMP-19409
                        if (getCurrentDealerId()) {
                            if (data) {
                                let partNumberList = [];
                                let accessoriesList = [];
                                let dealer = getCurrentDealer();
                                data.Parts.forEach(part => {
                                    partNumberList.push(part.PartNumber);
                                });
                                let uniquePartNumberList = partNumberList.filter(function (item, index, inputArray) {
                                    return inputArray.indexOf(item) == index;
                                });
								this.dataErrorMessage = '';//Added by vivek M for HDMP-18899
                                if (uniquePartNumberList.length > 0 || accessoriesList.length > 0) {
                                    GetDealerPrice({
                                        dealerNo: dealer.dealerNo,
                                        divisionId: this.vehicle.iNDivisionID__c,
                                        partNumbers: JSON.stringify(uniquePartNumberList),
                                        accessories: JSON.stringify(accessoriesList)
                                    }).then(result => {
                                        if (result) {
                                            let dealerPriceResult = JSON.parse(result);
                                            // Saravanan LTIM Added for 18865 !dealerPriceResult.isError
                                            if (dealerPriceResult.Parts && !dealerPriceResult.isError) {
                                                dealerPriceResult.Parts.forEach(pdp => {
                                                    data.Parts.forEach(product => {
                                                        if (pdp.PartNumber === product.PartNumber) {
                                                            // product.DealerNetPriceAmount = pdp.DealerPrice;
                                                            product.DealerNetPriceAmount = pdp.DIYPrice; // Added by Bhawesh
                                                            product.SuggestedRetailPriceAmount = pdp.DIYPrice;
															//Added by vivek M for HDMP-18899
                                                        if (product.CoreCostAmount!=0 &&(pdp.DIYPrice <= 0 || pdp.DIYPrice == null)) {
                                                            this.dataErrorMessage += '\nERROR: On PLP Page Dealer pricing API returned DIYPrice="' + pdp.DIYPrice + '" for part ' + pdp.PartNumber;
                                                        }
                                                        //End of changes by vivek M for HDMP-18899

                                                        }
                                                    });
                                                });
                                            }
											//Added by vivek M for HDMP-18899
                                            //Added by vivek M for HDMP-18865
                                            else {
                                                data.Parts.forEach(product => {
                                                    product.DealerNetPriceAmount = 0;
                                                    product.SuggestedRetailPriceAmount = 0;
                                                    product.disableAddToCart = true; // Saravanan LTIM for 18865
                                                });
                                                console.log('Data ' + JSON.stringify(data));
                                                this.isDealerAPiErr = true; // Added by Aditya LTIM for 18865
                                            }
                                            //End of changes by vivek M for HDMP-18865  
                                        if (this.dataErrorMessage) {
                                            console.log('Errors to log ' + this.dataErrorMessage);
                                            logAPIDataError({ errorMessage: this.dataErrorMessage, messageType: 'Dealer pricing API Data erorr' })
                                            .then(errId => {
                                                console.log('Error logged in Table ' + errId);
                                                this.dataErrorMessage='';                                     
                                            }).catch(error => console.log('Error log update failure' + JSON.stringify(error)));
                                        }
                                        //End of changes by vivek M for HDMP-18899
                                            this.productList = Object.assign({}, data);
                                            this.priceType = 'Dealer Price';
                                            this.showCategoryCard = false;
                                            this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
                                            sessionStorage.setItem('products', JSON.stringify(this.productList));
                                        }
                                    }).catch(error => {
                                    });
                                }
                                this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
                            }
                        } else {
                            if (!this.partSearchValue) {
                                this.productList = Object.assign({}, data);
                            }
                            if (!this.urlStateParameters.type) {
                                let subCategories = sessionStorage.getItem('subCategories') ? JSON.parse(sessionStorage.getItem('subCategories')) : undefined;
                                let selectedCategory = subCategories.IllustrationGroups.find((subCategory) => {
                                    return subCategory.ID == category.illustrationId;
                                })
                                this.buildBreadcrumbs(selectedCategory.SectionDescription, BREADCRUMB_TYPE.CATEGORY, false);
                                this.buildBreadcrumbs(selectedCategory.Description, BREADCRUMB_TYPE.SUBCATEGORY, true);
                            }
                            this.showCategoryCard = false;
                            this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
                            sessionStorage.setItem('products', JSON.stringify(this.productList));
                        }
                    }
                }).catch(error => { });
            } else {
                console.error('Request body is not valid : ', JSON.stringify(req));
            }
        }
    }
    _categoryPath;
    _resolvedCategoryPath = [];

    _resolveConnected;
    _connected = new Promise((resolve) => {
        this._resolveConnected = resolve;
    });
    disconnectedCallback() {
        this._connected = new Promise((resolve) => {
            this._resolveConnected = resolve;
        });
    }
    @api
    get categoryPath() {
        return this._categoryPath;
    }
    set categoryPath(newPath) {
        this._categoryPath = newPath;
        this.resolveCategoryPath(newPath || []);
    }
    get hasPrice() {
        return (this.price || {}) > 0;
    }
    handleQuantityChange(event) {
        if (event.target.validity.valid) {
            this._invalidQuantity = false;
            if (event.target.value != null) {
                this._quantityFieldValue = event.target.value;
            } else {
                this._quantityFieldValue = 0;
            }
        } else {
            this._invalidQuantity = true;
        }
    }
    @api
    displayData;

    resolveCategoryPath(newPath) {
        const path = [homePage].concat(
            newPath.map((level) => ({
                name: level.name,
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'view',
                    recordId: level.id
                }
            }))
        );
        this._connected
            .then(() => {
                const levelsResolved = path.map((level) =>
                    this[NavigationMixin.GenerateUrl]({
                        type: level.type,
                        attributes: level.attributes
                    }).then((url) => ({
                        name: level.name,
                        url: url
                    }))
                );
                return Promise.all(levelsResolved);
            })
            .then((levels) => {
                this._resolvedCategoryPath = levels;
            });
    }
    closeModal() {
        this.isModalOpen = false;
    }
    submitDetails() {
        this.isModalOpen = false;
    }
    handleNavigateTo(event) {
        event.preventDefault();
        const name = event.target.name;
        window.location.assign(name);
        i
    }
    handleOpenAccessories(event) {
        this.myBreadcrumbs = []
        let req = event.detail;
        this.myBreadcrumbs = req;
    }
    buildBreadcrumbs(label, type, isCurrentPage) {
        if (this.breadcrumbs) {
            this.breadcrumbs.forEach(breadcrumb => {
                breadcrumb.isCurrentPage = false;
            });
        }
        let url = 'javascript:void(0);';
        let categoryURL = '';
        if (type === BREADCRUMB_TYPE.BRAND) {
            url = window.location.origin + '/s/' + label.toLowerCase();
        }
        if (type === BREADCRUMB_TYPE.PRODUCTTYPE || type === BREADCRUMB_TYPE.CATEGORY || type === BREADCRUMB_TYPE.SUBCATEGORY) {
            categoryURL = window.location.href.split('?')[0];
        }
        let hasSubCategoryExist = false;
        if (type === BREADCRUMB_TYPE.SUBCATEGORY) {
            if (this.breadcrumbs) {
                this.breadcrumbs.forEach(breadcrumb => {
                    if (type === breadcrumb.name) {
                        breadcrumb.label = label;
                        breadcrumb.isCurrentPage = true;
                        hasSubCategoryExist = true;
                    }
                });
            }
        }
        if (!hasSubCategoryExist) {
            this.breadcrumbs.push({
                label: label,
                name: type,
                href: url,
                isCurrentPage: isCurrentPage,
                categoryURL: categoryURL
            });
        }
        if (this.breadcrumbs) {
            this.breadcrumbs.forEach(breadcrumb => {
                if (breadcrumb.label && breadcrumb.label.toLowerCase() == BREADCRUMB_TYPE.SEARCH) {
                    breadcrumb.isCurrentPage = false; //modified by Yashika for 5313
                }
            });
        }
        //End
        let brand = sessionStorage.getItem('vehicleBrand');
        let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
        breadcrumbsMap.set(brand, JSON.parse(JSON.stringify(this.breadcrumbs)));
        sessionStorage.setItem('breadcrumbsMap', JSON.stringify([...breadcrumbsMap]));
    }
    handleBreadcrumbClick(event) {
        let type = event.currentTarget.dataset.type;
        let label = event.currentTarget.dataset.label;
        let categorylabel = event.currentTarget.dataset.categorylabel;
        let url_string = this.fromAccessories ? window.location.origin : window.location.href;
        let url = new URL(url_string);
        let Subcategorylabel;
        if (type === BREADCRUMB_TYPE.CATEGORY) {
            Subcategorylabel = url.searchParams.get("label");
        }
        if (type === BREADCRUMB_TYPE.SUBCATEGORY) {
            Subcategorylabel = url.searchParams.get("categorylabel");
        }
        if (label) {
            label = label.replaceAll('+', ' ');
        }
        if (categorylabel) {
            categorylabel = categorylabel.replaceAll('+', ' ');
        }
        if (type === BREADCRUMB_TYPE.PRODUCTTYPE) {
            this.displaySearchPage = false;
            this.partSearchValue = '';
            this.catelogs = this.cloneCategoryData;
            if (type == BREADCRUMB_TYPE.PRODUCTTYPE && label == 'Parts') {
                let catelogDataObj = sessionStorage.getItem('CatLogsData');
                this.catelogs = JSON.parse(catelogDataObj)[sessionStorage.getItem('vehicleBrand')];
            }
            this.showErrorMessage = false;
            this.showAccessories = false;
            this.showCategoryCard = true;
            this.showPLP = false;
            this.subcategoriesdata = null;
            this.breadcrumbs = [];
            this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
            this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, true);
            if (this.template.querySelector('c-parent-category-card')) {
                this.template.querySelector('c-parent-category-card').closeSubCategory('Close');
            }
            if (this.template.querySelector('c-parent-category-accordion')) {
                this.template.querySelector('c-parent-category-accordion').closeAllCategory();
                this.template.querySelector('c-parent-category-accordion').setCollapseIconForAll();
            }
            sessionStorage.setItem('fromWhichPageUserHasRefresh', 'CATEGORY');
        } else if (type === BREADCRUMB_TYPE.CATEGORY) {
            this.showAccessories = false;
            if (this.partSearchedResult && this.partSearchValue.length && this.partSearchedResult.IllustrationGroups) {
                this.displaySearchPage = true;
                this.breadcrumbs = [];
                this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
                this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, false);
                this.buildBreadcrumbs('Search', BREADCRUMB_TYPE.SEARCH, true);
                this.buildBreadcrumbs(label, BREADCRUMB_TYPE.CATEGORY, true);
                let breadcrumbs_adobe = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));//for adobe bug-08
                if ((this.currentPage_Adobe == undefined || this.currentPage_Adobe != breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label) && (label != 'Honda' || label != 'Acura') && type !== BREADCRUMB_TYPE.SEARCH) {
                    this.currentPage_Adobe = breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label;
                    const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
                    publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                }
                return;
            }
            if (this.subCategories) {
                this.subcategoriesdata = this.subCategories;
                if (Subcategorylabel && sessionStorage.getItem(Subcategorylabel) != null) {
                    sessionStorage.setItem('subCategories', sessionStorage.getItem(Subcategorylabel));
                    this.subCategories = JSON.parse(sessionStorage.getItem(Subcategorylabel));
                    this.subcategoriesdata = JSON.parse(sessionStorage.getItem(Subcategorylabel));
                }
            }
            if (!this.subCategories) {
                this.subcategoriesdata = JSON.parse(sessionStorage.getItem('subCategories'));
                this.subCategories = this.subcategoriesdata;
            }
            window.clearTimeout(this.delayTimeout);
            this.delayTimeout = setTimeout(() => {
                if (this.template.querySelector('c-parent-category-accordion') && label != 'MAINTENANCE') {
                    this.template.querySelector('c-parent-category-accordion').subCategories(this.subCategories, parseInt(this.subCategories.IllustrationGroups[0].SectionID));
                }
            }, 2000);
            if (label == 'MAINTENANCE') {
                this.showCategoryCard = false;
                this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
                this.productList = JSON.parse(sessionStorage.getItem('products'));
                this.delayTimeout = setTimeout(() => {
                    if (this.template.querySelector('c-parent-category-accordion')) {
                        this.template.querySelector('c-parent-category-accordion').setAccordioIconForMaintenance();
                    }
                }, 2000);
            } else if (label != 'MAINTENANCE') {
                this.showCategoryCard = true;
                this.showPLP = false;
            }
            //End
            this.breadcrumbs = [];
            this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
            this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, false);
            this.buildBreadcrumbs(label, BREADCRUMB_TYPE.CATEGORY, true);
            sessionStorage.setItem('fromWhichPageUserHasRefresh', 'SUBCATEGORY');
        } else if (type === BREADCRUMB_TYPE.SUBCATEGORY) {
            this.showAccessories = false;
            if (this.subCategories && !this.partSearchValue) {
                this.subcategoriesdata = this.subCategories;
            }
            if (!this.subCategories && !this.partSearchValue) {
                this.subcategoriesdata = JSON.parse(sessionStorage.getItem('subCategories'));
                this.subCategories = this.subcategoriesdata;
                window.clearTimeout(this.delayTimeout);
                this.delayTimeout = setTimeout(() => {
                    if (this.template.querySelector('c-parent-category-accordion')) {
                        this.template.querySelector('c-parent-category-accordion').subCategories(this.subCategories, parseInt(sessionStorage.getItem('subCategoriesId')));
                    }
                }, 2000);
            }
            this.showCategoryCard = false;
            this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
            this.breadcrumbs = [];
            this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
            this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, false);
            if (this.partSearchValue) {
                this.buildBreadcrumbs('Search', BREADCRUMB_TYPE.SEARCH, true);
            }
            this.buildBreadcrumbs(categorylabel, BREADCRUMB_TYPE.CATEGORY, false);
            this.buildBreadcrumbs(label, BREADCRUMB_TYPE.SUBCATEGORY, true);
        }
        else if (type === BREADCRUMB_TYPE.SEARCH) {
            this.handleOnPartSearch();
        }
        let breadcrumbs_adobe = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));//for adobe bug-08
        if ((this.currentPage_Adobe == undefined || this.currentPage_Adobe != breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label) && (label != 'Honda' || label != 'Acura') && type !== BREADCRUMB_TYPE.SEARCH) {
            this.currentPage_Adobe = breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label;
            const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        }
    }
    handleUnloadFunctionality(event) {
        let breadcrumbsJSON = JSON.parse(sessionStorage.getItem('breadcrumbsMap'));
        let breadcrumbs = JSON.parse(sessionStorage.getItem('breadcrumbsMap'));
        let bready = this.breadcrumbs;
        if (this.breadcrumbs[1]) {
            var breads = this.breadcrumbs;
            for (let i = 0; i < breads.length; i++) {
                if (breads[i].isCurrentPage) {
                    const newevent = new Event('click');
                    event.preventDefault();
                    event.returnValue = 'Back?';
                }
            }
        }
    }
    handleBreadcrumbHelper(type, label, categorylabel) {
        if (label) {
            label = label.replaceAll('+', ' ');
        }
        if (categorylabel) {
            categorylabel = categorylabel.replaceAll('+', ' ');
        }
        if (type === BREADCRUMB_TYPE.PRODUCTTYPE) {
            this.showAccessories = false;
            this.showCategoryCard = true;
            this.showPLP = false;
            this.subcategoriesdata = null;
            this.breadcrumbs = [];
            this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
            this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, true);
            if (this.template.querySelector('c-parent-category-card')) {
                this.template.querySelector('c-parent-category-card').closeSubCategory('Close');
            }
            if (this.template.querySelector('c-parent-category-accordion')) {
                this.template.querySelector('c-parent-category-accordion').closeAllCategory();
            }
        } else if (type === BREADCRUMB_TYPE.CATEGORY) {
            this.showAccessories = false;
            if (this.subCategories) {
                this.subcategoriesdata = this.subCategories;
            }
            if (!this.subCategories) {
                this.subcategoriesdata = JSON.parse(sessionStorage.getItem('subCategories'));
                this.subCategories = this.subcategoriesdata;
            }
            window.clearTimeout(this.delayTimeout);
            this.delayTimeout = setTimeout(() => {
                if (this.template.querySelector('c-parent-category-accordion')) {
                    this.template.querySelector('c-parent-category-accordion').subCategories(this.subCategories, parseInt(sessionStorage.getItem('subCategoriesId')));
                }
            }, 2000);
            this.showCategoryCard = true;
            this.showPLP = false;
            this.breadcrumbs = [];
            this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
            this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, false);
            this.buildBreadcrumbs(label, BREADCRUMB_TYPE.CATEGORY, true);
        } else if (type === BREADCRUMB_TYPE.SUBCATEGORY) {
            this.showAccessories = false;
            if (this.subCategories) {
                this.subcategoriesdata = this.subCategories;
            }
            if (!this.subCategories) {
                this.subcategoriesdata = JSON.parse(sessionStorage.getItem('subCategories'));
                this.subCategories = this.subcategoriesdata;
                window.clearTimeout(this.delayTimeout);
                this.delayTimeout = setTimeout(() => {
                    if (this.template.querySelector('c-parent-category-accordion')) {
                        // multiple tab issue3 starts here
                        //this.template.querySelector('c-parent-category-accordion').subCategories(this.subCategories, parseInt(localStorage.getItem('subCategoriesId')));
                        this.template.querySelector('c-parent-category-accordion').subCategories(this.subCategories, parseInt(sessionStorage.getItem('subCategoriesId')));
                        // multiple tab issue3 ends here
                    }
                }, 2000);
            }
            this.showCategoryCard = false;
            this.productList = JSON.parse(sessionStorage.getItem('products'));
            this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
            this.breadcrumbs = [];
            this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
            this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, false);
            this.buildBreadcrumbs(categorylabel, BREADCRUMB_TYPE.CATEGORY, false);
            this.buildBreadcrumbs(label, BREADCRUMB_TYPE.SUBCATEGORY, true);
        }
    }
    //added by Yashika for R2 story: accessory search
    //start
    callAccordion() {
        this.isLoading = true;
        let filteredcategoryint = this.accessoriesList.Accessories.filter(elm => elm.displaygroups.includes(ACC_CATEGORIES.INTERIOR));
        let filteredcategoryext = this.accessoriesList.Accessories.filter(elm => elm.displaygroups.includes(ACC_CATEGORIES.EXTERIOR));
        let filteredcategoryelec = this.accessoriesList.Accessories.filter(elm => elm.displaygroups.includes(ACC_CATEGORIES.ELECTRICAL));
        this.filteredcategory = [];
        if (filteredcategoryint.length > 0) {
            this.filteredcategory.push(ACC_CATEGORIES.INTERIOR);
        }
        if (filteredcategoryext.length > 0) {
            this.filteredcategory.push(ACC_CATEGORIES.EXTERIOR);
        }
        if (filteredcategoryelec.length > 0) {
            this.filteredcategory.push(ACC_CATEGORIES.ELECTRICAL);
        }
        if (this.filteredcategory.length > 1) {
            this.filteredcategory.push(ACC_CATEGORIES.ALL);
        }
        setTimeout(() => {
            this.template.querySelector("c-accessories-accordion").filtercategory(this.filteredcategory);
            this.template.querySelector('c-accessories').filteredAccessories(STORAGE.CLOSE);
            this.template.querySelector("c-accessories-accordion").clearAccordion();
        }); //ends: 8391
        this.isLoading = false;
    }
    searchAccessories(filterValue, searchTextValue) {
        this.isLoading = true;
        let filteredAcc = [];
        let wordArray = []
        let searchTextOriginal = searchTextValue; //added by Yashika for bug 7645
        searchTextValue = searchTextValue.toLowerCase();
        wordArray = searchTextValue.split(' ');
        try {
            if (filterValue == SEARCH_ACC.KEY) {
                if (searchTextValue == '') {
                    filteredAcc = this.accessoriesListOrg.Accessories.filter(acc => acc.AccessoryName.toLowerCase().includes(searchTextValue));
                } else {
                    wordArray.forEach(wor => {
                        if (wor.length > 0) {
                            this.accessoriesListOrg.Accessories.filter(elm => {
                                if ((elm.AccessoryName != undefined && elm.AccessoryDesc != undefined && elm.AccessoryName != null && elm.AccessoryDesc != null)) {
                                    if ((elm.AccessoryName.toLowerCase().includes(wor) || elm.AccessoryDesc.toLowerCase().includes(wor))) {
                                        filteredAcc.push(elm);
                                    }
                                }
                            });
                            let reqAccOpcdList = [];
                            filteredAcc.forEach(el => {
                                if (el.RequiredAccessories) {
                                    el.RequiredAccessories.forEach(it => {
                                        reqAccOpcdList.push(it);
                                    });
                                }
                            });
                            let newArray = [];
                            reqAccOpcdList.forEach(el => {
                                newArray.push(this.accessoriesListOrg.Accessories.filter(acc => acc.op_cd.includes(el.op_cd))[0]);
                            });
                            newArray.forEach(element => {
                                if (!filteredAcc.includes(element)) {
                                    filteredAcc.push(element);
                                }
                            });
                        }
                    });
                }
            }
            else if (filterValue == SEARCH_ACC.PART) {
                filteredAcc = this.accessoriesListOrg.Accessories.filter(acc => acc.Colors.filter(elm => elm.part_number.toLowerCase().replaceAll('-', '').includes(searchTextValue.replaceAll('-', '').toLowerCase())).length > 0);
                let reqAccOpcdList = [];
                filteredAcc.forEach(el => {
                    if (el.RequiredAccessories) {
                        el.RequiredAccessories.forEach(it => {
                            reqAccOpcdList.push(it);
                        });
                    }
                });
                let newArray = [];
                reqAccOpcdList.forEach(el => {
                    newArray.push(this.accessoriesListOrg.Accessories.filter(acc => acc.op_cd.includes(el.op_cd))[0]);
                });
                newArray.forEach(element => {
                    if (!filteredAcc.includes(element)) {
                        filteredAcc.push(element);
                    }
                });
            }
        } catch (error) {
        }
        this.accessoriesList[ACC_CATEGORIES.ACCESSORIES] = filteredAcc;
        this.accessoriesList[ACC_CATEGORIES.ACCESSORY] = this.accessoriesList[ACC_CATEGORIES.ACCESSORIES];
        this.accessoriesList = JSON.parse(JSON.stringify(this.accessoriesList));
        sessionStorage.setItem(STORAGE.SEARCHED_TERM, searchTextOriginal);
        sessionStorage.setItem(STORAGE.CHOSEN_FILTER, filterValue);
        this.callAccordion();
        this.isLoading = false;
    }

    filterValue = SEARCH_ACC.KEY;
    searchResults;
    handleChangeOption(event) {
        this.template.querySelector("lightning-input").value = null;
        this.filterValue = event.target.value;
        this.searchAccessories(this.filterValue, '');
    }
    handleEmptySearch(event) {
        const searchTextValue = event.target.value;
        if (searchTextValue == '') {
            this.searchAccessories(this.filterValue, '');
        }
    }
    handelOnPressEnterAcc(event) {
        if (event.which == 13) {
            this.handleSearch();
        }
    }
    handleSearch(event) {
        const searchTextValue = this.template.querySelector('.accessorySearch').value;
        let breadcrumbs_adobe = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
        this.currentPage_Adobe = breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label;
        const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        if (searchTextValue.length <= 2) {
            this.accessoriesList = this.accessoriesListOrg;
            this.accessoriesList = JSON.parse(JSON.stringify(this.accessoriesList));
            sessionStorage.setItem(STORAGE.SEARCHED_TERM, searchTextValue);
        } else {
            this.searchAccessories(this.filterValue, searchTextValue);
        }
        this.callAccordion();
    }
    handleOnSelectPartSearchVariant(event) {
        this.selectedPartSearchMethod = event.target.value;
        localStorage.setItem('selectedPartSearchMethod', this.selectedPartSearchMethod);
        this.partSearchValue = '';
        if (this.searchedApplied) {
            this.displaySearchPage = false;
            this.showAccessories = false;
            this.showCategoryCard = true;
            this.showPLP = false;
            this.catelogs = this.cloneCategoryData;
            this.subCategories = this.cloneCategoryData;
            this.searchedApplied = false;
            this.breadcrumbs = [];
            this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
            this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, true);
            this.template.querySelector('c-parent-category-accordion').closeAllCategory();
            this.template.querySelector('c-parent-category-accordion').setCollapseIconForAll();
        }
    }
    handleOnPartSearch(event) {
        if (this.selectedSectionId && !this.selectedSubCategoryId) {
            this.fromWhichPageSearched = 'category';
        } else if (this.selectedSectionId && this.selectedSubCategoryId) {
            this.fromWhichPageSearched = 'subcategory';
        } else {
            this.fromWhichPageSearched = 'producttype';
        }
        const searchCodeTypeId = this.selectedPartSearchMethod == 'keyword' ? 1 : 0;
        this.searchedApplied = true; //Added By Bhawesh 28-01-2022 for BugNo. 7067
        if (this.selectedPartSearchMethod && this.partSearchValue && this.partSearchValue.length >= MinimumPartSearch) {
            localStorage.setItem('selectedPartSearchMethod', this.selectedPartSearchMethod); //Added By Bhawesh 27-01-2022 for BugNo. 6880
            this.isLoading = true;
            this.breadcrumbs = [];
            this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
            this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, true);
            this.buildBreadcrumbs('Search', BREADCRUMB_TYPE.SEARCH, true);
            this.partSearchValue = this.partSearchValue.substring(0, 60);
            PartialSearchbyProduct({ division: this.vehicle.iNDivisionID__c, year: this.vehicle.iNYearID__c, productId: this.vehicle.iNModelID__c, doorId: this.vehicle.iNDoorID__c, gradeId: this.vehicle.iNGradeID__c, catalogId: this.vehicle.iNCatalogID__c, transmissionID: 0, sectionID: 0, illustrationGroupID: 0, illustrationGroupImageID: 0, searchCodeTypeID: searchCodeTypeId, searchCodeContains: searchCodeTypeId, searchstring: this.partSearchValue })
                .then(result => {
                    if (result) {
                        if (result && !result.isError) {
                            this.partSearchedResult = JSON.parse(result);
                            this.clone_PartSearchResult = JSON.parse(result);
                            this.template.querySelector('c-parent-category-accordion').closeAllCategory();
                            this.template.querySelector('c-parent-category-accordion').setCollapseIconForAll();
                            this.showAccordion = true;
                            let partSerachResults = JSON.parse(result);
                            partSerachResults.Sections = partSerachResults.Sections.filter(category => category.Description !== 'MULTIPLE SECTION'); // Added By Bhawesh 28-01-2022 for 6876
                            this.catelogs = partSerachResults
                            localStorage.setItem('filterCatLogs', JSON.stringify(this.catelogs));
                            if (this.catelogs && this.catelogs.IllustrationGroups && this.catelogs.IllustrationGroups.length == 1) {
                                let subCategoryInfo = this.catelogs.IllustrationGroups[0];
                                this.breadcrumbs = [];
                                this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
                                this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, true);
                                this.buildBreadcrumbs('Search', BREADCRUMB_TYPE.SEARCH, true);
                                this.buildBreadcrumbs(this.catelogs.Sections[0].Description, BREADCRUMB_TYPE.CATEGORY, true);
                                this.buildBreadcrumbs(this.catelogs.IllustrationGroups[0].Description, BREADCRUMB_TYPE.SUBCATEGORY, true);
                                if (this.partSearchedResult && this.partSearchedResult.Parts && this.partSearchedResult.Parts.length == 0) {
                                    this.isLoading = true;
                                    this.fetchPartialSearchProduct(subCategoryInfo.SectionID, subCategoryInfo.IllustrationGroupID, subCategoryInfo.IllustrationGroupImageID, this.partSearchValue);
                                } else {
                                    this.productList = this.partSearchedResult;
                                    localStorage.setItem('filteredProductData', JSON.stringify(this.productList)); // Added By BHawesh 27-01-2022 for BugNo. 6880
                                    sessionStorage.setItem('products', JSON.stringify(this.productList));
                                    this.displaySearchPage = false;
                                    this.showCategoryCard = false;
                                    this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
                                    this.isLoading = false;
                                    this.template.querySelector('c-parent-category-accordion').subCategories(this.partSearchedResult, subCategoryInfo.SectionID);
                                    this.template.querySelector('c-parent-category-accordion').openIconWithSubCategory(subCategoryInfo.SectionID, 0);
                                    let partNumberList = [];
                                    let accessoriesList = [];
                                    let dealer = getCurrentDealer();
                                    this.partSearchedResult.Parts.forEach(part => {
                                        partNumberList.push(part.PartNumber);
                                    });
                                    let uniquePartNumberList = partNumberList.filter(function (item, index, inputArray) {
                                        return inputArray.indexOf(item) == index;
                                    });
                                    if (uniquePartNumberList.length > 0 || accessoriesList.length > 0) {
                                        GetDealerPrice({
                                            dealerNo: dealer.dealerNo,
                                            divisionId: this.vehicle.iNDivisionID__c,
                                            partNumbers: JSON.stringify(uniquePartNumberList),
                                            accessories: JSON.stringify(accessoriesList)
                                        }).then(result => {
                                            if (result) {
                                                let dealerPriceResult = JSON.parse(result);
                                                if (dealerPriceResult.Parts) {
                                                    dealerPriceResult.Parts.forEach(pdp => {
                                                        this.partSearchedResult.Parts.forEach(product => {
                                                            if (pdp.PartNumber === product.PartNumber) {
                                                                product.DealerNetPriceAmount = pdp.DIYPrice; // Added by Bhawesh
                                                                product.SuggestedRetailPriceAmount = pdp.DIYPrice;

                                                            }
                                                        });
                                                    });
                                                }
                                                this.productList = Object.assign({}, this.partSearchedResult);
                                                this.priceType = 'Dealer Price';
                                                // this.productList = this.partSearchedResult;
                                                localStorage.setItem('filteredProductData', JSON.stringify(this.productList)); // Added By BHawesh 27-01-2022 for BugNo. 6880
                                                sessionStorage.setItem('products', JSON.stringify(this.productList));
                                                this.displaySearchPage = false;
                                                this.showCategoryCard = false;
                                                this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
                                                this.isLoading = false;
                                                this.template.querySelector('c-parent-category-accordion').subCategories(this.partSearchedResult, subCategoryInfo.SectionID);
                                                this.template.querySelector('c-parent-category-accordion').openIconWithSubCategory(subCategoryInfo.SectionID, 0);
                                            }
                                        }).catch(error => {
                                        });
                                    }
                                }
                            } else {
                                this.displaySearchPage = true;
                                this.isLoading = false;
                            }
                            let fromlogin = localStorage.getItem('fromlogin');
                            if (fromlogin) {
                                let breadBRMBS = JSON.parse(sessionStorage.getItem('breadcrumbsMap'));
                                breadBRMBS = breadBRMBS[0][1];
                                let storedbreadcrumbs = localStorage.getItem('storedbreadcrumbs');
                                storedbreadcrumbs = JSON.parse(storedbreadcrumbs);
                                setTimeout(() => {
                                    this.breadcrumbs = breadBRMBS;
                                }, 1000);
                                localStorage.removeItem('fromlogin');
                            }
                        }
                        else if (result.isError == TRUE && result.errorMessage == 'API Issue') {
                            this.isErrorSearch = true;
                            this.isLoading = false;
                        }
                    }
                    this.currentPage_Adobe = 'Search';
                    const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
                    publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                })
                .catch(error => {
                    this.isLoading = false;
                });
        }
    }
    handelSelectSubCategory(event) {
        if (ISGUEST)
            sessionStorage.setItem('handelSelectSubCategoryEvent', JSON.stringify(event));
        let partSearchAndSelectedSubCategoryID = JSON.parse(JSON.stringify(event.detail));
        sessionStorage.setItem('fromWhichPageUserHasRefresh', 'PLP');
        if (partSearchAndSelectedSubCategoryID.partSearchResult.Parts.length == 0 || this.selectedPartSearchMethod == KEYWORD_PART_NUM) {
            this.isLoading = true;
            let selectSubCategory = partSearchAndSelectedSubCategoryID.partSearchResult.IllustrationGroups.find((subCategory) => {
                return subCategory.ID == partSearchAndSelectedSubCategoryID.subCategoryId
            })
            this.fetchPartialSearchProduct(selectSubCategory.SectionID, selectSubCategory.ID, selectSubCategory.IllustrationGroupImageID, this.partSearchValue);
            let selectedCategoryIndex;
            this.catelogs.Sections.forEach(function (category, index) {
                if (category.ID == selectSubCategory.SectionID) {
                    selectedCategoryIndex = index;
                }
            });
            let filterCategoryRecord = partSearchAndSelectedSubCategoryID.partSearchResult.Sections.find((category) => {
                return category.ID == selectSubCategory.SectionID
            })
            this.breadcrumbs = [];
            this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
            this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, true);
            this.buildBreadcrumbs('Search', BREADCRUMB_TYPE.SEARCH, true);
            this.buildBreadcrumbs(filterCategoryRecord.Description, BREADCRUMB_TYPE.CATEGORY, true);
            this.buildBreadcrumbs(selectSubCategory.Description, BREADCRUMB_TYPE.SUBCATEGORY, true);
            let fillterSubCategoryList = this.clone_PartSearchResult.IllustrationGroups.filter(subCategory => {
                return subCategory.SectionID == selectSubCategory.SectionID;
            });
            setTimeout(() => {
                this.partSearchedResult.IllustrationGroups = fillterSubCategoryList;
                this.template.querySelector('c-parent-category-accordion').subCategories(this.partSearchedResult, selectSubCategory.SectionID);
                this.template.querySelector('c-parent-category-accordion').openIconWithSubCategory(selectSubCategory.SectionID, selectedCategoryIndex);
            }, 1500);
        } else {
            this.displaySearchPage = false;
            this.showCategoryCard = false;
            this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
            this.productList = partSearchAndSelectedSubCategoryID.partSearchResult;
        }
        let breadcrumbs_adobe = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
        if ((this.currentPage_Adobe == undefined || this.currentPage_Adobe != breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label)) {
            this.currentPage_Adobe = breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label;
            const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        }
    }
    handleOnPartSearchValue(event) {
        this.partSearchValue = event.target.value;
        localStorage.setItem('partSerachValue', this.partSearchValue);
        if (this.partSearchValue.length == 0 && this.searchedApplied) {
            this.displaySearchPage = false;
            this.showAccessories = false;
            this.showCategoryCard = true;
            this.showPLP = false;
            this.catelogs = this.cloneCategoryData;
            this.subCategories = this.cloneCategoryData;
            this.searchedApplied = false;
            this.breadcrumbs = [];
            this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
            this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, true);
            this.template.querySelector('c-parent-category-accordion').closeAllCategory();
            this.template.querySelector('c-parent-category-accordion').setCollapseIconForAll();
        }
    }
    fetchPartialSearchProduct(sectionId, subCategeroyId, subCategoryImgId, partSearchValue) {
        if (sectionId && subCategeroyId && subCategoryImgId && partSearchValue) {
            sessionStorage.setItem('category', JSON.stringify({ 'division': this.division, 'sectionId': sectionId, 'illustrationId': subCategeroyId, 'illustrationGroupImageId': subCategoryImgId }));
            this.partSearchValue = this.partSearchValue.substring(0, 60);
            const searchCodeTypeId = this.selectedPartSearchMethod == 'keyword' ? 1 : 0;
            PartialSearchbyProduct({ division: this.vehicle.iNDivisionID__c, year: this.vehicle.iNYearID__c, productId: this.vehicle.iNModelID__c, doorId: this.vehicle.iNDoorID__c, gradeId: this.vehicle.iNGradeID__c, catalogId: this.vehicle.iNCatalogID__c, transmissionID: this.vehicle.iNTransmissionID__c, sectionID: sectionId, illustrationGroupID: subCategeroyId, illustrationGroupImageID: subCategoryImgId, searchCodeTypeID: searchCodeTypeId, searchCodeContains: searchCodeTypeId, searchstring: partSearchValue })
                .then(result => {
                    if (result) {
                        if (result && !result.isError) {
                            let PartialSearchbyProductResult = JSON.parse(result);
                            this.productList = PartialSearchbyProductResult;
                            localStorage.setItem('filteredProductData', JSON.stringify(this.productList)); // Added By Bhawesh 27-01-2022 for bugNo. 6880
                            sessionStorage.setItem('products', JSON.stringify(this.productList));
                            this.getDealerPriceForMaintenance();
                            this.displaySearchPage = false;
                            this.showCategoryCard = false;
                            this.showPLP = this.vehicle && this.vehicle.productType == 'Parts' ? true : false;
                            this.isLoading = false;
                        }
                        else if (result.isError == TRUE && result.errorMessage == 'API Issue') {
                            this.isErrorSearch = true;
                            this.isLoading = false;
                        }
                    }
                })
                .catch(error => {
                });
        }
    }
    handelOnPressEnter(event) {
        if (event.which == 13) {
            this.handleOnPartSearch();
        }
    }
    handleFilterOnLoad() {
        this.disablepartsAndAccessories = false;
        if (this.partSearchValue && localStorage.getItem('filterCatLogs') !== null && localStorage.getItem('filterCatLogs') !== undefined) {
            let partSearchedResult_clone_str = localStorage.getItem('filterCatLogs');
            let currentURL = window.location.href;
            let selectedCategory = currentURL.includes('type=category&label=') ? currentURL.split('type=category&label=')[1] : null;
            if (selectedCategory !== '' && selectedCategory !== undefined & selectedCategory !== null) {
                let partSearchedResult_clone = JSON.parse(partSearchedResult_clone_str);
                let sectionValues = partSearchedResult_clone.Sections;
                let selectedSection = sectionValues.find(item => {
                    return item.Description === selectedCategory;
                })
                let subCategories = partSearchedResult_clone.IllustrationGroups;
                let filteredSubCategories = subCategories.filter(subCat => {
                    return subCat.SectionID === selectedSection.ID;
                })
                partSearchedResult_clone.IllustrationGroups = filteredSubCategories;
                this.partSearchedResult.IllustrationGroups = filteredSubCategories;
                if (this.template.querySelector('c-parent-category-accordion')) {
                    this.template.querySelector('c-parent-category-accordion').subCategories(partSearchedResult_clone, selectedSection.ID);
                    this.breadcrumbs = [];
                    this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
                    this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, true);
                    this.buildBreadcrumbs('Search', BREADCRUMB_TYPE.SEARCH, true);
                    this.buildBreadcrumbs(selectedSection.Description, BREADCRUMB_TYPE.CATEGORY, true);
                    this.template.querySelector('c-parent-category-accordion').openSelectedCategoryFromParent(selectedSection.ID);
                }
            }
            let urlPart = currentURL.includes('type=subcategory&categorylabel=') ? currentURL.split('type=subcategory&categorylabel=')[1] : '';
            let subCategory = urlPart.includes('&label') ? urlPart.split('&label')[0] : null;
            if (subCategory !== '') {
                let handelSelectSubCategoryEvent = sessionStorage.getItem('handelSelectSubCategoryEvent');
                if (this.pageParams && this.pageParams.searchText && handelSelectSubCategoryEvent) {
                    handelSelectSubCategoryEvent = JSON.parse(handelSelectSubCategoryEvent);
                    this.handelSelectSubCategory(handelSelectSubCategoryEvent);
                    sessionStorage.removeItem('handelSelectSubCategoryEvent');
                }
                let partSearchedResult_clone = JSON.parse(partSearchedResult_clone_str);
                let sectionValues = partSearchedResult_clone.Sections;
                let selectedSection = sectionValues.find(item => {
                    return item.Description === subCategory;
                })
                let subCategories = partSearchedResult_clone.IllustrationGroups;
                let filteredSubCategories = subCategories.filter(subCat => {
                    return subCat.SectionID === selectedSection.ID;
                })
                this.catelogs = partSearchedResult_clone;
                partSearchedResult_clone.IllustrationGroups = filteredSubCategories;
                let subcategoryId = localStorage.getItem('subCategoryIdDetails');
                let subCategoryRecDetails = filteredSubCategories.find(item => {
                    return String(item.ID) === subcategoryId;
                })
                if (this.template.querySelector('c-parent-category-accordion')) {
                    this.template.querySelector('c-parent-category-accordion').subCategories(partSearchedResult_clone, selectedSection.ID);
                    this.breadcrumbs = [];
                    this.buildBreadcrumbs(sessionStorage.getItem('vehicleBrand'), BREADCRUMB_TYPE.BRAND, false);
                    this.buildBreadcrumbs(this.productType, BREADCRUMB_TYPE.PRODUCTTYPE, true);
                    this.buildBreadcrumbs('Search', BREADCRUMB_TYPE.SEARCH, true);
                    this.buildBreadcrumbs(selectedSection.Description, BREADCRUMB_TYPE.CATEGORY, true);
                    this.buildBreadcrumbs(subCategoryRecDetails.Description, BREADCRUMB_TYPE.SUBCATEGORY, true);
                    this.template.querySelector('c-parent-category-accordion').openSelectedCategoryFromParent(selectedSection.ID);
                }
            }
        }
    }
    @track flag = false;
    renderedCallback() {
        let breadcrumbsArray = JSON.parse(JSON.stringify(this.breadcrumbs));
        if (this.productList && this.productList.Parts && this.productList.Parts.length && breadcrumbsArray && breadcrumbsArray != null && breadcrumbsArray.length) {
            sessionStorage.setItem('productListData' + breadcrumbsArray[breadcrumbsArray.length - 1].label, JSON.stringify(this.productList));
        } else if (!this.productList || (this.productList.Parts && this.productList.Parts.length == 0)) {
            if (this.urlStateParameters && this.urlStateParameters.label) {
                let productListJson = sessionStorage.getItem('productListData' + this.urlStateParameters.label);
                this.productList = JSON.parse(productListJson);
            }
        }
        let fromlogin = localStorage.getItem('fromlogin');
        if (!fromlogin) {
            localStorage.setItem('storedbreadcrumbs', JSON.stringify(breadcrumbsArray));
            let storedbreadcrumbs = localStorage.getItem('storedbreadcrumbs');
        }
        localStorage.removeItem('catagoryName');
        if (!this.flag && this.breadcrumbs && this.breadcrumbs.length == 5 && this.pageParams && !this.pageParams.searchText) {
            this.flag = true;
            breadcrumbsArray.splice(-1);
            if (this.pageParams.searchText)
                breadcrumbsArray.splice(-1);
            this.breadcrumbs = breadcrumbsArray;
        }
        let currentPageObj = breadcrumbsArray.find(element => { return element.isCurrentPage == true; })
        let relayStateURL = window.location.origin + window.location.pathname;
        if (currentPageObj) {
            if (currentPageObj.name && currentPageObj.name == 'category') {
                localStorage.setItem('catagoryName', currentPageObj.label);
            }
            let ctgName = localStorage.getItem('catagoryName');
            if (!ctgName) {
                let ctgObj = breadcrumbsArray.find(element => { return element.name == 'category'; });
                if (ctgObj) {
                    ctgName = ctgObj.label;
                }
            }
            if (ctgName && currentPageObj.name == 'subcategory') {
                localStorage.setItem('Catagory', ctgName);
                localStorage.setItem('Subcatagory', currentPageObj.label);
                relayStateURL = window.location.origin + window.location.pathname + '?page=' + this.createUri(currentPageObj.name) + '_' + this.createUri(ctgName) + '_' + this.createUri(currentPageObj.label) + (this.partSearchValue ? '_' + this.partSearchValue : '');
                if (ISGUEST)
                    sessionStorage.setItem('relayStatePage', this.createUri(currentPageObj.name) + '_' + this.createUri(ctgName) + '_' + this.createUri(currentPageObj.label) + (this.partSearchValue ? '_' + this.partSearchValue : ''));
                else if (this.isGuestUser && this.isGuestUser == 'True')
                    sessionStorage.setItem('relayStatePage', this.createUri(currentPageObj.name) + '_' + this.createUri(ctgName) + '_' + this.createUri(currentPageObj.label) + (this.partSearchValue ? '_' + this.partSearchValue : ''));
            } else {
                relayStateURL = window.location.origin + window.location.pathname + '?page=' + this.createUri(currentPageObj.name) + '_' + this.createUri(currentPageObj.label) + '_' + this.createUri(currentPageObj.label) + (this.partSearchValue ? '_' + this.partSearchValue : '');
                if (ISGUEST)
                    sessionStorage.setItem('relayStatePage', this.createUri(currentPageObj.name) + '_' + this.createUri(currentPageObj.label) + '_' + this.createUri(currentPageObj.label) + (this.partSearchValue ? '_' + this.partSearchValue : ''));
                else if (this.isGuestUser && this.isGuestUser == 'True')
                    sessionStorage.setItem('relayStatePage', this.createUri(currentPageObj.name) + '_' + this.createUri(currentPageObj.label) + '_' + this.createUri(currentPageObj.label) + (this.partSearchValue ? '_' + this.partSearchValue : ''));
            }
            if (currentPageObj.name == 'producttype') {
                relayStateURL = window.location.origin + window.location.pathname;
            }
        }
    }
    createUri(url) {
        return url ? url.replaceAll(' ', 'usp').replaceAll('/', 'usl').replaceAll('(', 'uopb').replaceAll(')', 'uclb') : '';
    }
    buildDataLayer() {
        let breadcrumbs_adobe = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));//for adobe bug-08
        if (this.currentPage_Adobe == undefined || this.currentPage_Adobe != breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label) {
            this.currentPage_Adobe = breadcrumbs_adobe[breadcrumbs_adobe.length - 1].label;
            const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        }
    }

    //Added by vivek M for HDMP-19409
    checkMSRPreturnedAsZeroOrNull(parts){
        let msrpErrorMessage='';
        parts.forEach(part => {
            if(part.CoreCostAmount!=0 &&(part.SuggestedRetailPriceAmount <= 0 || part.SuggestedRetailPriceAmount == null)){
                msrpErrorMessage += '\nERROR: On PLP Page MSRP pricing API returned SuggestedRetailPriceAmount="' + part.SuggestedRetailPriceAmount + '" for part ' + part.PartNumber ;
            }
        });
          if (msrpErrorMessage) {
            console.log('Errors to log(msrp) ' + msrpErrorMessage);
            logAPIDataError({ errorMessage: msrpErrorMessage, messageType: 'MSRP pricing API Data erorr' })
            .then(errId => {
                console.log('Error logged in Table ' + errId);
                this.dataErrorMessage='';                                     
            }).catch(error => console.log('Error log update failure' + JSON.stringify(error)));
        }
    }
    //End of changes by vivek M for HDMP-19409
}