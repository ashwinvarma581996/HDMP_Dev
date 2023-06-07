/**
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 10-10-2021
 * @last modified by  : mbunch@gorillagroup.com
**/
({
    init : function(component, event, helper) {
        // Get the record ID attribute
        const jsonDataUrl = component.get("v.url");
        const urlSplit = jsonDataUrl ? jsonDataUrl.split('?data=') : '';
        const callbackUrl = urlSplit ? urlSplit[0] : '';
        const jsonData = urlSplit ? urlSplit[1] : '';
        let returnUrl = '';
        if (jsonData) {
            const resUtils = component.find('resUtils');
            const compressedDataUrl = resUtils.compressJSONString(jsonData);
            returnUrl = `${callbackUrl}?data=${compressedDataUrl}`;
        }
        console.log("URL --->", returnUrl);
        window.location.href = returnUrl;

    }})