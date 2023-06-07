import { LightningElement, api, track } from 'lwc';

export default class OwnFindProductsCombobox extends LightningElement {
    @api dropdown;
    @api dropdownData;
    @api highestFilledTier;
    @api tiers;
    @api tierNameMap;
    @api selectedValues;


    get dropdownOptions(){

        let options = [];
        let valueSet = new Set();

        this.dropdownData.forEach(element => {
            // Check tier values in each element against currently selected values up to this dropdown menu's tier;
            // if any value does not match the currently selected values, then the element is not viable for this menu.
            let allowed = true;
            for (let i=0; i<this.dropdown.controlData.Tier_Number__c-1; ++i){
                let tier = this.tiers[i];
                if (!(element[tier.name] === this.selectedValues[this.tierIt(tier.number)])){
                    allowed = false;
                }
            }
            // For each allowed element, the value corresponding to this dropdown menu's tier is selected
            let value = element[this.tierNameMap.get(this.dropdown.controlData.Tier_Number__c)];
            if (allowed && !valueSet.has(value)){
                options.push({value : value, label : value});
                valueSet.add(value);
            }
        });

        //console.log(typeof(this.dropdown.controlData.Tier_Number__c));

        /* this.selectedValues.forEach(function(value, key){
            console.log('Child dropdown '  + ' key: ' + key + ', value: ' + value);
        }) */

        //console.log('Child dropdown ' + this.dropdown.controlData.Tier_Number__c + ' values: ' + this.selectedValues);

/*         if (this.dropdown.controlData.Tier_Number__c === 1){
            console.log(op)
        } */

        return this.dropdown.controlData.Tier_Number__c === 1 ? options.sort(function(a,b){return b.value-a.value;}) : options.sort(function(a,b){return a.value.localeCompare(b.value);});
    }

    tierIt(tier){
        return tier-1;
    }

    /* get value(){
        return this.selectedValues.get(this.dropdown.controlData.Tier_Number__c) ? this.selectedValues.get(this.dropdown.controlData.Tier_Number__c) : '';
    } */
    get value(){
        return this.selectedValues[this.tierIt(this.dropdown.controlData.Tier_Number__c)] ? this.selectedValues[this.tierIt(this.dropdown.controlData.Tier_Number__c)] : '';
    }

    get placeholderText(){
        return "Select " + this.dropdown.controlData.Tier_Name__c;
    }

    get comboboxDisabled(){
        return this.dropdown.controlData.Tier_Number__c > this.highestFilledTier+1;
    }

    handleSelect(event){
        this.dispatchEvent(new CustomEvent('optionselect', {detail : {value: event.detail.value, tier: this.dropdown.controlData.Tier_Number__c}}));
    }
}