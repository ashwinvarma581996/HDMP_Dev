public class B2B_Compile_All_Class {
    public static void toCompileAllClass(String username, string password){
        partnerSoapSforceCom.Soap obj=new partnerSoapSforceCom.Soap();
        partnerSoapSforceCom.LoginResult loginResult = obj.login(username, password);
        obj.SessionHeader=new partnerSoapSforceCom.SessionHeader_element();
        obj.endpoint_x=loginResult.serverUrl;
        obj.SessionHeader.sessionId=loginResult.sessionId;
        List<ApexClass> classtocompile=[select Body from ApexClass];
        try{
            for(ApexClass com:classtocompile){
                //apexBinding.compileClasses(new String[]{com.Body});
            }
        }catch(Exception e){
            
        }
    }

}