//============================================================================
// Title:    Data Access Controller for Honda MyGarage Community
// Summary:  Common logic to support Data Access:  to/from Server via Apex or to/from browser Local Storage
// Details:  If the user is logged in then data access is from the server.  but if the user is a Guest then data access is from browser Local Storage
//
// Sample Usage:
// 1) add this line into the js of your lwc: 
//          a) import { refreshGarage } from 'c/ownAdobedtmUtils';
//          b) import { getContext } from 'c/ownAdobedtmUtils';
// 2) call the methods from your lwc:
//          a) var garage = refreshGarage();
//          b) var context = getContext();
//			
//--------------------------------------------------------------------------------------
//
// History:
// September 2, 2022 Arunprasad Nagarajan (Wipro) Initial coding
//===========================================================================

import isGuest from '@salesforce/user/isGuest';
import { getProductContext, getContext, getOrigin, getKnowledgeArticleByUrlName } from 'c/ownDataUtils';
import getFamilyValue from '@salesforce/apex/OwnGarageController.getFamilyValue';
import getSegmentValue from '@salesforce/apex/OwnWarrantyController.getSegmentValue';
import getCategoryValue from '@salesforce/apex/OwnGarageController.getCategoryValue';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';
export { getDataLayer }
export { intializeAdobe }

export { DATALAYER_EVENT_TYPE }

const DATALAYER_EVENT_TYPE = {
    LOAD: 'PageLoadReady',
    CLICK: 'click-event',
    DO_NOT_SELL: 'do_not_sell',
    COOKIE_POLICY: 'cookie_policy',
    PRIVACY_POLICY: 'privacy_policy',
    DOWNLOAD_EVENT: 'download-event',
    EXIT_EVENT: 'exit-event',
    COMPLIANCE_CLICK: 'compliance-click'
}
const PAGE_NAME = ['/garage-', '-service-maintenance', '-connected-features', '-marketplace', '-financial-services', '-resources-downloads',
    '/recalls-detail', 'enter-vin', '/acura-accelerated-service', '/honda-maintenance-minder', '/how-to-guides', '/how-to-category', '/specifications',
    '/hondacare-protection-plan', '/owners-manuals', '/manual-request', '/warranty-info', '/tips-', '/roadside-assistance', '/product-registration',
    '/product-settings', '-vehicle-report', '/service-record-detail', '/my-service-records', '/bluetooth-compatibility-phone', 'phone-compatibility-phone',
    '/vehicle-data-privacy-settings', '/vehicle-data-privacy-settings-result', 'phone-compatibility-result', 'bluetooth-compatibility-result',
    '/acura-product-compatibility-result', '/honda-product-compatibility-result', '/radio-nav-code?fb=true', '/service-records',
    '/vin-help/?division=Acura&frompage=AcuraResourcesDownloads', '/vin-help/?division=Honda&frompage=HondaResourcesDownloads',
    '/vin-help?division=Powersports&frompage=PowersportsResourcesDownloads'];
function getDataLayer(data) {
    return buildDataLayer(data)
}

async function buildDataLayer(data) {
    //console.log('@data', data)
    let dataLayer = {
        EventMetadata: data.eventMetadata || {},
        Model: {},
        Page: {},
        User: {},
        ContentMetadata: {},
        Metadata: {},
        Dealer: {}
    };
    dataLayer.Metadata.property_name = 'mygarage';
    dataLayer.Page.page_friendly_url = window.location.href.split('?')[0];
    dataLayer.Page.full_url = document.location.href;
    dataLayer.Page.referrer_url = sessionStorage.getItem('referrer') ? sessionStorage.getItem('referrer') : document.referrer;
    dataLayer.Page.referrer_type = dataLayer.Page.referrer_url ? (new URL(dataLayer.Page.referrer_url)).hostname : 'typed/bookmark';
    if (!isGuest && !JSON.parse(localStorage.getItem('isLoggedIn'))) {
        localStorage.setItem('isLoggedIn', true);
        dataLayer.User.login_status = 'login success';
        dataLayer.Page.referrer_url = document.referrer;
        dataLayer.Page.referrer_type = (new URL(document.referrer)).hostname;
    }
    if (isGuest) {
        localStorage.setItem('isLoggedIn', false);
        dataLayer.User.login_status = '';
        dataLayer.User.user_status = 'not_logged_in';
    } else {
        dataLayer.User.user_status = 'logged_in';
    }

    // let context = await getContext('');
    let fb = getUrlParameters().fb || null;
    let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
    let context;
    if (fromProductChooser || (fb == 'true' && (!document.location.pathname.includes('radio-nav-code') && !isGuest))) {
        context = await getProductContext('', true);
    } else {
        context = await getProductContext('', false);
    }
    //console.log('@@@@context', context);
    let pathName = document.location.pathname;
    let pathNamehref = document.location.href;

    if (data.eventMetadata && data.eventMetadata.action_label) {
        dataLayer = JSON.parse(sessionStorage.getItem('dataLayer'));
        let actionLabel = '';
        // if (data.eventMetadata.action_category === 'body') {
        actionLabel = dataLayer.Page.page_name + ':' + data.eventMetadata.action_label;
        // } else {
        //     actionLabel = dataLayer.Page.page_name + ':' + data.eventMetadata.action_category + ':' + data.eventMetadata.action_label;
        // }
        dataLayer.EventMetadata = {
            action_type: data.eventMetadata.action_type,
            action_category: data.eventMetadata.action_category === 'body' ? getActionCategory() : data.eventMetadata.action_category,
            action_label: actionLabel,
            download_title: data.eventMetadata.download_title ? data.eventMetadata.download_title : ''
        }

        dataLayer.EventMetadata.action_label = dataLayer.EventMetadata.action_label.replace(/[®#™]/g, '');
        function getActionCategory() {
            if (data.page && data.page.destination_url) {//exit links
                return 'Exit link';
            }
            else if (dataLayer.Page.site_section == 'help center') {//help center
                return `${dataLayer.Page.brand_name} ${dataLayer.Page.site_section} - navigation`;
            } else if (dataLayer.Page.site_section && dataLayer.Page.sub_section2 && dataLayer.Page.sub_section2 != '' && data.eventMetadata.action_label != 'find' && data.eventMetadata.action_label != 'search') {
                return `${dataLayer.Page.site_section} - ${dataLayer.Page.sub_section2}`;
            } else if ((data.eventMetadata.action_label == 'find') && pathName.includes('find-')) {//find product page
                return `${dataLayer.Page.sub_section} - ${data.eventMetadata.action_label}`;
            }
            else if ((data.eventMetadata.action_label == 'find') && !pathName.includes('find-') && dataLayer.Page.sub_section2) {//find button in pdp
                return `${dataLayer.Page.site_section} - ${dataLayer.Page.sub_section2}`;
            } else if (data.eventMetadata.action_label == 'search' && dataLayer.Page.site_section == 'find a dealer') {//search
                return `${dataLayer.Page.sub_section} - ${data.eventMetadata.action_label}`;
            } else {
                return `${dataLayer.Page.sub_section} - navigation`;
            }
        }

        if (data.page && data.page.destination_url && data.page.destination_url != 'https://app-download.com') {
            dataLayer.Page.destination_url = data.page.destination_url;
        }

        // if (dataLayer && dataLayer.Page && (dataLayer.Page.site_section || dataLayer.Page.site_section == '')) { delete dataLayer.Page.site_section; }
        // if (dataLayer && dataLayer.Page && (dataLayer.Page.sub_section || dataLayer.Page.sub_section == '')) { delete dataLayer.Page.sub_section; }
        // if (dataLayer && dataLayer.Page && (dataLayer.Page.sub_section2 || dataLayer.Page.sub_section2 == '')) { delete dataLayer.Page.sub_section2; }
        if (data.dealer && data.dealer.dealer_locator_search_type && data.dealer.dealer_locator_search_term) {
            dataLayer.Dealer = {
                dealer_locator_search_type: data.dealer.dealer_locator_search_type,
                dealer_locator_search_term: data.dealer.dealer_locator_search_term,
            }
        }
        if (data.findProductDetails && data.findProductDetails.brandName) {
            dataLayer.Model = {};
            if (data.findProductDetails.vin) {
                dataLayer.Model.model_vin = data.findProductDetails.vin;
            }
            else {
                if (data.findProductDetails.brandName == 'Powersports') {
                    if (data.findProductDetails.Tier1__c) { dataLayer.Model.model_year = data.findProductDetails.Tier1__c; }
                    if (data.findProductDetails.Tier2__c) { dataLayer.Model.model_body_style = data.findProductDetails.Tier2__c; }
                    if (data.findProductDetails.Tier3__c) { dataLayer.Model.product_line = data.findProductDetails.Tier3__c; }
                    if (data.findProductDetails.Tier4__c) { dataLayer.Model.model_name = data.findProductDetails.Tier4__c; }
                    if (data.findProductDetails.Tier5__c) { dataLayer.Model.model_trim = data.findProductDetails.Tier5__c; }
                    if (data.findProductDetails.model_id) { dataLayer.Model.model_id = data.findProductDetails.model_id }
                } else if (data.findProductDetails.brandName == 'Honda' || data.findProductDetails.brandName == 'Acura') {
                    if (data.findProductDetails.Tier1__c) { dataLayer.Model.model_year = data.findProductDetails.Tier1__c; }
                    if (data.findProductDetails.Tier2__c) { dataLayer.Model.model_name = data.findProductDetails.Tier2__c; }
                    if (data.findProductDetails.Tier3__c) { dataLayer.Model.model_trim = data.findProductDetails.Tier3__c; }
                    if (data.findProductDetails.model_id) { dataLayer.Model.model_id = data.findProductDetails.model_id }
                }
            }
        }
    }
    else {
        if (document.title === 'Home' || document.title === 'Welcome') {//home
            dataLayer.Page.brand_name = 'no brand';
            dataLayer.Model.model_brand = 'no model';
            dataLayer.Page.page_name = 'mygarage:home:overview';
            dataLayer.Page.site_section = 'home';
            dataLayer.Page.sub_section = '';
            dataLayer.Page.sub_section2 = '';
        }
        else if (pathName.includes('/help-') && !pathName.includes('help-center')) {//help pages
            let page = pathName.split('/').at(-1);
            let brandName = page.split('-').at(-1);
            if (brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'help center';

            if (brandName == 'honda' || brandName == 'acura') {
                dataLayer.Page.sub_section = page.replace('-', ' ');
                dataLayer.Page.sub_section2 = ''
                dataLayer.Page.page_name = 'mygarage:help center:' + brandName + ' help center:' + dataLayer.Page.sub_section;
            }
            else {
                dataLayer.Page.sub_section = brandName == 'power equipment' ? 'help power equipment' : page.replace('-', ' ');
                dataLayer.Page.sub_section2 = ''
                dataLayer.Page.page_name = 'mygarage:help center:honda ' + brandName + ' help center:' + dataLayer.Page.sub_section;
            }
        }
        else if (pathName.includes('help-center') && !pathName.includes('help-center-')) {//all help articles
            dataLayer.Page.brand_name = 'no brand';
            dataLayer.Model.model_brand = 'no model';
            dataLayer.Page.site_section = 'help center';
            dataLayer.Page.sub_section = 'help center';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:help center:all help articles & FAQs';
        }
        else if (pathName.includes('garage-')) {//PDP overview
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division;
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'garage ' + brandName;
            dataLayer.Page.sub_section2 = 'overview';
            let pageURL = 'garage-' + brandName.toLowerCase();
            if (brandName === 'power equipment') {
                pageURL = 'garage-powerequipment';
            }
            dataLayer.Page.page_friendly_url = window.location.href.split('/').at(-1).includes('garage-') ? window.location.href.split('?')[0].replaceAll(window.location.href.split('/').at(-1), pageURL, '') : window.location.href.split('?')[0];
            dataLayer.Page.full_url = window.location.href.split('/').at(-1).includes('garage-') ? window.location.href.replaceAll(window.location.href.split('/').at(-1), pageURL, '') : window.location.href;
            if (brandName == 'Acura' || brandName == 'Honda') {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:' + dataLayer.Page.sub_section;
            } else {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':' + dataLayer.Page.sub_section;
            }
            let i = 0;
            while (!localStorage.getItem('faouriteDealer')) {
                await sleep(1000);
                //console.log('@data while ', i)
                if (i == 10) { break };
                i++;
            }
            if (localStorage.getItem('faouriteDealer')) {
                if (JSON.parse(localStorage.getItem('faouriteDealer')) != {}) {
                    let favouriteDealer = JSON.parse(localStorage.getItem('faouriteDealer'));
                    dataLayer.Dealer.selected_dealer_name = favouriteDealer.selected_dealer_name;
                    dataLayer.Dealer.selected_dealer_id = favouriteDealer.selected_dealer_id;
                }
                localStorage.removeItem('faouriteDealer');
            }
        } else if (pathName.includes('-service-maintenance')) {//pdp s&m
            let page = pathName.split('/').at(-1);
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = replaceAll(page, '-', ' ');
            dataLayer.Page.sub_section2 = 'service & maintenance'
            if (brandName == 'Acura' || brandName == 'Honda') {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:' + dataLayer.Page.sub_section;
            } else {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':' + dataLayer.Page.sub_section;
            }
            let i = 0;
            while (!localStorage.getItem('faouriteDealer')) {
                await sleep(1000);
                //console.log('@data while ', i)
                if (i == 10) { break };
                i++;
            }
            if (localStorage.getItem('faouriteDealer')) {
                if (JSON.parse(localStorage.getItem('faouriteDealer')) != {}) {
                    let favouriteDealer = JSON.parse(localStorage.getItem('faouriteDealer'));
                    dataLayer.Dealer.selected_dealer_name = favouriteDealer.selected_dealer_name;
                    dataLayer.Dealer.selected_dealer_id = favouriteDealer.selected_dealer_id;
                }
                localStorage.removeItem('faouriteDealer');
            }
        } else if (pathName.includes('-connected-features')) {//connected features
            let page = pathName.split('/').at(-1);
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = replaceAll(page, '-', ' ');
            dataLayer.Page.sub_section2 = 'connected features'
            if (brandName == 'Acura' || brandName == 'Honda') {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:' + dataLayer.Page.sub_section;
            } else {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':' + dataLayer.Page.sub_section;
            }

        } else if (pathName.includes('-marketplace')) {//marketplace
            let page = pathName.split('/').at(-1);
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = replaceAll(page, '-', ' ');
            dataLayer.Page.sub_section2 = 'marketplace'
            if (brandName == 'Acura' || brandName == 'Honda') {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:' + dataLayer.Page.sub_section;
            } else {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':' + dataLayer.Page.sub_section;
            }

        } else if (pathName.includes('-financial-services')) {//finance
            let page = pathName.split('/').at(-1);
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = replaceAll(page, '-', ' ');
            dataLayer.Page.sub_section2 = 'finance'
            if (brandName == 'Acura' || brandName == 'Honda') {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:' + dataLayer.Page.sub_section;
            } else {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':' + dataLayer.Page.sub_section;
            }
        } else if (pathName.includes('-resources-downloads')) {//R&D
            let page = pathName.split('/').at(-1);
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = replaceAll(page, '-', ' ');
            dataLayer.Page.sub_section2 = 'resources & downloads';
            if (brandName == 'Acura' || brandName == 'Honda') {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:' + dataLayer.Page.sub_section;
            } else {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':' + dataLayer.Page.sub_section;
            }
        }
        else if (pathName.includes('enter-vin')) {//enter vin
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'enter vin';
            dataLayer.Page.sub_section = 'enter vin';
            dataLayer.Page.sub_section2 = '';
            dataLayer.Page.page_name = 'mygarage:my products:' + dataLayer.Page.sub_section;

        }
        else if (pathName.includes('/find-acura') || pathName.includes('/find-honda') || pathName.includes('/find-powersports') || pathName.includes('/find-powerequipment') || pathName.includes('/find-marine')) {
            let page = pathName.split('/').at(-1);
            let brandName = page.split('-').at(-1);
            if (brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = brandName == 'power equipment' ? 'find power equipment' : page.replace('-', ' ');
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:my products:' + dataLayer.Page.sub_section;
        }
        else if ((pathName.includes('/acuralink') || pathName.includes('/acura-product-compatibility-result')) && !pathName.includes('/acuralink-video-detail')) {//acuralink
            let page = pathName.split('/').at(-1);
            let brandName = 'acura';
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'acuralink';
            dataLayer.Page.sub_section = replaceAll(page, '-', ' ');
            dataLayer.Page.sub_section2 = ''
            if (dataLayer.Page.sub_section == 'acuralink marketing') {
                dataLayer.Page.page_name = 'mygarage:acuralink:stay connected with acuralink:acuralink marketing';
            }
            if (dataLayer.Page.sub_section == 'acuralink amazon alexa') {
                dataLayer.Page.page_name = 'mygarage:acuralink:amazon alexa:acuralink amazon alexa';
            }
            if (dataLayer.Page.sub_section == 'acuralink driver feedback') {
                dataLayer.Page.page_name = 'mygarage:acuralink:driver feedback:acuralink driver feedback';
            }
            if (dataLayer.Page.sub_section == 'acuralink product compatibility') {
                dataLayer.Page.page_name = 'mygarage:acuralink:check acuralink compatibility for your vehicle:acuralink product compatibility';
            }
            if (pathName.includes('/acura-product-compatibility-result')) {
                dataLayer.Page.sub_section = 'acura product compatibility result';
                dataLayer.Page.page_name = 'mygarage:acuralink:vehicle compatibility:acura product compatibility result';
            }
        }
        else if ((pathName.includes('/hondalink') || pathName.includes('/honda-product-compatibility-result')) && !pathName.includes('/hondalink-video-detail')) {//hondalink
            let page = pathName.split('/').at(-1);
            let brandName = 'honda';
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'hondalink';
            dataLayer.Page.sub_section = replaceAll(page, '-', ' ');
            dataLayer.Page.sub_section2 = ''
            if (dataLayer.Page.sub_section == 'hondalink marketing') {
                dataLayer.Page.page_name = 'mygarage:hondalink:stay connected with hondalink:hondalink marketing';
            }
            if (dataLayer.Page.sub_section == 'hondalink amazon alexa') {
                dataLayer.Page.page_name = 'mygarage:hondalink:amazon alexa:hondalink amazon alexa';
            }
            if (dataLayer.Page.sub_section == 'hondalink driver feedback') {
                dataLayer.Page.page_name = 'mygarage:hondalink:driver feedback:hondalink driver feedback';
            }
            if (dataLayer.Page.sub_section == 'hondalink product compatibility') {
                dataLayer.Page.page_name = 'mygarage:hondalink:check hondalink compatibility for your vehicle:hondalink product compatibility';
            }
            if (dataLayer.Page.sub_section == 'hondalink google built in') {
                dataLayer.Page.page_name = 'mygarage:hondalink:Available with Google built-in:hondalink google built in';
            }
            if (pathName.includes('/honda-product-compatibility-result')) {
                dataLayer.Page.sub_section = 'honda product compatibility result';
                dataLayer.Page.page_name = 'mygarage:hondalink:vehicle compatibility:honda product compatibility result';
            }
        }
        else if (pathName.includes('acura-handsfreelink-compatibility-check') || pathName.includes('honda-handsfreelink-compatibility-check')) {//handsfreelink
            let brandName = pathName.includes('acura-handsfreelink-compatibility-check') ? 'acura' : 'honda';
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'handsfreelink';
            dataLayer.Page.sub_section = brandName + ' handsfreelink compatibilty check';
            dataLayer.Page.sub_section2 = ''
            if (pathName.includes('acura-handsfreelink-compatibility-check')) {
                dataLayer.Page.page_name = 'mygarage:handsfreelink:check phone compatibility:acura handsfreelink compatibility check';
            }
            if (pathName.includes('honda-handsfreelink-compatibility-check')) {
                dataLayer.Page.page_name = 'mygarage:handsfreelink:check phone compatibility:honda handsfreelink compatibility check';
            }
        } else if (pathName.includes('phone-compatibility-phone')) {//phone compatibilty phone
            let brandName = context.product.division;
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'handsfreelink';
            dataLayer.Page.sub_section = 'phone compatibility phone';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:handsfreelink:check phone compatibility:phone compatibility phone';
        } else if (pathName.includes('phone-compatibility-result')) {
            let brandName = context.product.division;
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'handsfreelink';
            dataLayer.Page.sub_section = 'phone compatibility result';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:handsfreelink:' + context.product.manufacturerName + ' ' + context.product.phoneModelName + ':compatibility result';
        }
        else if (pathName.includes('bluetooth-compatibility-result')) {
            let brandName = context.product.division;
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'connect via bluetooth';
            dataLayer.Page.sub_section = 'bluetooth compatibility result';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:connect via bluetooth:' + context.product.manufacturerName + ' ' + context.product.phoneModelName + ':compatibility result';
        }
        else if (pathName.includes('find-a-dealer')) {//find a dealer 

            let brandName = '';
            if (sessionStorage.getItem('findDealerContext')) {
                brandName = JSON.parse(sessionStorage.getItem('findDealerContext')).brand;
            }
            let brandName1 = brandName;
            brandName = brandName == 'Motorcycle/Powersports' ? 'powersports' : brandName
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'find a dealer';
            dataLayer.Page.sub_section = 'find a dealer';
            dataLayer.Page.sub_section2 = ''
            if (brandName == 'Acura') {
                dataLayer.Page.page_name = 'mygarage:find a dealer:' + 'find an ' + brandName1 + ' dealer';
            }
            else {
                dataLayer.Page.page_name = 'mygarage:find a dealer:' + 'find a ' + brandName1 + ' dealer';
            }
        }
        else if (pathName.includes('/recall-search')) {//recall search
            let brandName = getUrlParameters().brand;
            if (brandName.includes('#')) {
                brandName = brandName.split('#')[0];
            }
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'recalls';
            dataLayer.Page.sub_section = 'recall search';
            dataLayer.Page.sub_section2 = ''
            if (brandName.toLowerCase() == 'acura' || brandName.toLowerCase() == 'honda' || brandName.toLowerCase() == 'power equipment') {
                dataLayer.Page.page_name = 'mygarage:recalls:recall details for ' + brandName + ':recall search';
            } else {
                dataLayer.Page.page_name = 'mygarage:recalls:recall details for honda ' + brandName + ':recall search';
            }

        }
        else if (pathName.includes('/recalls-detail')) {//recall detail
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'recalls';
            dataLayer.Page.sub_section = 'recalls detail';
            dataLayer.Page.sub_section2 = '';
            if (brandName.toLowerCase() == 'acura' || brandName.toLowerCase() == 'honda') {
                dataLayer.Page.page_name = 'mygarage:recalls:recalls details for ' + brandName + ':recalls detail';
            } else {
                dataLayer.Page.page_name = 'mygarage:recalls:recalls details for honda ' + brandName + ':recalls detail';
            }
        }
        else if (pathName.includes('/warranty-search')) {//warranty search
            let brandName = getUrlParameters().brand;
            if (brandName.includes('#')) {
                brandName = brandName.split('#')[0];
            }
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'warranty information';
            dataLayer.Page.sub_section = 'warranty search';
            dataLayer.Page.sub_section2 = ''
            if (brandName == 'acura' || brandName == 'honda' || brandName == 'power equipment') {
                dataLayer.Page.page_name = 'mygarage:warranty information:warranty information for ' + brandName + ':warranty search';
            } else {
                dataLayer.Page.page_name = 'mygarage:warranty information:warranty information for honda ' + brandName + ':warranty search';
            }

        }
        else if (pathName.includes('/manuals-search')) {//manuals search
            let brandName = getUrlParameters().brand;
            if (brandName.includes('#')) {
                brandName = brandName.split('#')[0];
            }
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = "owner's manuals";
            dataLayer.Page.sub_section = 'manuals search';
            dataLayer.Page.sub_section2 = ''

            if (brandName == 'acura' || brandName == 'honda' || brandName == 'power equipment') {
                dataLayer.Page.page_name = "mygarage:owner's manuals:owner's manuals for " + brandName + ':manuals search';
            } else {
                dataLayer.Page.page_name = "mygarage:owner's manuals:owner's manuals for honda " + brandName + ':manuals search';
            }
        }
        else if (pathName.includes('/radio-nav-code')) {//radio nav code

            let brandName = getUrlParameters().brand;
            if (brandName.includes('#')) {
                brandName = brandName.split('#')[0];
            }
            if (pathNamehref.includes('/radio-nav-code?fb=true')) {
                dataLayer.Page.brand_name = context.product.division;;
            } else {
                dataLayer.Page.brand_name = brandName;
            }
            // dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = "radio & navi code";
            dataLayer.Page.sub_section = 'radio nav code';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = "mygarage:radio & navi code:retrieve radio/navigation codes:radio nav code";
        }
        else if (pathName.includes('-bluetooth-compatibility-check')) {//connect via bluetooth
            let brandName = pathName.includes('/acura') ? 'acura' : 'honda';
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'connect via bluetooth';
            dataLayer.Page.sub_section = brandName + ' bluetooth compatibility check';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:connect via bluetooth:connect mobile device:' + brandName + ' bluetooth compatibility check';
        }
        else if (pathName.includes('/bluetooth-compatibility-phone')) {//connect via bluetooth
            let brandName = context.product.division;
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'connect via bluetooth';
            dataLayer.Page.sub_section = ' bluetooth compatibility phone';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:connect via bluetooth:connect mobile device:' + brandName + ' bluetooth compatibility phone';
        }
        else if (pathName.includes('/help-center-')) {//FAQ
           // console.log('@data faq url ', getUrlParameters().dc)
            let page = pathName.split('/').at(-1);
            let brandName = page.split('-').at(-1);
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'faq';
            dataLayer.Page.sub_section = 'help center ' + brandName;
            if (data && data.page && data.page.sub_section2) {
                dataLayer.Page.sub_section2 = data.page.sub_section2;
            } else {
                if (getUrlParameters().dc == 'HondaLinkDriverFeedback') {
                    dataLayer.Page.sub_section2 = 'HondaLink Driver Feedback';
                } else if (getUrlParameters().dc == 'AcuraLinkDriverFeedback') {
                    dataLayer.Page.sub_section2 = 'AcuraLink Driver Feedback';
                }
                else {
                    dataLayer.Page.sub_section2 = brandName == 'acura' ? 'Popular Article & FAQ' : 'Popular Articles & FAQ';
                }
            }
            if (brandName == 'acura' || brandName == 'honda') {
                dataLayer.Page.page_name = 'mygarage:faq:' + brandName + ' autos help articles & faqs:help center ' + brandName;
            } else {
                dataLayer.Page.page_name = 'mygarage:faq:honda ' + brandName + ' help articles & faqs:help center ' + brandName;
            }
        } else if (pathName.includes('-collision-repair')) {//collision repair
            let brandName = pathName.includes('/acura') ? 'acura' : 'honda';
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'certified collision facilities';
            dataLayer.Page.sub_section = brandName + ' collision repair';
            if (data && data.page && data.page.sub_section2) {
                dataLayer.Page.sub_section2 = data.page.sub_section2;
            } else {
                dataLayer.Page.sub_section2 = brandName == 'acura' ? 'acura certified body shop' : 'honda certified body shop';
            }
            dataLayer.Page.page_name = 'mygarage:certified collision facilities:collision repair:' + brandName + ' collision repair';
        }
        else if (pathName.includes('/my-account')) {//my account
            let brandName = 'no brand';
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = 'no model';
            dataLayer.Page.site_section = 'my account';
            dataLayer.Page.sub_section = 'my account';
            if (data && data.page && data.page.sub_section2) {
                dataLayer.Page.sub_section2 = data.page.sub_section2;
            } else {
                dataLayer.Page.sub_section2 = 'account information';
            }
            dataLayer.Page.page_name = 'mygarage:my account:' + dataLayer.Page.sub_section2;
        }
        else if (pathName.includes('/warranty-info')) {//warranty search
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'warranty info';
            dataLayer.Page.sub_section2 = ''
            if (brandName == 'Acura' || brandName == 'Honda') {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:warranty info';
            } else {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':warranty info';
            }

        }
        else if (pathName.includes('/acura-accelerated-service')) {//maintenance minders 
            let brandName = 'acura';
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'acura accelerated service';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:my products:acura autos:acura accelerated service';
        }
        else if (pathName.includes('/honda-maintenance-minder')) {//maintenance minders 
            let brandName = 'honda';
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'honda maintenance minders';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:my products:honda autos:honda maintenance minders';
        } else if (pathName.includes('/how-to-guides')) {//how to guides
            let brandName = context.product.division;
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'how to guides';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:how to guides';
        }
        else if (pathName.includes('/how-to-category')) {//how to guides
            let brandName = context.product.division;
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'how to category';
            dataLayer.Page.sub_section2 = '';
            let categoryData = JSON.parse(sessionStorage.getItem('howtoguides'));
            let title = categoryData.title ? convertToPlain(categoryData.title) + ' How-to Guides' : 'How-to Guides';
            dataLayer.Page.page_name = 'mygarage:my products:' + title + ':how to category';
        } else if (pathName.includes('/vin-help')) {//VIN
            let brandName = getUrlParameters().division;
            if (brandName.includes('#')) {
                brandName = brandName.split('#')[0];
            }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'vin help';
            dataLayer.Page.sub_section2 = ''
            if (brandName == 'Acura' || brandName == 'Honda') {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:vin help';
            } else {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':vin help';
            }
        }
        else if (pathName.includes('/marine-serial-number-help')) {//serial number
            let brandName = 'marine';
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'marine serial number help';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:my products:marine:marine serial number help';
        }
        else if (pathName.includes('/sample-emission-label-powerequipment')) {//serial number
            let brandName = 'power equipment';
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'sample emission label powerequipmment ';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:my products:warranties:sample emission label powerequipment';
        }
        else if (pathName.includes('/marine-emissions-location-label')) {//serial number
            let brandName = 'marine';
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'marine emission location label';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:my products:warranties:marine emission location label';
        }
        // else if (pathName.includes('/specifications')) {//specifications
        //     let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division
        //     dataLayer.Page.brand_name = brandName;
        //     dataLayer.Model.model_brand = brandName;
        //     dataLayer.Page.site_section = 'my products';
        //     dataLayer.Page.sub_section = 'specifications';
        //     console.log('@specification', localStorage.getItem('AdobeData'))
        //     if (data && data.page && data.page.sub_section2) {
        //         dataLayer.Page.sub_section2 = data.page.sub_section2;
        //     }
        //     else if (localStorage.getItem('AdobeData')) {
        //         dataLayer.Page.sub_section2 = localStorage.getItem('AdobeData');
        //         localStorage.removeItem('AdobeData')
        //     } else {
        //         dataLayer.Page.sub_section2 = '';
        //     }
        //     if (brandName == 'Acura' || brandName == 'Honda') {
        //         dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:specifications';
        //     } else {
        //         dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':specifications';
        //     }
        // } 
        else if (pathName.includes('/specifications')) {//specifications
            await sleep(3000);
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'specifications';
           // console.log('@specification', localStorage.getItem('AdobeData'), 'showTrimList', localStorage.getItem('showTrimList'))
            if (localStorage.getItem('showTrimList') == 'true') {
                if (localStorage.getItem('AdobeData')) {
                    dataLayer.Page.sub_section2 = localStorage.getItem('AdobeData');
                    localStorage.removeItem('AdobeData')
                }
                localStorage.removeItem('showTrimList')
            }
            else {
                if (data && data.page && data.page.sub_section2) {
                    dataLayer.Page.sub_section2 = data.page.sub_section2;
                } else {
                    dataLayer.Page.sub_section2 = '';
                }
                localStorage.removeItem('showTrimList')
            }
            if (brandName == 'Acura' || brandName == 'Honda') {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:specifications';
            } else {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':specifications';
            }
        }
        else if (pathName.includes('/hondacare-protection-plan')) {//protection plan
            let brandName = 'powersports'
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'hondacare protection plan';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:my products:powersports:hondacare protection plan';
        }
        else if (pathName.includes('/manual-request') || pathName.includes('/owners-manuals')) {//manuals
            let page = pathName.split('/').at(-1);
            let brandName
            if (context.product.division == 'Motorcycle/Powersports') {
                brandName = 'powersports';
            } else if (context.product.division == 'Powerequipment') {
                brandName = 'power equipment'
            } else {
                brandName = context.product.division;
            }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = page.replace('-', ' ');
            dataLayer.Page.sub_section2 = ''
            if (brandName == 'Acura' || brandName == 'Honda') {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:' + dataLayer.Page.sub_section;
            } else {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':' + dataLayer.Page.sub_section;
            }
        }
        else if (pathName.includes('/tips-')) {//tips
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division;
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'tips ' + brandName;
            if (data && data.page && data.page.sub_section2) {
                dataLayer.Page.sub_section2 = data.page.sub_section2;
            }
            else if (window.location.href.includes('/tips-marine?isFuelRecommendation=true')) {
                dataLayer.Page.sub_section2 = 'Fuel Recommendations';
            } else if (window.location.href.includes('/tips-marine') && !window.location.href.includes('/tips-marine?isFuelRecommendation=true')) {
                dataLayer.Page.sub_section2 = 'Popular Tips';
            } else {
                dataLayer.Page.sub_section2 = '';
            }
            dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':tips ' + brandName;
        }
        else if (pathName.includes('/roadside-assistance')) {//roadside assistance
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division;
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'roadside assistance';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:roadside assistance';
        }
        else if (pathName.includes('/product-registration')) {//product registration
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division;
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'product registration';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':product registration';
        }
        else if (pathName.includes('/product-settings')) {//product settings
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division;
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'product settings';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':product settings';
        }
        else if (pathName.includes('-vehicle-report')) {//vehicle report
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division;
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = brandName + ' vehicle report';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:' + brandName + ' vehicle report ';
        }
        else if (pathName.includes('/my-service-records') || pathName.includes('/service-record-detail')) {//service records
            let page = pathName.split('/').at(-1);
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division;
            if (brandName.toLowerCase() == 'powerequipment') {
                brandName = 'power equipment';
            }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = replaceAll(page, '-', ' ');
            dataLayer.Page.sub_section2 = ''
            if (brandName == 'Acura' || brandName == 'Honda') {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ' autos:' + dataLayer.Page.sub_section;
            } else {
                dataLayer.Page.page_name = 'mygarage:my products:' + brandName + ':' + dataLayer.Page.sub_section;;
            }
        }
        else if (!pathName.includes('/my-service-records') && pathName.includes('/service-records')) {//service records
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division;
            if (brandName.toLowerCase() == 'powerequipment') {
                brandName = 'power equipment';
            }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my products';
            dataLayer.Page.sub_section = 'service records';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:my products:add a new service record:service records';
        }
        else if (pathName.includes('/send-an-email')) {//send an email
            let brandName = sessionStorage.getItem('BrandName') ? sessionStorage.getItem('BrandName') : 'Honda';
            if (brandName == 'Powerequipment' || brandName == 'powerequipment') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'help center';
            dataLayer.Page.sub_section = 'send an email';
            dataLayer.Page.sub_section2 = ''
            if (brandName == 'Acura' || brandName == 'Honda') {
                dataLayer.Page.page_name = 'mygarage:help center:' + brandName + ' autos:send an email';
            } else {
                dataLayer.Page.page_name = 'mygarage:help center:honda ' + brandName + ':send an email';
            }
        }
        else if (pathName.includes('/guide-video-detail')) {//guide-video-detail
            let fromData = JSON.parse(sessionStorage.getItem('fromhowtoguides'));
            let brandName;
            if (fromData) {
                brandName = fromData[0].label.split(' ')[0];
            }
            if (brandName) {
                let cmpBrandName = brandName.toLowerCase();
                if (cmpBrandName != 'honda' && cmpBrandName != 'acura' && cmpBrandName != 'motorcycle/powersports' && cmpBrandName != 'powersports' && cmpBrandName != 'marine' && cmpBrandName != 'power' && cmpBrandName != 'power equipment') {
                    brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division
                }
            } else {
                brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division
            }
            if (brandName == 'Power') { brandName = 'power equipment' }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'help center';
            dataLayer.Page.sub_section = 'guide video detail';
            dataLayer.Page.sub_section2 = ''
            let videoName = await getDetailsFromCMS();
            if (videoName) {
                if (brandName == 'Acura' || brandName == 'Honda') {
                    dataLayer.Page.page_name = 'mygarage:help center:' + videoName + ':guide video detail';
                } else {
                    dataLayer.Page.page_name = 'mygarage:help center:' + videoName + ':guide video detail';
                }
            } else {
                dataLayer.Page.page_name = 'mygarage:help center:' + convertToPlain(sessionStorage.getItem('howtoguidesTitle').replaceAll('\"', '')) + ':guide video detail';
            }
        }
        else if (pathName.includes('/radio-nav-result')) {//radio nav result
            let brandName = getUrlParameters().brand;
            if (brandName.includes('#')) {
                brandName = brandName.split('#')[0];
            }
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'radio & navi code';
            dataLayer.Page.sub_section = 'radio nav result ';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:radio & navi code:retrieve radio/navigation codes:radio nav result';
        }
        else if (pathName.includes('/vehicle-data-privacy-settings-result') || pathName.includes('/vehicle-data-privacy-settings')) {//vehicle data privacy
            let page = pathName.split('/').at(-1);
            // let brandName = localStorage.getItem('AdobeVehicleDataPrivacyProduct')
            let brandName = context.product.division == 'Motorcycle/Powersports' ? 'powersports' : context.product.division
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'my account';
            dataLayer.Page.sub_section = replaceAll(page, '-', ' ');
            dataLayer.Page.sub_section2 = ''
            // localStorage.removeItem('AdobeVehicleDataPrivacyProduct')
            if (pathName.includes('/vehicle-data-privacy-settings-result')) {
                dataLayer.Page.page_name = 'mygarage:my account:vehicle data privacy:vehicle data privacy settings result';
            } else {
                dataLayer.Page.page_name = 'mygarage:my account:vehicle data privacy:vehicle data privacy settings';
            }
        }
        else if (pathName.includes('/messages')) {//messages
            //console.log('@adobe else if')
            let brandName = 'no brand';
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = 'no model';
            // console.log('@adobe else if 1', data.page.pageName)
            dataLayer.Page.site_section = 'messages';
            dataLayer.Page.sub_section = 'messages';
            if (localStorage.getItem('MessagesTab')) {
                dataLayer.Page.sub_section2 = 'recalls';
                localStorage.removeItem('MessagesTab')
            } else if (data && data.page && data.page.sub_section2) {
                dataLayer.Page.sub_section2 = data.page.sub_section2;
            } else {
                dataLayer.Page.sub_section2 = 'all messages';
            }
            dataLayer.Page.page_name = 'mygarage:messages:' + dataLayer.Page.sub_section2;
        }
        else if (pathName.includes('/acuralink-video-detail')) {//video detail
            let brandName = 'acura'
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'acuralink';
            dataLayer.Page.sub_section = 'acuralink video detail';
            dataLayer.Page.sub_section2 = '';
            dataLayer.Page.page_name = 'mygarage:acuralink:' + await getDetailsFromCMS() + ':acuralink video detail';
        } else if (pathName.includes('/hondalink-video-detail')) {//video detail
            let brandName = 'honda'
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'hondalink';
            dataLayer.Page.sub_section = 'hondalink video detail';
            dataLayer.Page.sub_section2 = ''
            dataLayer.Page.page_name = 'mygarage:hondalink:' + await getDetailsFromCMS() + ':hondalink video detail';
        }
        else if (pathName.includes('/article')) {//article
            let urlName;
            if (pathName.split('/')) {
                urlName = pathName.split('/')[pathName.split('/').length - 1];
            }
            let results;
            if (urlName) {
                results = await getKnowledgeArticleByUrlName(urlName);
                //console.log('@data article brand', urlName, results);
                if (results.title) {
                    dataLayer.ContentMetadata = {
                        article_name: results.title.replace(/[®#™]/g, '')
                    }
                }
            }

            let brandName = getArticleBrand(JSON.parse(sessionStorage.getItem('acticleBrand')));
            dataLayer.Page.brand_name = brandName;
            dataLayer.Model.model_brand = brandName;
            dataLayer.Page.site_section = 'help center';
            dataLayer.Page.sub_section = replaceAll(urlName, '-', ' ');
            dataLayer.Page.sub_section2 = ''
            if (brandName == 'acura' || brandName == 'honda') {
                dataLayer.Page.page_name = 'mygarage:article:' + replaceAll(urlName, '-', ' ');
            } else {
                dataLayer.Page.page_name = 'mygarage:article:' + replaceAll(urlName, '-', ' ');
            }
        }
        // else {
        //     console.log('@adobe else')
        //     if (context && context.product && context.product.division && context.product.model && document.title !== 'Home') {
        //         dataLayer.Page.brand_name = context.product.division;
        //         dataLayer.Model.model_brand = context.product.division;
        //     } else {
        //         dataLayer.Page.brand_name = 'no brand';
        //         dataLayer.Model.model_brand = 'no model';
        //     }
        //     let property = 'mygarage';
        //     dataLayer.Page.site_section = ''; //set the localstorage siteSection value on click of button/link - //write a javascript method to capture all the click event
        //     dataLayer.Page.sub_section = document.title; //page title - document.title - modify the text based on context and page title // substring the url
        //     dataLayer.Page.sub_section2 = '' //tab title;
        //     let pageName = '';
        //     pageName += property;
        //     if (dataLayer.Page.site_section && dataLayer.Page.site_section !== '') {
        //         pageName += ':' + dataLayer.Page.site_section;
        //     }
        //     if (dataLayer.Page.sub_section && dataLayer.Page.sub_section !== '') {
        //         pageName += ':' + dataLayer.Page.sub_section;
        //     }
        //     if (dataLayer.Page.sub_section2 && dataLayer.Page.sub_section2 !== '') {
        //         pageName += ':' + dataLayer.Page.sub_section2;
        //     }
        //     dataLayer.Page.page_name = pageName;
        // }
        //console.log('@data sessionStorage')
        sessionStorage.setItem('referrer', document.location.href)
        for (let i = 0; i < PAGE_NAME.length; i++) {
            if (pathName.includes(PAGE_NAME[i]) || pathNamehref.includes(PAGE_NAME[i])) {
                if (context && context.product) {
                    if (context.product.divisionId == 'M' && context.product.modelId) {
                        dataLayer.Model.model_name = await getFamilyValue({ modelId: context.product.modelId });
                        if (context.product.model) { dataLayer.Model.model_trim = context.product.model; }
                        dataLayer.Model.model_body_style = await getSegmentValue({ modelId: context.product.modelId });
                        if (context.product.year) { dataLayer.Model.model_year = context.product.year; }
                        if (context.product.modelId) { dataLayer.Model.model_id = context.product.modelId; }
                        dataLayer.Model.product_line = await getCategoryValue({ modelId: context.product.modelId });
                    } else {
                        if (context.product.model) { dataLayer.Model.model_name = context.product.model; }
                        if (context.product.year) { dataLayer.Model.model_year = context.product.year; }
                        if (context.product.trim) { dataLayer.Model.model_trim = context.product.trim; }
                        if (context.product.modelId) { dataLayer.Model.model_id = context.product.modelId; }
                    }
                    if (context.product.vin && context.product.vin != '-' && context.product.vin != '') { dataLayer.Model.model_vin = context.product.vin; };
                }
                break;
            }
        }
    }
    // if (dataLayer.EventMetadata.action_label) {
    //     let actionLabel = dataLayer.Page.page_name + ':' + dataLayer.EventMetadata.action_category + ':' + dataLayer.EventMetadata.action_label;
    //     dataLayer.EventMetadata = {
    //         action_type: dataLayer.EventMetadata.action_type,
    //         action_category: dataLayer.EventMetadata.action_category,
    //         action_label: actionLabel
    //     }
    //     if (dataLayer && dataLayer.Page && (dataLayer.Page.site_section || dataLayer.Page.site_section == '')) { delete dataLayer.Page.site_section; }
    //     if (dataLayer && dataLayer.Page && (dataLayer.Page.sub_section || dataLayer.Page.sub_section == '')) { delete dataLayer.Page.sub_section; }
    //     if (dataLayer && dataLayer.Page && (dataLayer.Page.sub_section2 || dataLayer.Page.sub_section2 == '')) { delete dataLayer.Page.sub_section2; }
    // } else {
    //     console.log('@data sessionStorage')
    //     sessionStorage.setItem('referrer', document.location.href)
    // }

    if (dataLayer && dataLayer.Model && dataLayer.Model.model_brand) { delete dataLayer.Model.model_brand; };
    sessionStorage.setItem('dataLayer', JSON.stringify(dataLayer))
    if ((data && data.page && data.page.remove_sections) || (data.eventMetadata && data.eventMetadata.action_label)) {
        if (dataLayer && dataLayer.Page && (dataLayer.Page.site_section || dataLayer.Page.site_section == '')) { delete dataLayer.Page.site_section; }
        if (dataLayer && dataLayer.Page && (dataLayer.Page.sub_section || dataLayer.Page.sub_section == '')) { delete dataLayer.Page.sub_section; }
        if (dataLayer && dataLayer.Page && (dataLayer.Page.sub_section2 || dataLayer.Page.sub_section2 == '')) { delete dataLayer.Page.sub_section2; }
    }

    dataLayer.Page.page_name = dataLayer.Page.page_name.replace(/[®#™]/g, '');
    //console.log('@data dataLayer', dataLayer)
    return dataLayer;
}

function replaceAll(string, search, replace) {
    return string.split(search).join(replace);
}

function getUrlParameters() {
    let href = window.location.href;
    let urlParameters = {};
    if (href.includes('?')) {
        href = href.substring(href.indexOf('?') + 1).includes('&') ? href.substring(href.indexOf('?') + 1).split('&') : href.substring(href.indexOf('?') + 1).split('=').join('=');
        href = Array.isArray(href) ? href : [href];
        href.forEach(param => {
            param = param.split('=');
            urlParameters[param[0]] = param[1];
        });
    }
    return urlParameters;
}

async function getDetailsFromCMS() {
    let videoName = '';
    let topics = null;
    let pageSize = null;
    let managedContentType = '';
    let key = getUrlParameters().key ? getUrlParameters().key : null;
    //console.log('@@@]key-->', key);
    if (key) {
        let cmsRecords = await getManagedContentByTopicsAndContentKeys([key], topics, pageSize, managedContentType);
        //console.log('@@@cmsRecords', cmsRecords);
        cmsRecords.forEach(r => {
            if (r.videoLink) {
                videoName = htmlDecode(r.title.value);
            }
        });
    }
    return videoName;
}
async function intializeAdobe(adobedtmObj) {
    //console.log('@data intializeAdobe');
    if (adobedtmObj.delay) {
        await this.sleep(3000);
    }
    let dataLayer = await getDataLayer(adobedtmObj.data);
    const adobedtmEvent = new CustomEvent('adobedtm', {
        detail: {
            eventType: adobedtmObj.eventType,
            data: JSON.parse(JSON.stringify(dataLayer))
        },
        bubbles: true,
        composed: true
    });
    //console.log('@dataLayer1', JSON.stringify(dataLayer))
    dispatchEvent(adobedtmEvent);
}
function htmlDecode(input) {
    if (!input) return '';
    let doc = new DOMParser().parseFromString(input, "text/html");
    return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
}
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function convertToPlain(html) {
    let tempDivElement = document.createElement("div");
    tempDivElement.innerHTML = html;
    return tempDivElement.textContent || tempDivElement.innerText || "";
}

function getArticleBrand(categories) {
    let brandName = getUrlParameters().brand;
    for (let i = 0; i < categories.length; i++) {
        if (categories[i].name.includes('Marine') || categories[i].name.includes('CleaningFlushingInstructions') || categories[i].name.includes('GearCaseOilChange') ||
            categories[i].name.includes('HD4DisplayManualSupport') || categories[i].name.includes('PortableOutboardWinterization')) {
            return 'marine'
        } else if ((categories[i].name.includes('PS') || categories[i].name.includes('Powersports'))) {
            return 'powersports'
        } else if (categories[i].name.includes('PE') || categories[i].name.includes('Power Equipment') || categories[i].name.includes('Powerequipment') ||
            categories[i].name.includes('Pumps') || categories[i].name.includes('Trimmers') || categories[i].name.includes('AvoidingFuelRelatedProblems') ||
            categories[i].name.includes('ResettingtheHourCounter')) {
            return 'power equipment'
        } else if (categories[i].name.includes('Honda')) {
            return 'honda'
        } else if (categories[i].name.includes('Acura')) {
            return 'acura'
        }
    }
    if (brandName.includes('#')) {
        brandName = brandName.split('#')[0];
    }
    if (brandName == 'AcuraAutos') {
        return 'acura';
    }
    else if (brandName == 'HondaAutos') {
        return 'honda';
    } else if (brandName == 'HondaPowersports') {
        return 'powersports';
    } else if (brandName == 'HondaPowerEquipment') {
        return 'power equipment';
    } else if (brandName == 'HondaMarine') {
        return 'marine';
    } else {
        return brandName;
    }
}