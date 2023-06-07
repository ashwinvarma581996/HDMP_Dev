({
	init : function(component, event, helper) {
		        const navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get("v.childRecordId"),
          "slideDevName": "related"
        });
        navEvt.fire();
	}
})