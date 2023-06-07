public class B2B_ShippingWrapper {
    	
        public String responseCode;
        public String errorMessage;
        public Boolean isSuccess;
        public String defaultspeed;
        public Map<String,String> serviceTypewithChargeMap;
        //public B2B_ShippingWrapper ShippingDataWrapper;
        
        public B2B_ShippingWrapper(){
            responseCode = '';
            errorMessage = '';
            isSuccess = false;
            defaultspeed='';
            serviceTypewithChargeMap = New Map<String,String>();
        }
    

}