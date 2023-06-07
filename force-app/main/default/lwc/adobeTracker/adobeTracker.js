import { LightningElement, api, track } from 'lwc';

import adobedtm from '@salesforce/resourceUrl/adobedtm';
import { loadScript } from 'lightning/platformResourceLoader';

export default class AdobeTracker extends LightningElement {

    builderText = '';

    @api adobeTracker = {
        log_tracker : true,
        track_action : "click",
        page_name : "home page",
        site_section : "default",
        page_property_name : "honda_owners",
        version : '1.0',
        pageLanguage : 'en',
        Page_full_url : window.location.href,
        Page_page_friendly_url : window.location.href
    };


    connectedCallback(){
        let digitalData = {
            "Page_full_url": this.adobeTracker.Page_full_url,
            "Page_internal_referrer": "", 
            "Page_page_friendly_url": this.adobeTracker.Page_page_friendly_url, 
            "Page_page_language": this.adobeTracker.pageLanguage,
            "Page_page_name": this.adobeTracker.page_name, 
            "Page_property_name": this.adobeTracker.page_property_name,
            "Page_referrer_url": document.referrer,
            "Page_site_section": this.adobeTracker.siteSection, 
            "metadata_version_dl": this.adobeTracker.version
        };
        //console.log('Window Tracker :::::::::::::::::: ', digitalData);
        window.dataLayer = digitalData;
        window._satellite.track('PageLoadReady');
        //this.loadJs();
    }

    loadJs(){
        var self = this;

        var digitalData = {
            "page": {
                "pageInfo" : {
                    "pageName": "American Honda",
                    "pageData" : "sample data",
                    "page_full_url": window.location.href, // Full Page URL information
                    "page_internal_referrer": "", // Previous page information (URL)
                    "page_page_friendly_url": window.location.href, 
                    "page_page_language": "en", // Page language,
                    "page_page_name": "Honda Home Page", // Page name,
                    "page_property_name": "Seach", // provide the property name based on the pages like      (acuraFinance or acuraOwners or hondaFinance or hondaOwners)
                    "page_referrer_url": document.referrer, // from where user visits to the site (e.g., google.com),
                    "page_site_section": "Vehical Filter", // by default keep value as login,
                    "metadata_version_dl": "1.0" // please provide the app version,
                }
            }
        };

        loadScript(this, adobedtm)
        .then(function() {
            window._satellite.track('PageLoadReady');
            //console.log('Track Response :: ',window._satellite.track('sample'));
            //self.initialize();
        })
        .catch(error => console.log('adobedtm -----> '));
    }

    initialize () {
        var self = this;

        //console.log('Adobe Tracker in Adobe Tracker Component', JSON.parse( JSON.stringify( this.adobeTracker ) ) );

        if(window.location.href.includes("livepreview")){
            this.builderText = "Adobe Tracker - Builder View";
        }
        try {
            //console.log('Adding Adobe Tracker', this.pageName, this.propertyName, this.siteSection, this.version);
            
            window._satellite.track(
                self.track_action ,
                {
                    "Page_full_url": self.adobeTracker.Page_full_url, // Full Page URL information
                    "Page_internal_referrer": "", // Previous page information (URL)
                    "Page_page_friendly_url": self.adobeTracker.Page_page_friendly_url, 
                    "Page_page_language": self.adobeTracker.pageLanguage, // Page language,
                    "Page_page_name": self.adobeTracker.page_name, // Page name,
                    "Page_property_name": self.adobeTracker.page_property_name, // provide the property name based on the pages like      (acuraFinance or acuraOwners or hondaFinance or hondaOwners)
                    "Page_referrer_url": document.referrer, // from where user visits to the site (e.g., google.com),
                    "Page_site_section": self.adobeTracker.siteSection, // by default keep value as login,
                    "metadata_version_dl": self.adobeTracker.version // please provide the app version,
                }
            );
        }catch(err) {
            //console.log(err);
        }
    }
}