public class JWTToken {
    
    public static String getAccessToken() {
 		JWT jwt = new JWT();
        jwt.alg = 'HS256';
        jwt.typ = 'JWT';
        
        jwt.iss = 'developer.force.com';
        jwt.sub = 'Honda Owners';
        jwt.aud = 'https://site.force.com/customers';
        Long exp = (System.currentTimeMillis()/1000 ) + 900000;
        jwt.exp = exp.intValue();
        return jwt.getToken();
    }
}