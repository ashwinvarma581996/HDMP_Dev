({
    myAction : function(component, event, helper) {

    },

    paymentMethodChange : function(component, event, helper) {  
        component.set('v.paypalErrorMessage', '');    
        var parentComponent = component.get("v.parent");                         
		parentComponent.onPaymentMethodChange(event.target.value);
    },
    addNewPaymentMethod : function(component, event, helper) {
        component.set('v.paypalErrorMessage', ''); 
        //Call Parent aura method        
        console.log('addNewPaymentMethod child : ',event);
        var parentComponent = component.get("v.parent");                         
		parentComponent.addPaymentMethod();
    }
})