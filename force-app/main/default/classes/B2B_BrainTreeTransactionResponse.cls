public class B2B_BrainTreeTransactionResponse {
	public Integer status; 
    public String requestBody;
    public String responseBody;
    public String merchantId; 
    public String errorMessage;
    public String billingAddressId;
    public transactions transactionBT;
    public facilitatedDetail facilitatedDetails;
    public facilitatorDetail facilitatorDetails;
    
    public static B2B_BrainTreeTransactionResponse parse(String json){
        return (B2B_BrainTreeTransactionResponse) System.JSON.deserialize(json, B2B_BrainTreeTransactionResponse.class);
    }
    
    public static B2B_BrainTreeTransactionResponse parseTransactionData(B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse, String responseBody,Map<String,Object> mapTransaction){
        objBrainTreeTransactionResponse = parse(responseBody);
        objBrainTreeTransactionResponse.transactionBT = new transactions();
        objBrainTreeTransactionResponse.transactionBT.id = String.valueOf(mapTransaction.get('id'));
        objBrainTreeTransactionResponse.transactionBT.status = String.valueOf(mapTransaction.get('status'));
        objBrainTreeTransactionResponse.transactionBT.type = String.valueOf(mapTransaction.get('type'));
        objBrainTreeTransactionResponse.transactionBT.amount = String.valueOf(mapTransaction.get('amount'));
        return objBrainTreeTransactionResponse;
    }
    
    public class transactions {
        public String id;
        public String status;
        public String type;
        public String amount;
    }
    
    public class facilitatedDetail {
        public String merchantId;
        public String merchantName;
    }
    
    public class facilitatorDetail {
        public String oauthApplicationClientId;
        public String oauthApplicationName;
        public String sourcePaymentMethodToken;
    }
}