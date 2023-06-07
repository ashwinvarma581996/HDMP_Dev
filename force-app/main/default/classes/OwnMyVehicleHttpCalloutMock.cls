@isTest
global with sharing class OwnMyVehicleHttpCalloutMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req){
        HttpResponse mockResponse = new HttpResponse();

        if (req.getMethod() == 'POST'){
            mockResponse.setHeader('Content-Type', 'application/json');
            mockResponse.setBody('{"status": "SUCCESS"}');
            mockResponse.setStatusCode(200);
        }
        if (req.getMethod() == 'GET'){
            mockResponse.setHeader('Content-Type', 'application/json');
            String respBody = '{"status":"SUCCESS","responseBody":{"accountStatus":"success"},"CustomerInfo":[{"UserType":"INDIVIDUAL"}],"vehicleInfo":[{"VIN":"VINNUMBER00000001","VINHeader":"VINNUMBER0","DivisionCode":"A","DivisionName":"Honda","ModelYear":"2022","ModelId":"TEST","ModelCode":"TestModel1 TestTrim1","ModelTypeCode":"","ModelTrimTypeCode":"TestTrim1","FactoryCode":"","FactoryName":"CELAYA","ExteriorBaseColorCode":"AA","ExteriorBaseColorName":"GREY","ExteriorMarketingColorName":"TestColor1","ExteriorMarketingColorCode":"TE-0001","ManufacturingColorCode":"TE-0001","ModelGroupNameFriendly":"CIVIC","EmbeddedNavi":"N","TelematicsFlag":"Y","TelematicsPlatform":"MY14","Enrollment":"N","EnrollmentMethod":"AGENT","TelematicsUnit":"Y","Asset34FrontPath":"http://www.myhonda.honda.ca/static/MyHonda/Models/HONDA/CIVIC%204D/2015/default.jpg","Asset34RearPath":"http://www.myhonda.honda.ca/static/MyHonda/Models/HONDA/CIVIC%204D/2015/default.jpg","CountryCoded":"CA","VehicleAlias":"AliasName","AssociationDate":"03/21/2013","RelationshipStatus":"CONFIRMED","Ownership":"Y"}]}';
            mockResponse.setBody(respBody);
            mockResponse.setStatusCode(200);
        }

        return mockResponse;
    }
}