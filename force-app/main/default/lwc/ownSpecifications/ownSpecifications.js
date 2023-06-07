//============================================================================
// Title:    Honda Owners Experience - Specifications
//
// Summary:  
//
// Details:  
//
//
// History:
// February 4, Brett Spokes (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getProductContext, ISGUEST, getContext_fromBrowser, getOrigin, getContext } from 'c/ownDataUtils';
import getTrims from '@salesforce/apex/FindProductController.getTrims';// Trims
import getSpecificationsByModelID from '@salesforce/apex/OwnSpecificationsController.getSpecificationsByModelID';
import getAutoSpecificationsByModelId from '@salesforce/apex/OwnSpecificationsController.getAutoSpecificationsByModelId';
import getspecificationsByModelID_Honda from '@salesforce/apex/OwnSpecificationsController.getSpecificationsByModelID_Honda';
import getspecificationsByModelID_Acura from '@salesforce/apex/OwnSpecificationsController.getSpecificationsByModelID_Acura';
//import getDataCategories from '@salesforce/apex/OwnHelpCenterController.getDataCategories';
//import { brandDataCategoryMap } from 'c/ownDataUtils';

export default class OwnSpecifications extends OwnBaseElement {
    @track categories;
    @track subcategory;
    @track showResult = false;
    @track showSearchResult = false;
    @track category;
    @track showData = false;

    @track divisionId; //Trims
    @track year; //Trims
    @track modelName; //Trims
    @track trims; //Trims
    @track trim; //Trims
    @track modelId; //Trims
    @track selectedYear;//Trims
    @track selectedModel;//Trims
    @track selectedDivisionID;//Trims

    @track selectedTrim = '';
    @track activeTrim = '';
    @track showTrimList = false;

    @track specificationsJSON;
    specificationsList = [];
    //tempspecList = [];
    @track vehicleTrimList;
    @track vinNumber;
    @track isTrimsPresent;

    @track showMessage = false;
    @track warningImage = this.myGarageResource() + '/ahmicons/warning.png';

    connectedCallback() {
        /*const TRIMS = ["Gold Wing", "Gold Wing Automatic DCT", "Gold Wing Tour", "Gold Wing Tour Automatic DCT", "Gold Wing Tour Airbag Automatic DCT"];
        this.categories = TRIMS;
        console.log('Trims', JSON.stringify(this.categories));*/

        this.initialize();
    }

    initialize = async () => {

        // this.context = await getProductContext('');
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getContext('');
        }
        this.modelId = this.context.product.modelId;
        this.selectedYear = this.context.product.year; //Trims
        this.selectedModel = this.context.product.model; //Trims
        this.selectedDivisionID = this.context.product.divisionId; //Trims
        this.vinNumber = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
        //console.log('@@Test23' + this.selectedDivisionID);
        if (this.vinNumber && this.vinNumber != '-') {
            this.trims = undefined;
            this.showTrimList = false;
            localStorage.setItem('showTrimList', this.showTrimList);
            this.isTrimsPresent = false;
        }
        if (this.selectedDivisionID === 'A' || this.selectedDivisionID === 'B') {
            this.getAutoSpecificationsByModel();
        } else {
            this.getSpecificationsByModel();
        }
    }

    @wire(getTrims, { divisionId: '$selectedDivisionID', year: '$selectedYear', modelName: '$selectedModel' }) //Trims
    wiredGetTrims({ error, data }) {
        if (data) {
            this.trims = data;
            //console.log('Trims', JSON.stringify(this.trims));
            if ((this.trims).length > 0) {
                if (this.selectedDivisionID === 'A' || this.selectedDivisionID === 'B') {
                    this.showTrimList = true;
                    localStorage.setItem('showTrimList', this.showTrimList);
                    this.isTrimsPresent = true;
                    if (this.vinNumber && this.vinNumber != '-') {
                        this.trims = undefined;
                        this.showTrimList = false;
                        localStorage.setItem('showTrimList', this.showTrimList);
                        this.isTrimsPresent = false;
                    }
                }
                //console.log('My Trims:', JSON.stringify(this.trims));
            }

        } else if (error) {
            //this.showToast_error(error);
            this.trims = undefined;
            this.trim = undefined;
            this.modelId = undefined;
        }
    }

    trimSelectHandler(event) {
        this.showData = false;
        this.selectedTrim = event.detail.trim;
        this.activeTrim = event.detail.trim;
        this.modelId = event.detail.modelId;
        //console.log('this.modelId', this.modelId);
        if (event.detail.tab == 'false') {
            this.showTrimList = false;
            localStorage.setItem('showTrimList', this.showTrimList);
        }
        if (this.selectedDivisionID === 'A' || this.selectedDivisionID === 'B') {
            this.getAutoSpecificationsByModel();
        } else {
            this.getSpecificationsByModel();
        }
        //console.log('selectedTrim', this.selectedTrim);
    }

    getSpecificationsByModel() {

        try {
            getSpecificationsByModelID({ modID: this.modelId, divisionId: this.selectedDivisionID })
                .then((result) => {
                    if (result) {
                        var xmlString = result;
                        //console.log('@resul', xmlString)
                        var parser = new DOMParser();
                        var xml = parser.parseFromString(xmlString, "text/xml");
                        var obj = this.xmlToJson(xml);
                        this.specificationsJSON = obj;
                        var jsonString = JSON.stringify(this.specificationsJSON);
                        var replaced = JSON.stringify(JSON.parse(jsonString));
                        replaced = replaced.replace(/#/g, 'sub');
                        var replacedObj = JSON.parse(replaced);
                        //console.log('@@Replaced', JSON.stringify(replacedObj));
                        this.specificationsJSON = replacedObj;
                        //console.log('Set Specifications', JSON.stringify(this.specificationsJSON));
                        //this.specificationsList = this.specificationsJSON.mot.db_results.specifications.specification_set;
                        if (this.specificationsJSON.mot.db_results.specifications) {
                            if (this.specificationsJSON.mot.db_results.specifications.specification_set) {
                                if (this.specificationsJSON.mot.db_results.specifications.specification_set.length) {
                                    this.specificationsList = this.specificationsJSON.mot.db_results.specifications.specification_set;
                                } else {
                                    this.specificationsList = [this.specificationsJSON.mot.db_results.specifications.specification_set];
                                }
                            }
                        }
                        //console.log('Specifications List', JSON.stringify(this.specificationsList));
                        var currentModel;
                        var newModel = false;
                        var modelList = [];
                        //var holdingList = [];
                        if (this.specificationsList) {
                            this.specificationsList.forEach(set => {
                                //console.log('Set', set);
                                let modelName = set.product_specifications.attributes.name;
                                //console.log(modelName);
                                if (currentModel != modelName) {
                                    currentModel = modelName;
                                    this.selectedTrim = modelName;
                                    //console.log('New Model ', currentModel);
                                    newModel = true;
                                    //holdingList = [];
                                    let specCategories = set.product_specifications.specification_categories.specification_category;
                                    //console.log('Category List ', JSON.stringify(specCategories));
                                    var specCats = [];
                                    specCategories.forEach(category => {
                                        let categoryTitle = category.attributes.name;
                                        //console.log('Category Title ', categoryTitle);
                                        let categorySpecifications = category.specification;
                                        var categorySpecList = [];
                                        if (categorySpecifications) {
                                            if (!categorySpecifications.length) {
                                                categorySpecifications = [categorySpecifications];
                                            }
                                        }
                                        if (categorySpecifications) {
                                            categorySpecifications.forEach(spec => {
                                                //console.log('Category Specification ', JSON.stringify(spec.attributes.name));
                                                let specName = spec.attributes.name;
                                                let specDetail = spec.display_group_content.text.subtext;
                                                /*let detail = JSON.stringify(spec.display_group_content.text.subtext);
                                                detail = detail.replace(/[/\\*]/g, '');
                                                console.log('Category Detail ', detail);*/
                                                let o = { specName, specDetail };
                                                categorySpecList.push(o);
                                            });
                                        }
                                        let specCatObj = { categoryTitle, categorySpecList };
                                        specCats.push(specCatObj);
                                        //console.log(JSON.stringify(catSpecList));
                                    });
                                    //console.log('specCats', JSON.stringify(specCats));
                                    /*holdingList = holdingList.concat(specCats);
                                    console.log('holdingList', JSON.stringify(holdingList));
                                    console.log('newModel? ', newModel);
                                    if(newModel != true){
                                        var holderList = [];
                                        holderList = modelList.concat(specCats);
                                        console.log('Concat Arrays');
                                        modelList = holderList;
                                    }
                                    else
                                    {
                                        modelList.push(specCats);
                                        console.log('Pushed Arrays');
                                    }*/
                                    var modelSpecifications = { modelName, specCats }
                                    modelList.push(modelSpecifications);
                                    //console.log('Model List', JSON.stringify(modelList));
                                }
                                else {
                                    newModel = false;
                                }
                            });
                        }
                        this.vehicleTrimList = modelList;
                        if (this.vehicleTrimList && this.vehicleTrimList.length === 0) {
                            console.log('@@Test22 if');
                            this.showMessage = true;
                        }
                        this.showData = true;
                        // console.log(JSON.stringify(this.vehicleTrimList));
                    } else {
                        //console.log('@@Test22 else');
                        this.showMessage = true;
                        this.showData = true;
                    }

                })
                .catch((error) => {
                    this.showData = true;
                    //console.log('Error getting specifications', error);
                });
        } catch (e) {
            this.showData = true;
        }
    }

    getAutoSpecificationsByModel() {
        try {
            //console.log('@@model' + this.modelId + '@@divisionId' + this.selectedDivisionID);
            getAutoSpecificationsByModelId({ modelId: this.modelId, divisionId: this.selectedDivisionID })
                .then((result) => {
                    //console.log('@resule', result)
                    if (result) {
                        let xmlString = result;
                        xmlString = xmlString.replace('<?xml version="1.0" encoding="utf-8"?>', '');
                        //console.log('@resul', xmlString)
                        let parser = new DOMParser();
                        let xml = parser.parseFromString(xmlString, "text/xml");
                        let obj = this.xmlToJson(xml);
                        this.specificationsJSON = obj;
                        var jsonString = JSON.stringify(this.specificationsJSON);
                        var replaced = JSON.stringify(JSON.parse(jsonString));
                        //replaced = replaced.replace(/#/g, 'sub');
                        replaced = replaced.replaceAll('(^sup)', '<sup>');
                        replaced = replaced.replaceAll('($sup)', '</sup>');
                        replaced = replaced.replaceAll('(^i)', '<i>');
                        replaced = replaced.replaceAll('($i)', '</i>');
                        replaced = replaced.replaceAll('(r)', '&reg;');
                        var replacedObj = JSON.parse(replaced);
                        //console.log('@@Result' + JSON.stringify(replacedObj));
                        this.specificationsJSON = replacedObj;
                        if (this.specificationsJSON && this.specificationsJSON.model) {
                            let modelList = [];
                            let modelName = this.specificationsJSON.model.attributes.name;
                            this.selectedTrim = modelName;
                            let specCats = [];
                            if (this.specificationsJSON.model.section) {
                                this.specificationsJSON.model.section.forEach(section => {
                                    let categorySpecList = [];
                                    let disclaimerList = [];
                                    let categoryTitle = section.attributes.name;
                                    if (section.details && section.details.length > 0) {
                                        section.details.forEach(detail => {
                                            let specName = detail.attributes ? detail.attributes.name : detail['#text'];
                                            let specDetail = detail.attributes ? detail['#text'] : '&nbsp;';
                                            let o = { specName, specDetail };
                                            categorySpecList.push(o);
                                        });
                                    }
                                    if(section.disclaimer){
                                        //console.log('@@test12'+JSON.stringify(section.disclaimer));
                                    }

                                    if (section.disclaimer && section.disclaimer.length > 0) {
                                        section.disclaimer.forEach(discla => {
                                            let disclaimerText = discla['#text'];
                                            let o = { disclaimerText };
                                            disclaimerList.push(o);
                                        });
                                    }else if(section.disclaimer && section.disclaimer['#text']){
                                        let disclaimerText = section.disclaimer['#text'];
                                        let o = { disclaimerText };
                                        disclaimerList.push(o);
                                    }
                                    if (section.subsection && section.subsection && section.subsection.length > 0) {
                                        section.subsection.forEach(subsection => {
                                            if (subsection && subsection.details && subsection.details.length > 0) {
                                                let subsectionSpecName = subsection.attributes ? subsection.attributes.name : subsection['#text'];
                                                subsection.details.forEach(detail => {
                                                    let specName = (subsectionSpecName ? subsectionSpecName + ' ' : '') + (detail.attributes ? detail.attributes.name : detail['#text']);
                                                    let specDetail = detail.attributes ? detail['#text'] : '&nbsp;';
                                                    let o = { specName, specDetail };
                                                    categorySpecList.push(o);
                                                });
                                            }
                                            if (subsection && subsection.disclaimer && subsection.disclaimer.length > 0) {
                                                subsection.disclaimer.forEach(discla => {
                                                    let disclaimerText = discla['#text'];
                                                    //console.log('@@disclaimerText'+disclaimerText);
                                                    let o = { disclaimerText };
                                                    disclaimerList.push(o);
                                                });
                                            }
                                        });
                                    }
                                    let specCatObj = { categoryTitle, categorySpecList, disclaimerList };
                                    specCats.push(specCatObj);
                                });
                                let modelSpecifications = { modelName, specCats }
                                modelList.push(modelSpecifications);
                                this.vehicleTrimList = modelList;
                                //console.log('@@TestVT' + JSON.stringify(this.vehicleTrimList));
                                if (this.vehicleTrimList && this.vehicleTrimList.length === 0) {
                                    //console.log('@@Test21 if');
                                    this.showMessage = true;
                                }
                            }
                        } else {
                            this.showMessage = true;
                        }
                        this.showData = true;
                    } else {
                        console.log('@@Test21 else');
                        this.showMessage = true;
                        this.showData = true;
                    }
                })
                .catch((error) => {
                    //console.log('Error getting specifications', error);
                    this.showData = true;
                });
        } catch (e) {
            this.showData = true;
        }
    }

    getSpecifications_Acura() {
        getSpecificationsByModelID_Acura({ modID: this.modelId })
            .then((result) => {
                var xmlString = result;
                var parser = new DOMParser();
                var xml = parser.parseFromString(xmlString, "text/xml");
                var obj = this.xmlToJson(xml);
                this.specificationsJSON = obj;
                var jsonString = JSON.stringify(this.specificationsJSON);
                var replaced = JSON.stringify(JSON.parse(jsonString));
                replaced = replaced.replace(/#/g, 'sub');
                var replacedObj = JSON.parse(replaced);
                //console.log('Replaced', JSON.stringify(replacedObj));
                this.specificationsJSON = replacedObj;
                //console.log('Set Specifications', JSON.stringify(this.specificationsJSON));
                this.specificationsList = this.specificationsJSON.mot.db_results.specifications.specification_set;
                //console.log('Specifications List', JSON.stringify(this.specificationsList));
                var currentModel;
                var newModel = false;
                var modelList = [];
                //var holdingList = [];
                this.specificationsList.forEach(set => {
                    //console.log('Set', set);
                    let modelName = set.product_specifications.attributes.name;
                    //console.log(modelName);
                    if (currentModel != modelName) {
                        currentModel = modelName;
                        //console.log('New Model ', currentModel);
                        newModel = true;
                        //holdingList = [];
                        let specCategories = set.product_specifications.specification_categories.specification_category;
                        //console.log('Category List ', JSON.stringify(specCategories));
                        var specCats = [];
                        specCategories.forEach(category => {
                            let categoryTitle = category.attributes.name;
                            //console.log('Category Title ', categoryTitle);
                            let categorySpecifications = category.specification;
                            var categorySpecList = [];
                            categorySpecifications.forEach(spec => {
                                //console.log('Category Specification ', JSON.stringify(spec.attributes.name));
                                let specName = spec.attributes.name;
                                let specDetail = spec.display_group_content.text.subtext;
                                /*let detail = JSON.stringify(spec.display_group_content.text.subtext);
                                detail = detail.replace(/[/\\*]/g, '');
                                console.log('Category Detail ', detail);*/
                                let o = { specName, specDetail };
                                categorySpecList.push(o);
                            });
                            let specCatObj = { categoryTitle, categorySpecList };
                            specCats.push(specCatObj);
                            //console.log(JSON.stringify(catSpecList));
                        });
                        var modelSpecifications = { modelName, specCats }
                        modelList.push(modelSpecifications);
                        //console.log('Model List', JSON.stringify(modelList));
                    }
                    else {
                        newModel = false;
                    }
                });
                this.vehicleTrimList = modelList;
                // console.log(JSON.stringify(this.vehicleTrimList));
            })
            .catch((error) => {
                //console.log('Error getting specifications', error);
            });
    }

    getSpecifications_Honda() {
        getSpecificationsByModelID_Honda({ modID: 'YK3F2HEW' })
            .then((result) => {
                var xmlString = result;
                var parser = new DOMParser();
                var xml = parser.parseFromString(xmlString, "text/xml");
                var obj = this.xmlToJson(xml);
                this.specificationsJSON = obj;
                var jsonString = JSON.stringify(this.specificationsJSON);
                var replaced = JSON.stringify(JSON.parse(jsonString));
                replaced = replaced.replace(/#/g, 'sub');
                var replacedObj = JSON.parse(replaced);
                //console.log('Replaced', JSON.stringify(replacedObj));
                this.specificationsJSON = replacedObj;
                //console.log('Set Specifications', JSON.stringify(this.specificationsJSON));
                this.specificationsList = this.specificationsJSON.mot.db_results.specifications.specification_set;
                //console.log('Specifications List', JSON.stringify(this.specificationsList));
                var currentModel;
                var newModel = false;
                var modelList = [];
                //var holdingList = [];
                this.specificationsList.forEach(set => {
                    //console.log('Set', set);
                    let modelName = set.product_specifications.attributes.name;
                    //console.log(modelName);
                    if (currentModel != modelName) {
                        currentModel = modelName;
                        //console.log('New Model ', currentModel);
                        newModel = true;
                        //holdingList = [];
                        let specCategories = set.product_specifications.specification_categories.specification_category;
                        //console.log('Category List ', JSON.stringify(specCategories));
                        var specCats = [];
                        specCategories.forEach(category => {
                            let categoryTitle = category.attributes.name;
                            //console.log('Category Title ', categoryTitle);
                            let categorySpecifications = category.specification;
                            var categorySpecList = [];
                            categorySpecifications.forEach(spec => {
                                //console.log('Category Specification ', JSON.stringify(spec.attributes.name));
                                let specName = spec.attributes.name;
                                let specDetail = spec.display_group_content.text.subtext;
                                /*let detail = JSON.stringify(spec.display_group_content.text.subtext);
                                detail = detail.replace(/[/\\*]/g, '');
                                console.log('Category Detail ', detail);*/
                                let o = { specName, specDetail };
                                categorySpecList.push(o);
                            });
                            let specCatObj = { categoryTitle, categorySpecList };
                            specCats.push(specCatObj);
                            //console.log(JSON.stringify(catSpecList));
                        });
                        var modelSpecifications = { modelName, specCats }
                        modelList.push(modelSpecifications);
                        //console.log('Model List', JSON.stringify(modelList));
                    }
                    else {
                        newModel = false;
                    }
                });
                this.vehicleTrimList = modelList;
                // console.log(JSON.stringify(this.vehicleTrimList));
            })
            .catch((error) => {
                //console.log('Error getting specifications', error);
            });
    }

    xmlToJson(xml) {
        var obj = {};

        if (xml.nodeType == 1) {
            if (xml.attributes.length > 0) {
                obj["attributes"] = {};
                for (var j = 0; j < xml.attributes.length; j++) {
                    var attribute = xml.attributes.item(j);
                    obj["attributes"][attribute.nodeName] = attribute.nodeValue;
                }
            }
        } else if (xml.nodeType == 3) {
            obj = xml.nodeValue;
        }

        if (xml.hasChildNodes()) {
            for (var i = 0; i < xml.childNodes.length; i++) {
                var item = xml.childNodes.item(i);
                var nodeName = item.nodeName;
                if (typeof (obj[nodeName]) == "undefined") {
                    obj[nodeName] = this.xmlToJson(item);
                } else {
                    if (typeof (obj[nodeName].push) == "undefined") {
                        var old = obj[nodeName];
                        obj[nodeName] = [];
                        obj[nodeName].push(old);
                    }
                    obj[nodeName].push(this.xmlToJson(item));
                }
            }
        }
        return obj;
    }

    handlebackdrop() {
        this.showTrimList = true;
        localStorage.setItem('showTrimList', this.showTrimList);
    }
}