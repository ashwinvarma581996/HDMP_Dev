({
	doInit : function(component, event) {      
        component.set("v.showSpinner", true);
        console.log("do init");    
        

        // the function that reads the url parameters
        var getUrlParameter = function getUrlParameter(sParam) {
            var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;

            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');

                if (sParameterName[0] === sParam) {
                    return sParameterName[1] === undefined ? true : sParameterName[1];
                }
            }
        };

        /*if(getUrlParameter('orderId').size != 18 || !getUrlParameter('orderId').isEmpty()  ){
            this.handleErrorMessage(component, "Invalid Order number");
        }*/
            component.set("v.orderId", getUrlParameter('orderId'));
            //component.set("v.orderId","801g000000FTybTAAT");        
            //component.set("v.orderId","801g000000FU402AAD");   
            console.log('orderId : '+ component.get("v.orderId"));
            this.setupForm(component, event);
        
	},
    setupForm : function(component, event) {      
        var action = component.get("c.hostedFormSetup");       
        action.setCallback(this, this.setupForm_Callback(component, event));
        action.setParams({ 
            orderId : component.get("v.orderId")
        });
        $A.enqueueAction(action);
    },
    setupForm_Callback : function(component, event) {
        let self = this;
        self.component = component;
        return (function(a){
            if (a.getState() === "SUCCESS") {
                let res = a.getReturnValue();
                console.log('res : '+ JSON.stringify(res));
                if(res && res.success) {
                    //component.set("v.stateCodes", res.codes);
                    component.set("v.paymentTypes", res.paymentTypes)
                    component.set("v.shippingAddress", res.shipping);
                    component.set("v.cartId", res.cartId);
                    component.set("v.isShowForm", true);
                    component.set("v.order", res.order);
                    component.set("v.stateCodes", res.codes);

                    if(res.customerId != ''){
                        component.set("v.customerId", res.customerId);
                    }
                    //Have to check as String value due to Boolean value getting removed from response
                    if(res.shipping.dealerPickup && res.shipping.dealerPickup != 'true') {
                        component.set("v.dealerPickup", false);
                    }
                    
                    this.setupHostedFields(component, res.token, self, event);
                } else {
                    component.set("v.showSpinner", false);
                    component.set("v.isShowForm", false);
                    if(res.error) {
                        this.handleErrorMessage(component, res.error);
                    }
                }
            } else {
                component.set("v.showSpinner", false);
                this.handleErrorMessage(component, "Error occurred");
            }
        });
    },
    setupHostedFields : function(component, clientToken, self, event) {
        braintree.client.create({
            authorization: clientToken
        }, function(err, clientInstance) {
            if (err) {
                return;
            }
            
            braintree.paypalCheckout.create({
                client: clientInstance
            }, function (paypalCheckoutErr, paypalCheckoutInstance) {
                if (paypalCheckoutErr) {
                    console.error('Error creating PayPal Checkout:', paypalCheckoutErr);
                    return;
                }          
    
                paypalCheckoutInstance.loadPayPalSDK({
                vault: true
                }, function () {
                paypal.Buttons({
                    style: {
                        label : 'pay'
                    },
                    fundingSource: paypal.FUNDING.PAYPAL,

                    createBillingAgreement: function () {
                    return paypalCheckoutInstance.createPayment({
                        flow: 'vault', // Required

                        // The following are optional params
                        billingAgreementDescription: 'Your total amount for Order is $' + component.get("v.order").Updated_Order_Total__c+'.',
                        enableShippingAddress: false,
                        shippingAddressEditable: false,
                        //enableBillingAddress: true
                    });
                    },

                    onApprove: function (data, actions) {
                    return paypalCheckoutInstance.tokenizePayment(data, function (err, payload) {
                        console.log('payload.nonce  : ',payload);
                        console.log('data  : ',data);
                        component.set("v.showSpinner", true);
                        // Submit `payload.nonce` to your server   
                        var customerData = {
                            'name' : payload.details.firstName + ' ' + payload.details.lastName,
                            'address1' :  payload.details.billingAddress ? payload.details.billingAddress.line1 : '',
                            'address2' : payload.details.billingAddress ? payload.details.billingAddress.line2 : '',
                            'city' : payload.details.billingAddress ? payload.details.billingAddress.city : '',
                            'state' : payload.details.billingAddress ? payload.details.billingAddress.state : '',
                            'zipCode' :  payload.details.billingAddress ? payload.details.billingAddress.postalCode : '',
                            'phone' : payload.details.phone ? payload.details.phone.replaceAll('-','') : '',
                            'email' : payload.details.email,
                            'country' : 'USA',
                        };
                        var customerId = self.component.get("v.customerId");
                        if(customerId && customerId != ''){
                            customerData['customerId'] = customerId;
                        }                   
                        self.submitPayment(self.component, payload.nonce, event, 'PayPal', customerData);
                    });
                   
                    },

                    onCancel: function (data) {
                    console.log('PayPal payment canceled', JSON.stringify(data, 0, 2));
                    },

                    onError: function (err) {
                    console.error('PayPal error', err);
                    component.set('v.paypalErrorMessage', 'An error occured processing the Paypal payment.Please try again or select another payment method.')
                    }
                }).render('#paypal-button').then(function () {
                    // The PayPal button will be rendered in an html element with the ID
                    // `paypal-button`. This function will be called when the PayPal button
                    // is set up and ready to be used
                });

                });

            });

            braintree.hostedFields.create({
                client: clientInstance,
                styles: {
                    input: {
                        color: '#666666'
                    }
                },
                fields: {
                    
                    number: {
                        selector: '#cc-number',
                        placeholder: 'xxxx xxxx xxxx xxxx'                       
                    },
                    cvv: {
                        selector: '#cc-cvv',
                        placeholder: 'xxx'
                    },
                    expirationDate: {
                        selector: '#cc-expiration',
                        placeholder: 'MM/YYYY'
                    }
                }
            }, function (hostedFieldsErr, hostedFieldsInstance) {
                component.set("v.hostedFieldsInstance", hostedFieldsInstance);
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
                    console.log('cardTypes : ',cardTypes);
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
                    console.log('card : ',event);
                    var cardBrand = $('#card-brand');
                    var cvvLabel = $('[for="cc-cvv"]');
                    console.log('OUTPUT : ',);
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
    
    handleSubmitPayment : function(component, event) {
        component.set("v.showSpinner", true);
        const dropin = component.get("v.hostedFieldsInstance");
        let self = this;
        self.component = component;
        console.log('handleSubmitPayment : ');
        if(dropin) {     
            console.log('dropin : '+dropin);
            const addressData = this.getBillingAddressInfo(component);
            console.log('addressData : '+addressData);
            dropin.tokenize(addressData, function (tokenizeErr, payload) {
                if(tokenizeErr) {
                    console.log('handleSubmitPayment tokenizeErr: '+ JSON.stringify(tokenizeErr));
                    self.component.set("v.showSpinner", false);
                    self.handleErrorMessage(self.component, "Some payment fields are invalid. Please review and verify that the correct information is entered.");
                    return;
                }                          
                console.log('OUTPUT : ',payload.nonce);
                //this.handleErrorMessage(component, null);
                var customerData = self.getCustomerData(component);
                var customerId = self.component.get("v.customerId");
                if(customerId && customerId != ''){
                    customerData['customerId'] = customerId;
                }
                self.submitPayment(self.component, payload.nonce, event, 'CreditCard', customerData);
            });
        } else {
            component.set("v.showSpinner", false);
        }
    },

    validateForm : function(component, event) {
        component.set("v.showSpinner", true);

        const fieldsToCorrect = [];
        let isValid = true;
        
        const inputFields = component.find("inputField");
        
        if(inputFields) {
            for(let i = 0 ; i < inputFields.length ; i++) {
                let currInput = inputFields[i];    
                let fieldName = currInput.get("v.name");
                let fieldVal = currInput.get("v.value");
                if(fieldName == "Address 2") {
                    if(fieldVal && !(/^[a-zA-Z0-9\s,\''-]*$/.test(fieldVal))) {
                        currInput.setCustomValidity("Please enter a valid address.")
                        currInput.reportValidity();
                        fieldsToCorrect.push(fieldName);
                    }
                }
                //Only validate required fields
                if(currInput.get("v.required") || currInput.get("v.name") == "Cardholder Name") {                   
                    //Validation on existing inputs
                    if(fieldName == "Name" || fieldName == "Cardholder Name") {                     
                        if(!fieldVal || fieldVal.trim().length < 2 || !(/^[ A-Za-z0-9_@./#&+-]*$/.test(fieldVal))) {
                            console.log('fieldName : ',fieldName);
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
                    } else if(fieldName == "Address 1") {
                        if(!fieldVal || fieldVal.trim().length < 3 || !(/^[a-zA-Z0-9\s,\''-]*$/.test(fieldVal))) {
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
                this.handleErrorMessage(component, "Please review and check that all information is complete.");
                component.set("v.showSpinner", false);
            } else {
                component.set("v.isError", false);
                this.handleSubmitPayment(component, event);
            }
        } else {
            component.set("v.showSpinner", false);
        }
    },

    submitPayment : function(component, nonce ,event, paymentType, customerData) {
        component.set("v.isShowForm", false);
        component.set("v.iconName", "action:defer");
        this.handleSuccessMessage(component, 'Payment is Processing please wait');
        //TODO - add spinner to prevent form interaction while handling payment
        console.log('submitPayment : ');
        var action = component.get("c.processPayment");
       
        action.setCallback(this, this.submitPayment_Callback(component, event));
        action.setParams({ 
            nonce : nonce,   
            customerData : customerData,      
            cartId : component.get("v.cartId"),
            orderId : component.get("v.orderId"),
            paymentType : paymentType           
        });

        $A.getCallback(function() {
            $A.enqueueAction(action);
        })();
    },
    
    submitPayment_Callback : function(component, event) {
        console.log('submitPayment_Callback');
        return (function(a){
            var state = a.getState(); 
            
            if (state === "SUCCESS") {
                let res = a.getReturnValue();                                         
                if(res && res.success) {                   
                  console.log('In SUCCESS'+res.successMessage);
                  component.set("v.iconName", "action:approval");
                  this.handleSuccessMessage(component, res.successMessage);               
                  var toastEvent = $A.get("e.force:showToast");
                  toastEvent.setParams({
                      "title": "Success!",
                      "message": res.successMessage
                  });
                  toastEvent.fire();
                } else {   
                    var errorMessage = '';
                    if(res.errorReason && res.errorReason == 'AVS'){
                        errorMessage = 'Some address fields are invalid. Please review and verify that the correct information is entered.';
                    }else if(res.errorReason && (res.errorReason == 'CVV' || res.errorReason =='AVS_AND_CVV')){
                        errorMessage = 'Some payment fields are invalid. Please review and verify that the correct information is entered.';
                    }

                    if(res.error && res.error.includes('Credit card type is not accepted by this merchant account')){
                        errorMessage = 'This card is not supported, please either use a Visa, Mastercard, American Express, or Discover for payment.';
                    }else if(errorMessage == ''){
                        errorMessage = 'We’re sorry, we could not process this transaction. Please check your information and resubmit. Your credit card was not charged.';                                         
                    }
                   console.log('submitPayment_Callback else 1: '+res.error);   
                   //console.log('submitPayment_Callback else 1: '+(res.errorReason);                                                    
                    this.handleErrorMessage(component, errorMessage);               
                }
            } else {  
                var errorMessage = 'We’re sorry, we could not process this transaction. Please check your information and resubmit. Your credit card was not charged.';                                          
                console.log('submitPayment_Callback else 2: ',a);           
                this.handleErrorMessage(component, errorMessage);               
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": res.error
                });
                toastEvent.fire();
            }
        });
    },

    //Displays an error message if present
    handleErrorMessage : function(component, message) {
        component.set("v.isError", true);
        component.set("v.isSuccess", false);
        component.set("v.showSpinner", false)
        if(message) {
            component.set("v.errorMessage", message);
        } else {
            component.set("v.errorMessage", null);
        }
    },


    //Displays an success message if present
    handleSuccessMessage : function(component, message) {
        console.log("In handleSuccessMessage");
        component.set("v.showSpinner", false)    
        component.set("v.isError", false);   
        component.set("v.isSuccess", true);
        if(message) {
            component.set("v.successMessage", message);
        } else {
            component.set("v.successMessage", null);
        }
        
    },    


    
     //Returns an object containg the Customer's Information
    getCustomerData : function(component) {
        return {
            'name' : component.get("v.name"),
            'address1' : component.get("v.address1"),
            'address2' : component.get("v.address2"),
            'city' : component.get("v.city"),
            'state' : component.get("v.state"),
            'zipCode' : component.get("v.zipCode"),
            'phone' : component.get("v.phoneNumber"),
            'email' : component.get("v.email")
        };    
    },
    
    //Returns an object containing the User's Billing Address Information
    getBillingAddressInfo : function(component) {      
        

        let fullName = component.get("v.name");
        let nameParts = fullName.split(' ');
        
        let firstName = nameParts[0];
        let lastName = '';
        
        if(nameParts.length > 1) {
            nameParts.shift();
            lastName = nameParts.join(' ');
        }
        
        //TODO - Country name will need to be moved to a Variable once more countries are available
        return {
            cardholderName : component.get("v.cardholderName"),
            billingAddress : {
                firstName: firstName,
                lastName: lastName,
                streetAddress : component.get("v.address1"),
                extendedAddress : component.get("v.address2"),
                locality : component.get("v.city"),
                region : component.get("v.state"),
                postalCode : component.get("v.zipCode"),
                countryName : component.get("v.country")
            }
        };

        //TODO - Country name will need to be moved to a Variable once more countries are available
        /*return {
            billingAddress : {
                firstName: 'Rajrishi',
                lastName: 'Kaushik',
                streetAddress : '6300 E State',
                extendedAddress : 'University Dr Ste 104',
                locality : 'Long Beach',
                region : 'CA',
                postalCode : '90815-4678',
                countryName: 'United States',
            }
        };*/
    }
})