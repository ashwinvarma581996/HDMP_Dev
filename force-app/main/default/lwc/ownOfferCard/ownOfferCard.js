import { track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/Owners";
import offersResources from "@salesforce/resourceUrl/MyGarageAssets";
import getOffers from '@salesforce/apex/OwnAPIController.getOffers';
import getCurrentOfferLinks from '@salesforce/apex/OwnGarageController.getCurrentOfferLinks';
export default class OwnOfferCard extends OwnBaseElement {

    @track isSorted = false;
    @track offerLinks = {};
    @track productDivisionCds = ['B', 'A', 'M'];
    @track offers = [/*{
        logo: '',
        brand: '',
        order: ,
        allofferslink: ,
        offers : []
    }*/];
    @track i = 0;
    connectedCallback() {
        getCurrentOfferLinks().then((result) => {
           // console.log('@@Links', result);
            this.offerLinks = result;
            this.getAllOffers();
        }).catch((err) => {
           // console.log(err);
        });
    }

    getAllOffers() {
        this.productDivisionCds.forEach(productDivisionCD => {
            getOffers({ productDivisionCD: productDivisionCD }).then((result) => {
                if (productDivisionCD == 'B') {
                    //console.log('@Acura:-', JSON.stringify(result));
                } else if (productDivisionCD == 'A') {
                    //console.log('@Honda:-', JSON.stringify(result));
                } else {
                   // console.log('@Powersports:-', JSON.stringify(result));
                }
                let dataToProcesssList = [];
                let tandardSpecialData = JSON.parse(JSON.stringify(result.Output.Results.StandardSpecials.StandardSpecial));
                if (Array.isArray(tandardSpecialData)) {
                    tandardSpecialData.forEach(standard => {
                        let dataToProcesssListTemp = this.getdataToProcesssList(standard, productDivisionCD);
                        dataToProcesssListTemp.forEach(dt => {
                            dataToProcesssList.push(dt);
                        });
                    });
                } else {
                    let dataToProcesssListTemp = this.getdataToProcesssList(tandardSpecialData, productDivisionCD);
                    dataToProcesssListTemp.forEach(dt => {
                        dataToProcesssList.push(dt);
                    });
                }
                let order;
                let brand;
                let brandLogo;
                let allofferslink;
                if (productDivisionCD == 'B') {
                    brandLogo = offersResources + '/AcuraPrimaryPCP.png';
                    brand = 'Acura';
                    order = 1;
                    allofferslink = this.offerLinks.acura;
                } else if (productDivisionCD == 'A') {
                    brandLogo = commonResources + '/Logos/honda_autos.svg';
                    brand = 'Honda';
                    order = 2;
                    allofferslink = this.offerLinks.honda;
                } else if (productDivisionCD == 'M') {
                    brandLogo = commonResources + '/Logos/honda_powersports.svg';
                    brand = 'Honda Powersports';
                    order = 3;
                    allofferslink = this.offerLinks.powersports;
                }
                let tempData = {
                    logo: brandLogo,
                    brand: brand,
                    order: order,
                    offers: dataToProcesssList,
                    allofferslink: allofferslink
                };
                this.offers.push(tempData);
            }).catch((err) => {
                //console.error('err: ', err);
            });
        });
    }

    getdataToProcesssList(tandardSpecialData, productDivisionCD) {
        let dataToProcesssList = [];
        if (Array.isArray(tandardSpecialData.Models.Model)) {
            //console.log('@tandardSpecialData.Models.Model is array', tandardSpecialData.Models.Model)
            tandardSpecialData.Models.Model.forEach((model, index) => {
                let tempRec = JSON.parse(JSON.stringify(model));
                //console.log('@@models', tempRec.ModelGroupName, tandardSpecialData.Models.Model[index].SpecialShortDescription, typeof tempRec)
                tempRec.EndDates = this.getDateString(new Date(Date.parse(tandardSpecialData.EndDate)), 'mdy', '/');
                if (productDivisionCD == 'B') {
                    //console.log('$EndDates:-', tempRec.EndDates);
                }
                tempRec.hasFinanceTerm = tandardSpecialData.Models && tandardSpecialData.Models.Model && tandardSpecialData.Models.Model[index].SpecialShortDescription ? true : false;
                //console.log('@@hasFinanceTerm', tandardSpecialData.Models.Model.ModelGroupName, tempRec.hasFinanceTerm)
                if (tempRec.hasFinanceTerm) {
                    tempRec.financeTerm = this.parseSpecialShortDescription(tandardSpecialData.Models.Model[index].SpecialShortDescription);
                }
                //console.log('@@hasFinanceTerm1', tempRec.financeTerm, tempRec.ModelGroupName)
                // tempRec.hasFinanceTerm = tandardSpecialData.PaymentTerms && tandardSpecialData.PaymentTerms.FinanceTerms && tandardSpecialData.PaymentTerms.FinanceTerms.FinanceTerm ? true : false;
                // if (tempRec.hasFinanceTerm) {
                //     if (tandardSpecialData.PaymentTerms.FinanceTerms.FinanceTerm[0])
                //         tempRec.financeTerm1 = '<b>' + tandardSpecialData.PaymentTerms.FinanceTerms.FinanceTerm[0].APR + '% APR</b>' + ' For ' + tandardSpecialData.PaymentTerms.FinanceTerms.FinanceTerm[0].TermMin + '-' + tandardSpecialData.PaymentTerms.FinanceTerms.FinanceTerm[0].TermMax + ' Months';
                //     if (tandardSpecialData.PaymentTerms.FinanceTerms.FinanceTerm[1])
                //         tempRec.financeTerm2 = '<b>' + tandardSpecialData.PaymentTerms.FinanceTerms.FinanceTerm[1].APR + '%</b>' + ' For ' + tandardSpecialData.PaymentTerms.FinanceTerms.FinanceTerm[1].TermMin + '-' + tandardSpecialData.PaymentTerms.FinanceTerms.FinanceTerm[1].TermMax + ' Months';
                //     if (tandardSpecialData.PaymenstTerms.FinanceTerms.FinanceTerm[2])
                //         tempRec.financeTerm3 = '<b>' + tandardSpecialData.PaymentTerms.FinanceTerms.FinanceTerm[2].APR + '%</b>' + ' For ' + tandardSpecialData.PaymentTerms.FinanceTerms.FinanceTerm[2].TermMin + '-' + tandardSpecialData.PaymentTerms.FinanceTerms.FinanceTerm[2].TermMax + ' Months';
                // }
                tempRec.allOffer = 'All ' + model.ModelGroupName + ' Offers';
                let modelname = model.ModelGroupName.toLocaleLowerCase();
                modelname = modelname.includes(' ') ? modelname.replaceAll(' ', '-') : modelname;
                if (productDivisionCD == 'B') {
                    tempRec.offerlink = this.offerLinks.acura + '?vehiclemodelseries=' + modelname;
                } else if (productDivisionCD == 'A') {
                    tempRec.offerlink = this.offerLinks.honda + '?vehiclemodelseries=' + modelname;
                } else if (productDivisionCD == 'M') {
                    tempRec.offerlink = this.offerLinks.powersports;
                }
                let modelnm = model.ModelGroupName.toLocaleLowerCase();
                if (modelnm != 'accord hybrid' && modelnm.includes('accord')) {
                    tempRec.offerlink = this.offerLinks.honda + '?vehiclemodelseries=accord';
                }
                //console.log('@@LINK: ', tempRec.offerlink);
                if (productDivisionCD == 'B') {
                    tempRec.ModelStockPhotoLarge = 'https://www.acura.com/' + model.ModelStockPhotoLarge;
                } else if (productDivisionCD == 'A') {
                    tempRec.ModelStockPhotoLarge = 'https://automobiles.honda.com/' + model.ModelStockPhotoLarge;
                } else if (productDivisionCD == 'M') {
                    tempRec.ModelStockPhotoLarge = this.myGarageResource() + '/images/thumbnail_powersports.png';
                }
                tempRec.subHeadClass = 'sub-head-container sub-head-container-' + this.i;
                tempRec.hrClass = 'hr hr-' + this.i;
                dataToProcesssList.push(tempRec);
                this.i = this.i + 1;
            });
        } else {
            //console.log('@tandardSpecialData.Models.Model is not array', tandardSpecialData.Models.Model)
            let tempRec = JSON.parse(JSON.stringify(tandardSpecialData.Models.Model))
            tempRec.EndDates = this.getDateString(new Date(Date.parse(tandardSpecialData.EndDate)), 'mdy', '/');
            if (productDivisionCD == 'B') {
                //console.log('$EndDates:-', tempRec.EndDates);
            }
            tempRec.allOffer = 'All ' + tandardSpecialData.Models.Model.ModelGroupName + ' Offers';
            let modelname = tandardSpecialData.Models.Model.ModelGroupName.toLocaleLowerCase();
            modelname = modelname.includes(' ') ? modelname.replaceAll(' ', '-') : modelname;
            if (productDivisionCD == 'B') {
                tempRec.offerlink = this.offerLinks.acura + '?vehiclemodelseries=' + modelname;
            } else if (productDivisionCD == 'A') {
                tempRec.offerlink = this.offerLinks.honda + '?vehiclemodelseries=' + modelname;
            } else if (productDivisionCD == 'M') {
                tempRec.offerlink = this.offerLinks.powersports;
            }
            let modelnm = tandardSpecialData.Models.Model.ModelGroupName.toLocaleLowerCase();
            if (modelnm != 'accord hybrid' && modelnm.includes('accord')) {
                tempRec.offerlink = this.offerLinks.honda + '?vehiclemodelseries=accord';
            }
            //console.log('@@LINK: ', tempRec.offerlink);
            if (productDivisionCD == 'B') {
                tempRec.ModelStockPhotoLarge = 'https://www.acura.com/' + tandardSpecialData.Models.Model.ModelStockPhotoLarge;
            } else if (productDivisionCD == 'A') {
                tempRec.ModelStockPhotoLarge = 'https://automobiles.honda.com/' + tandardSpecialData.Models.Model.ModelStockPhotoLarge;
            } else if (productDivisionCD == 'M') {
                tempRec.ModelStockPhotoLarge = this.myGarageResource() + '/images/thumbnail_powersports.png';
            }
            tempRec.hasFinanceTerm = tandardSpecialData.Models && tandardSpecialData.Models.Model && tandardSpecialData.Models.Model.SpecialShortDescription ? true : false;
            // tempRec.hasFinanceTerm = tandardSpecialData.PaymentTerms && tandardSpecialData.PaymentTerms.FinanceTerms && tandardSpecialData.PaymentTerms.FinanceTerms.FinanceTerm ? true : false;
            if (tempRec.hasFinanceTerm) {
                tempRec.financeTerm = this.parseSpecialShortDescription(tandardSpecialData.Models.Model.SpecialShortDescription);
            }
            //console.log('@@hasFinanceTerm', tandardSpecialData.Models.Model.ModelGroupName, tempRec.hasFinanceTerm)
            tempRec.subHeadClass = 'sub-head-container sub-head-container-' + this.i;
            tempRec.hrClass = 'hr hr-' + this.i;
            dataToProcesssList.push(tempRec);
            this.i = this.i + 1;
        }
        return dataToProcesssList;
    }

    getDateString(date, format, seperator) {
        seperator = seperator ? seperator : '/';
        let day = date.getDate();
        let month = date.getMonth() + 1;
        day = day > 9 ? day : '0' + day;
        month = month > 9 ? month : '0' + month;
        if (format === 'ymd') {
            return date.getFullYear() + seperator + month + seperator + day;
        } else if (format === 'mdy') {
            return month + seperator + day + seperator + date.getFullYear();
        } else {
            return day + seperator + month + seperator + date.getFullYear();
        }
    }

    parseSpecialShortDescription(s) {
        let arr = [];
        let arr1 = [];
        let arr2 = [];
        //remove "." and ","
        if(typeof s == 'string' && s.includes(". ")){
        s.split(". ").forEach((element, index) => {
            arr = arr.concat(element.split(", "));
        });
        //remove "/n/n"
        arr.forEach((element, index) => {
            arr1 = arr1.concat(element.split("\n\n"));
        });
        //remove "and"
        arr1.forEach((element, index) => {
            arr2 = arr2.concat(element.split("and"));
        });
        arr2.forEach((str, index) => {

            if (str[str.length - 1] === ".") {
                arr2[index] = str.slice(0, -1);
            }
            //console.log('final', JSON.parse(JSON.stringify(str)).trim());
            arr2[index] = JSON.parse(JSON.stringify(arr2[index])).trim();
        });
        // if (arr2.length > 3) {
        //     return arr2.slice(0, 3);
        // }
    }
        return arr2;
    }
    renderedCallback() {
        if (this.offers.length == 3 && this.isSorted == false) {
            this.offers = this.offers.sort(function (a, b) { return a.order - b.order });
            this.isSorted = true;
           // console.log('@@SORTED: ', JSON.parse(JSON.stringify(this.offers)));
        }
        /*this.template.querySelectorAll(".sub-head-container").forEach((subHead, index, arr) => {
            let subDiv1 = this.template.querySelector(".sub-head-container-" + index);
            let offsetWidth = subDiv1.offsetWidth / 2;
            let hrLine = this.template.querySelector(".hr-" + index);
            hrLine.style.width = offsetWidth + "px"
        });*/
    }

    handleclick(event) {
        let offerlink = event.target.dataset.offerlink;
        //console.log(offerlink);
        window.open(offerlink, '_blank');
    }
}