({
    doInit : function(component, event, helper) {       
		helper.doInit(component, event);
	},
    
    handleSumbitOrder : function(component, event, helper) {       
        let onNewPaymentMethod = component.get("v.isShowBillingAddress");
        let onNewAddress = component.get("v.isShowNewAddress");
        if(onNewPaymentMethod == false){
            if(component.get("v.paymentId") != ''){
                 // payment method is selected or paying with PayPal
                helper.submitPaymentByMyPayment(component, event);
            }else {
                helper.handleErrorMessage(component, "Please select any payment method.");
            }
           

        }else if(onNewAddress == true){
            // need to validate address form and payment fields 
            helper.validateForm(component, event);
        }else {
            // billing address is selected from saved one
            component.set("v.showSpinner", true);
            let fieldsToCorrect = [];                     
            let currInput = component.find("inputField");
            let fieldVal = currInput.get("v.value");
            console.log('currInput.get("v.name") : ',currInput.get("v.name"));
            console.log('fieldVal : ',fieldVal);
            if(currInput.get("v.name") == "Cardholder Name"){
                if(!fieldVal || fieldVal.trim().length < 2 || !(/^[ A-Za-z0-9_@./','#&+-]*$/.test(fieldVal))) {
                    currInput.setCustomValidity("Invalid name, please enter a valid name.")
                    currInput.reportValidity();
                    fieldsToCorrect.push(currInput.get("v.name"));
                }
            }
                
            
            console.log('fieldsToCorrect : ',fieldsToCorrect);
            if(fieldsToCorrect.length > 0) {
                //this.handleErrorMessage(component, "Please complete the following field(s): " + fieldsToCorrect.join(", "));
                helper.handleErrorMessage(component, "Please review and check that all information is complete.");               
                component.set("v.showSpinner", false);
            } else {
                helper.handleSubmitPayment(component, event);
            }           
        }
    },

    handleSameAsShipping : function(component, event, helper) {
        helper.handleSameAsShipping(component, event);
    },
    handleToAllowName : function(component, event, helper) {
        helper.handleToAllowName(event);
    },
    handleToAllowPhone : function(component, event, helper) {
        helper.handleToAllowPhone(event);
    },
    handleToAllowZipcode : function(component, event, helper) {
        helper.handleToAllowZipcode(event);
    },
    
    removeCustomMessage : function(component, event, helper) {
        event.target.setCustomValidity("");
    },

    paymentMethodChange : function(component, event, helper) {
        component.set('v.paypalErrorMessage', ''); 
        var params = event.getParam('arguments');
        if (params) {
            var paymentId = params.paymentId;   
            if(paymentId == 'PayPal') {            
                component.set("v.paypalForLoggedIn",true);
                component.set("v.creditCardChecked",false);                           
                component.set("v.paypalLoggedInStyle","width: 200px;float: right;");
            }else {
                component.set("v.paymentId", paymentId);
                component.set("v.paypalForLoggedIn",false);
                component.set("v.creditCardChecked",true);                           
                component.set("v.paypalLoggedInStyle","width: 200px;float: right;display:none;");
            }                 
        }      
    },

    addNewPaymentMethod : function(component, event, helper) {  
        component.set('v.paypalErrorMessage', ''); 
        component.set("v.paymentId", '');     
        component.set("v.isShowBillingAddress",true);            
        component.set("v.isBackButtonChanged",true);   
        component.set("v.paypalForLoggedIn",false);
        component.set("v.creditCardChecked",false); 
        component.set("v.ccLoggedInStyle",'');             
        component.set("v.paypalLoggedInStyle","width: 200px;float: right;display:none;");   
        var addresses = component.get("v.myAddresses");
        if(addresses && addresses.length == 0){
            component.set("v.isShowNewAddress",true);
        }else {            
            component.set("v.addressId", addresses[0].Id); 
        }       
    },

    addressChange : function(component, event, helper) { 
        var params = event.getParam('arguments');
        if (params) {
            var addressId = params.addressId;  
            component.set("v.addressId", addressId);      
        }
        
    },

    addNewAddress : function(component, event, helper) {   
        component.set("v.addressId", '');      
        component.set("v.isShowNewAddress",true); 
    },

    handleBackClicked : function(component, event, helper) { 
        component.set("v.paymentId", component.get("v.defaultPaymentId")); 
        component.set("v.creditCardChecked",true);
        component.set("v.ccLoggedInStyle",'Display:none;');
        component.set("v.isShowNewAddress",false); 
        component.set("v.isShowBillingAddress",false); 
        component.set("v.isBackButtonChanged",false);
        component.set("v.paypalForLoggedIn",false);                                  
        component.set("v.paypalLoggedInStyle","width: 200px;float: right;display:none;");
    },

    saveNewPaymentMethod : function(component, event, helper) {
        component.set("v.isSaveNewPaymentMethod",event.getSource().get("v.checked"));
        if(event.getSource().get("v.checked")){
            component.set("v.isMakePreferredDisabled",false);            
        }else {
            component.set("v.isMakePreferredDisabled",true);
            component.set("v.isMakePreferred",false);
        }            
    },
    
    handleMakePreferred : function(component, event, helper) {
        component.set("v.isMakePreferred",event.getSource().get("v.checked"));       
    },

    handleGoBackClicked : function(component, event, helper){        
        let url = '/s/ordersummarypage?orderId=' + component.get("v.orderNumber");
        console.log('OUTPUT : ',url);
        window.open(url, '_self');
    }
})