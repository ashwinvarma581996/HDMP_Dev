/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : mbunch@gorillagroup.com
 * 
 *
 * @description       :  
 * Simple functions used to return org 
 * based information. Currently 
 * used for determining which 
 * Named Credentials to use 
 * from Sandboxes and Production
 * @author          :  Erin Antonson
 * Email: eantonson@gorillagroup.com
 * 
**/  
public class RES_Util{

    @TestVisible
    private static string defaultHost = null ;
  
    public static Boolean isSalesforceID(String value){
        try{
            Id salesforceId = Id.valueOf(value);
            return true;
        }catch(Exception ex){
            return false;
        }
    } 
     //Return the Named Cred to use
    public Static String getNamedCreds(String namedCredsLabel) {
        String host = URL.getOrgDomainUrl().getHost();
        String nc = getNamedCreds(namedCredsLabel,host);
        if ( !nc.startsWith('callout:')){
            return 'callout:' + nc ;
        }
        return nc ;
    } 
    
     //Return the Named Cred to use
    private Static String getNamedCreds(String namedCredsLabel, String host) {
        // 
        //RES_Logger.log('host: ' + host) ;
        String sandboxName = getSandboxName(host) ;
        //RES_Logger.log('sandbox: ' + sandboxName) ;
        if ( sandboxName != null )
        {
            return namedCredsLabel + '_' + sandboxName ;
        }
        if ( isSandox() )
        {
            throw new RES_Exception('Production Named Credential Used in Sandbox'); 
        }
        return namedCredsLabel ;
    } 

    //Return if you are in a sandbox
    public Static Boolean isSandox() {
        return Test.isRunningTest() && defaultHost == 'production' ? false : [SELECT isSandbox FROM Organization WHERE id = :System.UserInfo.getOrganizationId()][0].isSandbox ;
    }

    @TestVisible
    private static String getSandboxName(String host){
        return Test.isRunningTest() && defaultHost != null ? ( defaultHost == 'production' ? null : defaultHost  ) : System.DomainParser.parse(host).getSandboxName() ;
    }
}