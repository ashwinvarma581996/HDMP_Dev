({
    myAction : function(component, event, helper) {

    },
    addNewAddress : function(component, event, helper) {
        var parentComponent = component.get("v.parent");                         
		parentComponent.addAddress();
    },
    addressChange : function(component, event, helper) {      
        var parentComponent = component.get("v.parent");                         
		parentComponent.onAddressChange(event.target.value);
        console.log('OUTPUT : ',event.target.value);        
    }
})