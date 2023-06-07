/***********************************************************************************************
* File Name          : B2B_MyPaymentsController
* Description        : It is created to handle my payments for logged-in user only.
* Business Unit      : HDM
* Created By         : Soumya,Vipul
* Date               : 29/08/2022
************************************************************************************************/
({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.updateExpiredCard(component,event);
        helper.getAllMyPaymentsList(component, event); 
        
    },
    addNewAddress : function(component, event, helper) {
        component.set("v.isAddNewAddress", true);
        component.set("v.isNewAddress", true);
        component.set("v.isShowNewAddress", false);
        component.set("v.isSelectedAddress", false);
        component.set("v.isAnyAddressSelected",true);
          
    },
    openRemoveModel: function(component, event, helper) {      
        let paymentId = event.target.id;  
        let objPayment = component.get("v.paymentsList").find(item => item.Id == paymentId);
        component.set("v.objPayment", objPayment); 
        component.set("v.showRemoveModal", true);   
    },
   
    closeRemoveModel: function(component, event, helper) {
       component.set("v.showRemoveModal", false);
       component.set("v.objPayment", {});
    },
   
    handleRemovePayment: function(component, event, helper) {
       //Add your code to call apex method or do some processing
       component.set("v.showSpinner", true);
       component.set("v.showRemoveModal", false);
       let objPayment = component.get("v.objPayment");
       helper.removePaymentMethod(component, event, objPayment.Id);
    },

    openAddPaymentModal: function(component, event, helper) {  
        component.set("v.cardholderName",'');
		component.set("v.name",'');
		component.set("v.address1",'');
		component.set("v.address2",'');
		component.set("v.city",'');
		component.set("v.state",'');
		component.set("v.zipCode",'');
		component.set("v.phoneNumber",'');
        component.set("v.isAnyAddressSelected",false);
        component.set("v.openAddPaymentModal", true);
        component.set("v.isShowNewAddress", true);
        component.set("v.isAddNewAddress", false);
        component.set("v.isPreferredPayment", false);
        component.set("v.isSaveToAddressBook",false);
        
        helper.setupHostedFieldsMyPayment(component, component.get("v.clientToken"));
        helper.getAllSavedAddresses(component, event);
        
        
    },
    closeAddPaymentModal: function(component, event, helper) {
        component.set("v.openAddPaymentModal", false);
                       
    },
    handleAddPaymentSaveAction : function (component, event, helper){
       
        let objAddress = component.get("v.addressList");
        if(component.get("v.isNewAddress")){
            for(let i = 0 ; i < objAddress.length ; i++) {
                let currInput = objAddress[i];
                if(currInput.isPreferred__c && component.get("v.isSelectedAddress")){
                    component.set("v.isNewAddress", false);
                    component.set("v.replacedAddress", objAddress[i]);
                    component.set("v.isAnyAddressSelected",true);
                }
            }   
        }
         
        helper.validateFormAddPayment(component, event);
        //component.set("v.isNewAddress", true);
    },

    openEditModal: function(component, event, helper) {  
          
        let paymentId = event.target.value;  
        let objPayment = component.get("v.paymentsList").find(item => item.Id == paymentId);
        component.set("v.showEditModal", true);
        component.set("v.showSpinner", true);     
        component.set("v.objPayment", objPayment);
        component.set("v.replacedAddress", null); 
        component.set("v.isNewAddress", true);
        helper.setupHostedFields(component, component.get("v.clientToken"));
        helper.getAllSavedAddresses(component, event);       
    },
    
    closeEditModal: function(component, event, helper) {
        component.set("v.showEditModal", false);
        component.set("v.objPayment", {}); 
        component.set("v.paymentsList", JSON.parse(component.get("v.tempPaymentsList")));               
    },

    handleEditSaveAction: function(component, event, helper) {
        //Add your code to call apex method or do some processing
        //component.set("v.showEditModal", false);
        component.set("v.showSpinner", true);
        if(component.get("v.replacedAddress")){
            helper.getPaymentNonce(component, event);
        }else {
            helper.validateForm(component, event);
        }
        
    },
    handleMarkPreferred: function(component, event, helper) {
        helper.setMarkPreferred(component, event, event.target.id);
    },

    handleChangeAddress : function(component, event, helper) {    
        let objAddress = component.get("v.addressList").find(item => item.Id == event.target.id);
        component.set("v.isNewAddress", false);
        component.set("v.isSelectedAddress", false);
        component.set("v.isAnyAddressSelected",true);
        
        component.set("v.replacedAddress", objAddress);
    },
    handleChangeAddressEdit : function(component, event, helper) { 
        let objAddress = component.get("v.addressList").find(item => item.Id == event.target.id);
        component.set("v.isNewAddress", false);
        //component.set("v.isSelectedAddress", false);
        component.set("v.replacedAddress", objAddress);
    },
    handleToAllowPhone : function(component, event, helper) {
        helper.handleToAllowPhone(event);
    },
    handleToAllowZipcode : function(component, event, helper) {
        helper.handleToAllowZipcode(event);
    },
    removeCustomMessage : function(component, event, helper) {
        event.target.setCustomValidity("");
    }
 });