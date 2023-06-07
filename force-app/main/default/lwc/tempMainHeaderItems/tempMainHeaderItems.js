import { LightningElement, api, track, wire } from 'lwc';
import getVehicleYear from '@salesforce/apex/B2B_EconfigIntegration.getVehicleYear';
import getVehicleModel from '@salesforce/apex/B2B_EconfigIntegration.getVehicleModel';
import getVehicleTrim from '@salesforce/apex/B2B_EconfigIntegration.getVehicleTrim';




export default class TempMainHeaderItems extends LightningElement {
    @api brandName;
    @api brandImageUrl
    @track isGuest = true;
    @track divisionValue;

    @track yearAllOptions = [];
    @track modelAllOptions = [];
    @track trimAllOptions = [];

    @track yearId;
    @track modelId;

    @track modelValue;

    connectedCallback() {
        if (this.brandName === 'Honda') {
            this.divisionValue = 1;
        } else {
            this.divisionValue = 2;
        }
    }

    @wire(getVehicleYear, {
        division: '$divisionValue'
    })

    wiredGetVehicleYear(result) {
        if (result.data) {
            let parseData = JSON.parse(result.data)
            let allYearOptions = [];
            for (const [key, value] of Object.entries(parseData)) {
                allYearOptions.push({
                    label: value,
                    value: key
                })
            }

            let yearOption = allYearOptions.sort(function (a, b) {
                return b.label - a.label;
            });
            console.log('#### divisionValue::', this.divisionValue);
            console.log('#### yearOption::', JSON.stringify(yearOption));
            this.yearAllOptions = yearOption;

        } else if (result.error) {
            console.log('ERROR::' + JSON.stringify(result.error));
            this.error = error;
            this.yearAllOptions = [];
        }
    }


    handleYearChange(event) {
        this.yearId = event.target.value;
        console.log(' handleYearChange ', this.yearId);


        let modelName = '.Model';
        let modelCmp = this.template.querySelector(modelName);
        modelCmp.value = '';
        modelCmp.disabled = false;
        modelCmp.setCustomValidity("");
        modelCmp.reportValidity();


        getVehicleModel({ division: this.divisionValue, year: this.yearId }).then(result => {
            if (result) {
                let parseDataModel = JSON.parse(result)
                console.log('##@@parseDataModel', parseDataModel);
                let modelOptionAll = [];
                for (const [key, value] of Object.entries(parseDataModel)) {
                    modelOptionAll.push({
                        label: key,
                        value: value
                    })
                }
                let modelOption = modelOptionAll.sort((a, b) => (a.label > b.label) ? 1 : -1);

                this.modelAllOptions = modelOption;
                sessionStorage.setItem('modelAllOptions', JSON.stringify(this.modelAllOptions));
                console.log('this.modelAllOptions', this.modelAllOptions)

            }
        }).catch(error => {
            console.log('#error', error);
        })
        console.log('#@yearvalue', event.detail.value)
    }

    handleModelChange(event) {
        try {
            let modelCmp = this.template.querySelector('.Model');
            this.modelId = modelCmp.value;
            console.log('modelId ',JSON.stringify(this.modelId));

            console.log('modelCmp.options ',JSON.stringify(modelCmp.options));

            let modelObj = modelCmp.options.find(item => item.value == this.modelId);
            this.modelValue = modelObj.label;
            modelCmp.setCustomValidity('');
            modelCmp.reportValidity();

            let trimName = '.Trim';
            let trimCmp = this.template.querySelector(trimName);
            trimCmp.value = '';
            trimCmp.options = [];
            trimCmp.disabled = false;
            trimCmp.setCustomValidity("");
            trimCmp.reportValidity();



            getVehicleTrim({ division: this.divisionValue, year: this.yearId, modelValue: this.modelValue.toString() }).then(result => {
                if (result) {
                    let parseDataTrim = JSON.parse(result)

                    let allTrimOptions = [];
                    for (const [key, value] of Object.entries(parseDataTrim)) {
                        allTrimOptions.push({
                            label: key,
                            value: value
                        })
                    }
                    let trimOption = allTrimOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                    this.trimAllOptions = trimOption;

                }
            }).catch(error => {
                console.log('#error', error);
            })
        } catch (error) {
            console.error(error.message);
        }
    }

}