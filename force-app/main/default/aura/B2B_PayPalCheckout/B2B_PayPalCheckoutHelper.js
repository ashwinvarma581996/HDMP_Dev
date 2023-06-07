({
    doInit: function (component, event) {
        this.setupForm(component, event);
    },
    setupForm: function (component, event) {
        var action = component.get("c.getClientToken");

        action.setCallback(this, this.setupForm_Callback(component, event));
        action.setParams({
            cartId: component.get("v.recordId")
        });
        $A.enqueueAction(action);
    },
    setupForm_Callback: function (component, event) {
        let self = this;
        self.component = component;
        component.set("v.this", self);
        return (function (a) {
            console.log('client token response  ', a);
            if (a.getState() === "SUCCESS") {
                let res = a.getReturnValue();

                if (res && res.success) {
                    console.log('res : ', res);
                    component.set("v.clientToken", res.tokenPayPal);
                    if (res.cart) {
                        component.set("v.total", res.cart.TOTAL__c);
                        component.set("v.dealerName", res.cart.DealerId__r.Name);
                        component.set("v.orderType", res.cart.Delivery_Type__c);
                    }

                    if (res.returnPolicy) {
                        component.set("v.dealerReturnPolicy", res.returnPolicy);
                    } else {
                        component.set("v.dealerReturnPolicy", 'Returns and Exchange policies are at the dealer’s discretion, please contact your dealer for more details');
                    }

                    if (res.tokenPayPal) {
                        this.setupHostedFields(component, res.tokenPayPal, self);
                    } else {
                        component.set("v.isPayPalActivated", false);
                        component.set("v.isApexCalled", false);
                        component.set("v.buttonDisabled", true);
                    }
                } else {
                    component.set("v.isApexCalled", false);
                    component.set("v.showSpinner", false);
                }
            } else {
                component.set("v.isApexCalled", false);
                component.set("v.showSpinner", false);
            }
        });
    },
    setupHostedFields: function (component, paypalToken, self) {
        // for PayPal
        braintree.client.create({
            authorization: paypalToken
        }, function (err, clientInstance) {
            if (err) {
                component.set("v.isApexCalled", false);
                console.log('err in braintree: ', err);
                return;
            }
            // Create a PayPal Checkout component.
            console.log('in set time out', clientInstance);
            braintree.paypalCheckout.create({
                client: clientInstance
            }, function (paypalCheckoutErr, paypalCheckoutInstance) {
                if (paypalCheckoutErr) {
                    component.set("v.isApexCalled", false);
                    component.set("v.isPayPalActivated", false);
                    console.error('Error creating PayPal Checkout:', paypalCheckoutErr);
                    return;
                }
                component.set("v.isPayPalActivated", true);
                component.set("v.isApexCalled", false);
                // load the sdk by paypal instance
                // vault flow
                paypalCheckoutInstance.loadPayPalSDK({
                    //vault: true,
                    currency: 'USD',
                    intent: 'authorize'
                }, function () {
                    paypal.Buttons({
                        style: {
                            label: 'checkout'
                        },
                        fundingSource: paypal.FUNDING.PAYPAL,

                        createOrder: function () {
                            self.buildDatalayer(component, self); //for adobe analytics
                            return paypalCheckoutInstance.createPayment({
                                flow: 'checkout',
                                amount: component.get("v.total"),
                                currency: 'USD',
                                intent: 'authorize',
                                enableShippingAddress: (component.get('v.orderType') == 'Ship to Me') ? true : false,
                                shippingAddressEditable: (component.get('v.orderType') == 'Ship to Me') ? true : false,
                                enableBillingAddress: true, // for billing address
                                displayName: component.get("v.dealerName")
                            });
                        },

                        onApprove: function (data, actions) {
                            return paypalCheckoutInstance.tokenizePayment(data, function (err, payload) {
                                if (err) {
                                    console.log('err : ', err);
                                    var errorMessage = 'We’re experiencing technical difficulties, please try again later';
                                    self.handleErrorMessage(component, errorMessage);
                                } else {
                                    console.log('payload.nonce  : ', payload);
                                    console.log('data  : ', data);
                                    self.component.set("v.showSpinner", true);

                                    // Submit `payload.nonce` to your server            
                                    self.updateCart(self.component, payload);
                                }
                            });

                        },

                        onCancel: function (data) {
                            console.log('PayPal payment canceled', JSON.stringify(data, 0, 2));
                        },

                        onError: function (err) {
                            console.error('PayPal error', err);
                        }
                    }).render('#paypal-button').then(function () {
                        // The PayPal button will be rendered in an html element with the ID
                        // `paypal-button`. This function will be called when the PayPal button
                        // is set up and ready to be used
                    });

                });

            });
        });
    },
    updateCart: function (component, payload) {
        //TODO - add spinner to prevent form interaction while handling payment
        var action = component.get("c.updateCart");
        action.setCallback(this, this.updateCart_Callback(component, payload));
        action.setParams({
            shippingAddress: JSON.stringify(payload.details.shippingAddress),
            shippingEmail: payload.details.email,
            customerPhone: payload.details.phone != null ? payload.details.phone.replaceAll('-', '') : '91717',
            cartId: component.get("v.recordId"),
            orderType: component.get("v.orderType")
        });

        $A.getCallback(function () {
            $A.enqueueAction(action);
        })();
    },

    updateCart_Callback: function (component, payload) {
        return (function (a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                let res = a.getReturnValue();
                console.log('update cart response 2: ', res);
                if (res && res == 'success') {
                    if (component.get("v.orderType") == 'Ship to Me') {
                        //call fedex api to get shipping charges
                        this.calculateShippingCharges(component, payload);
                    } else {
                        //call vertex api from apex 
                        this.submitPayment(component, payload);
                    }

                } else {
                    component.set("v.showSpinner", false);
                    component.set("v.paypalErrorMessage", 'An error occured processing the PayPal payment.Please try again or select another payment method.');
                    var errorMessage = 'We’re experiencing technical difficulties, please try again later';
                    this.handleErrorMessage(component, errorMessage);
                }
            } else {
                component.set("v.showSpinner", false);
                component.set("v.paypalErrorMessage", 'An error occured processing the PayPal payment.Please try again or select another payment method.');
                var errorMessage = 'We’re experiencing technical difficulties, please try again later';
                this.handleErrorMessage(component, errorMessage);
            }
        });
    },

    calculateShippingCharges: function (component, payload) {
        //TODO - add spinner to prevent form interaction while handling payment
        var action = component.get("c.calculateShippingCharges");
        action.setCallback(this, this.calculateShippingCharges_Callback(component, payload));
        action.setParams({
            cartId: component.get("v.recordId"),
        });

        $A.getCallback(function () {
            $A.enqueueAction(action);
        })();
    },

    calculateShippingCharges_Callback: function (component, payload) {
        return (function (a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                let res = a.getReturnValue();
                console.log('calculateShippingCharges: ', res);
                if (res == true) {
                    //call vertex api from apex 
                    this.submitPayment(component, payload);
                } else {
                    component.set("v.showSpinner", false);
                    component.set("v.paypalErrorMessage", 'An error occured processing the PayPal payment.Please try again or select another payment method.');
                    var errorMessage = 'We’re experiencing technical difficulties, please try again later';
                    this.handleErrorMessage(component, errorMessage);
                }
            } else {
                component.set("v.showSpinner", false);
                component.set("v.paypalErrorMessage", 'An error occured processing the PayPal payment.Please try again or select another payment method.');
                var errorMessage = 'We’re experiencing technical difficulties, please try again later';
                this.handleErrorMessage(component, errorMessage);
            }
        });
    },

    submitPayment: function (component, payload) {
        //TODO - add spinner to prevent form interaction while handling payment
        var action = component.get("c.calculateTaxes");
        action.setCallback(this, this.submitPayment_Callback(component, payload));
        action.setParams({
            cartId: component.get("v.recordId"),
        });

        $A.getCallback(function () {
            $A.enqueueAction(action);
        })();
    },

    submitPayment_Callback: function (component, payload) {
        return (function (a) {
            var state = a.getState();
            console.log('submitPayment_Callback : ', a);
            if (state === "SUCCESS") {
                let res = a.getReturnValue();
                console.log('submitPayment_Callback res : ', res);
                if (res && res.isSuccess) {
                    //window.location = '/s/paypalcheckout?Id=' + component.get("v.recordId"); 
                    component.find('cartCmp').savePayload(JSON.stringify(payload));
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/s/checkout/' + component.get("v.recordId")
                    });
                    urlEvent.fire();
                } else {
                    component.set("v.showSpinner", false);
                    component.set("v.paypalErrorMessage", 'An error occured processing the PayPal payment.Please try again or select another payment method.');
                    var errorMessage = 'We’re experiencing technical difficulties, please try again later';
                    this.handleErrorMessage(component, errorMessage);
                }
            } else {
                component.set("v.showSpinner", false);
                component.set("v.paypalErrorMessage", 'An error occured processing the PayPal payment.Please try again or select another payment method.');
                var errorMessage = 'We’re experiencing technical difficulties, please try again later';
                this.handleErrorMessage(component, errorMessage);
            }
        });
    },

    //Displays an error message if present
    handleErrorMessage: function (component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error",
            "message": message,
            "type": "error"
        });
        toastEvent.fire();
    },


    //for adobe analytics:starts

    buildDatalayer: function (component, self) {
        var dataLayer = window.dataLayer;
        dataLayer.EventMetadata.action_label = dataLayer.Page.page_name + ':button:paypal checkout';
        dataLayer.EventMetadata.action_type = 'Button';
        dataLayer.EventMetadata.action_category = 'cart';
        dataLayer.Events = 'scCheckout';
        delete dataLayer.Page.site_section;
        delete dataLayer.Page.sub_section;
        delete dataLayer.Page.sub_section2;
        dataLayer.Product = [];
        var cartId = component.get("v.recordId");
        var action = component.get("c.getCartItemList2");
        self.component = component;
        component.set("v.this", self);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                let cart = {};
                if (cartId) { cart = { cart_id: cartId }; }
                let items = [];
                let products = response.returnValue;
                products.forEach((element) => {
                    let ProductInfo = {};
                    if (element.Name) { ProductInfo.product_name = element.Name.replace(/[,;|]/g, '') }
                    if (element.Product2 && element.Product2.StockKeepingUnit) { ProductInfo.product_id = element.Product2.StockKeepingUnit }
                    if (element.Product_Model__r && element.Product_Model__r.Product_Subdivision__c) { ProductInfo.product_brand = element.Product_Model__r.Product_Subdivision__c }
                    if (element.Product_Model__r && element.Product_Model__r.Product_Model_ID__c) { ProductInfo.model_id = element.Product_Model__r.Product_Model_ID__c }
                    if (element.Product_Model__r && element.Product_Model__r.Model_Name__c) { ProductInfo.model_name = element.Product_Model__r.Model_Name__c }
                    if (element.Product_Model__r && element.Product_Model__r.Model_Year__c) { ProductInfo.model_year = element.Product_Model__r.Model_Year__c }
                    if (element.Product_Model__r && element.Product_Model__r.Trim__c) { ProductInfo.model_trim = element.Product_Model__r.Trim__c }
                    items.push({ ProductInfo: ProductInfo });
                })
                cart.item = items;
                dataLayer.Cart = cart;
            window.dataLayer = dataLayer;
            console.log('datalayer', window.dataLayer);
        _satellite.track('click-event');
            }
        })
        action.setParams({
            cartId: cartId,
        });
        $A.enqueueAction(action);
        
    }
    //adobe analytics:ends 

})