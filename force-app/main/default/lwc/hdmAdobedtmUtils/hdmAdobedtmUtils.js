import SFisGuest from '@salesforce/user/isGuest';
import { getCurrentVehicle } from 'c/utils';
import communityId from '@salesforce/community/Id';
import getCartId from '@salesforce/apex/B2BGetInfo.getCartId';
import getCartItemList2 from '@salesforce/apex/CartItemsCtrl.getCartItemList2';
import returnCheckoutState from '@salesforce/apex/CartItemsCtrl.returnCheckoutState';
import getProductSKUById from '@salesforce/apex/B2BGuestUserController.getProductSKUById';
import getWishlistItem from '@salesforce/apex/B2B_LoggedInUserWishlist.getWishlistItem';
import isUserLoggedOut from '@salesforce/apex/B2B_Util.isUserLoggedOut';
import Id from '@salesforce/user/Id';
import getOrderInfo from '@salesforce/apex/CartItemsCtrl.getOrderInfo';
export { getDataLayer }

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

const BRANDS = {
    honda: 'honda',
    acura: 'acura',
    no_brand: 'no brand'
}

const CHECKOUT_STAGES = new Map([
    ["Delivery Method", "Shipping"],
    ["Shipping Cost", "Checkout Summary"],
    ["Payment And Billing Address", "Payment"],
    ["Order Confirmation", "Confirmation"]
]);

const CHECKOUT_EVENTS = new Map([
    ["Shipping", "checkout shipping"],
    ["Checkout Summary", "checkout summary"],
    ["Payment", "payment"],
    ["Confirmation", "purchase"],
])

function getDataLayer(data) {
    return buildDataLayer(data)
}

async function buildDataLayer(data) {
    console.log('@data -- buildDataLayer(data)', data)

    // refresh();
    let pathName = document.location.pathname;
    let events = '';
    let dataLayer = {
        EventMetadata: {},
        Model: {},
        Page: {},
        User: {},
        Metadata: {},
        Dealer: {},
        Cart: {},
        Product: [],
        Transaction: {},
        Payment: {},
        Delivery: {},
        Events: ''
    };
    dataLayer.Metadata.property_name = 'dreamshop';
    dataLayer.Page.page_friendly_url = window.location.href.split('?')[0];
    dataLayer.Page.full_url = document.location.href;
    dataLayer.Page.referrer_url = sessionStorage.getItem('referrer') ? sessionStorage.getItem('referrer') : document.referrer;
    dataLayer.Page.referrer_type = dataLayer.Page.referrer_url ? (new URL(dataLayer.Page.referrer_url)).hostname : 'typed/bookmark';

    let isGuest = SFisGuest;
    await isUserLoggedOut().then(result => {
        isGuest = result;
    }).catch(error => {
        console.log('@data error isGuest', error)
    });
    if (!isGuest && !JSON.parse(localStorage.getItem('isLoggedIn'))) {
        localStorage.setItem('isLoggedIn', true);
        // dataLayer.User.login_status = 'login success';
        events = sessionStorage.getItem('eventsForAdobe') ? sessionStorage.getItem('eventsForAdobe') : '';
        if (sessionStorage.getItem('eventsForAdobe')) {
            sessionStorage.removeItem('eventsForAdobe');
        }
        dataLayer.Page.referrer_url = document.referrer;
        dataLayer.Page.referrer_type = (new URL(document.referrer)).hostname;
    }
    if (isGuest) {
        localStorage.setItem('isLoggedIn', false);
        // dataLayer.User.login_status = '';
        dataLayer.User.user_status = 'not_logged_in';
    } else {
        dataLayer.User.user_status = 'logged_in';
    }

    let context = getCurrentVehicle();
    console.log('@data -- context', context);

    if (data.eventMetadata && data.eventMetadata.action_label) {
        dataLayer = JSON.parse(sessionStorage.getItem('dataLayer'));

        dataLayer.EventMetadata = populateEventMetadataDetails(data.eventMetadata, dataLayer.Page);

        if (data && data.page && data.page.destination_url) {
            dataLayer.Page.destination_url = data.page.destination_url
        }

        deletePageSections();

        dataLayer.Dealer = populateDealerDetails(data.dealer);

        if (data && data.findProductDetails && data.findProductDetails.year) {
            dataLayer.Model = populateModelDetails(data.findProductDetails);
        }
        if (data && data.findProductDetails && data.findProductDetails.brand) {
            dataLayer.Page.brand_name = data.findProductDetails.brand;
        }
        console.log('@data addToCartProductDetails', data.addToCartProductDetails)
        if (data && data.addToCartProductDetails && data.addToCartProductDetails.breadcrumbs && data.addToCartProductDetails.context && data.addToCartProductDetails.products) {
            dataLayer.Product = populatePdpProductDetails(data.addToCartProductDetails.breadcrumbs, data.addToCartProductDetails.context, data.addToCartProductDetails.products);
        }
        if (data && data.events) {
            dataLayer.Events = data.events;
        }
        else {
            dataLayer.Events = '';
        }
        if (data && data.events && data.events == 'scCheckout') {
            dataLayer.Cart = await populateCartDetails_fromServer();
        }
    }
    else {
        // dataLayer.Page = Object.assign(dataLayer.Page, await appendPageDetails((context) ? context : {}));
        // await populateAllDetails((context) ? context : {});
        let Page = {};
        let propertyName = dataLayer.Metadata.property_name;
        if (document.title.toLowerCase() === 'dreamshop' || document.title.toLowerCase().includes('home')) {//home
            Page.brand_name = BRANDS.no_brand;
            Page.page_name = `${propertyName}:home:overview`;
            Page.site_section = 'home';
            Page.sub_section = '';
            Page.sub_section2 = '';
            dataLayer.Events = events ? `${events}` : '';
        } else if (pathName.includes('/honda') && !pathName.includes('/category/')) {//honda 
            Page.brand_name = BRANDS.honda;
            Page.page_name = `${propertyName}:honda:overview`;
            Page.site_section = 'honda overview';
            Page.sub_section = '';
            Page.sub_section2 = '';
            dataLayer.Events = events ? `${events}` : '';
        } else if (pathName.includes('/acura') && !pathName.includes('/category/')) {//acura
            Page.brand_name = BRANDS.acura;
            Page.page_name = `${propertyName}:acura:overview`;
            Page.site_section = 'acura overview';
            Page.sub_section = '';
            Page.sub_section2 = '';
            dataLayer.Events = events ? `${events}` : '';
        } else if (pathName.includes('/faq')) {//faq
            Page.brand_name = BRANDS.no_brand;
            Page.page_name = `${propertyName}:faq`;
            Page.site_section = 'faq';
            Page.sub_section = '';
            Page.sub_section2 = '';
            dataLayer.Events = events ? `${events}` : '';
        }
        else if (pathName.includes('/category/')) {//plp
            let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
            console.log('@data PLP breadcrumb ', breadcrumbs)
            Page.brand_name = context.brand;
            Page.site_section = 'category detail';
            if (breadcrumbs.length >= 3 && breadcrumbs[2].label == "Search") {
                Page.sub_section = breadcrumbs[1].label;
                Page.sub_section2 = breadcrumbs.length >= 4 ? breadcrumbs[3].label : "";
                Page.sub_section3 = breadcrumbs.length == 5 ? breadcrumbs[4].label : "";
            } else {
            Page.sub_section = breadcrumbs[1].label;
            Page.sub_section2 = breadcrumbs.length >= 3 ? breadcrumbs[2].label : "";
            Page.sub_section3 = breadcrumbs.length == 4 ? breadcrumbs[3].label : "";
            }
            Page.page_name = `${propertyName}:${Page.site_section}:${Page.sub_section}`;
            if (Page.sub_section2 != '' && Page.sub_section3 == '') {
                Page.page_name = `${Page.page_name}:${Page.sub_section2}`;
            }
            if (Page.sub_section3 != '') {
                Page.page_name = `${Page.page_name}:${Page.sub_section3}`;
            }
            if (Page.sub_section3) {
                dataLayer.Events = events ? `${events},sub category1 detail page` : 'sub category1 detail page';
            } else if (Page.sub_section2) {
                dataLayer.Events = events ? `${events},sub category detail page` : 'sub category detail page';
            } else {
                dataLayer.Events = events ? `${events},category detail page` : 'category detail page';
            }
            dataLayer.Model = populateModelDetails(context);
        }
        else if (pathName.includes('/cart')) {//cart
            console.log('context / cart', context, localStorage.getItem('cartBrand'))
            if (context && context.brand) { Page.brand_name = context.brand; }
            ////for adobe bug: 32 starts
            else if (localStorage.getItem('cartBrand')) {
                Page.brand_name = localStorage.getItem('cartBrand');
            }
            else {
                Page.brand_name = 'no brand';
            } ////for adobe bug: 32 : ends
            Page.page_name = `${propertyName}:cart`;
            Page.site_section = 'cart';
            Page.sub_section = '';
            Page.sub_section2 = '';
            dataLayer.Cart = await populateCartDetails_fromServer();
            if (dataLayer.Cart && dataLayer.Cart.item && dataLayer.Cart.item.length > 0) {
                dataLayer.Events = events ? `${events},scView` : 'scView';
            }
        }
        else if (pathName.includes('/my-wishlist')) {//wishlist
            Page.brand_name = BRANDS.no_brand;
            Page.page_name = `${propertyName}:my account:my wishlist`;
            Page.site_section = 'my account';
            Page.sub_section = '';
            Page.sub_section2 = '';
            let wishlistItems = await getWishlistItem({ recordId: Id });
            dataLayer.Cart = populateCartDetails(wishlistItems, undefined);
            dataLayer.Events = dataLayer.Cart && dataLayer.Cart.item && dataLayer.Cart.item.length > 0 ? 'wishlist viewed' : '';
        }
        else if (pathName.includes('/findmyorder')) {//findMyOrder
            Page.brand_name = BRANDS.no_brand;
            Page.page_name = `${propertyName}:find my order`;
            Page.site_section = 'find my order';
            Page.sub_section = '';
            Page.sub_section2 = '';
            dataLayer.Events = events ? `${events}` : '';
        } else if (pathName.includes('/ordersummarypage')) {//ordersummarypage
            Page.brand_name = BRANDS.no_brand;
            Page.page_name = `${propertyName}:order summary`;
            Page.site_section = 'order summary';
            Page.sub_section = '';
            Page.sub_section2 = '';
            dataLayer.Events = events ? `${events}` : '';
        } else if (pathName.includes('/my-products')) {//my-products
            Page.brand_name = BRANDS.no_brand;
            Page.page_name = `${propertyName}:my account:my products`;
            Page.site_section = 'my account';
            Page.sub_section = '';
            Page.sub_section2 = '';
        }
        else if (pathName.includes('/my-dealers')) {//my-dealers
            Page.brand_name = BRANDS.no_brand;
            Page.page_name = `${propertyName}:my account:my dealers`;
            Page.site_section = 'my account';
            Page.sub_section = '';
            Page.sub_section2 = '';
        }
        else if (pathName.includes('/my-payments')) {//my-payments
            Page.brand_name = BRANDS.no_brand;
            Page.page_name = `${propertyName}:my account:my payments`;
            Page.site_section = 'my account';
            Page.sub_section = '';
            Page.sub_section2 = '';
        }
        else if (pathName.includes('/myaddressbook')) {//my address book
            Page.brand_name = BRANDS.no_brand;
            Page.page_name = `${propertyName}:my account:my address book`;
            Page.site_section = 'my account';
            Page.sub_section = '';
            Page.sub_section2 = '';
        }
        else if (pathName.includes('/mypreferences')) {//mypreferences
            Page.brand_name = BRANDS.no_brand;
            Page.page_name = `${propertyName}:my account:my preferences`;
            Page.site_section = 'my account';
            Page.sub_section = '';
            Page.sub_section2 = '';
        }
        else if (pathName.includes('/order-history')) {//order-history
            Page.brand_name = BRANDS.no_brand;
            Page.page_name = `${propertyName}:my account:order history`;
            Page.site_section = 'my account';
            Page.sub_section = '';
            Page.sub_section2 = '';
        }
        else if (pathName.includes('/product/')) {//pdp
            await sleep(2000);
            Page.brand_name = context.brand;
            //let breadcrumbs = new Map(JSON.parse(localStorage.getItem('breadcrumbsMap'))).get(localStorage.getItem('brand'));
            let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMapPDPforAd'))).get(sessionStorage.getItem('brand'));
            console.log('@data PLP breadcrumb ', breadcrumbs)
            Page.site_section = breadcrumbs[1].label;
            Page.sub_section = (breadcrumbs[1].label == 'Parts' && breadcrumbs.length >= 3) ? breadcrumbs[2].label : '';
            Page.sub_section2 = breadcrumbs.length > 4 ? breadcrumbs[3].label : "";
            let prodId = pathName.split('/').at(-1);
            let products = await getProductSKUById({ prodId: prodId })
            console.log('@data product', products)
            dataLayer.Product = populatePdpProductDetails(breadcrumbs, context, products);
            if (Page.sub_section != '') {
                Page.page_name = `${propertyName}:${Page.site_section}:${Page.sub_section}:${breadcrumbs[breadcrumbs.length - 1].label}`;
            } else {
                Page.page_name = `${propertyName}:${Page.site_section}:${breadcrumbs[breadcrumbs.length - 1].label}`;
            }
            dataLayer.Events = events ? `${events},prodView` : 'prodView';
            dataLayer.Model = populateModelDetails(context);
        }
        else if (pathName.includes('/checkout')) {//checkout
            Page.site_section = 'checkout';
            Page.sub_section2 = '';
            let cartId = pathName.split('/').at(-1);
            let checkoutStatus = await returnCheckoutState({ cartId: cartId });
            let checkoutState = '';
            if (Array.from(CHECKOUT_STAGES.values()).includes(checkoutStatus)) {
                checkoutState = checkoutStatus;
            }
            else {
                checkoutState = CHECKOUT_STAGES.get(await returnCheckoutState({ cartId: cartId }));
            }
            Page.page_name = `${propertyName}:checkout:${checkoutState}`;
            Page.sub_section = checkoutState;
            dataLayer.Events = CHECKOUT_EVENTS.get(checkoutState);
            if (checkoutState == 'Confirmation') {
                let checkoutDetails = await populateCheckoutDetails(data.confirmationOrderId);
                dataLayer.Cart = checkoutDetails.cart;
                dataLayer.Payment = checkoutDetails.payment;
                dataLayer.Delivery = checkoutDetails.delivery;
                dataLayer.Transaction = checkoutDetails.transaction;
            } else {
                let products = await getCartItemList2({ cartId: cartId })
                dataLayer.Cart = populateCartDetails(products, cartId);
            }

            ////for adobe bug: 44 starts
            if (localStorage.getItem('cartBrand')) { Page.brand_name = localStorage.getItem('cartBrand'); }
            else if (dataLayer && dataLayer.Cart && dataLayer.Cart.items.length > 0 && dataLayer.Cart.item[0].ProductInfo && dataLayer.Cart.item[0].ProductInfo.product_brand) {
                Page.brand_name = dataLayer.Cart.item[0].ProductInfo.product_brand;
            }
            else if (context && context.brand) { Page.brand_name = context.brand; }
            else { Page.brand_name = 'no brand' }
            ////for adobe bug: 44 : ends
        }
        Object.assign(dataLayer.Page, Page);

        sessionStorage.setItem('referrer', document.location.href);
        sessionStorage.setItem('dataLayer', JSON.stringify(dataLayer));

    }

    console.log('@data dataLayer', dataLayer)

    function deletePageSections() {
        if (dataLayer && dataLayer.Page && (dataLayer.Page.site_section || dataLayer.Page.site_section == '')) { delete dataLayer.Page.site_section; }
        if (dataLayer && dataLayer.Page && (dataLayer.Page.sub_section || dataLayer.Page.sub_section == '')) { delete dataLayer.Page.sub_section; }
        if (dataLayer && dataLayer.Page && (dataLayer.Page.sub_section2 || dataLayer.Page.sub_section2 == '')) { delete dataLayer.Page.sub_section2; }
        if (dataLayer && dataLayer.Page && (dataLayer.Page.sub_section3 || dataLayer.Page.sub_section3 == '')) { delete dataLayer.Page.sub_section3; }
    }
    dataLayer.Page.page_name = dataLayer.Page.page_name.replace(/[®#™]/g, '');

    return dataLayer;

}

function populatePdpProductDetails(breadcrumbs, context, products) {
    console.log('populate pdp details', breadcrumbs)
    let product = {
        ProductInfo: {
            product_name: breadcrumbs[breadcrumbs.length - 1].label.replace(/[,;|®#™]/g, '').toLowerCase(),
            product_id: products.StockKeepingUnit.toLowerCase(),
            category: breadcrumbs.length > 1 ? breadcrumbs[1].label.toLowerCase() : '',
            sub_category: (breadcrumbs.length > 1 && breadcrumbs[1].label == 'Parts') ? breadcrumbs[2].label.toLowerCase() : '',
            sub_category1: breadcrumbs.length > 4 ? breadcrumbs[3].label.toLowerCase() : "",//for adobe bug:24
            product_brand: context.brand.toLowerCase(),
            model_id: context.Model_Id__c ? context.Model_Id__c.toLowerCase() : '',
            model_name: context.model ? context.model.toLowerCase() : '', //for adobe bug 28&30
            model_year: context.year ? context.year.toLowerCase() : '',
            model_trim: context.trim ? context.trim.toLowerCase() : '',
        }
    };
    // dataLayer.Product.push(product);
    let Products = [];
    Products.push(product);
    return Products;
}

function populateEventMetadataDetails(eventMetadata, Page) {
    let actionLabel = '';

    if (eventMetadata.action_type == 'footer links') {
        actionLabel = Page.page_name + ':' + eventMetadata.action_label;
    } else {
        actionLabel = Page.page_name + ':' + eventMetadata.action_type + ':' + eventMetadata.action_label;
    }

    let EventMetadata = {
        action_type: eventMetadata.action_type,
        action_category: getActionCategory(eventMetadata, Page).replace(/[®#™]/g, ''),
        action_label: actionLabel.replace(/[®#™]/g, ''),
        download_title: eventMetadata.download_title ? eventMetadata.download_title.replace(/[®#™]/g, '') : ''
    }

    return EventMetadata;
}

function getActionCategory(eventMetadata, Page) {
    if (eventMetadata.action_category == 'dealer search') {
        return `${Page.site_section}-${eventMetadata.action_category}`;
    } else if (eventMetadata.action_category == 'login' || eventMetadata.action_category == 'register') {
        if (document.location.pathname.includes('/category') || document.location.pathname.includes('/product')) {
            let actionLabel = `${Page.site_section}`;
            console.log('@data login/register', actionLabel)
            if (Page.sub_section != '') {
                actionLabel = `${actionLabel}-${Page.sub_section}`;
                console.log('@data login/register sub_section', actionLabel)
            }
            if (Page.sub_section2 != '') {
                actionLabel = `${actionLabel}-${Page.sub_section2}`;
                console.log('@data login/register sub_section2', actionLabel)
            }
            if (Page.sub_section3 && Page.sub_section3 != '') {
                actionLabel = `${actionLabel}-${Page.sub_section3}`;
                console.log('@data login/register sub_section3', actionLabel)
            }
            console.log('@data login/register', actionLabel)
            return `${actionLabel}-${eventMetadata.action_category}`;
        } else {
            return `${Page.site_section}-${eventMetadata.action_category}`
        }
    } else {
        return eventMetadata.action_category;
    }
}

function populateModelDetails(product) {
    let Model = {};
    if (product.year) { Model.model_year = product.year; };
    if (product.model) { Model.model_name = product.model; };
    if (product.trim) { Model.model_trim = product.trim; };
    if (product.Model_Id__c) { Model.model_id = product.Model_Id__c };
    // if (product.vin && product.vin != '-' && product.vin != '') { Model.model_vin = product.vin; };
    return Model;
}

function populateDealerDetails(dealer) {
    let Dealer = {};
    if (dealer && dealer.dealer_locator_search_type && dealer.dealer_locator_search_term) {
        Dealer.dealer_locator_search_type = dealer.dealer_locator_search_type;
        Dealer.dealer_locator_search_term = dealer.dealer_locator_search_term;
    }
    return Dealer;
}

function populateCartDetails(products, cartId) {
    let cart = {};
    if (cartId) { cart = { cart_id: cartId }; }
    let items = [];
    console.log('@products', products)
    products.forEach((element) => {
        let ProductInfo = {};
        if (element.Name) { ProductInfo.product_name = element.Name.replace(/[,;|®#™]/g, '').toLowerCase() }
        if (element.Product2 && element.Product2.StockKeepingUnit) { ProductInfo.product_id = element.Product2.StockKeepingUnit.toLowerCase() }
        if (element.Product_Model__r && element.Product_Model__r.Product_Subdivision__c) { ProductInfo.product_brand = element.Product_Model__r.Product_Subdivision__c.toLowerCase() }
        if (element.Product_Model__r && element.Product_Model__r.Product_Model_ID__c) { ProductInfo.model_id = element.Product_Model__r.Product_Model_ID__c.toLowerCase() }
        if (element.Product_Model__r && element.Product_Model__r.Model_Name__c) { ProductInfo.model_name = element.Product_Model__r.Model_Name__c.toLowerCase() }
        if (element.Product_Model__r && element.Product_Model__r.Model_Year__c) { ProductInfo.model_year = element.Product_Model__r.Model_Year__c.toLowerCase() }
        if (element.Product_Model__r && element.Product_Model__r.Trim__c) { ProductInfo.model_trim = element.Product_Model__r.Trim__c.toLowerCase() }
        items.push({ ProductInfo: ProductInfo });
    })
    cart.item = items;
    return cart;
}
async function populateCartDetails_fromServer() {
    let cartId = await getCartId({ communityId: communityId });
    let products = await getCartItemList2({ cartId: cartId });
    return populateCartDetails(products, cartId);

}
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function populateCheckoutDetails(orderId) {
    let cart = {};
    let checkoutDetails = {
        cart: {},
        transaction: { total: {}, purchase_id: '' },
        delivery: {},
        payment: {}
    }
    let cartId = document.location.pathname.split("/").at(-1);
    let products = await getCartItemList2({ cartId: cartId });
    if (cartId) { cart = { cart_id: cartId }; }
    let items = [];
    products.forEach((element) => {
        items.push({
            quantity: element.Quantity ? element.Quantity : '',
            ProductInfo: {
                product_name: element.Name ? element.Name.replace(/[,;|®#™]/g, '').toLowerCase() : '',
                product_id: element.Product2 && element.Product2.StockKeepingUnit ? element.Product2.StockKeepingUnit.toLowerCase() : '',
                product_brand: element.Product_Model__r && element.Product_Model__r.Product_Subdivision__c ? element.Product_Model__r.Product_Subdivision__c.toLowerCase() : '',
                model_id: element.Product_Model__r && element.Product_Model__r.Product_Model_ID__c ? element.Product_Model__r.Product_Model_ID__c.toLowerCase() : '',
                model_name: element.Product_Model__r && element.Product_Model__r.Model_Name__c ? element.Product_Model__r.Model_Name__c.toLowerCase() : '',
                model_year: element.Product_Model__r && element.Product_Model__r.Model_Year__c ? element.Product_Model__r.Model_Year__c.toLowerCase() : '',
                model_trim: element.Product_Model__r && element.Product_Model__r.Trim__c ? element.Product_Model__r.Trim__c.toLowerCase() : ''
            },
            price: {
                unit_price: element.ListPrice ? element.ListPrice : '' //for adobe bug: 26
            }
        });
    })
    cart.item = items;
    checkoutDetails.cart = cart;

    await getOrderInfo({ orderId: orderId })
        .then(result => {
            if (result) {
                checkoutDetails.transaction.purchase_id = result.OrderNumber;
                checkoutDetails.payment.payment_method = result.Payment_Type__c;
            }
        })
        .catch(error => { });
    checkoutDetails.delivery.delivery_method = products[0].Cart.Delivery_Type__c;
    checkoutDetails.transaction.total.currency = 'USD';
    if (products[0].Cart.Total_Tax__c) { checkoutDetails.transaction.total.tax = products[0].Cart.Total_Tax__c }
    if (checkoutDetails.delivery.delivery_method == 'Ship to Me') {
        checkoutDetails.transaction.total.shipping = products[0].Cart.ShippingAmount__c;
    } else {
        checkoutDetails.transaction.total.shipping = 0;// for adobe bug: 27
    }
    if (checkoutDetails.delivery.delivery_method == 'Install At Dealer') {
        checkoutDetails.transaction.total.installation_charges = products[0].Cart.Total_Installation_Charge__c;
    } else {
        checkoutDetails.transaction.total.installation_charges = 0;
    }
    return checkoutDetails;
}