public class JWT {
    
    public String alg {get;set;}
    public String typ {get;set;}
    public String iss {get;set;}
    public String sub {get;set;}
    public String aud {get;set;}
    public Integer exp {get;set;}
    public String iat {get;set;}
    public Map<String,String> claims {get;set;}
    public Integer validFor {get;set;}
    public String cert {get;set;}
    public String pkcs8 {get;set;}
    public String privateKey {get;set;}
    
    public static final String HS256 = 'HS256';
    public static final String NONE = 'none';
    
    
    
    public String getToken() {
        
        String jwt = '';
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', this.alg);
        header.writeStringField('typ', this.typ);
        header.writeEndObject();
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
        
        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('iss', this.iss);
        body.writeStringField('sub', this.sub);
        body.writeStringField('aud', this.aud);
        body.writeNumberField('exp', this.exp);
        body.writeEndObject();
        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));
        
        AHMConfig__mdt tokenMetadata = [SELECT MasterLabel, QualifiedApiName, 
                                                    token_value__c FROM AHMConfig__mdt limit 1];

		system.debug('TOKEN::'+tokenMetadata.token_value__c);
        String keyContents = tokenMetadata.token_value__c;
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');
        
        
        if ( this.alg == HS256 ) {
            Blob key = EncodingUtil.base64Decode(keyContents);
            Blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
            jwt += '.' + base64URLencode(signature);  
        }  else if ( this.alg == NONE ) {
            jwt += '.';
        }
        return jwt;
    }
    
    public String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }
}