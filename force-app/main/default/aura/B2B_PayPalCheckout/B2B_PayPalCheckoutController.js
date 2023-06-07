({
    jsLoaded : function(component, event, helper) {
        
        let accountId = $A.get("$SObjectType.CurrentUser.effectiveAccountId");
        console.log('accountId : '+ accountId);
        component.set("v.accountId", accountId);      
        //helper.doInit(component, event);                 
    },

    validatePayPal : function(component, event, helper) {       
        let dealerId = event.getParam('dealerId');
        let buttonDisabled = event.getParam('buttonDisabled');
        component.set("v.buttonDisabled", true);
        if(dealerId){    
            if(component.get("v.isApexCalled") == false){
                component.set("v.isApexCalled",true);
                helper.doInit(component, event); 
            }                   
            component.set("v.dealerId", dealerId);
        }  
        component.set("v.buttonDisabled", buttonDisabled);                  

    },

    validateOrderType : function(component, event, helper) {
        console.log('orderType : ',event.getParam('orderType'));
        console.log('buttonDisabled validateOrderType: ',event.getParam('buttonDisabled'));
        let orderType = event.getParam('orderType');
        let buttonDisabled = event.getParam('buttonDisabled'); 
      
        if(component.get("v.orderType") != orderType){
            component.set("v.orderType",  orderType);        
        }                   
    },

    validateTotalPrice : function(component, event, helper){
        let totalPrice = event.getParam('totalPrice');
        let buttonDisabled = event.getParam('buttonDisabled');        
        console.log('validateTotalPrice : ',totalPrice);
        console.log('validateTotalPrice buttonDisabled: ',buttonDisabled);

        if(totalPrice){
            component.set("v.total", totalPrice);
        } 

        if(component.get("v.orderType") == 'Install At Dealer') {
            component.set("v.buttonDisabled", true);
        }  

        if(component.get("v.orderType") == 'Install At Dealer' && buttonDisabled == false && component.get("v.isApexCalled") == false) {
            let self = component.get("v.this");          
            helper.setupHostedFields(component, component.get("v.clientToken"), self);
        }   
        component.set("v.buttonDisabled", buttonDisabled);
    }
})