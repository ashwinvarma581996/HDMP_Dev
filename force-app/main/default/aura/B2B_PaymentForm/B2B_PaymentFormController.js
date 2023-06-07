({
	doInit : function(component, event, helper) {
		helper.doInit(component, event);
	},
    
    handleSumbitOrder : function(component, event, helper) {
        helper.validateForm(component, event);
    },
    removeCustomMessage : function(component, event, helper) {
        event.target.setCustomValidity("");
    },
    paymentOptionChange : function(component, event, helper) {
        if(component.get("v.creditCardChecked") == true){  
            component.set("v.creditCardChecked",false);
            component.set("v.paypalChecked",true);
            component.set("v.paypalButtonStyle","");
            component.set("v.creditCardStyle","display:none;");                    
            
        }else {
            component.set("v.creditCardChecked",true);
            component.set("v.paypalChecked",false);
            component.set("v.paypalButtonStyle","display:none;");
            component.set("v.creditCardStyle","");           
        }
    }
})