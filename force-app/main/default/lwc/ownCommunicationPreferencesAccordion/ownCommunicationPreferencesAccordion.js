import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/Owners";

const OPEN_ACCORDION_SECTION = "section  slds-accordion__section slds-is-open accordian_section";
const CLOSED_ACCORDION_SECTION = "section section-closed slds-accordion__section";

const OPEN_SECTION_TITLE = "selected-title slds-accordion__summary-content slds-text-title_caps";
const CLOSED_SECTION_TITLE = "slds-accordion__summary-content slds-text-title_caps";

const BRANDS = ['Acura', 'Honda Auto', 'Powersports', 'Power Equipment', 'Marine', 'Engines'];
const EVENTS_MAP = new Map();
EVENTS_MAP.set('Acura', {
    "consumerInterest": [
        {
            "InterestID": "1",
            "InterestName": "Acura-sponsored events",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        }
    ]
});
EVENTS_MAP.set('Honda Auto', { "consumerInterest": [
    {
        "InterestID": "482",
        "InterestName": "Honda Stage",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    }
] });
EVENTS_MAP.set('Powersports', {
    "consumerInterest": [
        {
            "InterestID": "116",
            "InterestName": "Powersports Events",
            "BusinessEntity": "Powersports",
            "OptInFlag": false
        }
    ]
});
EVENTS_MAP.set('Power Equipment', {
    "consumerInterest": [
        {
            "InterestID": "104",
            "InterestName": "Power Equipment Events",
            "BusinessEntity": "Power Equipment",
            "OptInFlag": false
        }
    ]
});
EVENTS_MAP.set('Marine', {
    "consumerInterest": [
        {
            "InterestID": "95",
            "InterestName": "Marine Events",
            "BusinessEntity": "Marine",
            "OptInFlag": false
        }
    ]
});
EVENTS_MAP.set('Engines', {
    "consumerInterest": [
        {
            "InterestID": "503",
            "InterestName": "Engines Events",
            "BusinessEntity": "Engines",
            "OptInFlag": false
        }
    ]
});

const NEWS_INFORMATION_MAP = new Map();
NEWS_INFORMATION_MAP.set('Acura', {
    "consumerInterest": [
        {
            "InterestID": "3",
            "InterestName": "General info about new models, special offers, and Acura stories.",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        }
    ]
});
NEWS_INFORMATION_MAP.set('Honda Auto', { "consumerInterest": [
    {
        "InterestID": "168",
        "InterestName": "General Honda Automobile News and Information",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "386",
        "InterestName": "HPD General",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "385",
        "InterestName": "HPD INDYCAR®",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "395",
        "InterestName": "HondaLink­™",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    }
] });
NEWS_INFORMATION_MAP.set('Powersports', {
    "consumerInterest": [
        {
            "InterestID": "119",
            "InterestName": "General News & Information",
            "BusinessEntity": "Powersports",
            "OptInFlag": false
        }
    ]
});
NEWS_INFORMATION_MAP.set('Power Equipment', {
    "consumerInterest": [
        {
            "InterestID": "511",
            "InterestName": "General Honda Power Equipment News & Information",
            "BusinessEntity": "Power Equipment",
            "OptInFlag": false
        }
    ]
});
NEWS_INFORMATION_MAP.set('Marine', {
    "consumerInterest": [
        {
            "InterestID": "97",
            "InterestName": "General Honda Marine News & Information",
            "BusinessEntity": "Marine",
            "OptInFlag": false
        }
    ]
});
NEWS_INFORMATION_MAP.set('Engines', {
    "consumerInterest": [
        {
            "InterestID": "501",
            "InterestName": "News and Information",
            "BusinessEntity": "Engines",
            "OptInFlag": false
        }
    ]
});

const PRODUCT_INFORMATION_MAP = new Map();
PRODUCT_INFORMATION_MAP.set('Acura', {
    "consumerInterest": [
        {
            "InterestID": "12",
            "InterestName": "Future Vehicles",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        },
        {
            "InterestID": "528",
            "InterestName": "INTEGRA",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        },
        {
            "InterestID": "11",
            "InterestName": "MDX",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        },
        {
            "InterestID": "362",
            "InterestName": "NXS",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        },
        {
            "InterestID": "13",
            "InterestName": "RDX",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        },
        {
            "InterestID": "461",
            "InterestName": "TLX",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        }
    ]
});
PRODUCT_INFORMATION_MAP.set('Honda Auto', { "consumerInterest": [
    {
        "InterestID": "404",
        "InterestName": "Accord Hybrid Sedan",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "60",
        "InterestName": "Accord Sedan",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "72",
        "InterestName": "CR-V Crossover",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "524",
        "InterestName": "CR-V Hybrid Crossover",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "62",
        "InterestName": "Civic Coupe",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "506",
        "InterestName": "Civic Hatchback",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "67",
        "InterestName": "Civic Sedan",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "69",
        "InterestName": "Civic Si Coupe",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "70",
        "InterestName": "Civic Si Sedan",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "507",
        "InterestName": "Civic Type R",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "76",
        "InterestName": "Fit Hatchback",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "78",
        "InterestName": "Honda Auto Future Vehicles",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "481",
        "InterestName": "HR-V Crossover",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "79",
        "InterestName": "Insight Hybrid Sedan",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "81",
        "InterestName": "Odyssey Minivan",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "520",
        "InterestName": "Passport SUV",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "82",
        "InterestName": "Pilot SUV",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "527",
        "InterestName": "Prologue SUV",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "83",
        "InterestName": "Ridgeline Truck",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    }
] });
PRODUCT_INFORMATION_MAP.set('Powersports', {
    "consumerInterest": [
        {
            "InterestID": "392",
            "InterestName": "Dual Sport/Adventure",
            "BusinessEntity": "Powersports",
            "OptInFlag": false
        },
        {
            "InterestID": "125",
            "InterestName": "Cruiser",
            "BusinessEntity": "Powersports",
            "OptInFlag": false
        },
        {
            "InterestID": "124",
            "InterestName": "Rec/Utility SxS",
            "BusinessEntity": "Powersports",
            "OptInFlag": false
        },
        {
            "InterestID": "127",
            "InterestName": "Competition",
            "BusinessEntity": "Powersports",
            "OptInFlag": false
        },
        {
            "InterestID": "128",
            "InterestName": "Trail",
            "BusinessEntity": "Powersports",
            "OptInFlag": false
        },
        {
            "InterestID": "130",
            "InterestName": "Scooters",
            "BusinessEntity": "Powersports",
            "OptInFlag": false
        },
        {
            "InterestID": "129",
            "InterestName": "Sport /Supersport",
            "BusinessEntity": "Powersports",
            "OptInFlag": false
        },
        {
            "InterestID": "122",
            "InterestName": "Sport ATV",
            "BusinessEntity": "Powersports",
            "OptInFlag": false
        },
        {
            "InterestID": "523",
            "InterestName": "Sport SxS",
            "BusinessEntity": "Powersports",
            "OptInFlag": false
        },
        {
            "InterestID": "131",
            "InterestName": "Touring / Sport Touring",
            "BusinessEntity": "Powersports",
            "OptInFlag": false
        },
        {
            "InterestID": "123",
            "InterestName": "Rec Utility/ATV",
            "BusinessEntity": "Powersports",
            "OptInFlag": false
        }
    ]
});
PRODUCT_INFORMATION_MAP.set('Power Equipment', {
    "consumerInterest": [
        {
            "InterestID": "140",
            "InterestName": "Generators",
            "BusinessEntity": "Power Equipment",
            "OptInFlag": false
        },
        {
            "InterestID": "141",
            "InterestName": "Lawnmowers",
            "BusinessEntity": "Power Equipment",
            "OptInFlag": false
        },
        {
            "InterestID": "515",
            "InterestName": "Miimo Robotic Lawn Mower",
            "BusinessEntity": "Power Equipment",
            "OptInFlag": false
        },
        {
            "InterestID": "441",
            "InterestName": "Portable Lighting Systems",
            "BusinessEntity": "Power Equipment",
            "OptInFlag": false
        },
        {
            "InterestID": "144",
            "InterestName": "Snowblowers",
            "BusinessEntity": "Power Equipment",
            "OptInFlag": false
        },
        {
            "InterestID": "142",
            "InterestName": "Tillers",
            "BusinessEntity": "Power Equipment",
            "OptInFlag": false
        },
        {
            "InterestID": "143",
            "InterestName": "Trimmers",
            "BusinessEntity": "Power Equipment",
            "OptInFlag": false
        },
        {
            "InterestID": "145",
            "InterestName": "Water Pumps",
            "BusinessEntity": "Power Equipment",
            "OptInFlag": false
        }
    ]
});

const ESTORE_MAP = new Map();
ESTORE_MAP.set('Acura', {
    "consumerInterest": [
        {
            "InterestID": "139",
            "InterestName": "Acura eStore",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        }
    ]
});
ESTORE_MAP.set('Honda Auto', { "consumerInterest": [
    {
        "InterestID": "27",
        "InterestName": "Honda eStore",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    }
] });

const IN_VEHICLE_SERVICES_MAP = new Map();
IN_VEHICLE_SERVICES_MAP.set('Acura', {
    "consumerInterest": [
        {
            "InterestID": "305",
            "InterestName": "Acura Navigation Updates",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        },
        {
            "InterestID": "512",
            "InterestName": "AcuraLink™",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        },
        {
            "InterestID": "306",
            "InterestName": "Gracenote Music Database",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        },
        {
            "InterestID": "518",
            "InterestName": "Vehicle Health Updates",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        },
        {
            "InterestID": "302",
            "InterestName": "XM® Satellite Radio",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        }
    ]
});
IN_VEHICLE_SERVICES_MAP.set('Honda Auto', { "consumerInterest": [
    {
        "InterestID": "309",
        "InterestName": "Honda Navigation System Updates",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "519",
        "InterestName": "Vehicle Health Report",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    },
    {
        "InterestID": "308",
        "InterestName": "SiriusXM®",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    }
] });
IN_VEHICLE_SERVICES_MAP.set('Marine', { "consumerInterest": [
    {
        "InterestID": "541",
        "InterestName": "HONDALINK MARINE",
        "BusinessEntity": "Marine",
        "OptInFlag": false
    }
] });

const GENUINE_PARTS_MAP = new Map();
GENUINE_PARTS_MAP.set('Acura', {
    "consumerInterest": [
        {
            "InterestID": "381",
            "InterestName": "Acura Genuine Parts",
            "BusinessEntity": "Acura",
            "OptInFlag": false
        }
    ]
});
GENUINE_PARTS_MAP.set('Honda Auto', { "consumerInterest": [
    {
        "InterestID": "382",
        "InterestName": "Honda Genuine Parts",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    }
] });

const OFFERS_MAP = new Map();
OFFERS_MAP.set('Power Equipment', { "consumerInterest": [
    {
        "InterestID": "115",
        "InterestName": "Special Offers",
        "BusinessEntity": "Power Equipment",
        "OptInFlag": false
    }
] });

OFFERS_MAP.set('Marine', { "consumerInterest": [
    {
        "InterestID": "103",
        "InterestName": "Special Offers",
        "BusinessEntity": "Marine",
        "OptInFlag": false
    }
] });
OFFERS_MAP.set('Engines', { "consumerInterest": [
    {
        "InterestID": "502",
        "InterestName": "Special Offers",
        "BusinessEntity": "Engines",
        "OptInFlag": false
    }
] });

const ENVIRONMENTAL_PRODUCTS_MAP = new Map();
ENVIRONMENTAL_PRODUCTS_MAP.set('Honda Auto', { "consumerInterest": [
    {
        "InterestID": "430",
        "InterestName": "Honda Environmental Products & Technologies",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    }
] });

const HONDA_RACING_MAP = new Map();
HONDA_RACING_MAP.set('Powersports', { "consumerInterest": [
    {
        "InterestID": "422",
        "InterestName": "Racing",
        "BusinessEntity": "Powersports",
        "OptInFlag": false
    }
] });

const SOFTWARE_UPDATES_MAP = new Map();
SOFTWARE_UPDATES_MAP.set('Powersports', { "consumerInterest": [
    {
        "InterestID": "521",
        "InterestName": "Gold Wing Navigation/Software Updates",
        "BusinessEntity": "Powersports",
        "OptInFlag": false
    }
] });

const ACURA_MOTORSPORTS_MAP = new Map();
ACURA_MOTORSPORTS_MAP.set('Acura', { "consumerInterest": [
    {
        "InterestID": "510",
        "InterestName": "Motorsports",
        "BusinessEntity": "Acura",
        "OptInFlag": false
    }
] });

const CURRENT_LEASE_FINANCE_OFFERS_MAP = new Map();
CURRENT_LEASE_FINANCE_OFFERS_MAP.set('Acura', { "consumerInterest": [
    {
        "InterestID": "522",
        "InterestName": "Sales events and the latest leasing and finance offers",
        "BusinessEntity": "Acura",
        "OptInFlag": false
    }
] });
CURRENT_LEASE_FINANCE_OFFERS_MAP.set('Honda Auto', { "consumerInterest": [
    {
        "InterestID": "283",
        "InterestName": "Current Lease and Finance Offers",
        "BusinessEntity": "Honda Auto",
        "OptInFlag": false
    }
] });

export default class OwnCommunicationPreferencesAccordion extends OwnBaseElement {
    @api selectedSectionId;
    @api result;
    @api selectedTitles;
    @api titleDivision
    @api timezone;
    @track propertiesList = [];
    @track isSelected = false;
    @track rightArrow = commonResources + '/Icons/right_arrow.svg';
    @api email;
    @api headerTitle;
    @track resultData;
    @track isHondaPresent;
    @track isAcuraPresent;
    @track isPSPresent;
    @track isPEPresent;
    @track isMarinePresent;
    @track isEnginesPresent;
    @track hondaData = [];
    @track acuraData = [];
    @track psData = [];
    @track peData = [];
    @track marineData = [];
    @track enginesData = [];

    connectedCallback() {
            this.initialize();
    }

    initialize = async () => {
        this.resultData = JSON.parse(JSON.stringify(this.result));
        let data;
        //console.log('@@Test' + this.resultData);
        if (this.titleDivision == 'PI') {
            if ('Product Information' in this.resultData) {
                data = this.resultData['Product Information'];
                ['Acura','Honda Auto','Powersports','Power Equipment'].forEach(brand => {
                    PRODUCT_INFORMATION_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Acura'){
                            this.isAcuraPresent = true;
                            this.acuraData.push(event);
                        }
                        if(brand === 'Honda Auto'){
                            this.isHondaPresent = true;
                            this.hondaData.push(event);
                        }
                        if(brand === 'Powersports'){
                            this.isPSPresent = true;
                            this.psData.push(event);
                        }
                        if(brand === 'Power Equipment'){
                            this.isPEPresent = true;
                            this.peData.push(event);
                        }
                        if(brand === 'Marine'){
                            this.isMarinePresent = true;
                            this.marineData.push(event);
                        }
                    });
                });

                // if ('Acura' in data) {
                //     if (data['Acura'].isConsumerInterestPresent == true) {
                //         this.isAcuraPresent = true;
                //         this.acuraData = data['Acura']['consumerInterest']; 
                //     }
                // }
                // if ('Powersports' in data) {
                //     if (data['Powersports'].isConsumerInterestPresent == true) {
                //         this.isPSPresent = true;
                //         this.psData = data['Powersports']['consumerInterest']; 
                //     }
                // }
                // if ('Power Equipment' in data) {
                //     if (data['Power Equipment'].isConsumerInterestPresent == true) {
                //         this.isPEPresent = true;
                //         this.peData = data['Power Equipment']['consumerInterest']; 
                //     }
                // }
                // if ('Marine' in data) {
                //     if (data['Marine'].isConsumerInterestPresent == true) {
                //         this.isMarinePresent = true;
                //         this.marineData = data['Marine']['consumerInterest']; 
                //     }
                // }
                // if ('Honda Auto' in data) {
                //     if (data['Honda Auto'].isConsumerInterestPresent == true) {
                //         this.isHondaPresent = true;
                //         this.hondaData = data['Honda Auto']['consumerInterest']; 
                //     }
                // }
            }
        }
        if (this.titleDivision == 'EV') {
            if ('Events' in this.resultData) {
                data = this.resultData['Events'];
                BRANDS.forEach(brand => {
                    EVENTS_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Acura'){
                            this.isAcuraPresent = true;
                            this.acuraData.push(event);
                        }
                        if(brand === 'Honda Auto'){
                            this.isHondaPresent = true;
                            this.hondaData.push(event);
                        }
                        if(brand === 'Powersports'){
                            this.isPSPresent = true;
                            this.psData.push(event);
                        }
                        if(brand === 'Power Equipment'){
                            this.isPEPresent = true;
                            this.peData.push(event);
                        }
                        if(brand === 'Marine'){
                            this.isMarinePresent = true;
                            this.marineData.push(event);
                        }
                        if(brand === 'Engines'){
                            this.isEnginesPresent = true;
                            this.enginesData.push(event);
                        }
                    });
                });
                // if ('Acura' in data) {
                //         this.isAcuraPresent = true;
                //         this.acuraData = data['Acura']['consumerInterest']; 
                // }
                // if ('Powersports' in data) {
                //         this.isPSPresent = true;
                //         this.psData = data['Powersports']['consumerInterest']; 
                // }
                // if ('Power Equipment' in data) {
                //         this.isPEPresent = true;
                //         this.peData = data['Power Equipment']['consumerInterest']; 
                // }
                // if ('Marine' in data) {
                //         this.isMarinePresent = true;
                //         this.marineData = data['Marine']['consumerInterest']; 
                // }
                // if ('Honda Auto' in data) {
                //         this.isHondaPresent = true;
                //         this.hondaData = data['Honda Auto']['consumerInterest']; 
                // }
            }
        }
        if (this.titleDivision == 'OP') {
            if ('Special Offers' in this.resultData) {
                data = this.resultData['Special Offers'];
                ['Power Equipment', 'Marine', 'Engines'].forEach(brand => {
                    OFFERS_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Acura'){
                            this.isAcuraPresent = true;
                            this.acuraData.push(event);
                        }
                        if(brand === 'Honda Auto'){
                            this.isHondaPresent = true;
                            this.hondaData.push(event);
                        }
                        if(brand === 'Powersports'){
                            this.isPSPresent = true;
                            this.psData.push(event);
                        }
                        if(brand === 'Power Equipment'){
                            this.isPEPresent = true;
                            this.peData.push(event);
                        }
                        if(brand === 'Marine'){
                            this.isMarinePresent = true;
                            this.marineData.push(event);
                        }
                        if(brand === 'Engines'){
                            this.isEnginesPresent = true;
                            this.enginesData.push(event);
                        }
                    });
                });
                
                // if ('Acura' in data) {
                //         this.isAcuraPresent = true;
                //         this.acuraData = data['Acura']; 
                // }
                // if ('Powersports' in data) {
                //     //    this.isPSPresent = true;
                //         this.psData = data['Powersports']; 
                // }
                // if ('Power Equipment' in data) {
                //     //    this.isPEPresent = true;
                //        this.peData = data['Power Equipment']; 
                // }
                // if ('Marine' in data) {
                //     //    this.isMarinePresent = true;
                //        this.marineData = data['Marine']; 
                // }
                // if ('Honda Auto' in data) {
                //         this.isHondaPresent = true;
                //         this.hondaData = data['Honda Auto']; 
                // }
            }
        }
        if (this.titleDivision == 'DM') {
            if ('eStore' in this.resultData) {
                data = this.resultData['eStore'];
                ['Acura', 'Honda Auto'].forEach(brand => {
                    ESTORE_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Acura'){
                            this.isAcuraPresent = true;
                            this.acuraData.push(event);
                        }
                        if(brand === 'Honda Auto'){
                            this.isHondaPresent = true;
                            this.hondaData.push(event);
                        }
                        if(brand === 'Powersports'){
                            this.isPSPresent = true;
                            this.psData.push(event);
                        }
                        if(brand === 'Power Equipment'){
                            this.isPEPresent = true;
                            this.peData.push(event);
                        }
                        if(brand === 'Marine'){
                            this.isMarinePresent = true;
                            this.marineData.push(event);
                        }
                    });
                });

                // if ('Acura' in data) {
                //         this.isAcuraPresent = true;
                //         this.acuraData = data['Acura']; 
                // }
                // if ('Powersports' in data) {
                //         this.isPSPresent = true;
                //         this.psData = data['Powersports']; 
                // }
                // if ('Power Equipment' in data) {
                //         this.isPEPresent = true;
                //         this.peData = data['Power Equipment']; 
                // }
                // if ('Marine' in data) {
                //         this.isMarinePresent = true;
                //         this.marineData = data['Marine']; 
                // }
                // if ('Honda Auto' in data) {
                //         this.isHondaPresent = true;
                //         this.hondaData = data['Honda Auto']; 
                // }
            }
        }
        if(this.titleDivision == 'HE'){
            if ('Acura Environmental Products & Technologies' in this.resultData) {
                data = this.resultData['Acura Environmental Products & Technologies'];
                [].forEach(brand => {
                    ENVIRONMENTAL_PRODUCTS_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Acura'){
                            this.isAcuraPresent = true;
                            this.acuraData.push(event);
                        }
                    });
                });
                // if ('Acura' in data) {
                // //        this.isAcuraPresent = true;
                //         this.acuraData = data['Acura']; 
                // }
            }
            if ('Powersports Environmental Products & Technologies' in this.resultData) {
                data = this.resultData['Powersports Environmental Products & Technologies'];
                [].forEach(brand => {
                    ENVIRONMENTAL_PRODUCTS_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Powersports'){
                            this.isPSPresent = true;
                            this.psData.push(event);
                        }
                    });
                });
                // if ('Powersports' in data) {
                //  //   this.isPSPresent = true;
                //     this.psData = data['Powersports'];
                // }
            }
            if ('Power Equipment Environmental Products & Technologies' in this.resultData) {
                data = this.resultData['Power Equipment Environmental Products & Technologies'];
                [].forEach(brand => {
                    ENVIRONMENTAL_PRODUCTS_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Power Equipment'){
                            this.isPEPresent = true;
                            this.peData.push(event);
                        }
                    });
                });

                // if ('Power Equipment' in data) {
                //  //   this.isPEPresent = true;
                //     this.peData = data['Power Equipment']; 
                // }
            }
            if ('Marine Environmental Products & Technologies' in this.resultData) {
                data = this.resultData['Marine Environmental Products & Technologies'];
                [].forEach(brand => {
                    ENVIRONMENTAL_PRODUCTS_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Marine'){
                            this.isMarinePresent = true;
                            this.marineData.push(event);
                        }
                    });
                });

                // if ('Marine' in data) {
                //    // this.isMarinePresent = true;
                //     this.marineData = data['Marine']; 
                // }
            }
            if ('Honda Environmental Products & Technologies' in this.resultData) {
                data = this.resultData['Honda Environmental Products & Technologies'];
                ['Honda Auto'].forEach(brand => {
                    ENVIRONMENTAL_PRODUCTS_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Honda Auto'){
                            this.isHondaPresent = true;
                            this.hondaData.push(event);
                        }
                    });
                });

                // if ('Honda Auto' in data) {
                //     this.isHondaPresent = true;
                //     this.hondaData = data['Honda Auto']; 
                // }
            }
        }
        if(this.titleDivision == 'GN'){
            if ('News & Information' in this.resultData) {
                data = this.resultData['News & Information'];
                ['Acura', 'Honda Auto', 'Engines'].forEach(brand => {
                    NEWS_INFORMATION_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Acura'){
                            this.isAcuraPresent = true;
                            this.acuraData.push(event);
                        }
                        if(brand === 'Honda Auto'){
                            this.isHondaPresent = true;
                            this.hondaData.push(event);
                        }
                        if(brand === 'Engines'){
                            this.isEnginesPresent = true;
                            this.enginesData.push(event);
                        }
                    });
                });
            }

            if ('General News & Information' in this.resultData) {
                data = this.resultData['General News & Information'];
                ['Powersports'].forEach(brand => {
                    NEWS_INFORMATION_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            data[brand]['consumerInterest'].forEach(element => {
                                if(event.InterestID === element.InterestID){
                                    event.OptInFlag = element.OptInFlag;
                                }
                            });
                        }
                        if(brand === 'Powersports'){
                            this.isPSPresent = true;
                            this.psData.push(event);
                        }
                    });
                });
            }
            if ('General Honda Power Equipment News & Information' in this.resultData) {
                data = this.resultData['General Honda Power Equipment News & Information'];
                ['Power Equipment'].forEach(brand => {
                    NEWS_INFORMATION_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            data[brand]['consumerInterest'].forEach(element => {
                                if(event.InterestID === element.InterestID){
                                    event.OptInFlag = element.OptInFlag;
                                }
                            });
                        }
                        if(brand === 'Power Equipment'){
                            this.isPEPresent = true;
                            this.peData.push(event);
                        }
                    });
                });
            }
            if ('General Honda marine News and Information' in this.resultData) {
                data = this.resultData['General Honda marine News and Information'];
                ['Marine'].forEach(brand => {
                    NEWS_INFORMATION_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            data[brand]['consumerInterest'].forEach(element => {
                                if(event.InterestID === element.InterestID){
                                    event.OptInFlag = element.OptInFlag;
                                }
                            });
                        }
                        if(brand === 'Marine'){
                            this.isMarinePresent = true;
                            this.marineData.push(event);
                        }
                    });
                });
            }

            // if ('News & Information' in this.resultData) {
            //     data = this.resultData['News & Information'];
            //     if ('Acura' in data) {
            //             this.isAcuraPresent = true;
            //             this.acuraData = data['Acura']; 
            //     }
            // }
            // if ('General News & Information' in this.resultData) {
            //     data = this.resultData['General News & Information'];
            //     if ('Powersports' in data) {
            //      //   this.isPSPresent = true;
            //         this.psData = data['Powersports'];
            //     }
            // }
            // if ('General Honda Power Equipment News & Information' in this.resultData) {
            //     data = this.resultData['General Honda Power Equipment News & Information'];
            //     if ('Power Equipment' in data) {
            //      //   this.isPEPresent = true;
            //         this.peData = data['Power Equipment']; 
            //     }
            // }
            // if ('General Honda marine News and Information' in this.resultData) {
            //     data = this.resultData['General Honda marine News and Information'];
            //     if ('Marine' in data) {
            //      //   this.isMarinePresent = true;
            //         this.marineData = data['Marine']; 
            //     }
            // }
            // if ('News & Information' in this.resultData) {
            //     data = this.resultData['News & Information'];
            //     if ('Honda Auto' in data) {
            //         this.isHondaPresent = true;
            //         this.hondaData = data['Honda Auto']; 
            //     }
            // }
        }
        if (this.titleDivision == 'IV') {
            if ('In-Vehicle Services' in this.resultData) {
                data = this.resultData['In-Vehicle Services'];
                ['Acura', 'Honda Auto'].forEach(brand => {
                    IN_VEHICLE_SERVICES_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Acura'){
                            this.isAcuraPresent = true;
                            this.acuraData.push(event);
                        }
                        if(brand === 'Honda Auto'){
                            this.isHondaPresent = true;
                            this.hondaData.push(event);
                        }
                        if(brand === 'Powersports'){
                            this.isPSPresent = true;
                            this.psData.push(event);
                        }
                        if(brand === 'Power Equipment'){
                            this.isPEPresent = true;
                            this.peData.push(event);
                        }
                        if(brand === 'Marine'){
                            this.isMarinePresent = true;
                            this.marineData.push(event);
                        }
                    });
                });

                // if ('Acura' in data) {
                //     if (data['Acura'].isConsumerInterestPresent == true) {
                //         this.isAcuraPresent = true;
                //         this.acuraData = data['Acura']['consumerInterest']; 
                //     }
                // }
                // if ('Powersports' in data) {
                //     if (data['Powersports'].isConsumerInterestPresent == true) {
                //      //   this.isPSPresent = true;
                //         this.psData = data['Powersports']['consumerInterest']; 
                //     }
                // }
                // if ('Power Equipment' in data) {
                //     if (data['Power Equipment'].isConsumerInterestPresent == true) {
                //       //  this.isPEPresent = true;
                //         this.peData = data['Power Equipment']['consumerInterest']; 
                //     }
                // }
                // if ('Marine' in data) {
                //     if (data['Marine'].isConsumerInterestPresent == true) {
                //      //   this.isMarinePresent = true;
                //         this.marineData = data['Marine']['consumerInterest']; 
                //     }
                // }
                // if ('Honda Auto' in data) {
                //     if (data['Honda Auto'].isConsumerInterestPresent == true) {
                //         this.isHondaPresent = true;
                //         this.hondaData = data['Honda Auto']['consumerInterest']; 
                //     }
                // }
            }
            if ('In-Product Services' in this.resultData) {
                data = this.resultData['In-Product Services'];
                ['Marine'].forEach(brand => {
                    IN_VEHICLE_SERVICES_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Acura'){
                            this.isAcuraPresent = true;
                            this.acuraData.push(event);
                        }
                        if(brand === 'Honda Auto'){
                            this.isHondaPresent = true;
                            this.hondaData.push(event);
                        }
                        if(brand === 'Powersports'){
                            this.isPSPresent = true;
                            this.psData.push(event);
                        }
                        if(brand === 'Power Equipment'){
                            this.isPEPresent = true;
                            this.peData.push(event);
                        }
                        if(brand === 'Marine'){
                            this.isMarinePresent = true;
                            this.marineData.push(event);
                        }
                    });
                });

                // if ('Acura' in data) {
                //     if (data['Acura'].isConsumerInterestPresent == true) {
                //         this.isAcuraPresent = true;
                //         this.acuraData = data['Acura']['consumerInterest']; 
                //     }
                // }
                // if ('Powersports' in data) {
                //     if (data['Powersports'].isConsumerInterestPresent == true) {
                //      //   this.isPSPresent = true;
                //         this.psData = data['Powersports']['consumerInterest']; 
                //     }
                // }
                // if ('Power Equipment' in data) {
                //     if (data['Power Equipment'].isConsumerInterestPresent == true) {
                //       //  this.isPEPresent = true;
                //         this.peData = data['Power Equipment']['consumerInterest']; 
                //     }
                // }
                // if ('Marine' in data) {
                //     if (data['Marine'].isConsumerInterestPresent == true) {
                //      //   this.isMarinePresent = true;
                //         this.marineData = data['Marine']['consumerInterest']; 
                //     }
                // }
                // if ('Honda Auto' in data) {
                //     if (data['Honda Auto'].isConsumerInterestPresent == true) {
                //         this.isHondaPresent = true;
                //         this.hondaData = data['Honda Auto']['consumerInterest']; 
                //     }
                // }
            }
        }
        if(this.titleDivision == 'HG'){
            if ('Acura Genuine Parts' in this.resultData) {
                data = this.resultData['Acura Genuine Parts'];
                ['Acura'].forEach(brand => {
                    GENUINE_PARTS_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Acura'){
                            this.isAcuraPresent = true;
                            this.acuraData.push(event);
                        }
                    });
                });

                // if ('Acura' in data) {
                //         this.isAcuraPresent = true;
                //         this.acuraData = data['Acura']; 
                // }
            }
            if ('Honda Genuine Parts' in this.resultData) {
                data = this.resultData['Honda Genuine Parts'];
                ['Honda Auto'].forEach(brand => {
                    GENUINE_PARTS_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            data[brand]['consumerInterest'].forEach(element => {
                                if(event.InterestID === element.InterestID){
                                    event.OptInFlag = element.OptInFlag;
                                }
                            });
                        }
                        if(brand === 'Honda Auto'){
                            this.isHondaPresent = true;
                            this.hondaData.push(event);
                        }
                    });
                });
                // if ('Powersports' in data) {
                // //    this.isPSPresent = true;
                //     this.psData = data['Powersports'];
                // }
                // if ('Honda Auto' in data) {
                //     this.isHondaPresent = true;
                //     this.hondaData = data['Honda Auto'];
                // }
            }
        }
        if(this.titleDivision == 'R'){
            if ('Honda Racing' in this.resultData) {
                data = this.resultData['Honda Racing'];
                ['Powersports'].forEach(brand => {
                    HONDA_RACING_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Acura'){
                            this.isAcuraPresent = true;
                            this.acuraData.push(event);
                        }
                        if(brand === 'Honda Auto'){
                            this.isHondaPresent = true;
                            this.hondaData.push(event);
                        }
                        if(brand === 'Powersports'){
                            this.isPSPresent = true;
                            this.psData.push(event);
                        }
                        if(brand === 'Power Equipment'){
                            this.isPEPresent = true;
                            this.peData.push(event);
                        }
                        if(brand === 'Marine'){
                            this.isMarinePresent = true;
                            this.marineData.push(event);
                        }
                    });
                });
                // if ('Powersports' in data) {
                //     this.isPSPresent = true;
                //     this.psData = data['Powersports'];
                // }
            }
        }
        if(this.titleDivision == 'SU'){
            if ('Software Updates' in this.resultData) {
                data = this.resultData['Software Updates'];
                ['Powersports'].forEach(brand => {
                    SOFTWARE_UPDATES_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Acura'){
                            this.isAcuraPresent = true;
                            this.acuraData.push(event);
                        }
                        if(brand === 'Honda Auto'){
                            this.isHondaPresent = true;
                            this.hondaData.push(event);
                        }
                        if(brand === 'Powersports'){
                            this.isPSPresent = true;
                            this.psData.push(event);
                        }
                        if(brand === 'Power Equipment'){
                            this.isPEPresent = true;
                            this.peData.push(event);
                        }
                        if(brand === 'Marine'){
                            this.isMarinePresent = true;
                            this.marineData.push(event);
                        }
                    });
                });
                // if ('Powersports' in data) {
                //     this.isPSPresent = true;
                //     this.psData = data['Powersports'];
                // }
            }
        }
        if(this.titleDivision == 'AM'){
            if ('Acura Motorsports' in this.resultData) {
                data = this.resultData['Acura Motorsports'];
                ['Acura'].forEach(brand => {
                    ACURA_MOTORSPORTS_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Acura'){
                            this.isAcuraPresent = true;
                            this.acuraData.push(event);
                        }
                    });
                });
                // if ('Powersports' in data) {
                //     this.isPSPresent = true;
                //     this.psData = data['Powersports'];
                // }
            }
        }
        if(this.titleDivision == 'CLFO'){
            if ('Current Lease and Finance Offers' in this.resultData) {
                data = this.resultData['Current Lease and Finance Offers'];
                ['Acura', 'Honda Auto'].forEach(brand => {
                    CURRENT_LEASE_FINANCE_OFFERS_MAP.get(brand).consumerInterest.forEach(event => {
                        if(data[brand] && data[brand].InterestID === event.InterestID){
                            event.OptInFlag = data[brand].OptInFlag;
                        }else{
                            if(data[brand]){
                                data[brand]['consumerInterest'].forEach(element => {
                                    if(event.InterestID === element.InterestID){
                                        event.OptInFlag = element.OptInFlag;
                                    }
                                });
                            }
                        }
                        if(brand === 'Acura'){
                            this.isAcuraPresent = true;
                            this.acuraData.push(event);
                        }
                        if(brand === 'Honda Auto'){
                            this.isHondaPresent = true;
                            this.hondaData.push(event);
                        }
                        if(brand === 'Powersports'){
                            this.isPSPresent = true;
                            this.psData.push(event);
                        }
                        if(brand === 'Power Equipment'){
                            this.isPEPresent = true;
                            this.peData.push(event);
                        }
                        if(brand === 'Marine'){
                            this.isMarinePresent = true;
                            this.marineData.push(event);
                        }
                    });
                });
            }
        }
    }

    get sectionClass() {
        return (this.selectedTitles.includes(this.headerTitle)) ? OPEN_ACCORDION_SECTION : CLOSED_ACCORDION_SECTION;
    }

    get sectionTitleClass() {
        return (this.selectedTitles.includes(this.headerTitle)) ? OPEN_SECTION_TITLE : CLOSED_SECTION_TITLE;
    }

    handleSectionClick(event) {
        //console.log(event.currentTarget.dataset.value);
        this.dispatchEvent(new CustomEvent('sectionselect', { detail: event.currentTarget.dataset.value }));
    }
    get isSelectedRow() {
        return (this.selectedTitles.includes(this.headerTitle));
    }

    get isProductInformation() {
        return (this.titleDivision == 'PI');
    }
    get isUnsubscribeAll(){
        return (this.titleDivision == 'UA');
    }
    get isDigitalMarketPlace(){
        return (this.titleDivision == 'DM');
    }
    get isEnvironmentAndTechnologies(){
        return (this.titleDivision == 'HE');
    }
    get isGeneralNews(){
        return (this.titleDivision == 'GN');
    }
    get isEvents(){
        return (this.titleDivision == 'EV');
    }
    get isOffers(){
        return (this.titleDivision == 'OP');
    }
    get isInVehicleService(){
        return (this.titleDivision == 'IV');
    }
    get isGenuineParts(){
        return (this.titleDivision == 'HG');
    }
    get isRacing(){
        return (this.titleDivision == 'R');
    }
    get isContactPrefence(){
        return (this.titleDivision == 'CP');
    }
    get getEmail(){
        return 'Remove '+this.email;
    }
    get isSoftwareUpdates(){
        return (this.titleDivision == 'SU');
    }
    get isAcuraMotorsports(){
        return (this.titleDivision == 'AM');
    }
    get isCurrentLeaseAndFinanceOffers(){
        return (this.titleDivision == 'CLFO');
    }

    handleChexboxClick(event){  
         //console.log('@@Clicked')  
         var data = this.resultData;
         try{  
          if(event.target.checked){
           // alert(event.currentTarget.dataset.id+'C');
            for(var i in data){
                for(var j in data[i]){
                    if(data[i][j].InterestID == event.currentTarget.dataset.id){
                        data[i][j].OptInFlag = true;   
                    }
                    if(data[i][j].isConsumerInterestPresent == true){
                        for(var k in data[i][j].consumerInterest){
                          if(data[i][j].consumerInterest[k].InterestID == event.currentTarget.dataset.id){
                            data[i][j].consumerInterest[k].OptInFlag = true; 
                          }
                        }
                    }
                }
            }
          }else{
            //alert(event.currentTarget.dataset.id+'U');
            for(var i in data){
                for(var j in data[i]){
                    if(data[i][j].InterestID == event.currentTarget.dataset.id){
                        data[i][j].OptInFlag = false; 
                    }
                    if(data[i][j].isConsumerInterestPresent == true){
                        for(var k in data[i][j].consumerInterest){
                          if(data[i][j].consumerInterest[k].InterestID == event.currentTarget.dataset.id){
                            data[i][j].consumerInterest[k].OptInFlag = false; 
                          }
                        }
                    }
                }
            }
          }
          this.dispatchEvent(new CustomEvent('checkboxselect', { detail: {value : event.currentTarget.dataset.id, selection : event.target.checked} }));
        }catch(ex){
            //console.log(ex);
        }
    }

    get contactFrequency(){
        return [{label : 'Twice a week', value : 'Twice a week'},
        {label : 'Weekly', value : 'Weekly'},
        {label : 'Monthly', value : 'Monthly'},
        {label : 'Less than once a month', value : 'Less than once a month'}
    ];
    }
    get contactday(){
        return [{label : 'Morning', value : 'Morning'},
        {label : 'Afternoon', value : 'Afternoon'},
        {label : 'Evening', value : 'Evening'}
    ];
    }

    get isDataPresent(){
        return (this.isAcuraPresent || this.isHondaPresent || this.isPEPresent || this.isPSPresent || this.isMarinePresent || (this.titleDivision == 'CP') || (this.titleDivision == 'UA'));
    }
}