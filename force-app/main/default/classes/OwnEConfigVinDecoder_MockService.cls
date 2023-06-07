global class OwnEConfigVinDecoder_MockService implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req){
        
        String body = '{'+
                '"mot": {'+
                '"@id": "1",'+
                '"input_parameters": {'+
                '"required": {'+
                '"vins": {'+
                '"vin": {'+
                '"@vin_number": "2HKRM3H53GH500289",'+
                '"@division_cd": "A"'+
                '}'+
                '}'+
                '},'+
                '"optional": {'+
                '"assets": {'+
                '"@suppress_asset_name": "true",'+
                '"@suppress_asset_description": "true",'+
                '"asset": ['+
                '{'+
                '"@type_cd": "IMGOVERLAY",'+
                '"@view_cd": "34FRONT"'+
                '},'+
                '{'+
                '"@type_cd": "IMGMIDSIZE",'+
                '"@view_cd": "34FRONT"'+
                '},'+
                '{'+
                '"@type_cd": "BASECAR",'+
                '"@view_cd": "34FRONT"'+
                '}'+
                ']'+
                '}'+
                '}'+
                '},'+
                '"db_results": {'+
                '"@when_cached": "2021-07-21T04:46:02.5694864Z",'+
                '"@from_cache": "true",'+
                '"@cached_by": "ownerportal.honda.com",'+
                '"messages": {'+
                '"message": {'+
                '"@msg_type": "Informational",'+
                '"@msg_number": "5000",'+
                '"#cdata-section": "No warnings."'+
                '}'+
                '},'+
                '"vins": {'+
                '"vin": ['+
                '{'+
                '"@number": "2HKRM3H53GH500289",'+
                '"model": {'+
                '"@id": "RM3H5GJW",'+
                '"@model_group_name": "CR-V",'+
                '"@trim_name": "2WD EX",'+
                '"@trans_name": "Continuously Variable Transmission",'+
                '"@make": "Honda",'+
                '"@division_cd": "A",'+
                '"@model_name": "CR-V 5DR 2WD EX",'+
                '"@model_year": "2016",'+
                '"colors": {'+
                '"color": ['+
                '{'+
                '"@id": "418",'+
                '"@color_type": "I",'+
                '"@name": "Gray",'+
                '"@color_cd": "GR"'+
                '},'+
                '{'+
                '"@id": "8385",'+
                '"@color_type": "E",'+
                '"@name": "Modern Steel Metallic",'+
                '"@color_cd": "GX",'+
                '"@mfg_color_cd": "NH-797M",'+
                '"@base_color_name": "Gray",'+
                '"assets": {'+
                '	"asset": ['+
                '		{'+
                '			"@id": "1270021",'+
                '			"@type_cd": "BASECAR",'+
                '			"@view_cd": "34FRONT",'+
                '			"@path": "https://automobiles.honda.com/images/2016/cr-v/configurations/base-cars/MS_ex2wd_34FRONT.png"'+
                '		},'+
                '		{'+
                '			"@id": "1270072",'+
                '			"@type_cd": "IMGMIDSIZE",'+
                '			"@view_cd": "34FRONT",'+
                '			"@path": "https://automobiles.honda.com/images/shopping-assets/medium/2016/RM3H5GJW_Modern_Steel_Metallic_medium.jpg"'+
                '		}'+
                '	]'+
                '}'+
                '}'+
                ']'+
                '},'+
                '"accessories": null,'+
                '"marketing_texts": null'+
                '}'+
                '}'+
                ']'+
                '},'+
                '"dependency_info": {'+
                '"dependency": ['+
                '{'+
                '"@name": ".2016.CR-V",'+
                '"@filename": "",'+
                '"@type": "ModelGroup"'+
                '}'+
                '],'+
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