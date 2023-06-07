/*******************************************************************************
Name: B2B_DealerDetails
Business Unit: HDM
Date: 28/04/2022
Developer: Sayalee
Description: This class is used as to fetch Dealer related details
*******************************************************************************
MODIFICATIONS – V1 | 29/03/2022 | Sayalee | Added Header
MODIFICATIONS – V2 | 29/06/2022 | Yashika | Appointment Scheduler changes
*******************************************************************************/
public without sharing class B2B_DealerDetails{
    
    public String dealerRecId{get;set;}
    public String customer_Name{get;set;}
    public String order_Number{get;set;}
    public Boolean isCoreChargeExist{get;set;}
    public Date order_Date{get;set;}
    public String orderNumber{get;set;}
    public String order_deliveryType{get;set;}
    public Integer compPos{get;set;}
    public String dealer_No{get;set;}
    public String order_formatedDate{get;set;}
    public String rec_Name{get;set;} //Added by ashwin for 18855
    
    

    
    
    
    
    /* Started by Ashwin for US SP3-16546 */
    public Boolean getCoreChrageItemExist(){
        return ![SELECT Id,Description,Product_Type__c FROM OrderItem WHERE Order.OrderReferenceNumber =: order_Number AND Product_Type__c = 'Core Charge'].isEmpty() ? true : false;        
    }
    
    /* ended by Ashwin for US SP3-16546 */
    
    //Removed by Aditya for 19428,19430
     /*public Boolean getNonZeroCoreChrageItemExist(){
         Boolean isExist = false ;
         
         for(OrderItem oi : [SELECT Id,Description,Product_Type__c,Updated_Quantity__c,Return_Quantity__c FROM OrderItem WHERE Order.OrderReferenceNumber =: order_Number AND Product_Type__c = 'Core Charge']){
             if(oi.Updated_Quantity__c - oi.Return_Quantity__c > 0){
                 isExist = true;
             }
         }    
         
         return isExist;
    } */
    //Removed by Aditya for 19428,19430 
    
    
    
     public Account getdealerRec() {
         if(order_Date != null){
            order_formatedDate = order_Date.format();
         }
        if(String.isNotBlank(dealerRecId)){
            //updated by Saikiran velugundula as part of removing tags from return policy.
            Account dealerAccount =  [SELECT Id,Name,shippingStreet,shippingCity,shippingState,shippingCountry,ShippingPostalCode,Email__c,Phone,Service_Scheduling_URL__c,Operation_Hour__c,Privacy_Policy_URL__c,Return_Policy__c  
                    				  FROM Account
                    				  WHERE Id=: dealerRecId];
            String dealerPolicy = dealerAccount.Return_Policy__c;
            if(string.isNotEmpty(dealerPolicy)){
                dealerAccount.Return_Policy__c = dealerPolicy.stripHtmlTags();
            	return dealerAccount; 
            }else{
                return dealerAccount;
            }
        }
        return null;
    }
    
        public B2B_DealerDetails(){

        
    }
    
    
}