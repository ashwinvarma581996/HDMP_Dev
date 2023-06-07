//Date : 25/05/2021
//Created by : Apoorv Garg
//Description: Mock class for B2B_INSystemIntegration.cls

@isTest
global class B2B_INSystemIntegrationMock implements HTTPCalloutMock {
    
   /* String status = '';
    global B2B_INSystemIntegrationMock(){
        
    }
    global B2B_INSystemIntegrationMock(String status){
        status = status;
    }*/
    global HTTPResponse respond(HTTPRequest request) {   
        String reqBody = request.getBody();
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        //GetModelByVinDecoder start
        //Negative for VIN
        if(reqBody.contains('0GA0730041HGCR2F3'))
        {
            
            System.debug('##IF');
            String body = '{"Body"{"ErrorFlag": True,"ErrorCode": null,"ErrorType": null,"ErrorMessage": null,';
            body += '"VINInfo": {"ExternalColorCode": "NH797M","ExternalColorDescription": "MODERN STEEL M."},';
            body += '"Catalog": {"ProductCategories": [{"ID": 0,"Description": "AUTOMOBILE"}],"Products": [{"ID": 5,"Description": "ACCORD"}],"Doors": [{"ID": 4,"Description": "4"}],"Years": [{"ID": 4,"Description": "4"}],"Catalogs": [{"CatalogID": 134}],';
            body += '"SelectedProducts": [{"ProductID": 0}],"Origins": [{"ID": 2,"Description": "USA"}],"Areas": [{"ID": 4,"Description": "KL"}],"Grades": [{"ID": 5,"Description": "LX"}],"Transmissions": [{"ID": 4,"Description": "CVT"}],"ColorLabels": [{"ID": 2,"Description": "B-GRAY"}],"ColorNames": [{"ID": 2,"Description": "GRAY"}],';
            body += '"Sections": [{"ID": 1,"Description": "ENGINE","SectionURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/Sections/Section_1.png","ImageSize": 0}],"IllustrationGroups": null,"HotSpots": null,"Parts": null}}}';
            response.setBody(body);
            response.setStatusCode(200); 
        }
   
        // GetModelByVinDecoder statuscode != 200
        else if (reqBody.contains('1HGCR2F30GA073006')) {
            System.debug('##Else');
            String body ='{"Body":{"ErrorFlag": True,"ErrorCode": null,"ErrorType": null,"ErrorMessage": null,';
            body += '"VINInfo": {"ExternalColorCode": "NH797M","ExternalColorDescription": "MODERN STEEL M."},';
            body += '"Catalog": {"ProductCategories": [{"ID": 0,"Description": "AUTOMOBILE"}],"Products": [{"ID": 5,"Description": "ACCORD"}],"Doors": [{"ID": 4,"Description": "4"}],"Years": [{"ID": 4,"Description": "4"}],"Catalogs": [{"CatalogID": 134}],';
            body += '"SelectedProducts": [{"ProductID": 0}],"Origins": [{"ID": 2,"Description": "USA"}],"Areas": [{"ID": 4,"Description": "KL"}],"Grades": [{"ID": 5,"Description": "LX"}],"Transmissions": [{"ID": 4,"Description": "CVT"}],"ColorLabels": [{"ID": 2,"Description": "B-GRAY"}],"ColorNames": [{"ID": 2,"Description": "GRAY"}],';
            body += '"Sections": [{"ID": 1,"Description": "ENGINE","SectionURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/Sections/Section_1.png","ImageSize": 0}],"IllustrationGroups": null,"HotSpots": null,"Parts": null}}, "Header": {"Code": "200","Status": "Success","Message": ""}}';
            response.setBody(body);
             response.setStatusCode(202); 
        }
        
        //Positive for VIN //changed the header to tester
        //created another else if to cover line 77 to 88
         else if (request.getEndpoint().endsWith('vin/1.0') && reqBody.contains('1HGCR2F30GA073005')) {
            System.debug('##Else');
            String body = '{"Body":{"ErrorFlag": false,"ErrorCode": null,"ErrorType": null,"ErrorMessage": null,';
            body += '"VINInfo": {"ExternalColorCode": "NH797M","ExternalColorDescription": "MODERN STEEL M."},';
            body += '"Catalog": {"ProductCategories": [{"ID": 0,"Description": "AUTOMOBILE"}],"Products": [{"ID": 5,"Description": "ACCORD"}],"Doors": [{"ID": 4,"Description": "4"}],"Years": [{"ID": 4,"Description": "4"}],"Catalogs": [{"CatalogID": 134}],';
            body += '"SelectedProducts": [{"ProductID": 0}],"Origins": [{"ID": 2,"Description": "USA"}],"Areas": [{"ID": 4,"Description": "KL"}],"Grades": [{"ID": 5,"Description": "LX"}],"Transmissions": [{"ID": 4,"Description": "CVT"}],"ColorLabels": [{"ID": 2,"Description": "B-GRAY"}],"ColorNames": [{"ID": 2,"Description": "GRAY"}],';
            body += '"Sections": [{"ID": 1,"Description": "ENGINE","SectionURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/Sections/Section_1.png","ImageSize": 0}],"IllustrationGroups": null,"HotSpots": null,"Parts": null}}, "Header": {"Code": "200","Status": "Success","Message": ""}}';
            response.setBody(body);
             response.setStatusCode(200); 
        }
         else if (request.getEndpoint().endsWith('vin/1.0') && reqBody.contains('12300-P0G-A01')) {
            System.debug('##Else');
            String body = '{"Body":{"ErrorFlag": false,"ErrorCode": null,"ErrorType": null,"ErrorMessage": null,';
            body += '"VINInfo": {"ExternalColorCode": "NH797M","ExternalColorDescription": "MODERN STEEL M."},';
            body += '"Catalog": {"ProductCategories": [{"ID": 0,"Description": "AUTOMOBILE"}],"Products": [{"ID": 5,"Description": "ACCORD"}],"Doors": [{"ID": 4,"Description": "4"}],"Years": [{"ID": 4,"Description": "4"}],"Catalogs": [{"CatalogID": 134}],';
            body += '"SelectedProducts": [{"ProductID": 0}],"Origins": [{"ID": 2,"Description": "USA"}],"Areas": [{"ID": 4,"Description": "KL"}],"Grades": [{"ID": 5,"Description": "LX"}],"Transmissions": [{"ID": 4,"Description": "CVT"}],"ColorLabels": [{"ID": 2,"Description": "B-GRAY"}],"ColorNames": [{"ID": 2,"Description": "GRAY"}],';
            body += '"Sections": [{"ID": 1,"Description": "ENGINE","SectionURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/Sections/Section_1.png","ImageSize": 0}],"IllustrationGroups": null,"HotSpots": null,"Parts": null}}, "Header": {"Code": "200","Status": "Success","Message": ""}}';
            response.setBody(body);
             response.setStatusCode(200); 
        }
        //GetModelByVinDecoder End
        
        //GetIllustrationBySectionID Start
            else if (request.getEndpoint().endsWith('vin/1.0')) {
            System.debug('##Else');
            String body = '{"Body":{"ErrorFlag": false,"ErrorCode": null,"ErrorType": null,"ErrorMessage": null,';
            body += '"VINInfo": {"ExternalColorCode": "NH797M","ExternalColorDescription": "MODERN STEEL M."},';
            body += '"Catalog": {"ProductCategories": [{"ID": 0,"Description": "AUTOMOBILE"}],"Products": [{"ID": 5,"Description": "ACCORD"}],"Doors": [{"ID": 4,"Description": "4"}],"Years": [{"ID": 4,"Description": "4"}],"Catalogs": [{"CatalogID": 134}],';
            body += '"SelectedProducts": [{"ProductID": 0}],"Origins": [{"ID": 2,"Description": "USA"}],"Areas": [{"ID": 4,"Description": "KL"}],"Grades": [{"ID": 5,"Description": "LX"}],"Transmissions": [{"ID": 4,"Description": "CVT"}],"ColorLabels": [{"ID": 2,"Description": "B-GRAY"}],"ColorNames": [{"ID": 2,"Description": "GRAY"}],';
            body += '"Sections": [{"ID": 1,"Description": "ENGINE","SectionURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/Sections/Section_1.png","ImageSize": 0}],"IllustrationGroups": null,"HotSpots": null,"Parts": null}}, "Header": {"Code": "200","Status": "Success","Message": ""}}';
            response.setBody(body);
                response.setStatusCode(200); 
        }
        //negativetocoverelse changed error type as true   
        else if (request.getEndpoint().endsWith('vin/1.0')) {
            System.debug('##Else');
            String body = '{"Body":{"ErrorFlag": true,"ErrorCode": null,"ErrorType": null,"ErrorMessage": null,';
            body += '"VINInfo": {"ExternalColorCode": "NH797M","ExternalColorDescription": "MODERN STEEL M."},';
            body += '"Catalog": {"ProductCategories": [{"ID": 0,"Description": "AUTOMOBILE"}],"Products": [{"ID": 5,"Description": "ACCORD"}],"Doors": [{"ID": 4,"Description": "4"}],"Years": [{"ID": 4,"Description": "4"}],"Catalogs": [{"CatalogID": 134}],';
            body += '"SelectedProducts": [{"ProductID": 0}],"Origins": [{"ID": 2,"Description": "USA"}],"Areas": [{"ID": 4,"Description": "KL"}],"Grades": [{"ID": 5,"Description": "LX"}],"Transmissions": [{"ID": 4,"Description": "CVT"}],"ColorLabels": [{"ID": 2,"Description": "B-GRAY"}],"ColorNames": [{"ID": 2,"Description": "GRAY"}],';
            body += '"Sections": [{"ID": 1,"Description": "ENGINE","SectionURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/Sections/Section_1.png","ImageSize": 0}],"IllustrationGroups": null,"HotSpots": null,"Parts": null}}, "Header": {"Code": "200","Status": "Success","Message": ""}}';
            response.setBody(body);
                response.setStatusCode(200); 
        }
        
        ///Negative for Get illustration
        else if(reqBody.contains('64321'))
        {
            //Added body and status changed to failure to cover method:GetIllustrationBySectionID else block line 172-177
            String body = '{{ [{" "THROTTLE BODY (1.5L)","SectionID": 1,"SectionDescription": "ENGINE","IllustrationGroupImageID": 4245407,"SerialNumberFlag": false,"ChartFlag": false,"Subject": null,"ThumbnailHeight": 109,"ThumbnailWidth": 200,"Code2": "E 01","ThumbnailURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/EA/14TLAH01/Thumbnails/TLA4E0100.png"},';
            body +='{": "PURGE CONTROL SOLENOID VALVE (1.5L)","SectionID": 1,"SectionDescription": "ENGINE","IllustrationGroupImageID": 4245409,"SerialNumberFlag": false,"ChartFlag": false,"Subject": null,"ThumbnailHeight": 109,"ThumbnailWidth": 200,"Code2": "E 02","ThumbnailURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/EA/14TLAH01/Thumbnails/TLA4E0200.png"}]},"Header": {"Code": "200","Status": "Failure","Message": ""}}';
            response.setBody(body);
            response.setStatusCode(202); 
        }
        else if(reqBody.contains('54321'))
        {
            //Added body and status changed to failure to cover method:GetIllustrationBySectionID else block line 162-171
            String body = '{"Body":{"IllustrationGroups": [{"ID": 26260,"Code": "E-1","Description": "THROTTLE BODY (1.5L)","SectionID": 1,"SectionDescription": "ENGINE","IllustrationGroupImageID": 4245407,"SerialNumberFlag": false,"ChartFlag": false,"Subject": null,"ThumbnailHeight": 109,"ThumbnailWidth": 200,"Code2": "E 01","ThumbnailURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/EA/14TLAH01/Thumbnails/TLA4E0100.png"},';
            body +='{"ID":26262,"Code": "E-2","Description": "PURGE CONTROL SOLENOID VALVE (1.5L)","SectionID": 1,"SectionDescription": "ENGINE","IllustrationGroupImageID": 4245409,"SerialNumberFlag": false,"ChartFlag": false,"Subject": null,"ThumbnailHeight": 109,"ThumbnailWidth": 200,"Code2": "E 02","ThumbnailURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/EA/14TLAH01/Thumbnails/TLA4E0200.png"}]},"Header": {"Code": "200","Status": "Failure","Message": ""}}';
            response.setBody(body);
            response.setStatusCode(200); 
        }
        
        //Positive for Get Illustration
        else if (request.getEndpoint().endsWith('/illustration/1.0')) {
            String body = '{"Body":{"IllustrationGroups": [{"ID": 26260,"Code": "E-1","Description": "THROTTLE BODY (1.5L)","SectionID": 1,"SectionDescription": "ENGINE","IllustrationGroupImageID": 4245407,"SerialNumberFlag": false,"ChartFlag": false,"Subject": null,"ThumbnailHeight": 109,"ThumbnailWidth": 200,"Code2": "E 01","ThumbnailURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/EA/14TLAH01/Thumbnails/TLA4E0100.png"},';
            body +='{"ID":26262,"Code": "E-2","Description": "PURGE CONTROL SOLENOID VALVE (1.5L)","SectionID": 1,"SectionDescription": "ENGINE","IllustrationGroupImageID": 4245409,"SerialNumberFlag": false,"ChartFlag": false,"Subject": null,"ThumbnailHeight": 109,"ThumbnailWidth": 200,"Code2": "E 02","ThumbnailURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/EA/14TLAH01/Thumbnails/TLA4E0200.png"}]},"Header": {"Code": "200","Status": "Success","Message": ""}}';
            response.setBody(body);
            response.setStatusCode(200); 
        }
        //GetIllustrationBySectionID End
        
        //GetPartsByIllustrationID Start
        //Negative for Get Parts
        else if(reqBody.contains('234'))
        {
            //added header with status failure to cover line 220 to 228
            String body = '{"Body":{"ImageIllustrationGroupDetails": [{"ID": 4245407,"CatalogID": 151,"Code": "TLA4E0100","PixelHeight": 960,"PixelWidth": 1920,"IllustrationURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/EA/14TLAH01/Illustrations/TLA4E0100.png"}],';
            body += '"HotSpots": [{"ItemSequenceID": 1214961,"IllustrationReferenceCode": "001","XPosition": 6630,"YPosition": 3791}],';
            body += '"": ["QuantityRequired ": "001","EngineFrameTransmissionTypeCode ": "E","LoUnVisSerialGroup ": "","HighUnVisSerialGroup ": "","HondaCode ": 8144966,"PartNumber ": "16430 - RTA - J01 ","PartDescription ": "CASE(LOWER)","PartControlCode ": "","SRACode ": "E ","MostForwardSupersession ": "","ForwardSupersession ": "","BackwardSupersession ": "","MultiOrderQuantity ": 1,"DealerNetPriceAmount ": 9.99,"SuggestedRetailPriceAmount ": 16.64,"CoreCostAmount ": 0.00,"PriceChangeFlag ": "","PartStatusCode ": "Z","VDFlag ": "N",';
            body += '"WholsaleCompFlag": "","PartModificationCode": "","NATABCQuantityCode": "H","PartSizeCode": "","CRSShipCode ": "","CommonPartFlag ": "","Height ": "00051","Length ": "00145","GradeID ": 0,"GradeDescription ": "EX(2 WD / E.LIBERTY)","AreaID": 0,"AreaDescription ": "ALL","OriginID ": 0,"OriginDescription ": "USA ","TransmissionID ": 0,"TransmissionDescription ": "ALL","ColorLabelID ": 0,"ColorLabelDescription ": "","IllustrationReferenceCodeOrderBy": "002","IllustrationReferenceCode2": "48","PartDescriptionMasterFile": "CASE(LOWER)"}]},"Header": {"Code": "200","Status": "Failure","Message": ""}}';
            response.setBody(body);
            response.setStatusCode(200); 
        }
        
        //Positive for Get Parts
        //else if (request.getEndpoint().endsWith('parts/1.0')) {
        // modified else condition to differentiate methods
        else if (reqBody.contains('569')) {
            String body = '{"Body":{"ImageIllustrationGroupDetails": [{"ID": 4245407,"CatalogID": 151,"Code": "TLA4E0100","PixelHeight": 960,"PixelWidth": 1920,"IllustrationURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/EA/14TLAH01/Illustrations/TLA4E0100.png"}],';
            body += '"HotSpots": [{"ItemSequenceID": 1214961,"IllustrationReferenceCode": "001","XPosition": 6630,"YPosition": 3791}],';
            body += '"Parts": [{"PartID": 32955,"IllustrationReferenceCode": "002","QuantityRequired ": "001","EngineFrameTransmissionTypeCode ": "E","LoUnVisSerialGroup ": "","HighUnVisSerialGroup ": "","HondaCode ": 8144966,"PartNumber ": "16430 - RTA - J01 ","PartDescription ": "CASE(LOWER)","PartControlCode ": "","SRACode ": "E ","MostForwardSupersession ": "","ForwardSupersession ": "","BackwardSupersession ": "","MultiOrderQuantity ": 1,"DealerNetPriceAmount ": 9.99,"SuggestedRetailPriceAmount ": 16.64,"CoreCostAmount ": 0.00,"PriceChangeFlag ": "","PartStatusCode ": "Z","VDFlag ": "N",';
            body += '"WholsaleCompFlag": "","PartModificationCode": "","NATABCQuantityCode": "H","PartSizeCode": "","CRSShipCode ": "","CommonPartFlag ": "","Height ": "00051","Length ": "00145","GradeID ": 0,"GradeDescription ": "EX(2 WD / E.LIBERTY)","AreaID": 0,"AreaDescription ": "ALL","OriginID ": 0,"OriginDescription ": "USA ","TransmissionID ": 0,"TransmissionDescription ": "ALL","ColorLabelID ": 0,"ColorLabelDescription ": "","IllustrationReferenceCodeOrderBy": "002","IllustrationReferenceCode2": "48","PartDescriptionMasterFile": "CASE(LOWER)"}]},"Header": {"Code": "200","Status": "Success","Message": ""}}';
            response.setBody(body);
            response.setStatusCode(200); 
        }
        // status code check in method : getparts line 229 t0 233
        else if (reqBody.contains('432')) {
            String body = '{"Body":{"ImageIllustrationGroupDetails": [{"ID": 4245407,"CatalogID": 151,"Code": "TLA4E0100","PixelHeight": 960,"PixelWidth": 1920,"IllustrationURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/EA/14TLAH01/Illustrations/TLA4E0100.png"}],';
            body += '"HotSpots": [{"ItemSequenceID": 1214961,"IllustrationReferenceCode": "001","XPosition": 6630,"YPosition": 3791}],';
            body += '"Parts": [{"PartID": 32955,"IllustrationReferenceCode": "002","QuantityRequired ": "001","EngineFrameTransmissionTypeCode ": "E","LoUnVisSerialGroup ": "","HighUnVisSerialGroup ": "","HondaCode ": 8144966,"PartNumber ": "16430 - RTA - J01 ","PartDescription ": "CASE(LOWER)","PartControlCode ": "","SRACode ": "E ","MostForwardSupersession ": "","ForwardSupersession ": "","BackwardSupersession ": "","MultiOrderQuantity ": 1,"DealerNetPriceAmount ": 9.99,"SuggestedRetailPriceAmount ": 16.64,"CoreCostAmount ": 0.00,"PriceChangeFlag ": "","PartStatusCode ": "Z","VDFlag ": "N",';
            body += '"WholsaleCompFlag": "","PartModificationCode": "","NATABCQuantityCode": "H","PartSizeCode": "","CRSShipCode ": "","CommonPartFlag ": "","Height ": "00051","Length ": "00145","GradeID ": 0,"GradeDescription ": "EX(2 WD / E.LIBERTY)","AreaID": 0,"AreaDescription ": "ALL","OriginID ": 0,"OriginDescription ": "USA ","TransmissionID ": 0,"TransmissionDescription ": "ALL","ColorLabelID ": 0,"ColorLabelDescription ": "","IllustrationReferenceCodeOrderBy": "002","IllustrationReferenceCode2": "48","PartDescriptionMasterFile": "CASE(LOWER)"}]},"Header": {"Code": "200","Status": "Success","Message": ""}}';
            response.setBody(body);
            response.setStatusCode(202); 
        }
        else if (reqBody.contains('431')) {
            String body = '{"Body":{"ImageIllustrationGroupDetails": [{"ID": 4245407,"CatalogID": 151,"Code": "TLA4E0100","PixelHeight": 960,"PixelWidth": 1920,"IllustrationURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/EA/14TLAH01/Illustrations/TLA4E0100.png"}],';
            body += '"HotSpots": [{"ItemSequenceID": 1214961,"IllustrationReferenceCode": "001","XPosition": 6630,"YPosition": 3791}],';
            body += '"Parts": [{"PartID": 32955,"IllustrationReferenceCode": "002","QuantityRequired ": "001","EngineFrameTransmissionTypeCode ": "E","LoUnVisSerialGroup ": "","HighUnVisSerialGroup ": "","HondaCode ": 8144966,"PartNumber ": "16430 - RTA - J01 ","PartDescription ": "CASE(LOWER)","PartControlCode ": "","SRACode ": "E ","MostForwardSupersession ": "","ForwardSupersession ": "","BackwardSupersession ": "","MultiOrderQuantity ": 1,"DealerNetPriceAmount ": 9.99,"SuggestedRetailPriceAmount ": 16.64,"CoreCostAmount ": 0.00,"PriceChangeFlag ": "","PartStatusCode ": "Z","VDFlag ": "N",';
            body += '"WholsaleCompFlag": "","PartModificationCode": "","NATABCQuantityCode": "H","PartSizeCode": "","CRSShipCode ": "","CommonPartFlag ": "","Height ": "00051","Length ": "00145","GradeID ": 0,"GradeDescription ": "EX(2 WD / E.LIBERTY)","AreaID": 0,"AreaDescription ": "ALL","OriginID ": 0,"OriginDescription ": "USA ","TransmissionID ": 0,"TransmissionDescription ": "ALL","ColorLabelID ": 0,"ColorLabelDescription ": "","IllustrationReferenceCodeOrderBy": "002","IllustrationReferenceCode2": "48","PartDescriptionMasterFile": "CASE(LOWER)"}]},"Header": {"Code": "200","Status": "Failure","Message": ""}}';
            response.setBody(body);
            response.setStatusCode(200); 
        }
        //GetPartsByIllustrationID End
        
        //SearchbyProduct Start
        //Negative for Search Product
        //added body and header with status failure
        else if(reqBody.contains('2022')) {
            String body = '{"Body":{"ProductCategories": [{"ID": 0,"Description": "AUTOMOBILE"}],"Products":: [{"ID": 5,"Description": "ACCORD"}],"Doors": [{"ID": 1,"Description": "2"}],"Years": [{"ID": 52,"Description": "2021"}],"Catalogs": [{"CatalogID": 1}],"SelectedProducts":[],"Origins":[],"Areas":[],"Grades":[],"Transmissions":[],"ColorLabels":[],"ColorNames":[],"Sections":[],"IllustrationGroups": [],"HotSpots": [],"Parts": []},"Header": {"Code": "202","Status": "Failure","Message": ""}}';
            response.setBody(body);
            response.setStatusCode(202); 
        }
        
        //Positive for Search Product
        //else if (request.getEndpoint().endsWith('product/1.0')) 
        else if(reqBody.contains('2021')){
            String body = '{"Body":{"ProductCategories": [{"ID": 0,"Description": "AUTOMOBILE"}],"Products": [{"ID": 5,"Description": "ACCORD"}],"Doors": [{"ID": 1,"Description": "2"}],"Years": [{"ID": 52,"Description": "2021"}],"Catalogs": [{"CatalogID": 1}],"SelectedProducts":[],"Origins":[],"Areas":[],"Grades":[],"Transmissions":[],"ColorLabels":[],"ColorNames":[],"Sections":[],"IllustrationGroups": [],"HotSpots": [],"Parts": []},"Header": {"Code": "200","Status": "Success","Message": ""}}';
            response.setBody(body);
            response.setStatusCode(200); 
        }
        
        
        //SearchbyProduct End
        
        
        //Get Dealer Price Start
       //Negative for Dealer price
        //else if(reqBody.contains('4S6CM58W2'))
        else if(reqBody.contains('2065288'))
        {
            //added body and header with status failure
            String body = '{"Body": {"DealerNo": "206506","Division": "A","Parts": [{"PartNumber": "12300-P0G-A01","DealerPrice": 1153.32,"DIYPrice": 260.08},{"PartNumber": "12300-P8E-306","DealerPrice": 88.81},{"PartNumber": "12300-P8F-307","DealerPrice": 14.80},{"PartNumber": "23411-P0X-000","DealerPrice": 107.60}]},';
            body += '"Accessories": [{"OpCode": "ACCOR17005","DealerPrice": 320.08,"DIYPrice": 260.08},{"OpCode": "ACCOR17110","DealerPrice": 440.08,"DIYPrice": 260.08}],"Header": {"Code": "200","Status": "Failure","Message": ""}}';
            response.setBody(body);
            response.setStatusCode(200);  
        }
        else if(reqBody.contains('206506'))
        {
            //added body and header with status failure
           String body = '{"Body": {"DealerNo": "206506","Division": "A","Parts": [{"PartNumber": "12300-P0G-A01","DealerPrice": 1153.32,"DIYPrice": 260.08},{"PartNumber": "12300-P8E-306","DealerPrice": 88.81},{"PartNumber": "12300-P8F-307","DealerPrice": 14.80},{"PartNumber": "23411-P0X-000","DealerPrice": 107.60}]},';
            body += '"Accessories": [{"OpCode": "ACCOR17005","DealerPrice": 320.08,"DIYPrice": 260.08},{"OpCode": "ACCOR17110","DealerPrice": 440.08,"DIYPrice": 260.08}],"Header": {"Code": "200","Status": "Success","Message": ""}}';
           // String body='{"Body":{"DealerNo":"251059","DivisionID":1,"Parts":[{"PartNumber":"31200-634-671","DIYPrice":167.14}],"Accessories":[{"OpCode":"RDX0021030","PriceWithInstallation":0,"DIYPrice":0,"InstallationCharges":0}]},"Header":{"Code":"200","Status":"Success","Message":""}';
            response.setBody(body);
            response.setStatusCode(200);  
        }
        //positive dealer price
          else if(reqBody.contains('2065287'))
        {
            //added body and header with status failure
            String body = '{"Body": {"DealerNo": "206506","Division": "A","Parts": [{"PartNumber": "12300-P0G-A01","DealerPrice": 1153.32,"DIYPrice": 260.08},{"PartNumber": "12300-P8E-306","DealerPrice": 88.81},{"PartNumber": "12300-P8F-307","DealerPrice": 14.80},{"PartNumber": "23411-P0X-000","DealerPrice": 107.60}]},';
            body += '"Accessories": [{"OpCode": "ACCOR17005","DealerPrice": 320.08,"DIYPrice": 260.08},{"OpCode": "ACCOR17110","DealerPrice": 440.08,"DIYPrice": 260.08}],"Header": {"Code": "200","Status": "Success","Message": ""}}';
            response.setBody(body);
            response.setStatusCode(200);  
        }
        
        //statuscode 202 for Dealer Price
        //else if (request.getEndpoint().endsWith('dealerprice/1.0')) {
        ////shalini
        else if(reqBody.contains('ACCOR17005'))
        {
            String body = '{"Body": {"DealerNo": "206506","Division": "A","Parts": [{"PartNumber": "12300-P0G-A01","DealerPrice": 1153.32,"DIYPrice": 260.08},{"PartNumber": "12300-P0G-A01","DealerPrice": 88.81},{"PartNumber": "12300-P0G-A01","DealerPrice": 14.80},{"PartNumber": "12300-P0G-A01","DealerPrice": 107.60}]},';
            body += '"Accessories": [{"OpCode": "ACCOR17005","DealerPrice": 320.08,"DIYPrice": 260.08},{"OpCode": "ACCOR17005","DealerPrice": 440.08,"DIYPrice": 260.08}],"Header": {"Code": "200","Status": "Success","Message": ""}}';
            response.setBody(body);
            response.setStatusCode(200); 
        }
        //Get Dealer Price End
        
        
        //Negative for VIN Fitment
        else if (reqBody.contains('4S6CM58W2W4419771')) {
            String body = '{"Body":{"ErrorFlag":false,"ErrorCode":null,"ErrorType":null,"ErrorMessage":null,"DivisionID":1,"Parts":[{"PartNumber":"04635-T2F-A00ZZ","IsValid":true},{"PartNumber":"04636-T2F-A90ZZ","IsValid":true}]}}';
            response.setBody(body);
            response.setStatusCode(200); //mathi all above
        }
        
        //Positive for VIN Fitment
        else if (reqbody.contains('1HGCR2F30GA073004')) {
            String body = '{"Body":{"ErrorFlag":false,"ErrorCode":null,"ErrorType":null,"ErrorMessage":null,"DivisionID":1,"Parts":[{"PartNumber":"04635-T2F-A00ZZ","IsValid":true},{"PartNumber":"04636-T2F-A90ZZ","IsValid":true}]}}';
            response.setBody(body);
        }
		else if (reqbody.contains('1TRCR2F30GA073007')) {
            String body='{"Body":{"ErrorFlag":false,"ErrorCode":null,"ErrorType":null,"ErrorMessage":null,"DivisionID":1,{"Parts":[{"PartID":368908,"QuantityRequired":"004","EngineFrameTransmissionTypeCode":"F","LoUnVisSerialGroup":"","HighUnVisSerialGroup":"","HondaCode":"9625975","PartNumber":"42751-MIC-148","PartDescription":"TIRE (P225/50R17) (94V) (MICHELIN ENERGY SAVER A/S)","PartControlCode":"","SRACode":"Z","MostForwardSupersession":"","ForwardSupersession":"","BackwardSupersession":"42751-TVA-A01","MultiOrderQuantity":"1","DealerNetPriceAmount":"187.50","SuggestedRetailPriceAmount":"220.59","CoreCostAmount":"0.00","PriceChangeFlag":"","PartStatusCode":"A","VDFlag":"Y","WholsaleCompFlag":"","PartModificationCode":"","NATABCQuantityCode":"B","PartSizeCode":"","CRSShipCode":"Y","CommonPartFlag":"","Height":"8.27","Length":"24.94","Width":"23.21","Weight":"19.354","GradeID":0,"GradeDescription":"EX-L","AreaID":0,"AreaDescription":"ALL","OriginID":0,"OriginDescription":"ALL","TransmissionID":0,"TransmissionDescription":"CVT","ColorLabelID":0,"ColorLabelDescription":"","PartDescriptionMasterFile":"TIRE (P225/50R17) (94V) (MICHELIN ENERGY SAVER A/S)","FunctionCode":"42751"}]},"Header":{"Code":"200","Status":"Failure","Message":""}}';
            response.setBody(body);
            response.setStatusCode(200);
        }
		else if (request.getEndpoint().endsWith('maintenance/1.0')) {
            String body='{"Body":{"Parts":[{"PartID":368908,"QuantityRequired":"004","EngineFrameTransmissionTypeCode":"F","LoUnVisSerialGroup":"","HighUnVisSerialGroup":"","HondaCode":"9625975","PartNumber":"42751-MIC-148","PartDescription":"TIRE (P225/50R17) (94V) (MICHELIN ENERGY SAVER A/S)","PartControlCode":"","SRACode":"Z","MostForwardSupersession":"","ForwardSupersession":"","BackwardSupersession":"42751-TVA-A01","MultiOrderQuantity":"1","DealerNetPriceAmount":"187.50","SuggestedRetailPriceAmount":"220.59","CoreCostAmount":"0.00","PriceChangeFlag":"","PartStatusCode":"A","VDFlag":"Y","WholsaleCompFlag":"","PartModificationCode":"","NATABCQuantityCode":"B","PartSizeCode":"","CRSShipCode":"Y","CommonPartFlag":"","Height":"8.27","Length":"24.94","Width":"23.21","Weight":"19.354","GradeID":0,"GradeDescription":"EX-L","AreaID":0,"AreaDescription":"ALL","OriginID":0,"OriginDescription":"ALL","TransmissionID":0,"TransmissionDescription":"CVT","ColorLabelID":0,"ColorLabelDescription":"","PartDescriptionMasterFile":"TIRE (P225/50R17) (94V) (MICHELIN ENERGY SAVER A/S)","FunctionCode":"42751"}]},"Header":{"Code":"200","Status":"Success","Message":""}}';
            response.setBody(body);
            response.setStatusCode(200); 
        }else if (request.getEndpoint().endsWith('search/part/1.0')) {
            String body='{"Body":{"ProductCategories":[{"ID":0,"Description":"AUTOMOBILE"}],"Products":[{"ID":4,"Description":"CIVIC"}],"Doors":[{"ID":4,"Description":"4"}],"Years":[{"ID":52,"Description":"2021"}],"Catalogs":[{"CatalogID":162}],"SelectedProducts":[{"ProductID":4}],"Origins":[{"ID":3,"Description":"CAN"},{"ID":2,"Description":"USA"}],"Areas":[{"ID":2,"Description":"KA"},{"ID":4,"Description":"KL"}],"Grades":[{"ID":3022,"Description":"EX (TURBO)"}],"Transmissions":[{"ID":4,"Description":"CVT"}],"ColorLabels":[{"ID":224,"Description":"A-BLACK 1"},{"ID":221,"Description":"B-GRAYGE"},{"ID":225,"Description":"F-IVORY 1"}],"ColorNames":[{"ID":90,"Description":"BLACK 1"},{"ID":89,"Description":"GRAYGE"},{"ID":91,"Description":"IVORY 1"}],"Sections":[{"ID":1,"Description":"ENGINE","SectionURL":"https://akamai-staging.dreamshop.honda.com/PartsCatalog/US/Honda/Catalogs/Sections/Section_1.png","ImageSize":0}],"IllustrationGroups":[{"ID":29088,"Code":"E-1","Description":"THROTTLE BODY (1.5L)","SectionID":1,"SectionDescription":"ENGINE","IllustrationGroupImageID":4551028,"SerialNumberFlag":false,"ChartFlag":false,"ThumbnailHeight":109,"ThumbnailWidth":200,"Code2":"E  01","ThumbnailURL":"https://akamai-staging.dreamshop.honda.com/PartsCatalog/US/Honda/Catalogs/EA/14TBAL01/Thumbnails/TBALE0100.png"}],"ImageIllustrationGroupDetails":[{"ID":4551028,"CatalogID":162,"Code":"TBALE0100","PixelHeight":960,"PixelWidth":1920,"IllustrationURL":"https://akamai-staging.dreamshop.honda.com/PartsCatalog/US/Honda/Catalogs/EA/14TBAL01/Illustrations/TBALE0100.png"}],"HotSpots":[{"ItemSequenceID":1061121,"IllustrationReferenceCode":"001","XPosition":6656,"YPosition":2625,"Description":"THROTTLE BODY, ELECTRONIC CONTROL (GMG9A) (A)"},{"ItemSequenceID":1061122,"IllustrationReferenceCode":"002","XPosition":5755,"YPosition":8312,"Description":"CASE (LOWER)"},{"ItemSequenceID":1061123,"IllustrationReferenceCode":"003","XPosition":5593,"YPosition":7239,"Description":"GASKET, CASE (LOWER)"},{"ItemSequenceID":1061124,"IllustrationReferenceCode":"004","XPosition":5739,"YPosition":9083,"Description":"SCREW-WASHER (4X12)"},{"ItemSequenceID":1061125,"IllustrationReferenceCode":"005","XPosition":7375,"YPosition":4468,"Description":"BOLT, FLANGE (6X35)"}],"Parts":[{"PartID":392359,"IllustrationReferenceCode":"001","QuantityRequired":"001","EngineFrameTransmissionTypeCode":"E","LoUnVisSerialGroup":"","HighUnVisSerialGroup":"","HondaCode":"9712981","PartNumber":"16400-59B-003","PartDescription":"THROTTLE BODY, ELECTRONIC CONTROL (GMG9A) (A)","PartControlCode":"","SRACode":"E","MostForwardSupersession":"","ForwardSupersession":"","BackwardSupersession":"","MultiOrderQuantity":"1","DealerNetPriceAmount":"105.68","SuggestedRetailPriceAmount":"176.14","CoreCostAmount":"0.00","PriceChangeFlag":"","PartStatusCode":"Z","VDFlag":"N","PartModificationCode":"","NATABCQuantityCode":"F","PartSizeCode":"","CRSShipCode":"Y","CommonPartFlag":"","Height":"8.39","Length":"8.39","Width":"8.39","Weight":"2.778","GradeID":0,"GradeDescription":"EX (TURBO)","AreaID":0,"AreaDescription":"ALL","OriginID":0,"OriginDescription":"ALL","TransmissionID":0,"TransmissionDescription":"ALL","ColorLabelID":0,"ColorLabelDescription":"","IllustrationReferenceCodeOrderBy":"001","IllustrationReferenceCode2":"48","PartDescriptionMasterFile":"THROTTLE BODY, ELECTRONIC CONTROL (GMG9A) (A)","FunctionCode":"16400","IsMatched":true},{"PartID":32955,"IllustrationReferenceCode":"002","QuantityRequired":"001","EngineFrameTransmissionTypeCode":"E","LoUnVisSerialGroup":"","HighUnVisSerialGroup":"","HondaCode":"8144966","PartNumber":"16430-RTA-J01","PartDescription":"CASE (LOWER)","PartControlCode":"","SRACode":"E","MostForwardSupersession":"","ForwardSupersession":"","BackwardSupersession":"","MultiOrderQuantity":"1","DealerNetPriceAmount":"10.19","SuggestedRetailPriceAmount":"16.98","CoreCostAmount":"0.00","PriceChangeFlag":"","PartStatusCode":"Z","VDFlag":"N","PartModificationCode":"","NATABCQuantityCode":"H","PartSizeCode":"","CRSShipCode":"","CommonPartFlag":"","Height":"2.01","Length":"5.71","Width":"3.62","Weight":"0.042","GradeID":0,"GradeDescription":"EX (TURBO)","AreaID":0,"AreaDescription":"ALL","OriginID":0,"OriginDescription":"ALL","TransmissionID":0,"TransmissionDescription":"ALL","ColorLabelID":0,"ColorLabelDescription":"","IllustrationReferenceCodeOrderBy":"002","IllustrationReferenceCode2":"48","PartDescriptionMasterFile":"CASE (LOWER)","FunctionCode":"16999","IsMatched":false},{"PartID":32958,"IllustrationReferenceCode":"003","QuantityRequired":"001","EngineFrameTransmissionTypeCode":"E","LoUnVisSerialGroup":"","HighUnVisSerialGroup":"","HondaCode":"8144974","PartNumber":"16431-RTA-J01","PartDescription":"GASKET, CASE (LOWER)","PartControlCode":"","SRACode":"E","MostForwardSupersession":"","ForwardSupersession":"","BackwardSupersession":"","MultiOrderQuantity":"1","DealerNetPriceAmount":"10.72","SuggestedRetailPriceAmount":"17.87","CoreCostAmount":"0.00","PriceChangeFlag":"","PartStatusCode":"Z","VDFlag":"N","PartModificationCode":"","NATABCQuantityCode":"G","PartSizeCode":"","CRSShipCode":"Y","CommonPartFlag":"","Height":"0.12","Length":"2.29","Width":"2.05","Weight":"0.002","GradeID":0,"GradeDescription":"EX (TURBO)","AreaID":0,"AreaDescription":"ALL","OriginID":0,"OriginDescription":"ALL","TransmissionID":0,"TransmissionDescription":"ALL","ColorLabelID":0,"ColorLabelDescription":"","IllustrationReferenceCodeOrderBy":"003","IllustrationReferenceCode2":"48","PartDescriptionMasterFile":"GASKET, CASE (LOWER)","FunctionCode":"91810","IsMatched":false},{"PartID":284509,"IllustrationReferenceCode":"004","QuantityRequired":"004","EngineFrameTransmissionTypeCode":"E","LoUnVisSerialGroup":"","HighUnVisSerialGroup":"","HondaCode":"0485953","PartNumber":"93892-04012-08","PartDescription":"SCREW-WASHER (4X12)","PartControlCode":"","SRACode":"D","MostForwardSupersession":"","ForwardSupersession":"","BackwardSupersession":"93892-04012-18","MultiOrderQuantity":"1","DealerNetPriceAmount":"0.30","SuggestedRetailPriceAmount":"0.49","CoreCostAmount":"0.00","PriceChangeFlag":"","PartStatusCode":"Z","VDFlag":"Y","PartModificationCode":"","NATABCQuantityCode":"E","PartSizeCode":"","CRSShipCode":"Y","CommonPartFlag":"","Height":"0.32","Length":"0.59","Width":"0.32","Weight":"0.002","GradeID":0,"GradeDescription":"EX (TURBO)","AreaID":0,"AreaDescription":"ALL","OriginID":0,"OriginDescription":"ALL","TransmissionID":0,"TransmissionDescription":"ALL","ColorLabelID":0,"ColorLabelDescription":"","IllustrationReferenceCodeOrderBy":"004","IllustrationReferenceCode2":"48","PartDescriptionMasterFile":"SCREW-WASHER (4X12)","FunctionCode":"90100","IsMatched":false},{"PartID":291394,"IllustrationReferenceCode":"005","QuantityRequired":"004","EngineFrameTransmissionTypeCode":"E","LoUnVisSerialGroup":"","HighUnVisSerialGroup":"","HondaCode":"2170801","PartNumber":"95701-06035-08","PartDescription":"BOLT, FLANGE (6X35)","PartControlCode":"","SRACode":"D","MostForwardSupersession":"","ForwardSupersession":"","BackwardSupersession":"957010603508","MultiOrderQuantity":"1","DealerNetPriceAmount":"0.92","SuggestedRetailPriceAmount":"1.53","CoreCostAmount":"0.00","PriceChangeFlag":"","PartStatusCode":"Z","VDFlag":"Y","PartModificationCode":"M","NATABCQuantityCode":"D","PartSizeCode":"","CRSShipCode":"Y","CommonPartFlag":"","Height":"0.39","Length":"3.15","Width":"1.58","Weight":"0.026","GradeID":0,"GradeDescription":"EX (TURBO)","AreaID":0,"AreaDescription":"ALL","OriginID":0,"OriginDescription":"ALL","TransmissionID":0,"TransmissionDescription":"ALL","ColorLabelID":0,"ColorLabelDescription":"","IllustrationReferenceCodeOrderBy":"005","IllustrationReferenceCode2":"48","PartDescriptionMasterFile":"BOLT, FLANGE (6X35)","FunctionCode":"90001","IsMatched":false}]},"Header":{"Code":"200","Status":"Success","Message":""}}}';
            response.setBody(body);
            response.setStatusCode(200); 
        }
        
        system.debug('response'+response);
        return response;
    }
}