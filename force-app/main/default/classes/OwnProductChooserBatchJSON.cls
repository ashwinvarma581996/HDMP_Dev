//****************************************************************************** 
// File Name:       OwnProductChooserBatchJSON.cls
// Summary:         JSON Parser class for OwnProductChooserBatch.cls
// Created On:      22-12-2021
// Created By:      Girish J (Wipro) 
// Test Classes:    OwnProductChooserBatchTest.cls
// Data I/O:        
// Honda Jira Story: DOE-2520 & DOE-2568 
//*******************************************************************************
public class OwnProductChooserBatchJSON {
	//This is requestBody. We need to change it to dynamic format once we have the field mappings.
	//This requestBody are the input parameters for the external system.
	//Once we have the mappings we could set the dynamic format. 
    /* public static String requestBody = '{'+
    '"mit": {'+
        '"client_info": {'+
            '"@application_id": "powersports.honda.com",'+
            '"@echo_input": "true",'+
            '"@server_ip": "test",'+
            '"@session_id": "test",'+
            '"@domain": "prestage2.powersports.honda.com",'+
            '"@environment": "prestage"'+
        '},'+
		'"input_parameters": {'+
		'"required": {'+
			'"source_cd": "MOTORCYCLE",'+
			'"site_cd": "MOTORCYCLE",'+
			'"category_cd": "CONFIG",'+
			'"division": {'+
				'"@version_num": "0",'+
				'"#text": "M"'+
			'},'+
			'"brand_hierarchy": {'+
				'"brand_line_id": ['+
					'"1"'+
				']'+
		   '}'+
		'},'+
		'"optional": {'+
			'"assets": {'+
				'"asset": ['+
					'{'+
						'"@type_cd": "MCGMHRIMG"'+
					'}'+
				'],'+
				'"@suppress_asset_name": "false",'+
				'"@suppress_asset_description": "false"'+
			'},'+
			'"marketing_texts": {'+
				'"text": ['+
					'{'+
						'"@type_cd": "MCHMMPDIS",'+
						   '"@source_cd": "MOTORCYCLE"'+
					'},'+

					'{'+
						'"@type_cd": "MCTRIM",'+
						'"@source_cd": "MOTORCYCLE"'+
					'}'+
				']'+
			'},'+
			'"custom_types": {'+
				'"custom_type": ['+

					'{'+
						'"select_by_content_id": ['+

							'{'+
								'"@content_id": "Sitecore GUID",'+
								'"@version": "1"'+
							'},'+

							'{'+
								'"@content_id": "Sitecore GUID",'+
								'"@version": "1"'+
							'},'+

							'{'+
								'"@content_id": "Sitecore GUID",'+
								'"@version": "1"'+
							   '}'+
						'],'+
						'"select_by_custom_type_cd": ['+
							   '{'+
								'"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",'+
								'"@version": "1"'+
							'},'+
							'{'+
								'"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",'+
								'"@version": "1"'+
							'}'+
						']'+
					'},'+
					'{'+
						'"select_by_content_id": ['+
							'{'+
								'"@content_id": "Sitecore GUID",'+
								'"@version": "1"'+
							'},'+
							'{'+
								'"@content_id": "Sitecore GUID",'+
								'"@version": "1"'+
							'},'+
							'{'+
								'"@content_id": "Sitecore GUID",'+
								'"@version": "1"'+
							'}'+
						'],'+
						'"select_by_custom_type_cd": ['+
							'{'+
								'"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",'+
								'"@version": "1"'+
							'},'+
							'{'+
								'"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",'+
								'"@version": "1"'+
							'}'+
						']'+
					'}'+
				']'+
			'},'+
			'"attributes": {'+
				'"attribute": ['+
					'{'+
						'"@attribute_name": "2AT",'+
						'"@attribute_type_name": "TRANS"'+
					   '},'+
					'{'+
						'"@attribute_name": "CA",'+
						'"@attribute_type_name": "MOTORCYCLE EMISSION TYPE"'+
					'}'+
				']'+
			'},'+
			'"custom_attributes": {'+
				'"custom_attribute": ['+
					'{'+
						'"@custom_attribute_name": "Black",'+
						'"@custom_attribute_type_name": "Base Color Name",'+
						'"@source_cd": "MOTORCYCLE"'+
					'},'+
					'{'+
						'"@custom_attribute_type_name": "HEX",'+
						'"@source_cd": "MOTORCYCLE"'+
					'}'+
				']'+
			   '}'+
		'}'+
	'},'+
        '"private": {'+
            '"template_info": {'+
                '"@filename": "BrandLineHierarchy-GetBaseDetail-MIT.xml",'+
                '"@xsd": "BrandLineHierarchy-GetBaseDetail-MIT.xsd",'+
                '"@class": "BrandLineHierarchy",'+
                '"@method": "GetBaseDetail"'+
            '},'+
            '"stored_procedure": {'+
                '"@name": "ecnetsp_BrandLineHierarchy_GetBrandLineBaseDetails"'+
            '}'+
        '},'+
        '"@mit_version_number": "1",'+
        '"@mit_version_date": "2018-04-12"'+
    '}'+
'}'; */

// Response body for optional parameters
/*     public static String requestBody = '{' +
        '"mit": {' +
            '"client_info": {' +
                '"@application_id": "powersports.honda.com",' +
                '"@echo_input": "true",' +
                '"@server_ip": "test",' +
                '"@session_id": "test",' +
                '"@domain": "prestage2.powersports.honda.com",' +
                '"@environment": "prestage"' +
            '},' +
            '"input_parameters": {' +
                '"required": {' +
                    '"source_cd": "MOTORCYCLE",' +
                    '"site_cd": "MOTORCYCLE",' +
                    '"category_cd": "CONFIG",' +
                    '"division": {' +
                        '"@version_num": "0",' +
                        '"#text": "M"' +
                    '},' +
                    '"hierarchy_type": "product line"' +
                '},' +
                '"optional": {' +
                    '"active_brand_only": "active",' +
                    '"assets": {' +
                        '"asset": [' +
                            '{' +
                                '"@type_cd": "MC360",' +
                                '"@view_cd": "34FRONT",' +
                                '"@source_cd": "MOTORCYCLE"' +
                            '},' +
                            '{' +
                                '"@type_cd": "MCACCDTL",' +
                                '"@view_cd": "FRONT",' +
                                '"@source_cd": "MOTORCYCLE"' +
                            '},' +
                            '{' +
                                '"@type_cd": "MCCOTHUMB",' +
                                '"@view_cd": "FRONT",' +
                                '"@source_cd": "MOTORCYCLE"' +
                            '}' +
                        '],' +
                        '"@suppress_asset_name": "false",' +
                        '"@suppress_asset_description": "false"' +
                    '},' +
                    '"marketing_texts": {' +
                        '"text": [' +
                            '{' +
                                '"@type_cd": "MCPROMOTXT",' +
                                '"@source_cd": "MOTORCYCLE"' +
                            '},' +
                            '{' +
                                '"@type_cd": "MODELDESC",' +
                                '"@source_cd": "MOTORCYCLE"' +
                            '}' +
                        ']' +
                    '},' +
                    '"custom_types": {' +
                        '"custom_type": [' +
                            '{' +
                                '"select_by_content_id": [' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '}' +
                                '],' +
                                '"select_by_custom_type_cd": [' +
                                    '{' +
                                        '"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",' +
                                        '"@version": "1"' +
                                    '}' +
                                ']' +
                            '},' +
                            '{' +
                                '"select_by_content_id": [' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '}' +
                                '],' +
                                '"select_by_custom_type_cd": [' +
                                    '{' +
                                        '"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",' +
                                        '"@version": "1"' +
                                    '}' +
                                ']' +
                            '}' +
                        ']' +
                    '},' +
                    '"attributes": {' +
                        '"attribute": [' +
                            '{' +
                                '"@attribute_name": "2AT",' +
                                '"@attribute_type_name": "TRANS"' +
                            '},' +
                            '{' +
                                '"@attribute_name": "CA",' +
                                '"@attribute_type_name": "MOTORCYCLE EMISSION TYPE"' +
                            '}' +
                        ']' +
                    '},' +
                    '"filter_by_level": {' +
                        '"level": [{' +
                            '"@level_type_name": "Category",' +
                            '"@level_name": "Touring",' +
                            '"@parent_level_type_name": "Segment",' +
                            '"@parent_level_name": "Street"' +
                        '}]' +
                    '}' +
                '}' +
            '},' +
            '"private": {' +
                '"template_info": {' +
                    '"@filename": "BrandHierarchy-GetBrandlineProductByDivision-MIT.xml",' +
                    '"@xsd": "BrandHierarchy-GetBrandlineProductByDivision-MIT.xsd",' +
                    '"@class": "BrandHierarchy",' +
                    '"@method": "GetBrandlineProductByDivision"' +
                '},' +
                '"stored_procedure": {' +
                    '"@name": "ecnetsp_BrandLineHierarchy_GetBrandlineProductByDivision"' +
                '}' +
            '},' +
            '"@mit_version_number": "1",' +
            '"@mit_version_date": "2018-04-12"' +
        '}' +
    '}'; */

    // Mandatory parameters only request body
/*     public static String requestBody = '{' +
        '"mit": {' +
            '"client_info": {' +
                '"@application_id": "powersports.honda.com",' +
                '"@echo_input": "false",' +
                '"@server_ip": "test",' +
                '"@session_id": "test",' +
                '"@domain": "prestage2.powersports.honda.com",' +
                '"@environment": "prestage"' +
            '},' +
            '"input_parameters": {' +
                '"required": {' +
                    '"source_cd": "MOTORCYCLE",' +
                    '"site_cd": "MOTORCYCLE",' +
                    '"category_cd": "CONFIG",' +
                    '"division": {' +
                        '"@version_num": "0",' +
                        '"#text": "M"' +
                    '},' +
                    '"hierarchy_type": "product line"' +
                '}' +
            '},' +
            '"private": {' +
                '"template_info": {' +
                    '"@filename": "BrandHierarchy-GetBrandlineProductByDivision-MIT.xml",' +
                    '"@xsd": "BrandHierarchy-GetBrandlineProductByDivision-MIT.xsd",' +
                    '"@class": "BrandHierarchy",' +
                    '"@method": "GetBrandlineProductByDivision"' +
                '},' +
                '"stored_procedure": {' +
                    '"@name": "ecnetsp_BrandLineHierarchy_GetBrandlineProductByDivision"' +
                '}' +
            '},' +
            '"@mit_version_number": "1",' +
            '"@mit_version_date": "2018-04-12"' +
        '}' +
    '}'; */

    // Optional paramters request body test (for Assets, colors, & marketing texts)
    /* public static String requestBodyPowersports = '{' +
        '"mit": {' +
            '"client_info": {' +
                '"@application_id": "powersports.honda.com",' +
                '"@echo_input": "true",' +
                '"@server_ip": "test",' +
                '"@session_id": "test",' +
                '"@domain": "prestage2.powersports.honda.com",' +
                '"@environment": "prestage"' +
            '},' +
            '"input_parameters": {' +
                '"required": {' +
                    '"source_cd": "MOTORCYCLE",' +
                    '"site_cd": "MOTORCYCLE",' +
                    '"category_cd": "CONFIG",' +
                    '"division": {' +
                        '"@version_num": "0",' +
                        '"#text": "M"' +
                    '},' +
                    '"hierarchy_type": "product line"' +
                '},' +
                '"optional": {' +
                    '"active_brand_only": "active",' +
                    '"assets": {' +
                        '"asset": [' +
                            '{' +
                                '"@type_cd": "MCGMHRIMG"' +
                            '}' +
                        '],' +
                        '"@suppress_asset_name": "false",' +
                        '"@suppress_asset_description": "false"' +
                    '},' +
                    '"marketing_texts": {' +
                        '"text": [' +
                            '{' +
                                '"@type_cd": "MCHMMPDIS",' +
                                '"@source_cd": "MOTORCYCLE"' +
                            '},' +
                            '{' +
                                '"@type_cd": "MCTRIM",' +
                                '"@source_cd": "MOTORCYCLE"' +
                            '}' +
                        ']' +
                    '},' +
                    '"custom_types": {' +
                        '"custom_type": [' +
                            '{' +
                                '"select_by_content_id": [' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '}' +
                                '],' +
                                '"select_by_custom_type_cd": [' +
                                    '{' +
                                        '"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",' +
                                        '"@version": "1"' +
                                    '}' +
                                ']' +
                            '},' +
                            '{' +
                                '"select_by_content_id": [' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '}' +
                                '],' +
                                '"select_by_custom_type_cd": [' +
                                    '{' +
                                        '"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",' +
                                        '"@version": "1"' +
                                    '}' +
                                ']' +
                            '}' +
                        ']' +
                    '},' +
                    '"attributes": {' +
                        '"attribute": [' +
                            '{' +
                                '"@attribute_name": "2AT",' +
                                '"@attribute_type_name": "TRANS"' +
                            '},' +
                            '{' +
                                '"@attribute_name": "CA",' +
                                '"@attribute_type_name": "MOTORCYCLE EMISSION TYPE"' +
                            '}' +
                        ']' +
                    '},' +
                    '"filter_by_level": {' +
                        '"level": [{' +
                            '"@level_type_name": "Category",' +
                            '"@level_name": "Touring",' +
                            '"@parent_level_type_name": "Segment",' +
                            '"@parent_level_name": "Street"' +
                        '}]' +
                    '}' +
                '}' +
            '},' +
            '"private": {' +
                '"template_info": {' +
                    '"@filename": "BrandHierarchy-GetBrandlineProductByDivision-MIT.xml",' +
                    '"@xsd": "BrandHierarchy-GetBrandlineProductByDivision-MIT.xsd",' +
                    '"@class": "BrandHierarchy",' +
                    '"@method": "GetBrandlineProductByDivision"' +
                '},' +
                '"stored_procedure": {' +
                    '"@name": "ecnetsp_BrandLineHierarchy_GetBrandlineProductByDivision"' +
                '}' +
            '},' +
            '"@mit_version_number": "1",' +
            '"@mit_version_date": "2018-04-12"' +
        '}' +
    '}'; */

    /* public static String requestBodyAcura_old = '{'+
        '"mit": {'+
        '"client_info": {'+
        '"@application_id": "owners.honda.com",'+
        '"@echo_input": "true",'+
        '"@server_ip": "test",'+
        '"@session_id": "test",'+
        '"@domain": "dev.owners.honda.com",'+
        '"@environment": "dev"'+
        '},'+
        '"input_parameters": {'+
        '"required": {'+
        '"source_cd": "ACURA",'+
        '"site_cd": "ACURA",'+
        '"category_cd": "CONFIG",'+
        '"division": {'+
        '"@version_num": "0",'+
        '"#text": "B"'+
        '},'+
        '"brand_hierarchy": {'+
        '"brand_line_id": ['+
        '"1403"'+
        ']'+
        '}'+
        '},'+
        '"optional": {'+
        '"assets": {'+
        '"@suppress_asset_name": "false",'+
        '"@suppress_asset_description": "false",'+
        '"asset": ['+
        '{'+
        '"@type_cd": "IMGOVERLAY",'+
        '"@view_cd": "34FRONT"'+
        '},'+
        '{'+
        '"@type_cd": "BASECAR",'+
        '"@view_cd": "34FRONT"'+
        '}'+
        ']'+
        '},'+
        '"marketing_texts": {'+
        '"text": ['+
        '{'+
        '"@type_cd": "TRIM_FN_NM"'+
        '}'+
        ']'+
        '}'+
        '}'+
        '},'+
        '"private": {'+
        '"template_info": {'+
        '"@filename": "BrandLineHierarchy-GetBaseDetail-MIT.xml",'+
        '"@xsd": "BrandLineHierarchy-GetBaseDetail-MIT.xsd",'+
        '"@class": "BrandLineHierarchy",'+
        '"@method": "GetBaseDetail"'+
        '},'+
        '"stored_procedure": {'+
        '"@name": "ecnetsp_BrandLineHierarchy_GetBrandLineBaseDetails"'+
        '}'+
        '},'+
        '"@mit_version_number": "1",'+
        '"@mit_version_date": "2018-04-12"'+
        '}'+
        '}'; */


    /* public static String requestBodyHonda = '{' +
        '"mit": {' +
            '"client_info": {' +
                '"@application_id": "owners.honda.com",' +
                '"@echo_input": "true",' +
                '"@server_ip": "test",' +
                '"@session_id": "test",' +
                '"@domain": "prestage2.owners.honda.com",' +
                '"@environment": "prestage"' +
            '},' +
            '"input_parameters": {' +
                '"required": {' +
                    '"source_cd": "HONDA",' +
                    '"site_cd": "HONDA",' +
                    '"category_cd": "CONFIG",' +
                    '"division": {' +
                        '"@version_num": "0",' +
                        '"#text": "A"' +
                    '},' +
                    '"brand_hierarchy": {' +
                        '"brand_line_id": [' +
                            '"1600"' +
                        ']' +
                    '}' +
                '},' +
                '"optional": {' +
                    '"assets": {' +
                        '"asset": [' +
                            '{' +
                            '"@type_cd": "IMGOVERLAY",' +
                            '"@view_cd": "34FRONT"' +
                            '},' +
                            '{' +
                            '"@type_cd": "BASECAR",' +
                            '"@view_cd": "34FRONT"' +
                            '}' +
                        '],' +
                        '"@suppress_asset_name": "false",' +
                        '"@suppress_asset_description": "false"' +
                    '},' +
                    '"marketing_texts": {' +
                        '"text": [' +
                            '{' +
                            '"@type_cd": "MDLMKTNAME"' +
                            '}' +
                        ']' +
                    '}' +
                '}' +
            '},' +
            '"private": {' +
                '"template_info": {' +
                    '"@filename": "BrandLineHierarchy-GetBaseDetail-MIT.xml",' +
                    '"@xsd": "BrandLineHierarchy-GetBaseDetail-MIT.xsd",' +
                    '"@class": "BrandLineHierarchy",' +
                    '"@method": "GetBaseDetail"' +
                '},' +
                '"stored_procedure": {' +
                    '"@name": "ecnetsp_BrandLineHierarchy_GetBrandLineBaseDetails"' +
                '}' +
            '},' +
        '"@mit_version_number": "1",' +
        '"@mit_version_date": "2018-04-12"' +
      '}' +
    '}'; */

    /* public static String requestBodyAcura = '{' +
        '"mit": {' +
          '"client_info": {' +
            '"@application_id": "owners.honda.com",' +
            '"@echo_input": "true",' +
            '"@server_ip": "test",' +
            '"@session_id": "test",' +
            '"@domain": "dev.owners.honda.com",' +
            '"@environment": "dev"' +
          '},' +
          '"input_parameters": {' +
            '"required": {' +
              '"source_cd": "ACURA",' +
              '"site_cd": "ACURA",' +
              '"category_cd": "CONFIG",' +
              '"division": {' +
                '"@version_num": "0",' +
                '"#text": "B"' +
              '},' +
              '"brand_hierarchy": {' +
                '"brand_line_id": [' +
                  '"1403"' +
                ']' +
              '}' +
            '},' +
            '"optional": {' +
              '"assets": {' +
                '"@suppress_asset_name": "false",' +
                '"@suppress_asset_description": "false",' +
                '"asset": [' +
                  '{' +
                    '"@type_cd": "IMGOVERLAY",' +
                    '"@view_cd": "34FRONT"' +
                  '},' +
                  '{' +
                    '"@type_cd": "BASECAR",' +
                    '"@view_cd": "34FRONT"' +
                  '}' +
                ']' +
              '},' +
              '"marketing_texts": {' +
                '"text": [' +
                  '{' +
                    '"@type_cd": "MODELDESC"' +
                  '}' +
                ']' +
              '}' +
            '}' +
          '},' +
          '"private": {' +
            '"template_info": {' +
              '"@filename": "BrandLineHierarchy-GetBaseDetail-MIT.xml",' +
              '"@xsd": "BrandLineHierarchy-GetBaseDetail-MIT.xsd",' +
              '"@class": "BrandLineHierarchy",' +
              '"@method": "GetBaseDetail"' +
            '},' +
            '"stored_procedure": {' +
              '"@name": "ecnetsp_BrandLineHierarchy_GetBrandLineBaseDetails"' +
            '}' +
          '},' +
          '"@mit_version_number": "1",' +
          '"@mit_version_date": "2018-04-12"' +
        '}' +
      '}'; */

    
    /* public static String getAcuraReqBodyByYear(String year){
        return '{' +
        '"mit": {' +
          '"client_info": {' +
            '"@application_id": "owners.honda.com",' +
            '"@echo_input": "true",' +
            '"@server_ip": "test",' +
            '"@session_id": "test",' +
            '"@domain": "dev.owners.honda.com",' +
            '"@environment": "dev"' +
          '},' +
          '"input_parameters": {' +
            '"required": {' +
              '"source_cd": "ACURA",' +
              '"site_cd": "ACURA",' +
              '"category_cd": "CONFIG",' +
              '"division": {' +
                '"@version_num": "0",' +
                '"#text": "B"' +
              '},' +
              '"brand_hierarchy": {' +
                '"brand_line_id": [' +
                  '"1403"' +
                ']' +
              '}' +
            '},' +
            '"optional": {' +
                '"model_year": "' + year + '",' +
                '"config_date": "01/01/' + year + '",' +
              '"assets": {' +
                '"@suppress_asset_name": "false",' +
                '"@suppress_asset_description": "false",' +
                '"asset": [' +
                  '{' +
                    '"@type_cd": "IMGOVERLAY",' +
                    '"@view_cd": "34FRONT"' +
                  '},' +
                  '{' +
                    '"@type_cd": "BASECAR",' +
                    '"@view_cd": "34FRONT"' +
                  '}' +
                ']' +
              '},' +
              '"marketing_texts": {' +
                '"text": [' +
                  '{' +
                    '"@type_cd": "MODELDESC"' +
                  '}' +
                ']' +
              '}' +
            '}' +
          '},' +
          '"private": {' +
            '"template_info": {' +
              '"@filename": "BrandLineHierarchy-GetBaseDetail-MIT.xml",' +
              '"@xsd": "BrandLineHierarchy-GetBaseDetail-MIT.xsd",' +
              '"@class": "BrandLineHierarchy",' +
              '"@method": "GetBaseDetail"' +
            '},' +
            '"stored_procedure": {' +
              '"@name": "ecnetsp_BrandLineHierarchy_GetBrandLineBaseDetails"' +
            '}' +
          '},' +
          '"@mit_version_number": "1",' +
          '"@mit_version_date": "2018-04-12"' +
        '}' +
      '}';
    } */

    
    /* public static String getHondaReqBodyByYear(String year){
        return '{' +
                '"mit": {' +
                    '"client_info": {' +
                        '"@application_id": "owners.honda.com",' +
                        '"@echo_input": "true",' +
                        '"@server_ip": "test",' +
                        '"@session_id": "test",' +
                        '"@domain": "prestage2.owners.honda.com",' +
                        '"@environment": "prestage"' +
                    '},' +
                    '"input_parameters": {' +
                        '"required": {' +
                            '"source_cd": "HONDA",' +
                            '"site_cd": "HONDA",' +
                            '"category_cd": "CONFIG",' +
                            '"division": {' +
                                '"@version_num": "0",' +
                                '"#text": "A"' +
                            '},' +
                            '"brand_hierarchy": {' +
                                '"brand_line_id": [' +
                                    '"1600"' +
                                ']' +
                            '}' +
                        '},' +
                        '"optional": {' +
                            '"model_year": "' + year + '",' +
                            '"config_date": "01/01/' + year + '",' +
                            '"assets": {' +
                                '"asset": [' +
                                    '{' +
                                    '"@type_cd": "IMGOVERLAY",' +
                                    '"@view_cd": "34FRONT"' +
                                    '},' +
                                    '{' +
                                    '"@type_cd": "BASECAR",' +
                                    '"@view_cd": "34FRONT"' +
                                    '}' +
                                '],' +
                                '"@suppress_asset_name": "false",' +
                                '"@suppress_asset_description": "false"' +
                            '},' +
                            '"marketing_texts": {' +
                                '"text": [' +
                                    '{' +
                                    '"@type_cd": "MDLMKTNAME"' +
                                    '},' +
                                    '{' +
                                    '"@type_cd": "TRIM_FN_NM"' +
                                    '}' +
                                ']' +
                            '}' +
                        '}' +
                    '},' +
                    '"private": {' +
                        '"template_info": {' +
                            '"@filename": "BrandLineHierarchy-GetBaseDetail-MIT.xml",' +
                            '"@xsd": "BrandLineHierarchy-GetBaseDetail-MIT.xsd",' +
                            '"@class": "BrandLineHierarchy",' +
                            '"@method": "GetBaseDetail"' +
                        '},' +
                        '"stored_procedure": {' +
                            '"@name": "ecnetsp_BrandLineHierarchy_GetBrandLineBaseDetails"' +
                        '}' +
                    '},' +
                '"@mit_version_number": "1",' +
                '"@mit_version_date": "2018-04-12"' +
            '}' +
            '}';
    } */


    /* public static String getBrandLineReqBod = '{' +
        '"mit": {' +
            '"client_info": {' +
                '"@application_id": "automobiles.honda.com",' +
                '"@echo_input": "true",' +
                '"@server_ip": "test",' +
                '"@session_id": "test",' +
                '"@domain": "staging.automobiles.honda.com",' +
                '"@environment": "staging"' +
            '},' +
            '"input_parameters": {' +
                '"required": {' +
                    '"source_cd": "HONDA",' +
                    '"site_cd": "HONDA",' +
                    '"category_cd": "CONFIG",' +
                    '"division": {' +
                        '"@version_num": "0",' +
                        '"#text": "A"' +
                    '},' +
                    '"hierarchy_type": "product line"' +
                '},' +
                '"optional": {' +
                    '"active_brand_only": "active",' +
                    '"assets": {' +
                        '"@suppress_asset_name": "true",' +
                        '"@suppress_asset_description": "true",' +
                        '"asset": [' +
                            '{' +
                                '"@type_cd": "IMGOVERLAY",' +
                                '"@view_cd": "34FRONT"' +
                            '},' +
                            '{' +
                                '"@type_cd": "IMGMIDSIZE",' +
                                '"@view_cd": "34FRONT"' +
                            '},' +
                            '{' +
                                '"@type_cd": "BASECAR",' +
                                '"@view_cd": "34FRONT"' +
                            '}' +
                        ']' +
                    '},' +
                    '"custom_types": {' +
                        '"custom_type": [' +
                            '{' +
                                '"select_by_content_id": [' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '}' +
                                '],' +
                                '"select_by_custom_type_cd": [' +
                                    '{' +
                                        '"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",' +
                                        '"@version": "1"' +
                                    '}' +
                                ']' +
                            '},' +
                            '{' +
                                '"select_by_content_id": [' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@content_id": "Sitecore GUID",' +
                                        '"@version": "1"' +
                                    '}' +
                                '],' +
                                '"select_by_custom_type_cd": [' +
                                    '{' +
                                        '"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",' +
                                        '"@version": "1"' +
                                    '},' +
                                    '{' +
                                        '"@custom_type_cd": "eConfig Custom Type i.e. Event, Article, etc defined by Vendor",' +
                                        '"@version": "1"' +
                                    '}' +
                                ']' +
                            '}' +
                        ']' +
                    '},' +
                    '"attributes": {' +
                        '"attribute": [' +
                            '{' +
                                '"@attribute_name": "Clutch and Brake Controls",' +
                                '"@attribute_type_name": "BUILD SPEC OPTION"' +
                            '}' +
                        ']' +
                    '},' +
                    '"filter_by_level": {' +
                        '"level": [{' +
                            '"@level_type_name": "Category",' +
                            '"@level_name": "Touring",' +
                            '"@parent_level_type_name": "Odyssey",' +
                            '"@parent_level_name": "Odyssey Touring"' +
                        '}]' +
                    '}' +
                '}' +
            '},' +
            '"private": {' +
                '"template_info": {' +
                    '"@filename": "BrandHierarchy-GetBrandlineProductByDivision-MIT.xml",' +
                    '"@xsd": "BrandHierarchy-GetBrandlineProductByDivision-MIT.xsd",' +
                    '"@class": "BrandHierarchy",' +
                    '"@method": "GetBrandlineProductByDivision"' +
                '},' +
                '"stored_procedure": {' +
                    '"@name": "ecnetsp_BrandLineHierarchy_GetBrandlineProductByDivision"' +
                '}' +
            '},' +
            '"@mit_version_number": "1",' +
            '"@mit_version_date": "2018-04-12"' +
        '}' +
    '}'; */


    public static ResponseWrapper parseResponseJson(String json) {
        return (ResponseWrapper) System.JSON.deserialize(json, ResponseWrapper.class);
    }
        
    public class ResponseWrapper {
        public cls_mot mot;
    }
    
    public cls_mot mot;
	public class cls_mot {
		public cls_input_parameters input_parameters;
		public String id;	//1
		public cls_db_results db_results;
	}
	public class cls_input_parameters {
		public cls_required required;
		public cls_optional optional;
	}
	public class cls_required {
		public String source_cd;	//MOTORCYCLE
		public String site_cd;	//MOTORCYCLE
		public cls_division division;
		public String category_cd;	//CONFIG
		public cls_brand_hierarchy brand_hierarchy;
	}
	public class cls_division {
		public String name;	//Powersports
		public cls_marketing_texts marketing_texts;
		public cls_hierarchies hierarchies;
		public cls_display_groups display_groups;
		public cls_custom_types custom_types;
		public cls_custom_attributes custom_attributes;
		public cls_colors colors;
		public String cd;	//M
		public cls_attributes attributes;
		public cls_assets assets;
		public cls_accessories accessories;
	}
	public class cls_name {
	}
	public class cls_marketing_texts {
		public cls_text[] text;
	}

	public class cls_text{
		public String id;	
		public String type_cd;
		public String content_id;
		public String text;
	}
	public class cls_hierarchies {
		public cls_brand_hierarchy[] brand_hierarchy;
	}
	public class cls_display_groups {
	}
	public class cls_custom_types {
	}
	public class cls_custom_attributes {
	}
	public class cls_colors {
		public cls_exterior[] exterior;
	}
	public class cls_asset_color_match {
		public cls_color[] color;
	}
	public class cls_color {
		public String id;	//8917
	}

	public class cls_cd {
	}
	public class cls_attributes {
		public cls_attribute[] attribute;
	}
	public class cls_assets {
		public cls_asset[] asset;
	}
	public class cls_asset{
		public String id;	//1320616
		public String type_cd;	//MCGMHRIMG
		public String view_cd;	//FRONT
		public String path;	//-/media/products/family/cb500f/trims/trim-main/cb500f/2019/2019-cb500f-grand_prix_red-650x380.png
		public String name;	//2019-CB500F-Grand_Prix_Red-650x380
		public String description;	//
		public String content_id;	//3fcc2d40-01ab-40d8-8d6b-85062d01be22
		public cls_asset_color_match asset_color_match;
		public cls_custom_attributes custom_attributes;
	}
	public class cls_accessories {
	}
	public class cls_brand_hierarchy {
		public String type;	//Product Line
		public String cd;	//P
		public cls_brand[] brand;
	}
	public class cls_type {
	}
	public class cls_brand {
		public String id;	//color_27
		public cls_brand[] brand;
		public cls_brand_details brand_details; 
		public cls_brand_info brand_info; 

	}
	public class cls_optional {
		public cls_marketing_texts marketing_texts;
		public cls_custom_types custom_types;
		public cls_custom_attributes custom_attributes;
		public cls_attributes attributes;
		public cls_assets assets;
	}
	public class cls_custom_attribute {
		public String type;	//Color
		public String id;	//color_27
		public String custom_attribute_type;	//Base Color Name
		public String custom_attribute_name;	//Black
	}
	public class cls_id {
	}
	public class cls_custom_attribute_type {
	}
	public class cls_attribute {
		public String id;	//2479
		public String attribute_type;	//MOTORCYCLE EMISSION TYPE
		public String attribute_name;	//CA
	}
	public class cls_attribute_type {
	}
	public class cls_db_results {
		public String when_cached;	//2021-12-22T10:53:04.8164425Z
		public String from_cache;	//true
		public cls_division division;
		public cls_dependency_info dependency_info;
		public String cached_by;	//ownerportal.honda.com
	}
	public class cls_brand_info {
		public cls_models models;
		public cls_marketing_texts marketing_texts;
		public cls_custom_types custom_types;
		public cls_custom_attributes custom_attributes;
		public cls_assets assets;
		public cls_active_model_years active_model_years;
	}
	public class cls_models {
		public cls_model[] model;
	}
	public class cls_active_model_years {
		public cls_year[] year;
	}
	public class cls_year {
		public String text;	//2022
		public String highest_model_msrp;	//32800.00
		public String highest_model_id;	//GL1800DAN
		public String base_model_msrp;	//32800.00
		public String base_model_id;	//GL1800DAN
	}
	public class cls_brand_details {
		public String tree_level;	//4
		public String parent_id;	//70
        public String brand_line_type_name;
		public String highest_model_msrp;	//32800.00
		public String highest_model_id;	//GL1800DAN
		public String brand_line_type_cd;	//M
		public String brand_line_name;	//Gold Wing Tour Airbag Automatic DCT
		public String brand_level;	//5
		public String base_model_msrp;	//31500.00
		public String base_model_id;	//GL1800DAJ
	}
	public class cls_model {
		public String year;	//2018
		public String sort_order;	//5
		public String name;	//GOLDWING TOUR AIR BAG DCT
		public String msrp;	//31500.00
		public cls_marketing_texts marketing_texts;
		public String id;	//GL1800DAJ
		public cls_custom_types custom_types;
		public cls_custom_attributes custom_attributes;
		public cls_colors colors;
		public cls_attributes attributes;
		public cls_assets assets;
		public cls_accessories accessories;
	}
	public class cls_exterior {
		public String name;	//Honda Phantom Camo®
		public String mfg_color_cd;	//YRA05
		public cls_marketing_texts marketing_texts;
		public cls_interior[] interior;
		public String id;	//12
		public cls_custom_attributes custom_attributes;
		public String color_type;	//E
		public String color_cd;	//BE
	}
	public class cls_mfg_color_cd {
	}
	public class cls_interior {
		public String name;	//Mc Dummy Interior Color
		public String mfg_color_cd;	//MC-DUMMY
		public cls_marketing_texts marketing_texts;
		public String id;	//1011
		public cls_custom_attributes custom_attributes;
		public String color_type;	//I
		public String color_cd;	//ZZ
	}
	public class cls_color_type {
	}
	public class cls_color_cd {
	}
	public class cls_dependency_info {
		public cls_dependency[] dependency;
		public cls_cache cache;
	}
	public class cls_dependency {
		public String type;	//ModelGroup
		public String name;	//MOTORCYCLE.2021.Model Group
		public String filename;	//
	}
	public class cls_cache {
		public String filename;	//
	}
}