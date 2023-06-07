/**
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 03-30-2022
 * @last modified by  : mbunch@gorillagroup.com
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 03-30-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
({
    //Initialize Page (1)
	doInit : function(component, event) {
        let thisUrl = new URL( window.location.href ) ;
        try {
        let s = thisUrl.pathname.substring(0, thisUrl.pathname.indexOf('/s/')+3) + 'personal-information' ;
        }
        catch (e){
            console.log(e);
        }
        component.set('v.backToPersonalInfo', thisUrl.pathname.substring(0, thisUrl.pathname.indexOf('/s/')+3) + 'personal-information' ) ;
        window.document.title = 'Payment Details' ;
        component.set("v.showSpinner", true);
        //calls the setupForm Function (2)
		this.setupForm(component, event);
        let meta = document.createElement("meta");
        meta.name = "keywords";
        meta.content = "Payment Details"
        document.getElementsByTagName('head')[0].appendChild(meta);


        try {
        }
        catch(e)
        {

        }
	},
    //called form doInit (3)
    setupForm : function(component, event) {
        var action = component.get("c.hostedFormSetup");

        //callback to Controller (4)
        //Apex Class: RES_CreditCardController
        //Apex Class Function: hostedFormSetup Line ~21
        //invokes function setupForm_Callback (5) to handle returned values
        action.setCallback(this, this.setupForm_Callback(component, event));
        action.setParams({
            //sends cart Id as Parameter to Apex function
            cartId : component.get("v.cartId")
        });
        //first callback on Init
        $A.enqueueAction(action);
    },
    //Handles return values from call to hostedFormSetup(6)
    setupForm_Callback : function(component, event) {
        return (function(a){
            if (a.getState() === "SUCCESS") {
                let res = a.getReturnValue();
                //if the return is successfull add the state codes
                //and payment types to the page fields
                if(res && res.success) {
                    component.set("v.stateCodes", res.codes);
                    component.set("v.paymentTypes", res.paymentTypes)


                    //Have to check as String value due to Boolean value getting removed from response

                    this.getTaggingFields(component, res.token);
                } else {
                    component.set("v.showSpinner", false);

                    if(res.error) {
                        this.handleErrorMessage(component, res.error);
                    }
                }
            } else {
                component.set("v.showSpinner", false);
                alert('error');
                this.handleErrorMessage(component, "Error occurred");
            }
        });
    },
    //(8) function to callback to Apex
    //Apex Class: RES_CreditCardController
    //Apex Function: getTaggingFields
    getTaggingFields : function(component,token){
        var action = component.get("c.getTaggingFields");
        //(9) return handled in funciton getTaggingFields_Callback
        action.setCallback(this, this.getTaggingFields_Callback(component, token));
        action.setParams({
            cartId : component.get("v.cartId")
        });
        //second callback on Init
        $A.enqueueAction(action);
    },
    //(10) handles return values from getTaggingFields
    //Apex function: getTaggingFields
    getTaggingFields_Callback : function(component, token){
        return (function(a){
            if (a.getState() === "SUCCESS") {
                let res = a.getReturnValue();
                //if success add values to modelName
                if(res ) {
                    component.set("v.modelName",res.modelName);
                    component.set("v.modelYear",res.modelYear);
                    component.set("v.bodyStyle",res.bodyStyle);
                    component.set("v.depositAmount",res.depositAmount);
                    component.set("v.vehicleModelSeries", res.vehicleModelSeries)

                    var payload = { modelName : res.modelName , modelYear : res.modelYear , bodyStyle : res.bodyStyle  };
                    component.find('tagParameterUpdate').publish(payload);
                    //(11) invoke function setupHostedFields
                    this.setupHostedFields(component, token);
                    let pageLoadData = {
                        modelName: component.get("v.modelName"),
                        modelYear: component.get("v.modelYear"),
                        bodyStyle: component.get("v.bodyStyle"),
                    }
                    this.pageLoad(pageLoadData)
                } else {
                    component.set("v.showSpinner", false);

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
    //(12) setup Braintree credit card fields:
    setupHostedFields : function(component, clientToken) {
        braintree.client.create({
            authorization: clientToken
        }, function(err, clientInstance) {
            if (err) {
                console.log('error creating client' + err) ;
                return;
            }
            console.log(clientInstance) ;
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
                        placeholder: 'MM/YY'
                    }
                }
            }, function (hostedFieldsErr, hostedFieldsInstance) {
                component.set("v.hostedFieldsInstance", hostedFieldsInstance);
                component.set("v.showSpinner", false);

                if (hostedFieldsErr) {
                    console.error(errhostedFieldsErr);
                    return;
                }

                function createInputChangeEventListener(element) {
                    return function () {
                        validateInput(element);
                    }
                }
                //this sets the validity of the element
                function setValidityClasses(element, validity) {
                    if (validity) {
                        element.removeClass('is-invalid');
                        element.addClass('is-valid');
                    } else {
                        element.addClass('is-invalid');
                        element.removeClass('is-valid');
                    }
                }

                //this function is the basic function
                //it trims the value which if blank
                //will make it empty making it invalid
                function validateInput(element) {
                    //here is the trim
                    if (!element.val().trim()) {
                        setValidityClasses(element, false);

                        return false;
                    }
                    //this is the larger check of the
                    //field values used below
                    setValidityClasses(element, true);

                    return true;
                }
                //check email validity
                function validateEmail () {
                    //check if blank
                    var baseValidity = validateInput(email);

                    //in not blank
                    if (!baseValidity) {
                        return false;
                    }
                    //check if it has an @ symbol
                    if (email.val().indexOf('@') === -1) {
                        setValidityClasses(email, false);
                        return false;
                    }
                    //check if email has a .
                    if(email.val().indexOf('.') === -1 ) {
                        setValidityClasses(email, false);
                        return false;
                    }
                    setValidityClasses(email, true);
                    return true;
                }

                var ccName = $('#cc-name');
                var email = $('#email');


                email.on('change', validateEmail);

              	/*added for braintree empty field validation - start*/
                hostedFieldsInstance.on('blur', function (event) {

                    var currfield = event.fields[event.emittedBy];

                    if (!currfield.isEmpty) {
                        $(currfield.container).removeClass('is-invalid');
                        $(currfield.container).next('div').remove();
                    } else {
                        // Remove any previously applied error classes
                        $(currfield.container).removeClass('is-valid');
                        $(currfield.container).removeClass('is-invalid');
                        $(currfield.container).addClass('is-invalid');
                        if ($(currfield.container).next('div').attr('class') !== 'brainErrMsg'){
                            $(currfield.container).after("<div class='brainErrMsg' style='color:red;font-size: 0.75rem;display:block;'>Complete this field.</div>");
                        }
                    }
                });
                /*added for braintree empty field validation - end*/

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

                if ( component.get('v.error') === 'true' )
                {
                    this.handleErrorMessage(component, 'We’re sorry, we could not process this transaction. Please check your information and resubmit. Your credit card was not charged.');
                }

            });
        });
    },

    checkIfCapReached: function (component, event) {
        let hasReachedCap = false;
        const action = component.get("c.hasReachedCap");
        action.setParams({
            cartId: component.get("v.cartId")
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state == 'SUCCESS') {
                hasReachedCap = response.getReturnValue();
                if (hasReachedCap) {
                    component.set("v.errorHeaderMessage", 'Reservations Full');
                    this.handleErrorMessage(component, 'We’re sorry, the reservation limit has already been reached. You will now be redirected to join the waitlist.');
                    const data = sessionStorage.getItem('data');
                    const currentUrl = new URL(window.location.href);
                    let redirectUrl;
                    try {
                        redirectUrl = currentUrl.pathname.substring(0, currentUrl.pathname.indexOf('/s/')+3) + `personal-information?data=${data}`;
                        setTimeout(() => window.location.href = redirectUrl, 8000);
                    } catch (e){
                        console.error("Reservation full -> redirect to waitlist", e);
                        setTimeout(() => window.location.href = 'https://acura.com', 8000);
                    }
                } else {
                    this.validateForm(component, event);
                }
            }
        });
        $A.enqueueAction(action);
        return hasReachedCap;
    },

    //Performs a validation on the Form before tokenizing and calling out to Braintree
    validateForm : function(component, event) {
        component.set("v.showSpinner", true);
        const fieldsToCorrect = [];
        let isValid = true;

        const dropin = component.get("v.hostedFieldsInstance");

        let hostedState = dropin.getState();

        if ( hostedState.fields.number.isEmpty || ! hostedState.fields.number.isValid )
        {
            this.handleErrorMessage(component, 'Please enter a valid card number') ;

            return ;
        }

        if ( hostedState.fields.expirationDate.isEmpty || ! hostedState.fields.expirationDate.isValid )
        {
            this.handleErrorMessage(component, 'Please enter a valid expiration date') ;

            return ;
        }

        if ( hostedState.fields.cvv.isEmpty || ! hostedState.fields.cvv.isValid )
        {
            this.handleErrorMessage(component,'Please enter a valid cvv number') ;

            return ;
        }

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

                        if(!fieldVal || fieldVal.trim().length < 2 || !(/^[ A-Za-z0-9_@./','#&+-]*$/.test(fieldVal))) {
                            currInput.setCustomValidity("Invalid name, please enter a valid name.")
                            currInput.reportValidity();
                            this.handleErrorMessage(component,'Please enter a valid card holder name') ;

                            return ;                                        }
                    } else if(fieldName == "Zipcode") {
                        if(fieldVal && (/^[0-9-]*$/.test(fieldVal)) && (fieldVal.length == 5 || fieldVal.length == 10)) {
                            if(fieldVal.includes("-") && (fieldVal.split("-").length != 2 || fieldVal.trim().length != 10 || fieldVal.indexOf("-") != 5)) {
                                currInput.setCustomValidity("Invalid zip code, please provide valid zip code.")
                                currInput.reportValidity();
                                this.handleErrorMessage(component,'Please enter a valid zip code') ;

                                return ;
                            }
                        } else {
                            currInput.setCustomValidity("Invalid zip code, please provide valid zip code.")
                            currInput.reportValidity();
                            this.handleErrorMessage(component,'Please enter a valid zip code') ;

                            return ;
                        }
                    } else if(fieldName == "Address 1") {
                        if(!fieldVal || fieldVal.trim().length < 3) {
                            currInput.setCustomValidity("Please enter a valid address.")
                            currInput.reportValidity();
                            this.handleErrorMessage(component,'Please enter a valid address') ;

                            return ;
                        }
                    } else if(fieldName == "City") {
                        if(!fieldVal || fieldVal.trim().length < 3 || !(/^[a-zA-Z ]*$/.test(fieldVal))) {
                            currInput.setCustomValidity("Please enter a valid address.");
                            currInput.reportValidity();
                            this.handleErrorMessage(component,'Please enter a valid city') ;

                            return ;
                        }
                    } else if(fieldName == "State") {
                        if(!fieldVal || fieldVal.trim() == "") {
                            currInput.set("v.value", undefined);
                            currInput.showHelpMessageIfInvalid();
                            this.handleErrorMessage(component,'Please enter a valid state') ;

                            return ;
                        }
                    } else {
                        if(!currInput.checkValidity()) {
                            isValid = false;

                            currInput.reportValidity();
                            this.handleErrorMessage(component,'Please enter a valid ' + fieldName) ;

                            return ;
                        }
                    }
                }
            }

            //If one or more fields are invalid,
            if(fieldsToCorrect.length > 0) {

                this.handleErrorMessage(component, "Please review and check that all information is complete.");

                component.set("v.showSpinner", false);
            } else {
                this.handleSubmitPayment(component, event);
            }
        } else {
            component.set("v.showSpinner", false);
        }
    },

    interceptTokenizationRequest :function(event)
    {
        if ( event.data.startsWith("/*framebus*/"))
        {
            event.data = event.data.substring(12) ;

            self.postMessage(event) ;
            event.stopPropagation() ;
        }
    },

    handleSubmitPayment : function(component, event) {
        const dropin = component.get("v.hostedFieldsInstance");
        let self = this;
        self.component = component;

        try {
            this.clickEvent()
        }
        catch(e){

        }

        if(dropin) {
            const addressData = this.getBillingAddressInfo(component);



            component.addEventHandler("hosted-fields:TOKENIZATION_REQUEST", this.interceptTokenizationRequest) ;



            dropin.tokenize( addressData ,  function(err,payload) {
                if ( err )
                {

                    self.component.set("v.showSpinner",false) ;
                    this.handleErrorMessage(component,"Unable to process transaction") ;
                    return ;
                }
                console.log(payload)           ;
                const customerData = self.getCustomerData(self.component);
                self.submitPayment(self.component, payload.nonce, customerData);
            }) ;
        }
        else {

            component.set("v.showSpinner", false);
        }
    },
    submitPayment : function(component, nonce, customerData) {
        //TODO - add spinner to prevent form interaction while handling payment
        var action = component.get("c.processPayment");
        //added spinner
        component.set("v.showSpinner", true);
        action.setCallback(this, this.submitPayment_Callback(component, event));
        action.setParams({
            nonce : nonce,
            customerData : customerData,
            cartId : component.get("v.cartId"),
            orderId : component.get("v.orderId")
        });

        $A.getCallback(function() {
            $A.enqueueAction(action);
        })();

    },
    submitPayment_Callback : function(component, event) {
        return (function(a){

            var state = a.getState();

            if (state === "SUCCESS") {
                let res = a.getReturnValue();
                component.set("v.showSpinner", false);
                if(res && res.success) {
                    //Move the flow forward if the response is successfully
                    if ( res.authorizationId )
                    {
                        component.set("v.authCode",res.authorizationId)  ;
                    }
                    var navigate = component.get("v.navigateFlow");

                    navigate("NEXT");
                } else {
                    component.set("v.showSpinner", false);


                    var errorMessage = 'We’re sorry, we could not process this transaction. Please check your information and resubmit. Your credit card was not charged.';

                    this.handleErrorMessage(component, errorMessage);

                }
            } else {
                component.set("v.showSpinner", false);
            }
        });
    },

    //Displays an error message if present
    handleErrorMessage : function(component, message) {
        component.set("v.showSpinner",false);
        console.error('err - payment:' + message) ;
        if (message) {
            component.set("v.errorMessage", message);
        } else {
            component.set("v.errorMessage", 'There was an error processing your payment information. Please review your payment details and try again') ;
        }
        component.set("v.isModalOpen", true);
    },

    //Returns an object containing the User's Billing Address Information
    getBillingAddressInfo : function(component) {
        let fullName = component.get("v.cardholderName");
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
            'email' : component.get("v.email"),
            'country' : component.get("v.country")
        };
    },

    //Sets (or clears) the Billing Information to be similar to the Shipping Information


    //validates the entry of the Name
    handleToAllowName : function(event) {
        let charCode = (event.which) ? event.which : event.keyCode;

        if (!((charCode >= 91 && charCode <= 126) || (charCode >= 32 && charCode <= 47) ||(charCode >= 58 && charCode <= 90)|| (charCode == 32))) {
            event.preventDefault();
            return false;
        }

        return true;
    },

    //Validates the entry of the Zipcode
    handleToAllowZipcode : function(event) {
        let charCode = (event.which) ? event.which : event.keyCode;

        if (!((charCode >= 48 && charCode <= 57) || (charCode == 45))) {
            event.preventDefault();
            return false;
        }

        return true;
    } ,


    pageLoad: function(pageLoadData){
        let Acr
        if ( window.Acr ){
            Acr = window.Acr
        } else {
            window.Acr = {}
            Acr = window.Acr
        };
        const { modelName, modelYear, bodyStyle } = pageLoadData;

        const dataLayer = {
            Model: {
                model_brand: 'acura',
                model_name: modelName,
                model_year: modelYear,
                body_style: bodyStyle,
            },
            Page: {
                brand_name: 'Acura',
                full_url: window.location.href,
                page_name: 'Payment Details',
                page_friendly_url:
                document.querySelector("link[rel='canonical']") ? document.querySelector("link[rel='canonical']").getAttribute('href') : '',
                referrer_type: document.referrer || 'typed/bookmark',
                internal_referrer: document.referrer.includes('acura') ? document.referrer : '',
                referrer_url: document.referrer.includes('acura') ? '' : document.referrer,
                site_display_format: window.innerWidth < 550 ? 'mobile' : window.innerWidth < 1024 ? 'tablet' : 'desktop',
                site_language_code: document.getElementsByTagName('html')[0].getAttribute('lang').slice(0,2) || 'en',
                sub_section: 'reserve',
                sub_section2: 'payment details',
            }
        };

        Acr.dataLayer = Object.assign({},dataLayer ) ;
        window._satellite.track('page-load');
      },

    clickEvent: function(){
        let Acr
        if (window.Acr) {
            Acr = window.Acr
        }
        else {
            window.Acr = {}
            Acr = window.Acr
        };

        const dataLayer = Object.assign({},Acr.dataLayer) ;
        dataLayer.EventMetadata = {
            action_label: 'payment details:Complete Payment',
            action_category: 'payment details',
            action_type: 'cta'} ;


        Acr.dataLayer = Object.assign({},dataLayer) ;
        window._satellite.track('click-event');
    },

    showTAndC: function(cmp){
    let navService = cmp.find("navService");
        const pageReference = { type: 'comm__namedPage', attributes: { name: 'Terms_and_Conditions__c'} };
        navService.generateUrl(pageReference)
        .then( url => window.open(url,'_blank') ) ;
    }
})