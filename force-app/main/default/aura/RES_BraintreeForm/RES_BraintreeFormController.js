/**
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 03-29-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
({
	doInit : function(component, event, helper) {
		helper.doInit(component, event);
	},
    handleSumbitOrder : function(component, event, helper) {
        event.preventDefault = true;
        // helper.validateForm(component, event);
        helper.checkIfCapReached(component, event);
    },
    handleSameAsShipping : function(component, event, helper) {
        helper.handleSameAsShipping(component, event);
    },
    handleToAllowName : function(component, event, helper) {
        helper.handleToAllowName(event);
    },
    handleToAllowZipcode : function(component, event, helper) {
        helper.handleToAllowZipcode(event);
    },
    removeCustomMessage : function(component, event, helper) {
        try {
        event.target.setCustomValidity("");
        }
        catch (e)
        {
            console.log(e.message + ' ' + component) ;
        }
    },
    openModal: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    closeModal: function(component, event, helper) {
        // Set isModalOpen attribute to false
        component.set("v.isModalOpen", false);
     },

     showTermsAndConditions: function(component,event,helper){
         helper.showTAndC(component);
     }
})