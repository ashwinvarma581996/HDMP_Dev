@isTest
global class OwnEConfigApi_MockService implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        // Set response values, and 
        // return response.
        String body = '{'+
                        '"mot": {'+
                        '"@id": "1",'+
                        '"input_parameters": {'+
                        '"required": {'+
                        '"source_cd": "Honda",'+
                        '"site_cd": "Honda",'+
                        '"category_cd": "CONFIG",'+
                        '"division": {'+
                        '"@version_num": "0",'+
                        '"#text": "A"'+
                        '},'+
                        '"models": {'+
                        '"model": {'+
                        '"@id": "FC3B3KJW"'+
                        '}'+
                        '}'+
                        '},'+
                        '"optional": {'+
                        '"assets": {'+
                        '"@suppress_asset_name": "true",'+
                        '"@suppress_asset_description": "true",'+
                        '"asset": ['+
                        '{'+
                        '"@type_cd": "IMGMIDSIZE",'+
                        '"@view_cd": "34FRONT",'+
                        '"@source_cd": "HONDA"'+
                        '},'+
                        '{'+
                        '"@type_cd": "BASECAR",'+
                        '"@view_cd": "34FRONT",'+
                        '"@source_cd": "HONDA"'+
                        '},'+
                        '{'+
                        '"@type_cd": "IMGMIDSIZE",'+
                        '"@view_cd": "34FRONT",'+
                        '"@source_cd": "ACURA"'+
                        '}'+
                        ']'+
                        '},'+
                        '"fifs": {'+
                        '"@return_fifs": "true",'+
                        '"fif": {'+
                        '"@category_cd": "T"'+
                        '}'+
                        '}'+
                        '}'+
                        '},'+
                        '"db_results": {'+
                        '"@when_cached": "2021-07-15T11:26:13.0464352Z",'+
                        '"@from_cache": "true",'+
                        '"@cached_by": "marketplace.honda.com",'+
                        '"messages": {'+
                        '"message": {'+
                        '"@msg_type": "Informational",'+
                        '"@msg_number": "5000",'+
                        '"#text": "No warnings."'+
                        '}'+
                        '},'+
                        '"models": {'+
                        '"model": ['+
                        '{'+
                        '"@id": "FC3B3KJW",'+
                        '"@model_name": "CIVIC 1.5T 2DR EX",'+
                        '"@model_year": "2019",'+
                        '"@msrp": "23300.00",'+
                        '"@dhcost": "955.00",'+
                        '"colors": {'+
                        '"exteriorcolor": ['+
                        '{'+
                        '"@id": "302",'+
                        '"interiorcolor": ['+
                        '{'+
                        '"@id": "401",'+
                        '"@exterior_color_cd": "RE"'+
                        '}'+
                        ']'+
                        '},'+
                        '{'+
                        '"@id": "8083",'+
                        '"interiorcolor": ['+
                        '{'+
                        '"@id": "401",'+
                        '"@exterior_color_cd": "BK"'+
                        '},'+
                        '{'+
                        '"@id": "418",'+
                        '"@exterior_color_cd": "BX",'+
                        '"@exterior_mfg_color_cd_extension": "X"'+
                        '}'+
                        ']'+
                        '},'+
                        '{'+
                        '"@id": "8889",'+
                        '"interiorcolor": ['+
                        '{'+
                        '"@id": "401",'+
                        '"@exterior_color_cd": "WX"'+
                        '},'+
                        '{'+
                        '"@id": "441",'+
                        '"@exterior_color_cd": "WY",'+
                        '"@exterior_mfg_color_cd_extension": "X"'+
                        '}'+
                        ']'+
                        '}'+
                        ']'+
                        '},'+
                        '"features": null,'+
                        '"accessories": {'+
                        '"accessory": ['+
                        '{'+
                        '"@op_cd": "CIVIC19133",'+
                        '"@part_number": "08E16-TBA-100A",'+
                        '"@rolled_up": "349.00",'+
                        '"rules": {'+
                        '"rule": ['+
                        '{'+
                        '"@cd": "R",'+
                        '"@msrp": "199.00",'+
                        '"@op_cd": "CIVIC19211",'+
                        '"@derived": "0"'+
                        '}'+
                        '],'+
                        '"reverserules": {'+
                        '"rule": ['+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "724.00",'+
                        '"@op_cd": "CIVIC19187"'+
                        '}'+
                        ']'+
                        '}'+
                        '}'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19134",'+
                        '"colors": {'+
                        '"color": ['+
                        '{'+
                        '"@id": "8083",'+
                        '"@part_number": "08F01-TBA-110E"'+
                        '},'+
                        '{'+
                        '"@id": "8961",'+
                        '"@part_number": "08F01-TBA-1Z0E"'+
                        '}'+
                        ']'+
                        '}'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19135",'+
                        '"colors": {'+
                        '"color": ['+
                        '{'+
                        '"@id": "8083",'+
                        '"@part_number": "08F03-TBG-110"'+
                        '},'+
                        '{'+
                        '"@id": "8961",'+
                        '"@part_number": "08F03-TBG-1Z1"'+
                        '}'+
                        ']'+
                        '},'+
                        '"rules": {'+
                        '"rule": ['+
                        '{'+
                        '"@cd": "E",'+
                        '"@msrp": "104.00",'+
                        '"@op_cd": "CIVIC19141",'+
                        '"@derived": "0"'+
                        '}'+
                        '],'+
                        '"reverserules": null'+
                        '}'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19136",'+
                        '"colors": {'+
                        '"color": ['+
                        '{'+
                        '"@id": "8083",'+
                        '"@part_number": "08F04-TBG-110"'+
                        '},'+
                        '{'+
                        '"@id": "8961",'+
                        '"@part_number": "08F04-TBG-1Z0"'+
                        '}'+
                        ']'+
                        '},'+
                        '"rules": {'+
                        '"rule": ['+
                        '{'+
                        '"@cd": "E",'+
                        '"@msrp": "104.00",'+
                        '"@op_cd": "CIVIC19141",'+
                        '"@derived": "0"'+
                        '}'+
                        '],'+
                        '"reverserules": null'+
                        '}'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19137",'+
                        '"colors": {'+
                        '"color": ['+
                        '{'+
                        '"@id": "8083",'+
                        '"@part_number": "08F13-TBG-110"'+
                        '},'+
                        '{'+
                        '"@id": "8961",'+
                        '"@part_number": "08F13-TBG-1Z0"'+
                        '}'+
                        ']'+
                        '}'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19138",'+
                        '"colors": {'+
                        '"color": ['+
                        '{'+
                        '"@id": "302",'+
                        '"@part_number": "08F21-TBA-180A"'+
                        '}'+
                        ']'+
                        '},'+
                        '"rules": {'+
                        '"rule": ['+
                        '{'+
                        '"@cd": "E",'+
                        '"@msrp": "285.00",'+
                        '"@op_cd": "CIVIC19223",'+
                        '"@derived": "0"'+
                        '},'+
                        '{'+
                        '"@cd": "E",'+
                        '"@msrp": "285.00",'+
                        '"@op_cd": "CIVIC19289",'+
                        '"@derived": "0"'+
                        '}'+
                        '],'+
                        '"reverserules": null'+
                        '}'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19139",'+
                        '"@part_number": "08L96-TA0-101A",'+
                        '"displaygroups": {'+
                        '"displaygroup": ['+
                        '{'+
                        '"@cd": "HONDA_EXT_CARGO"'+
                        '},'+
                        '{'+
                        '"@cd": "HONDA_EXT_PROTECTION"'+
                        '}'+
                        ']'+
                        '}'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19168",'+
                        '"rules": {'+
                        '"rule": ['+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "104.00",'+
                        '"@op_cd": "CIVIC19141",'+
                        '"@derived": "0"'+
                        '},'+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "155.00",'+
                        '"@op_cd": "CIVIC19144",'+
                        '"@derived": "0"'+
                        '}'+
                        ']'+
                        '}'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19169",'+
                        '"rules": {'+
                        '"rule": ['+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "104.00",'+
                        '"@op_cd": "CIVIC19141",'+
                        '"@derived": "0"'+
                        '},'+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "114.00",'+
                        '"@op_cd": "CIVIC19151",'+
                        '"@derived": "0"'+
                        '},'+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "155.00",'+
                        '"@op_cd": "CIVIC19144",'+
                        '"@derived": "0"'+
                        '}'+
                        ']'+
                        '}'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19170",'+
                        '"rules": {'+
                        '"rule": ['+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "56.00",'+
                        '"@op_cd": "CIVIC19158",'+
                        '"@derived": "0"'+
                        '},'+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "114.00",'+
                        '"@op_cd": "CIVIC19151",'+
                        '"@derived": "0"'+
                        '},'+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "155.00",'+
                        '"@op_cd": "CIVIC19144",'+
                        '"@derived": "0"'+
                        '}'+
                        ']'+
                        '}'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19171",'+
                        '"rules": {'+
                        '"rule": ['+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "56.00",'+
                        '"@op_cd": "CIVIC19158",'+
                        '"@derived": "0"'+
                        '},'+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "104.00",'+
                        '"@op_cd": "CIVIC19141",'+
                        '"@derived": "0"'+
                        '},'+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "114.00",'+
                        '"@op_cd": "CIVIC19151",'+
                        '"@derived": "0"'+
                        '}'+
                        ']'+
                        '}'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19172",'+
                        '"rules": {'+
                        '"rule": ['+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "56.00",'+
                        '"@op_cd": "CIVIC19158",'+
                        '"@derived": "0"'+
                        '},'+
                        '{'+
                        '"@cd": "I",'+
                        '"@msrp": "104.00",'+
                        '"@op_cd": "CIVIC19141",'+
                        '"@derived": "0"'+
                        '}'+
                        ']'+
                        '}'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19228",'+
                        '"rules": {'+
                        '"rule": ['+
                        '{'+
                        '"@cd": "E",'+
                        '"@msrp": "250.00",'+
                        '"@op_cd": "CIVIC19160",'+
                        '"@derived": "0"'+
                        '},'+
                        '{'+
                        '"@cd": "E",'+
                        '"@msrp": "250.00",'+
                        '"@op_cd": "CIVIC19226",'+
                        '"@derived": "0"'+
                        '},'+
                        '{'+
                        '"@cd": "E",'+
                        '"@msrp": "250.00",'+
                        '"@op_cd": "CIVIC19227",'+
                        '"@derived": "0"'+
                        '}'+
                        '],'+
                        '"reverserules": null'+
                        '}'+
                        '}'+
                        ']'+
                        '}'+
                        '}'+
                        ']'+
                        '},'+
                        '"colors": {'+
                        '"color": ['+
                        '{'+
                        '"@id": "302",'+
                        '"@name": "Rallye Red",'+
                        '"@color_cd": "RE",'+
                        '"@mfg_color_cd": "R-513",'+
                        '"@color_type": "E"'+
                        '},'+
                        '{'+
                        '"@id": "8961",'+
                        '"@name": "Tonic Yellow Pearl",'+
                        '"@color_cd": "YF",'+
                        '"@mfg_color_cd": "Y-78P",'+
                        '"@color_type": "E"'+
                        '}'+
                        ']'+
                        '},'+
                        '"accessories": {'+
                        '"accessory": ['+
                        '{'+
                        '"@op_cd": "CIVIC19133",'+
                        '"@name": "Armrest w/Blue Illumination",'+
                        '"@quantity": "1",'+
                        '"@labor_time": "0.40",'+
                        '"@msrp": "150.00"'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19375",'+
                        '"@name": "Tires (P215/50R17)",'+
                        '"@quantity": "4",'+
                        '"@msrp": "529.40"'+
                        '}'+
                        ']'+
                        '},'+
                        '"assets": {'+
                        '"asset": ['+
                        '{'+
                        '"@id": "1308140",'+
                        '"@type_cd": "IMGMIDSIZE",'+
                        '"@view_cd": "34FRONT",'+
                        '"@path": "/-/media/Honda-Automobiles/Vehicles/2019/Civic Coupe/AW/Medium/medium_CivicCoupe_front_CIVIC15T2DREX_2019_AegeanBlueMetallic_FC3B3KJW_B-593M.jpg",'+
                        '"asset-color-match": {'+
                        '"color": {'+
                        '"@id": "8499"'+
                        '}'+
                        '}'+
                        '},'+
                        '{'+
                        '"@id": "1308237",'+
                        '"@type_cd": "BASECAR",'+
                        '"@view_cd": "34FRONT",'+
                        '"@path": "/-/media/Honda-Automobiles/Vehicles/2019/Civic Coupe/AW/Carshot/carshot_CivicCoupe_front_CIVIC15T2DREX_2019_TonicYellowPearl_FC3B3KJW_Y-78P.png",'+
                        '"asset-color-match": {'+
                        '"color": {'+
                        '"@id": "8961"'+
                        '}'+
                        '}'+
                        '}'+
                        ']'+
                        '},'+
                        '"displaygroups": {'+
                        '"displaygroup": ['+
                        '{'+
                        '"@cd": "HONDA_EXT_OTHER",'+
                        '"@description": "Honda Exterior - Other",'+
                        '"accessories": {'+
                        '"accessory": ['+
                        '{'+
                        '"@op_cd": "CIVIC19145",'+
                        '"@sort_order": "2147483647"'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19158",'+
                        '"@sort_order": "2147483647"'+
                        '}'+
                        ']'+
                        '}'+
                        '},'+
                        '{'+
                        '"@cd": "HONDA_EXT_PROTECTION",'+
                        '"@description": "Honda Exterior - Protection",'+
                        '"accessories": {'+
                        '"accessory": ['+
                        '{'+
                        '"@op_cd": "CIVIC19139",'+
                        '"@sort_order": "2147483647"'+
                        '},'+
                        '{'+
                        '"@op_cd": "CIVIC19158",'+
                        '"@sort_order": "2147483647"'+
                        '}'+
                        ']'+
                        '}'+
                        '}'+
                        ']'+
                        '},'+
                        '"dependency_info": {'+
                        '"dependency": {'+
                        '"@name": "Honda.2021.Model Group",'+
                        '"@filename": "",'+
                        '"@type": "ModelGroup"'+
                        '},'+
                        '"cache": {'+
                        '"@filename": ""'+
                        '}'+
                        '}'+
                        '},'+
                        '"private": {'+
                        '"server_info": {'+
                        '"@server_ip": "10.177.9.61",'+
                        '"@host_name": "CUA43362WEB326"'+
                        '},'+
                        '"errors": {'+
                        '"@base_exception_guid": "",'+
                        '"@exception_level": "",'+
                        '"@exception_type": ""'+
                        '}'+
                        '}'+
                        '}'+
                        '}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}