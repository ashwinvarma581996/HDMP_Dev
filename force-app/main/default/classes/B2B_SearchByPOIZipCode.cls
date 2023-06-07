/**
 * @description       : 
 * @author            : Pratik LTIM
 * @group             : 
 * @last modified on  : 04-04-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public class B2B_SearchByPOIZipCode {

    @AuraEnabled
    public static List<String> HitB2CCloud( String state,String zipcode, String poiType, String searchRadius, String numberOfPOIs){
        List<string> lstStringtoReturn = new List<string>();
        try{
            String response = ''; 
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept','application/json');
            req.setMethod('GET');
            String endpointURL = Label.POI_Zip_Code_Base_URL;
            endpointURL += '?AppId=';
            endpointURL += Label.POI_Zip_Code_App_Id;
            endpointURL += '&State='+state+'&ZipCode='+zipcode+'&POIType='+poiType+'&SearchRadius='+searchRadius+'&NumberOfPOIs='+numberOfPOIs+'&ShowAllAttributes=False&ShowAllProperties=False&ShowAllDepartments=False&Output=Xml';
            req.setEndpoint(endpointURL);  
            
            Http http = new Http(); 
            HttpResponse res = http.send(req); 
            if (res.getStatusCode() == 200) { 
                    response = res.getBody(); 
                }        
            
            // Parse the JSON response
            JSONParser parser = JSON.createParser(response);   
            set<String> states = new Set<String>();
            set<String> zipCodes = new Set<String>();
            
            String jurisdictionState, jurisdictionZipCode;
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'State') {
                    parser.nextToken();
                    jurisdictionState = parser.getText();
                    System.debug('State: ' + jurisdictionState);
                    states.add(jurisdictionState);
                }

                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'ZipCode') {
                    parser.nextToken();
                    jurisdictionZipCode = parser.getText();
                    system.debug('Zip Code: ' + jurisdictionZipCode);
                    zipcodes.add(jurisdictionZipCode);
                }

            }    

            if(!states.isEmpty()){
                lstStringtoReturn.addall(states);
            }
                System.debug('States: '+states);      
                System.debug('ZipCodes: '+zipCodes);
        }
        catch(Exception ex){

        }    
        return lstStringtoReturn;
    }
}