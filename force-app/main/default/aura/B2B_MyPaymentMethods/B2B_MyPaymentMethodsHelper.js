({
    updateExpiredCard : function(component, event){
        
        var action = component.get("c.updateExpiredCardList");
        $A.enqueueAction(action);
    },
    
    getAllMyPaymentsList : function(component, event){
        var action = component.get("c.getAllMyPaymentsNew");

        action.setCallback(this, this.getMyPayments_Callback(component, event));
        $A.enqueueAction(action);
    },
    getMyPayments_Callback : function(component, event) {
        return (function(a){           
            if (a.getState() === "SUCCESS") {
                let strResponse = a.getReturnValue();
                if(strResponse != 'No record found'){
                    let res = JSON.parse(strResponse);
                    component.set("v.clientToken", res.clientToken);
                    if(res.paymentMethodList)
                    	this.validateCardExpirationDate(component, res.paymentMethodList);
                    else
                       component.set("v.isNoPayments", true); 
                    let stateOptionList = res.states.sort((a, b) => (a.label > b.label) ? 1 : -1);
                    component.set("v.stateOptionList", stateOptionList);
                }else {
                    component.set("v.isNoPayments", true);
                }               
                component.set("v.showSpinner", false);
            } else {
                component.set("v.isNoPayments", true);
                component.set("v.showSpinner", false);
            }
        });
    },
    addAllPaymentList : function(component, event){
        var action = component.get("c.getAddMyPayments");

        action.setCallback(this, this.addAllPaymentList_Callback(component, event));
        $A.enqueueAction(action);
    },
    addAllPaymentList_Callback : function(component, event) {
        return (function(a){           
            if (a.getState() === "SUCCESS") {
                let strResponse = a.getReturnValue();
                if(strResponse != 'No record found'){
                    let res = JSON.parse(strResponse);
                    component.set("v.newClientToken", res.clientToken);
                    this.validateCardExpirationDate(component, res.paymentMethodList);
                    let stateOptionList = res.states.sort((a, b) => (a.label > b.label) ? 1 : -1);
                    //component.set("v.stateOptionList", stateOptionList);
                }else {
                    component.set("v.isNoPayments", true);
                }               
                component.set("v.showSpinner", false);
            } else {
                component.set("v.isNoPayments", true);
                component.set("v.showSpinner", false);
            }
        });
    },
    validateCardExpirationDate: function(component, paymentMethodList){ 
        if(paymentMethodList){
            paymentMethodList.forEach((element) => {
                element.dateNotExpired = isFutureDate(element.CC_Expiration_Year__c, new Date(),element.CC_Expiration_Month__c);
                
            });
        }else{
            component.set("v.isNoPayments", true);
            
        }
        component.set("v.paymentsList", paymentMethodList);
        component.set("v.tempPaymentsList", JSON.stringify(paymentMethodList));
             
        function isFutureDate(d1, today,m1) {
            var exact_month= today.getMonth()+1;
            if(d1 > today.getFullYear()){
                return true;
            }else if(d1 < today.getFullYear()){
                return false;
            }else if(d1 == today.getFullYear()){
                if(m1 > exact_month){
                    return true;
                }else if(m1 < exact_month){
                    return false;
                }else if(m1 == exact_month){
                    return true;
                }
            }
        }
    },
    setupHostedFields : function(component, clientToken){
       var objPayment = component.get("v.objPayment");
       var month;
       if(objPayment.CC_Expiration_Month__c > 9 )
        month = objPayment.CC_Expiration_Month__c;
        else
        month = '0' + objPayment.CC_Expiration_Month__c;
        braintree.client.create({
            authorization: clientToken
        }, function(err, clientInstance) {
            if (err) {
                return;
            }                      

            braintree.hostedFields.create({
                client: clientInstance,
                styles: {
                    input: {
                        color: '#666666',
                        'font-size': '16px'
                    }
                },
                fields: {
                    //Added by faraz on 20April22 for HDMP-8728 for Mask CC number/CVV & expiration date in MM/YY
                    
                    cvv: {
                        selector: '#cc-cvv',
                        placeholder: 'xxx',
                        maskInput: true,
                        minlength: (objPayment.Type__c == 'Credit Card - Amex') ? 4 : 3
                    },
                    expirationDate: {
                        selector: '#cc-expiration',
                        placeholder: 'MM/YY OR MM/YYYY',
                        prefill : month +'/'+objPayment.CC_Expiration_Year__c,
                    }                  
                    //End here HDMP-8728                  
                }
            }, function (hostedFieldsErr, hostedFieldsInstance) {
                let temp = [];
                temp.push(hostedFieldsInstance);
                component.set("v.hostedFieldsInstance", temp);              
                component.set("v.showSpinner", false);
                if (hostedFieldsErr) {
                    console.error(hostedFieldsErr);
                    return;
                }
                
                function createInputChangeEventListener(element) {
                    return function () {
                        validateInput(element);
                    }
                }
                
                function setValidityClasses(element, validity) {
                    if (validity) {
                        element.removeClass('is-invalid');
                        element.addClass('is-valid');  
                    } else {
                        element.addClass('is-invalid');
                        element.removeClass('is-valid');  
                    }    
                }
                
                
                function validateInput(element) {
                    // very basic validation, if the
                    // fields are empty, mark them
                    // as invalid, if not, mark them
                    // as valid
                    
                    if (!element.val().trim()) {
                        setValidityClasses(element, false);
                        
                        return false;
                    }
                    
                    setValidityClasses(element, true);
                    
                    return true;
                }
                
                function validateEmail () {
                    var baseValidity = validateInput(email);
                    
                    if (!baseValidity) {  
                        return false;
                    }
                    
                    if (email.val().indexOf('@') === -1) {
                        setValidityClasses(email, false);
                        return false;
                    }
                    
                    setValidityClasses(email, true);
                    return true;
                }
                
                var ccName = $('#cc-name');
                var email = $('#email');
                
                ccName.on('change', function () {
                    validateInput(ccName);
                });
                email.on('change', validateEmail);
                
                hostedFieldsInstance.getSupportedCardTypes().then(function (cardTypes) {
                    var objCardTypes = {};
                    cardTypes.forEach(item => {
                        if(item == 'Mastercard'){
                            objCardTypes['master'] = true;
                        }else if(item == 'Visa'){
                            objCardTypes['visa'] = true;
                        }else if(item == 'Discover'){
                            objCardTypes['discover'] = true;
                        }else if(item == 'American Express'){
                            objCardTypes['amex'] = true;
                        }
                    })
                    component.set("v.cardTypes",objCardTypes)
                    cardTypes // ['Visa', 'American Express', 'Mastercard']
                });

                hostedFieldsInstance.on('validityChange', function(event) {
                    var field = event.fields[event.emittedBy];
                    
                    // Remove any previously applied error or warning classes
                    $(field.container).removeClass('is-valid');
                    $(field.container).removeClass('is-invalid');
                    
                    if (field.isValid) {
                        $(field.container).addClass('is-valid');
                    } else if (field.isPotentiallyValid) {
                        // skip adding classes if the field is
                        // not valid, but is potentially valid
                    } else {
                        $(field.container).addClass('is-invalid');
                    }
                });
                
                hostedFieldsInstance.on('cardTypeChange', function(event) {
                    var cardBrand = $('#card-brand');
                    var cvvLabel = $('[for="cc-cvv"]');
                    if (event.cards.length === 1) {
                        var card = event.cards[0];
                        // change pay button to specify the type of card
                        // being used
                        cardBrand.text(card.niceType);
                        // update the security code label
                        cvvLabel.text(card.code.name);
                    } else {
                        // reset to defaults
                        cardBrand.text('Card');
                        cvvLabel.text('CVV');
                    }
                });
            });           
        });
    },

    //Performs a validation on the Form before tokenizing and calling out to Braintree
    validateForm : function(component, event) {
        //component.set("v.showSpinner", true);

        const fieldsToCorrect = [];
        let isValid = true;
        
        const inputFields = component.find("inputField");       
        if(inputFields) {
            for(let i = 0 ; i < inputFields.length ; i++) {
                let currInput = inputFields[i];

                //Only validate required fields
                if(currInput.get("v.required") || currInput.get("v.name") == "Cardholder Name") {
                    let fieldName = currInput.get("v.name");
                    let fieldVal = currInput.get("v.value");                   
                    //Validation on existing inputs
                    if(fieldName == "Name" || fieldName == "Cardholder Name") {
                        //    /^[a-zA-Z ]*$/
                        if(!fieldVal || fieldVal.trim().length < 2 || !(/^[ A-Za-z0-9_@./','#&+-]*$/.test(fieldVal))) {
                            currInput.setCustomValidity("Invalid name, please enter a valid name.")
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if(fieldName == "Zipcode") {
                        if(fieldVal && (/^[0-9-]*$/.test(fieldVal)) && (fieldVal.length == 5 || fieldVal.length == 10)) {
                            if(fieldVal.includes("-") && (fieldVal.split("-").length != 2 || fieldVal.trim().length != 10 || fieldVal.indexOf("-") != 5)) {
                                currInput.setCustomValidity("Invalid zip code, please provide valid zip code.")
                                currInput.reportValidity();
                                fieldsToCorrect.push(fieldName);
                            } 
                        } else {
                            currInput.setCustomValidity("Invalid zip code, please provide valid zip code.")
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if(fieldName == "Address") {
                        if(!fieldVal || fieldVal.trim().length < 3) {
                            currInput.setCustomValidity("Please enter a valid address.")
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if(fieldName == "City") {
                        if(!fieldVal || fieldVal.trim().length < 3 || !(/^[a-zA-Z ]*$/.test(fieldVal))) {
                            currInput.setCustomValidity("Please enter a valid address.");
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if(fieldName == "Phone") {
                        if(!fieldVal || fieldVal.trim().length != 10 || !(/^[0-9]*$/.test(fieldVal))) {
                            currInput.setCustomValidity("Please enter a valid phone number.")
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if(fieldName == "State") {
                        if(!fieldVal || fieldVal.trim() == "") {
                            currInput.set("v.value", undefined);
                            currInput.showHelpMessageIfInvalid();
                            fieldsToCorrect.push(currInput.get("v.name"));
                        }
                    } else {
                        if(!currInput.checkValidity()) {
                            isValid = false;
                            
                            currInput.reportValidity();
                            fieldsToCorrect.push(currInput.get("v.name"));
                        }
                    }
                }
            }
            
            //If one or more fields are invalid, 
            if(fieldsToCorrect.length > 0) {
                //this.handleErrorMessage(component, "Please complete the following field(s): " + fieldsToCorrect.join(", "));
                //this.handleErrorMessage(component, "Please review and check that all information is complete.");
                this.handleErrorMessage(component,"Some address fields are invalid.Please review and verify the correct information is entered.");
                component.set("v.showSpinner", false);
            } else {                            
                this.getPaymentNonce(component, event);
            }
        } else {
            component.set("v.showSpinner", false);
        }
    }, 
    validateFormAddPayment : function(component, event){
        component.set("v.showSpinner", true);
        const fieldsToCorrect = [];
        let isValid = true;
        const inputFields = component.find("inputField");
        if(inputFields) {
            for(let i = 0 ; i < inputFields.length ; i++) {
                let currInput = inputFields[i];

                //Only validate required fields
                if(currInput.get("v.required") || currInput.get("v.name") == "Cardholder Name") {
                    let fieldName = currInput.get("v.name");
                    let fieldVal = currInput.get("v.value");                   
                    //Validation on existing inputs
                    if(fieldName == "Name" || fieldName == "Cardholder Name") {
                        //    /^[a-zA-Z ]*$/
                        if(!fieldVal || fieldVal.trim().length < 2 || !(/^[ A-Za-z0-9_@./','#&+-]*$/.test(fieldVal))) {
                            currInput.setCustomValidity("Invalid name, please enter a valid name.")
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if(fieldName == "Zipcode") {
                        if(fieldVal && (/^[0-9-]*$/.test(fieldVal)) && (fieldVal.length == 5 || fieldVal.length == 10)) {
                            if(fieldVal.includes("-") && (fieldVal.split("-").length != 2 || fieldVal.trim().length != 10 || fieldVal.indexOf("-") != 5)) {
                                currInput.setCustomValidity("Invalid zip code, please provide valid zip code.")
                                currInput.reportValidity();
                                fieldsToCorrect.push(fieldName);
                            } 
                        } else {
                            currInput.setCustomValidity("Invalid zip code, please provide valid zip code.")
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if(fieldName == "Address") {
                        if(!fieldVal || fieldVal.trim().length < 3) {
                            currInput.setCustomValidity("Please enter a valid address.")
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if(fieldName == "City") {
                        if(!fieldVal || fieldVal.trim().length < 3 || !(/^[a-zA-Z ]*$/.test(fieldVal))) {
                            currInput.setCustomValidity("Please enter a valid address.");
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if(fieldName == "Phone") {
                        if(!fieldVal || fieldVal.trim().length != 10 || !(/^[0-9]*$/.test(fieldVal))) {
                            currInput.setCustomValidity("Please enter a valid phone number.")
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if(fieldName == "State") {
                        if(!fieldVal || fieldVal.trim() == "") {
                            currInput.set("v.value", undefined);
                            currInput.showHelpMessageIfInvalid();
                            fieldsToCorrect.push(currInput.get("v.name"));
                        }
                    } else {
                        if(!currInput.checkValidity()) {
                            isValid = false;
                            
                            currInput.reportValidity();
                            fieldsToCorrect.push(currInput.get("v.name"));
                        }
                    }
                }
            }
            
            //If one or more fields are invalid, 
            if(fieldsToCorrect.length > 0) {
                //this.handleErrorMessage(component, "Please complete the following field(s): " + fieldsToCorrect.join(", "));
                this.handleErrorMessage(component, "Some address fields are invalid.Please review and verify the correct information is entered.");
                
                component.set("v.showSpinner", false);
            } else {                            
                this.getPaymentNonceAddPayment(component, event);
            }
        } else {
            component.set("v.showSpinner", false);
        }
    },
    getPaymentNonceAddPayment : function(component, event) {
        const dropin = component.get("v.hostedFieldsInstance")[0];
        var isNewAddress=component.get("v.isSaveToAddressBook");
        let self = this;
        self.component = component;
        if(dropin) {
            var addressData = this.getBillingAddressInfoAddPayment(component);
            var customerData = this.getCustomerDataAddPayment(component);
            dropin.tokenize(addressData, function (tokenizeErr, payload) {             
                if(tokenizeErr || !component.get("v.isAnyAddressSelected")) {
                    if(tokenizeErr){
                    self.handleErrorMessage(self.component, "Some payment fields are invalid. Please review and verify that the correct information is entered.");
                    } else if(!component.get("v.isAnyAddressSelected")){
                        self.handleErrorMessage(self.component, "Please select any billing address from the list or provide new billing address.");
                    }
                    self.component.set("v.showSpinner", false);                    
                    return;
                }
               self.AddPayment(self.component, payload.nonce, customerData, 'Credit Card',isNewAddress);
            });
        } else {
            component.set("v.showSpinner", false);
        }
    },
    getBillingAddressInfoAddPayment : function (component){
        
        if(component.get("v.isNewAddress")){
            let fullName = component.get("v.name");
            //let fullName =component.get("v.selectedAddress").Name
            let nameParts = fullName.split(' ');

            let firstName = nameParts[0];
            let lastName = '';

            if (nameParts.length > 1) {
                nameParts.shift();
                lastName = nameParts.join(' ');
            }
            return {
                cardholderName: component.get("v.cardholderName"),
                billingAddress: {
                    firstName: firstName,
                    lastName: lastName,
                    streetAddress: component.get("v.address1"),
                    extendedAddress: component.get("v.address2"),
                    locality: component.get("v.city"),
                    region: component.get("v.state"),
                    postalCode: component.get("v.zipCode"),
                    countryName: component.get("v.country")
                }
            };
        }
        else{
            let fullName = component.get("v.replacedAddress").Name;
            let nameParts = fullName.split(' ');

            let firstName = nameParts[0];
            let lastName = '';

            if (nameParts.length > 1) {
                nameParts.shift();
                lastName = nameParts.join(' ');
            }
            return {
                cardholderName: component.get("v.cardholderName"),
                billingAddress: {
                    firstName: firstName,
                    lastName: lastName,
                    streetAddress: component.get("v.replacedAddress").Address__c,
                    extendedAddress: component.get("v.replacedAddress").Address_Line_2__c,
                    locality: component.get("v.replacedAddress").City__c,
                    region: component.get("v.replacedAddress").State__c,
                    postalCode: component.get("v.replacedAddress").Zip__c,
                    countryName: component.get("v.country")
                }
            };
            
        }    
    },
    getCustomerDataAddPayment: function(component) {
        if(component.get("v.isNewAddress")){
            return {
            'name': component.get("v.name"),
            'address1': component.get("v.address1"),
            'address2': component.get("v.address2"),
            'city': component.get("v.city"),
            'state': component.get("v.state"),
            'zipCode': component.get("v.zipCode"),
            'phone': component.get("v.phoneNumber"),
            'email': '',
            'country': component.get("v.country")
        };
        }else{
            return {
            'name': component.get("v.replacedAddress").Name,
            'address1': component.get("v.replacedAddress").Address__c,
            'address2': component.get("v.replacedAddress").Address_Line_2__c,
            'city': component.get("v.replacedAddress").City__c,
            'state': component.get("v.replacedAddress").State__c,
            'zipCode': component.get("v.replacedAddress").Zip__c,
            'phone': component.get("v.replacedAddress").Phone__c,
            'email': component.get("v.replacedAddress").Email__c,
            'country': component.get("v.country")
            
            };}
        
    },
    
    AddPayment: function(component, nonce, customerData, paymentType,isNewAddress) {
        var action = component.get("c.processAddPayment");
        action.setCallback(this, this.submitAddPayment_Callback(component, event, paymentType));
        action.setParams({
            nonce: nonce,
            customerData: customerData,
            paymentType: paymentType,
            ispreferred : component.get("v.isPreferredPayment"),
            isNewAddr : isNewAddress,
        });

        $A.getCallback(function() {
            $A.enqueueAction(action);
        })();
    },
        submitAddPayment_Callback: function(component, event, paymentType) {
        return (function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                let res = a.getReturnValue();
                if (res && res.success) {
					this.getAllAddedPayment(component,event);
                    component.set("v.openAddPaymentModal", false);
                 	component.set("v.isNoPayments", false);
                    component.set("v.showSpinner", false);
                    this.handleSuccessMessage(component, "Added Successfully");
                } 
                else {
                    component.set("v.showSpinner", false);
                    var errorMessage = '';
                    if (res.errorReason && res.errorReason == 'AVS') {
                        errorMessage = 'Some address fields are invalid. Please review and verify that the correct information is entered.';
                    } else if (res.errorReason && (res.errorReason == 'CVV' || res.errorReason == 'AVS_AND_CVV')) {
                        errorMessage = 'Some payment fields are invalid. Please review and verify that the correct information is entered.';
                    } else if (res.errorReason && res.errorReason == 'Duplicate Card') {
                        errorMessage = 'This payment method already exists in My Payment.';
                    } else if (res.errorReason == 'Credit card type is not accepted by this merchant account.') {
                        errorMessage = 'This card type is currently not supported. Dreamshop currently supports Visa, Mastercard, Discover and American Express.';
                    } else{
                        errorMessage = 'Some payment fields are invalid. Please review and verify that the correct information is entered.';
                    } 
                    this.handleErrorMessage(component, errorMessage);
                }
            } else {
                component.set("v.showSpinner", false);
            }
        });
    },
        getAllAddedPayment : function(component,event){
            var action = component.get("c.getAllMyPaymentsNew");
            action.setCallback(this, this.getAllAddedPayment_Callback(component, event));
            $A.enqueueAction(action);
            
        },
            getAllAddedPayment_Callback : function(component, event) {
        return (function(a){   
            if (a.getState() === "SUCCESS") {
                let strResponse = a.getReturnValue();
				if(strResponse != 'No record found'){
				let res = JSON.parse(strResponse);
				this.validateCardExpirationDate(component, res.paymentMethodList);
				 
                }
            }
			
        });
    },

    // Below code is for Add Payment
    setupHostedFieldsMyPayment : function(component, clientToken){
        component.set("v.showSpinner", true);
        braintree.client.create({
            authorization: clientToken
        }, function(err, clientInstance) {
            if (err) {
                return;
            }                      

        braintree.hostedFields.create({
            client: clientInstance,
            styles: {
                input: {
                    color: '#666666',
                    'font-size': '16px'
                }
            },
            fields: {
                number: {
                //Added by faraz on 20April22 for HDMP-8728 for Mask CC number/CVV & expiration date in MM/YY
                selector: '#cc-number',
                    placeholder: 'xxxx xxxx xxxx xxxx',
                    maskInput: true
                },
                cvv: {
                    selector: '#cc-cvv',
                    placeholder: 'xxx',
                    maskInput: true,
                },
                expirationDate: {
                    selector: '#cc-expiration',
                    placeholder: 'MM/YY OR MM/YYYY',
                    //prefill : objPayment.expirationDate,
                }                  
                //End here HDMP-8728                  
            }
        }, 
        function (hostedFieldsErr, hostedFieldsInstance) {
            let temp = [];
            temp.push(hostedFieldsInstance);
            component.set("v.hostedFieldsInstance", temp);              
            component.set("v.showSpinner", false);
            if (hostedFieldsErr) {
                console.error(hostedFieldsErr);
                return;
            }
            
            function createInputChangeEventListener(element) {
                return function () {
                    validateInput(element);
                }
            }
            
            function setValidityClasses(element, validity) {
                if (validity) {
                    element.removeClass('is-invalid');
                    element.addClass('is-valid');  
                } else {
                    element.addClass('is-invalid');
                    element.removeClass('is-valid');  
                }    
            }
            
            
            function validateInput(element) {
                // very basic validation, if the
                // fields are empty, mark them
                // as invalid, if not, mark them
                // as valid
                
                if (!element.val().trim()) {
                    setValidityClasses(element, false);
                    
                    return false;
                }
                
                setValidityClasses(element, true);
                
                return true;
            }
            
            function validateEmail () {
                var baseValidity = validateInput(email);
                
                if (!baseValidity) {  
                    return false;
                }
                
                if (email.val().indexOf('@') === -1) {
                    setValidityClasses(email, false);
                    return false;
                }
                
                setValidityClasses(email, true);
                return true;
            }
            
            var ccName = $('#cc-name');
            var email = $('#email');
            
            ccName.on('change', function () {
                validateInput(ccName);
            });
            email.on('change', validateEmail);
            
            hostedFieldsInstance.getSupportedCardTypes().then(function (cardTypes) {
                var objCardTypes = {};
                cardTypes.forEach(item => {
                    if(item == 'Mastercard'){
                        objCardTypes['master'] = true;
                    }else if(item == 'Visa'){
                        objCardTypes['visa'] = true;
                    }else if(item == 'Discover'){
                        objCardTypes['discover'] = true;
                    }else if(item == 'American Express'){
                        objCardTypes['amex'] = true;
                    }
                })
                component.set("v.cardTypes",objCardTypes)
                cardTypes // ['Visa', 'American Express', 'Mastercard']
            });

            hostedFieldsInstance.on('validityChange', function(event) {
                var field = event.fields[event.emittedBy];
                
                // Remove any previously applied error or warning classes
                $(field.container).removeClass('is-valid');
                $(field.container).removeClass('is-invalid');
                
                if (field.isValid) {
                    $(field.container).addClass('is-valid');
                } else if (field.isPotentiallyValid) {
                    // skip adding classes if the field is
                    // not valid, but is potentially valid
                } else {
                    $(field.container).addClass('is-invalid');
                }
            });
            
            hostedFieldsInstance.on('cardTypeChange', function(event) {
                var cardBrand = $('#card-brand');
                var cvvLabel = $('[for="cc-cvv"]');
                if (event.cards.length === 1) {
                    var card = event.cards[0];
                    // change pay button to specify the type of card
                    // being used
                    cardBrand.text(card.niceType);
                    // update the security code label
                    cvvLabel.text(card.code.name);
                } else {
                    // reset to defaults
                    cardBrand.text('Card');
                    cvvLabel.text('CVV');
                }
            });
        });           
    });
},
        
    getPaymentNonce : function(component, event) {
        const dropin = component.get("v.hostedFieldsInstance")[0];
        let self = this;
        self.component = component;


        if(dropin) {
            var addressData = this.getBillingAddressInfo(component);         
            dropin.tokenize(addressData, function (tokenizeErr, payload) {             
                if(tokenizeErr) {
                    self.component.set("v.showSpinner", false);
                    //self.handleErrorMessage(self.component, "Some payment fields are invalid. Please review and verify the correct information is entered.");                                    
                    self.handleErrorMessage(self.component, "Some payment fields are invalid. Please review and verify that the correct information is entered.");
                    return;
                }
                
                            
                self.updatePaymentMethod(self, self.component, payload);
            });
        } else {
            component.set("v.showSpinner", false);
        }
    },
    updatePaymentMethod : function(self, component, payload){
        //var address = component.get("v.replacedAddress");
        //var addressId = component.get("v.objPayment.Id")
        var addressId = '';
        //if(address){
         //   addressId = addressId;
        //}
        var objPayment = component.get("v.objPayment");
        var objAddess= component.get("v.replacedAddress");
        if(objAddess){
            objPayment.Billing_Customer_Name__c = objAddess.Name;
            objPayment.Billing_Street__c = objAddess.Address__c;
            objPayment.Billing_Street_Line2__c=objAddess.Address_Line_2__c;
            objPayment.Billing_City__c = objAddess.City__c;
            objPayment.Billing_State__c = objAddess.State__c;
            objPayment.Billing_Country__c = objAddess.Country__c;
            objPayment.Billing_PostalCode__c = objAddess.Zip__c;
            objPayment.Billing_Phone__c = objAddess.Phone__c;
        }
        
        var action = component.get("c.updatePaymentAndAddress");
        action.setParams({ 
            payload : JSON.stringify(payload),
            objPaymentStr : JSON.stringify(objPayment),
            replacedAddressId : addressId     
        });
        action.setCallback(this, this.updatePaymentMethod_Callback(self, component));
        $A.enqueueAction(action);
        
    },
    updatePaymentMethod_Callback : function(self, component) {
        return (function(a){
            
            if (a.getState() === "SUCCESS") {
                let strResponse = a.getReturnValue();
                let res = JSON.parse(strResponse);
                if(res.paymentMethodList){
                    let res = JSON.parse(strResponse);
                    //this.getAllAddedPayment(component,event);
                    self.validateCardExpirationDate(component, res.paymentMethodList); 
                    component.set("v.showEditModal", false);
                    component.set("v.objPayment", {}); 
                    self.handleSuccessMessage(self.component, "Updated Successfully");
                }else if(res.errorMessage == '"Gateway Rejected: avs"'){
                    self.handleErrorMessage(self.component, "Some address fields are invalid. Please review and verify that the correct information is entered.");                   
                }else {
                    self.handleErrorMessage(self.component, "Some payment fields are invalid. Please review and verify that the correct information is entered.");                   
                }                              
                component.set("v.showSpinner", false);                 
            } else {
                component.set("v.showSpinner", false);
                self.handleErrorMessage(self.component, "Update Failed");           
            }
        });
    },
    
    getAllSavedAddresses : function(component, event){
        var action = component.get("c.getSavedAddresses");
        action.setCallback(this, this.getAllSavedAddresses_Callback(component, event));
        $A.enqueueAction(action);
    },
    getAllSavedAddresses_Callback : function(component, event) {
        return (function(a){
            if (a.getState() === "SUCCESS") {
                let strResponse = a.getReturnValue();
                if(!strResponse.includes('No record found')){
                    let res = JSON.parse(strResponse);                          
                    component.set("v.addressList", res);      
                }                                     
            } else {
               
            }
        });
    },
    getSavedAddress : function(component, event, addressId){
        var action = component.get("c.getAllMyAddresses");
        action.setParams({ 
            addressId : addressId
        });
        action.setCallback(this, this.getSavedAddress_Callback(component, event));
        $A.enqueueAction(action);
    },
    getSavedAddress_Callback : function(component, event) {
        return (function(a){
            
            if (a.getState() === "SUCCESS") {
                let strResponse = a.getReturnValue();
                if(!strResponse.includes('No record found')){
                    let res = JSON.parse(strResponse);                          
                    component.set("v.addressList", res);      
                }                                     
            } else {
               
            }
        });
    },

    setMarkPreferred : function(component, event, paymentId){
        component.set("v.showSpinner", true);
        var action = component.get("c.markPreferredSingleRecord");
        action.setParams({ 
            paymentId : paymentId
        });
        action.setCallback(this, this.markPreferred_Callback(component, event));
        $A.enqueueAction(action);
    },
    markPreferred_Callback : function(component, event) {
        return (function(a){
            if (a.getState() === "SUCCESS") {
                let strResponse = a.getReturnValue();
                let res = JSON.parse(strResponse);
                this.validateCardExpirationDate(component, res.paymentMethodList);
                component.set("v.showSpinner", false);  
                this.handleSuccessMessage(component, "Marked Preferred Sucessfully");               
            } else {
                component.set("v.showSpinner", false);
                this.handleErrorMessage(component, "Marked Preferred Failed");
            }
        });
    },

    removePaymentMethod : function(component, event, paymentId){
        var action = component.get("c.deletePaymentRecord");
        action.setParams({ 
            paymentId : paymentId
        });
        action.setCallback(this, this.removePaymentMethod_Callback(component, event, paymentId));
        $A.enqueueAction(action);
    },
    removePaymentMethod_Callback : function(component, event, paymentId) {
        return (function(a){
            if (a.getState() === "SUCCESS") {
                let strResponse = a.getReturnValue();                
                if(strResponse != 'Delete Failed'){
                    if(strResponse == 'No record found'){
                        component.set("v.paymentsList", null);
                        component.set("v.tempPaymentsList", null); 
                    }else {
                    let res = JSON.parse(strResponse);  
                    this.validateCardExpirationDate(component, res.paymentMethodList);                   
                    }                     
                    component.set("v.showSpinner", false);
                    this.handleSuccessMessage(component, "Deleted Successfully");
                    component.set("v.showSpinner", false);
                    //this.handleErrorMessage(component, "Delete Failed");
                }else{
                    component.set("v.showSpinner", false);
                    this.handleErrorMessage(component, "Delete Failed");
                }                                                                        
            } else {
                component.set("v.showSpinner", false);
                this.handleErrorMessage(component, "Delete Failed");
            }
        });
    },
    
    //Returns an object containing the User's Billing Address Information
    getBillingAddressInfo : function(component) {
        let objAddress = component.get("v.replacedAddress");
        //let objPayment = component.get("v.objPayment");
        //TODO - Country name will need to be moved to a Variable once more countries are available
        if(component.get("v.isNewAddress")){
            let fullName = component.get("v.objPayment.Billing_Customer_Name__c");
            let nameParts = fullName.split(' ');
            let firstName = nameParts[0];
            let lastName = '';
            if (nameParts.length > 1) {
                nameParts.shift();
                lastName = nameParts.join(' ');
            }
            return {
            cardholderName : component.get("v.objPayment.Cardholder_Name__c"),
            billingAddress: {
                    'firstName': firstName,
                    'lastName': lastName,
                    'streetAddress': component.get("v.objPayment.Billing_Street__c"),
                    'extendedAddress': component.get("v.objPayment.Billing_Street_Line2__c"),
                    'locality': component.get("v.objPayment.Billing_City__c"),
                    'region': component.get("v.objPayment.Billing_State__c"),
                    'postalCode': component.get("v.objPayment.Billing_PostalCode__c"),
                    'countryName':component.get("v.objPayment.Billing_Country__c")
                }  
            };
        }else{
            let fullName = component.get("v.replacedAddress").Name;
            let nameParts = fullName.split(' ');
            let firstName = nameParts[0];
            let lastName = '';
            if (nameParts.length > 1) {
                nameParts.shift();
                lastName = nameParts.join(' ');
            }
            return {
            cardholderName : component.get("v.objPayment.Cardholder_Name__c"),
            billingAddress: {
                    'firstName': firstName,
                    'lastName':lastName,
                    'streetAddress': component.get("v.replacedAddress").Address__c,
                    'extendedAddress': component.get("v.replacedAddress").Address_Line_2__c,
                    'locality': component.get("v.replacedAddress").City__c,
                    'region': component.get("v.replacedAddress").State__c,
                    'postalCode': component.get("v.replacedAddress").Zip__c,
                    'countryName':component.get("v.replacedAddress").Country__c
                }  
            }
                
            };
                
        
    },

    //Displays an error message if present
    handleErrorMessage : function(component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error",
            "message": message,
            "type": "error"
        });
        toastEvent.fire();
    },

    //Displays an error message if present
    handleSuccessMessage : function(component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success",
            "message": message,
            "type": "success"
        });
        toastEvent.fire();
    },
        handleToAllowPhone: function(event) {
        let charCode = (event.which) ? event.which : event.keyCode;

        if (!((charCode >= 48 && charCode <= 57))) {
            event.preventDefault();
            return false;
        }

        return true;
    },
        handleToAllowZipcode: function(event) {
        let charCode = (event.which) ? event.which : event.keyCode;

        if (!((charCode >= 48 && charCode <= 57) || (charCode == 45))) {
            event.preventDefault();
            return false;
        }

        return true;
    }
})