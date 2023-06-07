({
    doInit: function(component, event) {
        window.scrollTo(0, 0);
        component.set("v.showSpinner", true);
        this.setupForm(component, event);
    },
    setupForm: function(component, event) {
        var action = component.get("c.hostedFormSetup");

        action.setCallback(this, this.setupForm_Callback(component, event));
        action.setParams({
            cartId: component.get("v.cartId")
        });
        $A.enqueueAction(action);
    },
    setupForm_Callback: function(component, event) {
        let self = this;
        self.component = component;
        return (function(a) {
            console.log('OUTPUT : ', a);
            if (a.getState() === "SUCCESS") {
                let res = a.getReturnValue();

                if (res && res.success) {
                    console.log('res : ', res);
                    res.codes = res.codes.sort((a, b) => (a.label > b.label) ? 1 : -1);
                    component.set("v.stateCodes", res.codes);
                    component.set("v.paymentTypes", res.paymentTypes)
                    component.set("v.shippingAddress", res.shipping);
                    component.set("v.totalAmount", Number(res.totalAmount).toFixed(2));
                    component.set("v.isLoggedInUser", res.isLoggedInUser);
                    component.set("v.clientToken", res.token);
                    //By Faraz for 5329 on 29/06/2022 - start
                    if (res.DeliveryType == 'Install At Dealer') {
                        component.set("v.installAtDealer", true);
                    }
                    //By Faraz for 5329 on 29/06/2022 - End

                    if (res.isLoggedInUser == false) {
                        component.set("v.isGuestUser", true);
                    } else {
                        if (res.myPayments != 'No record found') {
                            let myPayments = JSON.parse(res.myPayments);
                            myPayments.forEach(item => {
                                if (item.Type__c == 'Credit Card - Visa') {
                                    item.type = 'Visa';
                                } else if (item.Type__c == 'Credit Card - Mastercard') {
                                    item.type = 'Mastercard';
                                } else if (item.Type__c == 'Credit Card - Amex') {
                                    item.type = 'Amex';
                                } else if (item.Type__c == 'Credit Card - Discover') {
                                    item.type = 'Discover';
                                }
                                if (item.Default_Payment_Method__c == true) {
                                    component.set("v.paymentId", item.Id);
                                }
                                if(item.CC_Expiration_Month__c < 10){
                                    item.CC_Expiration_Month__c = '0'+item.CC_Expiration_Month__c;
                                }
                                item.dateNotExpired = isFutureDate(item.CC_Expiration_Year__c, new Date(),item.CC_Expiration_Month__c);
                            });
                            let excludeExpiredCards = myPayments.filter(item => {
                                return item.dateNotExpired;
                            })
                            myPayments = excludeExpiredCards;
                            if (component.get("v.paymentId") == '') {
                                //myPayments[0].Default_Payment_Method__c = true;
                                component.set("v.paymentId", myPayments[0].Id);
                            }
                            component.set("v.defaultPaymentId", component.get("v.paymentId"));
                            console.log('myPayments : ', myPayments);
                            component.set("v.myPayments", myPayments);
                        }
                        if (res.myAddresses != 'No record found') {
                            let myAddresses = JSON.parse(res.myAddresses);
                            if(res.myAddressesMG && res.myAddressesMG.My_Account_Address){
                                let myAddressMG = JSON.parse(res.myAddressesMG.My_Account_Address);
                                console.log('$BFH: myAddressMG1: ',myAddressMG);
                                if(myAddressMG && myAddressMG[0]){
                                    myAddressMG = myAddressMG[0];
                                    console.log('$BFH: myAddressMG2: ',myAddressMG);
                                    let statesMap = new Map(Object.entries({"alabama": "AL", "alaska": "AK", "american samoa": "AS", "arizona": "AZ", "arkansas": "AR", "california": "CA", "colorado": "CO", "connecticut": "CT", "delaware": "DE", "district of columbia": "DC", "federated states of micronesia": "FM", "florida": "FL", "georgia": "GA", "guam": "GU", "hawaii": "HI", "idaho": "ID", "illinois": "IL", "indiana": "IN", "iowa": "IA", "kansas": "KS", "kentucky": "KY", "louisiana": "LA", "maine": "ME", "marshall islands": "MH", "maryland": "MD", "massachusetts": "MA", "michigan": "MI", "minnesota": "MN", "mississippi": "MS", "missouri": "MO", "montana": "MT", "nebraska": "NE", "nevada": "NV", "new hampshire": "NH", "new jersey": "NJ", "new mexico": "NM", "new york": "NY", "north carolina": "NC", "north dakota": "ND", "northern mariana islands": "MP", "ohio": "OH", "oklahoma": "OK", "oregon": "OR", "palau": "PW", "pennsylvania": "PA", "puerto rico": "PR", "rhode island": "RI", "south carolina": "SC", "south dakota": "SD", "tennessee": "TN", "texas": "TX", "utah": "UT", "vermont": "VT", "virgin islands": "VI", "virginia": "VA", "washington": "WA", "west virginia": "WV", "wisconsin": "WI", "wyoming": "WY"}));
                                    if(myAddressMG.Name && myAddressMG.PersonMailingStreet && myAddressMG.PersonMailingCity && myAddressMG.PersonMailingState && myAddressMG.PersonMailingPostalCode){
                                        let duplicate = myAddresses.find(element => {
                                            return (
                                                myAddressMG.PersonMailingStreet.toLocaleLowerCase() == element.Address__c.toLocaleLowerCase() &&
                                                myAddressMG.PersonMailingCity.toLocaleLowerCase() == element.City__c.toLocaleLowerCase() &&
                                                statesMap.get(myAddressMG.PersonMailingState.toLocaleLowerCase()) == element.State__c
                                                )
                                            });
                                        console.log('$BFH: duplicate: ',duplicate);
                                        if(!duplicate){
                                        myAddresses.push({
                                            Id: myAddressMG.Id,
                                            Name: myAddressMG.Name,
                                            NickName__c: myAddressMG.Name,
                                            isPreferred__c: false,
                                            Address__c: myAddressMG.PersonMailingStreet,
                                            City__c: myAddressMG.PersonMailingCity,
                                            Phone__c: null,
                                            Notes__c: null,
                                            State__c: statesMap.get(myAddressMG.PersonMailingState.toLocaleLowerCase()),
                                            Country__c: "United States",
                                            Zip__c: myAddressMG.PersonMailingPostalCode,
                                            Person_Address_Account__c: myAddressMG.Id,
                                            AccountAddress: true
                                        });
                                        }
                                    }
                                }
                            }

                            console.log('$BFH: myAddresses: ',myAddresses);
                            myAddresses.forEach(item => {
                                item.selected = false;
                            });
                            myAddresses[0].selected = true;
                            component.set("v.addressId", myAddresses[0].Id);
                            component.set("v.myAddresses", myAddresses);
                            console.log('myAddresses : ', myAddresses);
                        }
                        if (res.customerId != '') {
                            component.set("v.customerId", res.customerId);
                        }
                        //console.log('res.customerId : ',res.customerId);
                        component.set("v.creditCardChecked", true);
                        component.set("v.paypalChecked", false);
                        component.set("v.paypalButtonStyle", "display:none;");
                        component.set("v.creditCardStyle", "display:none;");
                    }
                    //Have to check as String value due to Boolean value getting removed from response
                    if (res.shipping.dealerPickup && res.shipping.dealerPickup != 'true') {
                        component.set("v.dealerPickup", false);
                    }

                    this.setupHostedFields(component, res.token, self, res.tokenPayPal);

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
                } else {
                    component.set("v.showSpinner", false);
                    if (res.error) {
                        this.handleErrorMessage(component, res.error);
                    }
                }
            } else {
                component.set("v.showSpinner", false);
                this.handleErrorMessage(component, "Error occurred");
            }
        });
    },
    setupHostedFields: function(component, clientToken, self, paypalToken) {

        // for credit card
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
                    /*
                    cardholderName: {
                        selector: '#cc-name'
                    },
                    */
                    //Added by faraz on 20April22 for HDMP-8728 for Mask CC number/CVV & expiration date in MM/YY
                    number: {
                        selector: '#cc-number',
                        placeholder: 'xxxx xxxx xxxx xxxx',
                        maskInput: true
                    },
                    cvv: {
                        selector: '#cc-cvv',
                        placeholder: 'xxx',
                        maskInput: true,
                        //type: 'password'
                    },
                    expirationDate: {
                        selector: '#cc-expiration',
                        placeholder: 'MM/YY OR MM/YYYY'
                    }
                    //End here HDMP-8728
                }
            }, function(hostedFieldsErr, hostedFieldsInstance) {
                component.set("v.hostedFieldsInstance", hostedFieldsInstance);
                component.set("v.showSpinner", false);

                if (err) {
                    console.error(err);
                    return;
                }

                function createInputChangeEventListener(element) {
                    return function() {
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

                function validateEmail() {
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

                ccName.on('change', function() {
                    validateInput(ccName);
                });
                email.on('change', validateEmail);

                hostedFieldsInstance.getSupportedCardTypes().then(function(cardTypes) {
                    var objCardTypes = {};
                    cardTypes.forEach(item => {
                        if (item == 'Mastercard') {
                            objCardTypes['master'] = true;
                        } else if (item == 'Visa') {
                            objCardTypes['visa'] = true;
                        } else if (item == 'Discover') {
                            objCardTypes['discover'] = true;
                        } else if (item == 'American Express') {
                            objCardTypes['amex'] = true;
                        }
                    })
                    console.log('cardTypes : ', cardTypes);
                    component.set("v.cardTypes", objCardTypes)
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
                    console.log('event : ', event);
                    if (event.cards.length === 1) {
                        var card = event.cards[0];
                        console.log('card : ', card);
                        // change pay button to specify the type of card
                        // being used
                        cardBrand.text(card.niceType);
                        // update the security code label
                        cvvLabel.text(card.code.name);
                    } else {
                        // reset to defaults
                        cardBrand.text('Card');
                        cvvLabel.text('CVV');
                        console.log('card : ', cardBrand);
                    }
                });
            });
        });

        // for PayPal
        braintree.client.create({
            authorization: paypalToken
        }, function(err, clientInstance) {
            if (err) {
                return;
            }
            // Create a PayPal Checkout component.
            console.log('in set time out', clientInstance);
            braintree.paypalCheckout.create({
                client: clientInstance
            }, function(paypalCheckoutErr, paypalCheckoutInstance) {
                if (paypalCheckoutErr) {
                    component.set("v.isPayPalAccepted", false);
                    console.error('Error creating PayPal Checkout:', paypalCheckoutErr);
                    return;
                }
                component.set("v.isPayPalAccepted", true);
                // load the sdk by paypal instance
                // vault flow
                paypalCheckoutInstance.loadPayPalSDK({
                    //vault: true,
                    currency: 'USD',
                    intent: 'authorize'
                }, function() {
                    paypal.Buttons({
                        style: {
                            label: 'pay'
                        },
                        fundingSource: paypal.FUNDING.PAYPAL,

                        createOrder: function() {
                            return paypalCheckoutInstance.createPayment({
                                flow: 'checkout',
                                amount: component.get("v.totalAmount"),
                                currency: 'USD',
                                intent: 'authorize',
                                enableShippingAddress: false,
                                shippingAddressEditable: false,
                                enableBillingAddress: true, // for billing address
                                displayName: 'DreamShop'
                            });
                        },

                        onApprove: function(data, actions) {
                            return paypalCheckoutInstance.tokenizePayment(data, function(err, payload) {
                                if (err) {
                                    console.log('err : ', err);
                                    component.set("v.paypalErrorMessage", 'An error occured processing the PayPal payment.Please try again or select another payment method.');
                                } else {
                                    console.log('payload.nonce  : ', payload);
                                    console.log('data  : ', data);
                                    component.set("v.showSpinner", true);

                                    // Submit `payload.nonce` to your server 
                                    // get the billing address from PayPal account
                                    var customerData = {
                                        'name': payload.details.firstName + ' ' + payload.details.lastName,
                                        'address1': payload.details.billingAddress ? payload.details.billingAddress.line1 : '',
                                        'address2': payload.details.billingAddress ? payload.details.billingAddress.line2 : '',
                                        'city': payload.details.billingAddress ? payload.details.billingAddress.city : '',
                                        'state': payload.details.billingAddress ? payload.details.billingAddress.state : '',
                                        'zipCode': payload.details.billingAddress ? payload.details.billingAddress.postalCode : '',
                                        'phone': payload.details.phone ? payload.details.phone.replaceAll('-', '') : '',
                                        'email': payload.details.email,
                                        'country': payload.details.billingAddress ? payload.details.billingAddress.country : 'United states',
                                    };
                                    var customerId = self.component.get("v.customerId");
                                    if (customerId && customerId != '') {
                                        customerData['customerId'] = customerId;
                                    }
                                    console.log('customerData : ', customerData);
                                    self.submitPayment(self.component, payload.nonce, customerData, 'PayPal');
                                }
                            });

                        },

                        onCancel: function(data) {
                            console.log('PayPal payment canceled', JSON.stringify(data, 0, 2));
                        },

                        onError: function(err) {
                            console.error('PayPal error', err);
                            component.set("v.paypalErrorMessage", 'An error occured processing the PayPal payment.Please try again or select another payment method.');
                        }
                    }).render('#paypal-button').then(function() {
                        // The PayPal button will be rendered in an html element with the ID
                        // `paypal-button`. This function will be called when the PayPal button
                        // is set up and ready to be used
                    });

                });

            });
        });
    },

    //Performs a validation on the Form before tokenizing and calling out to Braintree
    validateForm: function(component, event) {
        component.set("v.showSpinner", true);

        const fieldsToCorrect = [];
        let isValid = true;

        const inputFields = component.find("inputField");

        if (inputFields) {
            for (let i = 0; i < inputFields.length; i++) {
                let currInput = inputFields[i];

                //Only validate required fields
                if (currInput.get("v.required") || currInput.get("v.name") == "Cardholder Name") {
                    let fieldName = currInput.get("v.name");
                    let fieldVal = currInput.get("v.value");

                    //Validation on existing inputs
                    if (fieldName == "Name" || fieldName == "Cardholder Name") {
                        //    /^[a-zA-Z ]*$/
                        if (!fieldVal || fieldVal.trim().length < 2/*  || !(/^[ A-Za-z0-9_@./','#&+-]*$/.test(fieldVal)) */) {
                            currInput.setCustomValidity("Invalid name, please enter a valid name.")
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if (fieldName == "Zipcode") {
                        if (fieldVal && (/^[0-9-]*$/.test(fieldVal)) && (fieldVal.length == 5 || fieldVal.length == 10)) {
                            if (fieldVal.includes("-") && (fieldVal.split("-").length != 2 || fieldVal.trim().length != 10 || fieldVal.indexOf("-") != 5)) {
                                currInput.setCustomValidity("Invalid zip code, please provide valid zip code.")
                                currInput.reportValidity();
                                fieldsToCorrect.push(fieldName);
                            }
                        } else {
                            currInput.setCustomValidity("Invalid zip code, please provide valid zip code.")
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if (fieldName == "Address 1") {
                        if (!fieldVal || fieldVal.trim().length < 3) {
                            currInput.setCustomValidity("Please enter a valid address.")
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if (fieldName == "City") {
                        if (!fieldVal || fieldVal.trim().length < 3 || !(/^[a-zA-Z ]*$/.test(fieldVal))) {
                            currInput.setCustomValidity("Please enter a valid address.");
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if (fieldName == "Phone") {
                        if (!fieldVal || fieldVal.trim().length != 10 || !(/^[0-9]*$/.test(fieldVal))) {
                            currInput.setCustomValidity("Please enter a valid phone number.")
                            currInput.reportValidity();
                            fieldsToCorrect.push(fieldName);
                        }
                    } else if (fieldName == "State") {
                        if (!fieldVal || fieldVal.trim() == "") {
                            currInput.set("v.value", undefined);
                            currInput.showHelpMessageIfInvalid();
                            fieldsToCorrect.push(currInput.get("v.name"));
                        }
                    } else {
                        if (!currInput.checkValidity()) {
                            isValid = false;

                            currInput.reportValidity();
                            fieldsToCorrect.push(currInput.get("v.name"));
                        }
                    }
                }
            }

            //If one or more fields are invalid, 
            if (fieldsToCorrect.length > 0) {
                //this.handleErrorMessage(component, "Please complete the following field(s): " + fieldsToCorrect.join(", "));
                this.handleErrorMessage(component, "Please review and check that all information is complete.");

                component.set("v.showSpinner", false);
            } else {
                this.handleSubmitPayment(component, event);
            }
        } else {
            component.set("v.showSpinner", false);
        }
    },
    handleSubmitPayment: function(component, event) {
        const dropin = component.get("v.hostedFieldsInstance");
        let self = this;
        self.component = component;


        if (dropin) {
            let onNewPaymentMethod = component.get("v.isShowBillingAddress");
            let onNewAddress = component.get("v.isShowNewAddress");
            var addressData;
            var customerData;
            if (onNewPaymentMethod == true && onNewAddress == false) {
                let data = this.getBillingAddressFromSaved(component);
                console.log('data : ', data);
                addressData = data.addressData;
                customerData = data.customerData;
            } else {
                addressData = this.getBillingAddressInfo(component);
                customerData = this.getCustomerData(component);
            }
            console.log('addressData : ', addressData);
            dropin.tokenize(addressData, function(tokenizeErr, payload) {
                if (tokenizeErr) {
                    console.log('tokenizeErr : ', tokenizeErr);
                    self.component.set("v.showSpinner", false);
                    //self.handleErrorMessage(self.component, "Some payment fields are invalid. Please review and verify the correct information is entered.");                                    
                    self.handleErrorMessage(self.component, "Some payment fields are invalid. Please review and verify that the correct information is entered.");
                    return;
                }

                var customerId = self.component.get("v.customerId");
                if (customerId && customerId != '') {
                    customerData['customerId'] = customerId;
                }

                if (component.get("v.isLoggedInUser") == true) {
                    customerData['isSaveNewPaymentMethod'] = component.get("v.isSaveNewPaymentMethod");
                    customerData['isMakePreferred'] = component.get("v.isMakePreferred");
                    customerData['addressId'] = component.get("v.addressId");
                }
                console.log('payload : ', payload);
                let saveNewAddress = component.get("v.isNewAddress");
                let isPreferredAddress = component.get("v.isPreferredAddress");
                customerData.newAddressData = onNewAddress && saveNewAddress;
                customerData.isPreferredAddress = isPreferredAddress;
                self.submitPayment(self.component, payload.nonce, customerData, 'Credit Card');
            });
        } else {
            component.set("v.showSpinner", false);
        }
    },

    //-- process payment for logged In user starts --//
    submitPaymentForLoggedInUser: function(component, event) {
        //TODO - add spinner to prevent form interaction while handling payment
        component.set("v.showSpinner", true);
        var myPayments = component.get("v.myPayments");
        var customerData;
        myPayments.forEach(item => {
            if (component.get("v.paymentId") == item.Id) {
                customerData = {
                    'name': item.Billing_Customer_Name__c,
                    'address1': item.Billing_Street__c,
                    'address2': item.Billing_Street_Line2__c,
                    'city': item.Billing_City__c,
                    'state': item.Billing_State__c,
                    'zipCode': item.Billing_PostalCode__c,
                    'phone': item.Billing_Phone__c,
                    'email': item.Customer__r.email,
                    'country': component.get("v.country")
                };
            }
        });
        console.log('customerData : ', customerData);
        var action = component.get("c.processPaymentForLoggedInUser");
        action.setCallback(this, this.submitPaymentLoogedInUser_Callback(component, event));
        action.setParams({
            paymentId: component.get("v.paymentId"),
            cartId: component.get("v.cartId"),
            orderId: component.get("v.orderId"),
            customerData: customerData
        });

        $A.getCallback(function() {
            $A.enqueueAction(action);
        })();
    },
    submitPaymentLoogedInUser_Callback: function(component, event) {
        return (function(a) {
            var state = a.getState();
            console.log('submitPayment_Callback : ', a);
            if (state === "SUCCESS") {
                let res = a.getReturnValue();
                console.log('submitPayment_Callback res : ', res);
                if (res && res.success) {
                    //Move the flow forward if the response is successfully
                    var navigate = component.get("v.navigateFlow");
                    navigate("NEXT");
                } else {
                    component.set("v.showSpinner", false);
                    var errorMessage = '';
                    errorMessage = 'We’re sorry, we could not process this transaction. Please check your information and resubmit. Your credit card was not charged.';
                    this.handleErrorMessage(component, errorMessage);
                }
            } else {
                component.set("v.showSpinner", false);
                var errorMessage = '';
                errorMessage = 'We’re sorry, we could not process this transaction. Please check your information and resubmit. Your credit card was not charged.';
                this.handleErrorMessage(component, errorMessage);
            }
        });
    },
    //-- process payment for logged In user ends --//

    //-- process payment for guest user starts --//
    submitPayment: function(component, nonce, customerData, paymentType) {
        //TODO - add spinner to prevent form interaction while handling payment
        var action = component.get("c.processPayment");
        action.setCallback(this, this.submitPayment_Callback(component, event, paymentType));
        action.setParams({
            nonce: nonce,
            customerData: customerData,
            cartId: component.get("v.cartId"),
            orderId: component.get("v.orderId"),
            paymentType: paymentType
        });

        $A.getCallback(function() {
            $A.enqueueAction(action);
        })();
    },
    submitPayment_Callback: function(component, event, paymentType) {
        return (function(a) {
            var state = a.getState();
            console.log('submitPayment_Callback : ', a);
            if (state === "SUCCESS") {
                let res = a.getReturnValue();
                console.log('submitPayment_Callback res : ', res);
                if (res && res.success) {
                    //Move the flow forward if the response is successfully
                    var navigate = component.get("v.navigateFlow");
                    navigate("NEXT");
                } else {
                    component.set("v.showSpinner", false);
                    if (paymentType == 'PayPal') {
                        component.set("v.paypalErrorMessage", 'An error occured processing the PayPal payment.Please try again or select another payment method.');
                    }
                    var errorMessage = '';
                    if (res.errorReason && res.errorReason == 'AVS') {
                        errorMessage = 'Some address fields are invalid. Please review and verify that the correct information is entered.';
                    } else if (res.errorReason && (res.errorReason == 'CVV' || res.errorReason == 'AVS_AND_CVV')) {
                        errorMessage = 'Some payment fields are invalid. Please review and verify that the correct information is entered.';
                    } else if (res.errorReason && res.errorReason == 'Duplicate Card') {
                        errorMessage = 'This payment method already exists in My Payment.';
                    }

                    if (res.error && res.error.includes('Credit card type is not accepted by this merchant account')) {
                        errorMessage = 'This card is not supported, please either use a Visa, Mastercard, American Express, or Discover for payment.';
                    } else if (errorMessage == '') {
                        if (paymentType == 'PayPal') {
                            errorMessage = 'We’re sorry, we could not process this transaction. Please check your information and resubmit. Your PayPal account was not charged.';
                        } else {
                            errorMessage = 'We’re sorry, we could not process this transaction. Please check your information and resubmit. Your credit card was not charged.';
                        }
                    }
                    this.handleErrorMessage(component, errorMessage);
                }
            } else {
                component.set("v.showSpinner", false);
            }
        });
    },
    //-- process payment for guest user starts --//

    //Displays an error message if present
    handleErrorMessage: function(component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error",
            "message": message,
            "type": "error"
        });
        toastEvent.fire();
    },

    getBillingAddressFromSaved: function(component) {
        var myAddresses = component.get("v.myAddresses");
        var addressData;
        var customerData;
        myAddresses.forEach(item => {
            if (component.get("v.addressId") == item.Id) {
                let nameParts = item.Name.split(' ');
                let firstName = nameParts[0];
                let lastName = '';

                if (nameParts.length > 1) {
                    nameParts.shift();
                    lastName = nameParts.join(' ');
                }
                addressData = {
                    'cardholderName': component.get("v.cardholderName"),
                    'billingAddress': {
                        'firstName': firstName,
                        'lastName': lastName,
                        'streetAddress': item.Address__c,
                        'extendedAddress': '',
                        'locality': item.City__c,
                        'region': item.State__c,
                        'postalCode': item.Zip__c,
                        'countryName': component.get("v.country")
                    }
                };

                customerData = {
                    'name': item.Name,
                    'address1': item.Address__c,
                    'address2': '',
                    'city': item.City__c,
                    'state': item.State__c,
                    'zipCode': item.Zip__c,
                    'phone': item.Phone__c,
                    'email': item.Email__c,
                    'country': component.get("v.country")
                };
            }
        });

        return { addressData: addressData, customerData: customerData };
    },
    //Returns an object containing the User's Billing Address Information
    getBillingAddressInfo: function(component) {
        let fullName = component.get("v.name");
        let nameParts = fullName.split(' ');

        let firstName = nameParts[0];
        let lastName = '';

        if (nameParts.length > 1) {
            nameParts.shift();
            lastName = nameParts.join(' ');
        }

        //TODO - Country name will need to be moved to a Variable once more countries are available
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
    },
    //Returns an object containg the Customer's Information
    getCustomerData: function(component) {
        return {
            'name': component.get("v.name"),
            'address1': component.get("v.address1"),
            'address2': component.get("v.address2"),
            'city': component.get("v.city"),
            'state': component.get("v.state"),
            'zipCode': component.get("v.zipCode"),
            'phone': component.get("v.phoneNumber"),
            'email': component.get("v.email"),
            'country': component.get("v.country")
        };
    },

    //Sets (or clears) the Billing Information to be similar to the Shipping Information
    handleSameAsShipping: function(component, event) {
        component.set("v.sameAsShipping", event.getSource().get("v.checked"));

        if (event.getSource().get("v.checked")) {
            const shippingAddress = component.get("v.shippingAddress");

            if (shippingAddress) {
                if (shippingAddress.address) {
                    component.set("v.address1", shippingAddress.address);
                }
                if (shippingAddress.city) {
                    component.set("v.city", shippingAddress.city);
                }
                if (shippingAddress.state) {
                    component.set("v.state", shippingAddress.state);
                }
                //TODO - Country needs to be dynamic once more countries are supported
                if (shippingAddress.country) {
                    component.set("v.country", "United States");
                }
                if (shippingAddress.zipcode) {
                    component.set("v.zipCode", shippingAddress.zipcode);
                }

                component.set("v.sameAsShipping", true);
            }
        } else {
            //TODO - Country needs to be dynamic once more countries are supported
            component.set("v.sameAsShipping", false);
            component.set("v.address1", undefined);
            component.set("v.city", undefined);
            component.set("v.state", undefined);
            component.set("v.country", "United States");
            component.set("v.zipCode", undefined);
        }
    },

    //validates the entry of the Name
    handleToAllowName: function(event) {
        let charCode = (event.which) ? event.which : event.keyCode;

        if (!((charCode >= 91 && charCode <= 126) || (charCode >= 32 && charCode <= 47) || (charCode >= 58 && charCode <= 90) || (charCode == 32))) {
            // event.preventDefault();
            return true;
        }

        return true;
    },

    //Validates the entry of the Phone Number
    handleToAllowPhone: function(event) {
        let charCode = (event.which) ? event.which : event.keyCode;

        if (!((charCode >= 48 && charCode <= 57))) {
            event.preventDefault();
            return false;
        }

        return true;
    },

    //Validates the entry of the Zipcode
    handleToAllowZipcode: function(event) {
        let charCode = (event.which) ? event.which : event.keyCode;

        if (!((charCode >= 48 && charCode <= 57) || (charCode == 45))) {
            event.preventDefault();
            return false;
        }

        return true;
    }
})