//============================================================================
// Title:    Data Access Controller for Honda Owners Community
// Summary:  Common logic to support Data Access:  to/from Server via Apex or to/from browser Local Storage
// Details:  If the user is logged in then data access is from the server.  but if the user is a Guest then data access is from browser Local Storage
//
// Sample Usage:
// 1) add this line into the js of your lwc: 
//          a) import { refreshGarage } from 'c/ownDataUtils';
//          b) import { getContext } from 'c/ownDataUtils';
// 2) call the methods from your lwc:
//          a) var garage = refreshGarage();
//          b) var context = getContext();
//			
//--------------------------------------------------------------------------------------
//
// History:
// June 2, 2021 Jim Kohs (Wipro) Initial coding
// June 27, 2021 Arunprasad N (Wipro) Initial coding
// June 27, 2021 Arunprasad N (Wipro) Initial coding
// July 27, 2021 Arunprasad N (Wipro) Help Center coding
//===========================================================================
//import { wire } from 'lwc';
//import Id from '@salesforce/user/Id';

import { LightningElement } from 'lwc';
import { createMessageContext, releaseMessageContext, publish } from 'lightning/messageService';
import OWNERS_MESSAGE_CHANNEL from "@salesforce/messageChannel/OwnersMessageChannel__c";
//import { OwnBaseElement } from 'c/ownBaseElement';

export class ownDataUtils extends LightningElement {

    static publishMC(message) {
        publish(createMessageContext(), OWNERS_MESSAGE_CHANNEL, message);
    }

    static disconnectedCallback() {
        releaseMessageContext(createMessageContext());
    }
}


import { refreshApex } from '@salesforce/apex';
import isGuest from '@salesforce/user/isGuest';
import basePath from "@salesforce/community/basePath";
import fromServer_getProduct from '@salesforce/apex/OwnGarageController.getProduct';
import fromServer_getGarage from '@salesforce/apex/OwnGarageController.getGarage';
import fromServer_addProduct from '@salesforce/apex/OwnGarageController.addProduct';
import fromServer_updateProduct from '@salesforce/apex/OwnGarageController.updateProduct';
import fromServer_removeProduct from '@salesforce/apex/OwnGarageController.removeProduct';

import fromServer_getContext from '@salesforce/apex/OwnContextController.getContext';
// import fromServer_setContextMenuL1 from '@salesforce/apex/OwnContextController.setContextMenuL1';
// import fromServer_setContextMenuL2 from '@salesforce/apex/OwnContextController.setContextMenuL2';
import fromServer_setProductContextUser from '@salesforce/apex/OwnContextController.setProductContextUser';

import fromServer_search from '@salesforce/apex/OwnHelpCenterController.search';
import fromServer_getKnowledgeArticles from '@salesforce/apex/OwnHelpCenterController.getKnowledgeArticles';
import fromServer_getPopularKnowledgeArticles from '@salesforce/apex/OwnHelpCenterController.getPopularKnowledgeArticles';
import fromServer_getPopularTipsArticles from '@salesforce/apex/OwnHelpCenterController.getPopularTipsArticles';
import fromServer_getKnowledgeArticle from '@salesforce/apex/OwnHelpCenterController.getKnowledgeArticle';
import fromServer_getKnowledgeArticleByUrlName from '@salesforce/apex/OwnHelpCenterController.getKnowledgeArticleByUrlName';
import fromServer_getRelatedArticles from '@salesforce/apex/OwnHelpCenterController.getRelatedArticles';
import fromServer_addKnowledgeArticleVote from '@salesforce/apex/OwnHelpCenterController.addKnowledgeArticleVote';
import fromServer_getGUID from '@salesforce/apex/OwnHelpCenterController.getGUID';
import fromServer_updateConnectedFlag from '@salesforce/apex/OwnContextController.update_UserConnectedFlag';
import fromServer_getManagedContentByTopicsAndContentKeys from '@salesforce/apex/OwnManagedContentController.getManagedContentByTopicsAndContentKeys';
import fromServer_getProductContext from '@salesforce/apex/OwnProductController.getProductContext';
import fromServer_getMyProducts from '@salesforce/apex/OwnProductController.getMyProducts';

import fromServer_getCommunityContext from '@salesforce/apex/OwnContextController.getCommunityContext';

import fromServer_productIdentifierLookUp from '@salesforce/apex/OwnAPIController.productIdentifierLookUp';

import getRecallsByProductIdentifier from '@salesforce/apex/OwnAPIController.getRecallsByProductIdentifier';
import getRecallsByModelId from '@salesforce/apex/OwnAPIController.getRecallsByModelId';

import getCategoryCode from '@salesforce/apex/OwnEConfigApiHelper.getCategoryCode';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export { viewProduct }
export { getGarage }

export { getGarage_fromBrowser }
export { getContext_fromBrowser }
export { refreshGarage }
export { addProduct }
export { updateProduct }
export { removeProduct }
export { getContext }
export { refreshContext }
// export { setContextMenuL1 }
// export { setContextMenuL2 }
export { setProductContextUser }
export { getGarageURL }
export { getGarageServiceMaintenanceURL }
export { search }
export { getKnowledgeArticles }
export { getPopularKnowledgeArticles }
export { getPopularTipsArticles }
export { getKnowledgeArticle }
export { getKnowledgeArticleByUrlName }
export { getRelatedArticles }
export { brandDataCategoryMap }
export { nonConnectedPlatformMap }
export { productIdentifierLookUp }
export { addKnowledgeArticleVote }
export { getGUID }
export { getManagedContentByTopicsAndContentKeys }
export { getProductContext }
export { getMyProducts }
export { getCommunityContext }
export { getProduct }
export { addProduct_fromBrowser }
export { setOrigin }
export { getOrigin }
export { getRecalls }
export { getCategoryCd }
export const ISGUEST = isGuest;

const POWERSPORTS_NAME = 'Powersports';

async function getRecalls(context) {
    let recalls = [];
    if (context && context.product && context.product.hasOwnProperty('recalls')) {
        recalls = context.product.recalls;
    } else if (context.product.productIdentifier || (context.product.vin && context.product.vin != '-')) {
        let vin = context.product.productIdentifier ? context.product.productIdentifier : context.product.vin;
        await getRecallsByProductIdentifier({ productIdentifier: vin, divisionId: context.product.divisionId }).then((res) => {
            if (res.response.recalls_response.response.recall.campaignType.campaign)
                recalls = JSON.parse(JSON.stringify(res.response.recalls_response.response.recall.campaignType.campaign));
        }).catch(err => {
             //console.log(err);
             });
    } else {
        let modelId = context.product.modelId;
        await getRecallsByModelId({ modelId: modelId, divisionId: context.product.divisionId }).then((res => {
            if (res.response.recalls_response.response.recall.campaignType.campaign)
                recalls = JSON.parse(JSON.stringify(res.response.recalls_response.response.recall.campaignType.campaign));
        })).catch(err => {
             //console.log(err);
             });
    }
    return recalls;
}

function getProduct(productId, brand) {
    return isGuest ? getProduct_fromBrowser(productId, brand) : getProduct_fromServer(productId, brand);
}

function getGarage(productId, source) {
    return isGuest || source == 'Browser' ? getGarage_fromBrowser(productId) : getGarage_fromServer(productId);
}

function refreshGarage(productId) {
    return isGuest ? refreshGarage_fromBrowser(productId) : refreshGarage_fromServer(productId);
}

function addProduct(product) {
    return isGuest ? viewProduct(product) : addProduct_fromServer(product);
}

function updateProduct(product) {
    return isGuest ? updateProduct_fromBrowser(product) : updateProduct_fromServer(product);
}

function removeProduct(productId) {
    return isGuest ? removeProduct_fromBrowser(productId) : removeProduct_fromServer(productId);
}


function getContext(productId) {
    return isGuest ? getContext_fromBrowser(productId) : getContext_fromServer(productId);
}

function refreshContext(productId) {
    return isGuest ? refreshContext_fromBrowser(productId) : refreshContext_fromServer(productId);
}

// function setContextMenuL1(contextInput) {
//     return isGuest ? setContextMenuL1_fromBrowser(contextInput) : setContextMenuL1_fromServer(contextInput);
// }

// function setContextMenuL2(contextInput) {
//     return isGuest || contextInput.origin === 'ProductChooser' ? setContextMenuL2_fromBrowser(contextInput) : setContextMenuL2_fromServer(contextInput);
// }

function setProductContextUser(contextInput) {
    return isGuest ? setProductContextUser_fromBrowser(contextInput) : setProductContextUser_fromServer(contextInput);
}

function search(searchKey, category, sortBy, maxResults) {
    return search_fromServer(searchKey, category, sortBy, maxResults);
}

function getKnowledgeArticles(category, maxResults) {
    return getKnowledgeArticles_fromServer(category, maxResults);
}

function getPopularKnowledgeArticles(category, maxResults) {
    return getPopularKnowledgeArticles_fromServer(category, maxResults);
}
function getPopularTipsArticles(brand, maxResults) {
    return getPopularTipsArticles_fromServer(brand, maxResults);
}

function getKnowledgeArticle(articleId, guestId) {
    return getKnowledgeArticle_fromServer(articleId, guestId);
}

function getKnowledgeArticleByUrlName(urlName) {
    return getKnowledgeArticleByUrlName_fromServer(urlName);
}

function getRelatedArticles(searchKey, category, maxResults) {
    return getRelatedArticles_fromServer(searchKey, category, maxResults);
}

function addKnowledgeArticleVote(articleId, vote, guestId,comment) {
    return addKnowledgeArticleVote_fromServer(articleId, vote, guestId,comment);
}

function getGUID() {
    return getGUID_fromServer();
}

function getManagedContentByTopicsAndContentKeys(contentKeys, topics, pageSize, managedContentType) {
    return getManagedContentByTopicsAndContentKeys_fromServer(contentKeys, topics, pageSize, managedContentType);
}

function getProductContext(productId, guest) {
    if (isGuest || guest) {
        return getProductContext_fromBrowser(productId);
    } else {
        return getProductContext_fromServer(productId);
    }
}

function getMyProducts(productId) {
    return getMyProducts_fromServer(productId);
}

function setOrigin(origin) {
    localStorage.setItem('origin', origin);
}

function getOrigin() {
    return localStorage.getItem('origin') ? localStorage.getItem('origin') : '';
}

//Added By: Abhishek Salecha on 8th Oct 2021
async function getCommunityContext() {
    return isGuest ? await getCommunityContext_fromBrowser() : await getCommunityContext_fromServer();
}

const brandDataCategoryMap = new Map();
brandDataCategoryMap.set('AcuraAutos', {
    'label': 'Acura Autos',
    'name': 'AcuraAutos',
    'url': '/help-center-acura'
});
brandDataCategoryMap.set('HondaAutos', {
    'label': 'Honda Autos',
    'name': 'HondaAutos',
    'url': '/help-center-honda'
});
brandDataCategoryMap.set('HondaPowersports', {
    'label': 'Honda Powersports',
    'name': 'HondaPowersports',
    'url': '/help-center-powersports'
});
brandDataCategoryMap.set('HondaPowerEquipment', {
    'label': 'Honda Power Equipment',
    'name': 'HondaPowerEquipment',
    'url': '/help-center-powerequipment'
});
brandDataCategoryMap.set('HondaMarine', {
    'label': 'Honda Marine',
    'name': 'HondaMarine',
    'url': '/help-center-marine'
});

const nonConnectedPlatformMap = ['Legacy', 'legacy', 'LEGACY', 'MY14'];

function productIdentifierLookUp(productIdentifier, divisionId) {
    return productIdentifierLookUp_fromServer(productIdentifier, divisionId);
}

//====================
// Added By:  Abhishek Salecha
// Date: 8th Oct 2021
//====================
function getCommunityContext_fromBrowser() {
    const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
    return context;
}

//====================
// Added By:  Abhishek Salecha
// Date: 8th Oct 2021
//====================
async function getCommunityContext_fromServer() {
    let communityContext = {};
    await fromServer_getCommunityContext()
        .then((result) => {
            communityContext = result;
            //console.log('result =>', result);
        })
        .catch((error) => {
            //console.log('error =>', error);
        })
        .finally(() => { });
    return communityContext;
}

//=======================
// Added By:  Abhishek Salecha
// Date: 11th Oct 2021
// Getting Product From Browser
//=======================
function getProduct_fromBrowser(productId, brand) {
    const garage = localStorage.getItem('garage') ? JSON.parse(localStorage.getItem('garage')) : {};
    let division = '';
    switch (brand.toLowerCase()) {
        case 'powersports':
            division = 'M';
            break;

        case 'acura':
            division = 'A';
            break;
    }
    if (garage.products && productId && brand) {
        return garage.products.find(element => element.productId === productId && element.divisionId === division);
    }
    return {};
}
//====================
// Added By:  Abhishek Salecha
// Date: 11th Oct 2021
// Getting Product From Server
//====================
async function getProduct_fromServer(productId, brand) {
    //console.log('getProduct_fromServer : ', productId, brand);
    let product = {};
    await fromServer_getProduct({
        productId: productId,
        brand: brand
    })
        .then((result) => {
            //console.log('OwnDataUtils : result :  ', result);
            product = result;
        })
        .catch((error) => {
           // console.error(error);
        })
        .finally(() => { });
    return product;
}

//=======================
//= Garage
//=======================
function getGarage_fromBrowser(productId) {
    //console.log('get Garage from Browser!');
    const garage = localStorage.getItem('garage') ? JSON.parse(localStorage.getItem('garage')) : {};
    if (garage.products && productId) {
        const product = garage.products.find(element => element.productId === productId);
        if (product) {
            garage.products = [product];
        }
    }
    return garage;
}
async function getGarage_fromServer(productId) {
    let garage = {};
    await fromServer_getGarage({
        productId: productId
    })
        .then((result) => {
            garage = result;
        })
        .catch((error) => { })
        .finally(() => { });
    return garage;
}

function refreshGarage_fromBrowser(productId) {
    return getGarage_fromBrowser(productId);
}

function refreshGarage_fromServer(productId) {
    getGarage_fromServer(productId);
}

function viewProduct(product) {
    let garage = localStorage.getItem('garage') ? JSON.parse(localStorage.getItem('garage')) : {};

    if (!product.image) {
        let divisionLogo;
        if (product.division === 'Honda') {
            divisionLogo = '/resource/MyGarage/img/thumbnail_honda.png'; //'/cms/delivery/media/MCYYDI357BSZDS5FXGPSPN5AH4AQ';
        }
        else if (product.division === 'Acura') {
            divisionLogo = '/resource/MyGarage/img/thumbnail_acura.png'; //'/cms/delivery/media/MCZYP2ZIWGIJCNTB5TO4LRLE4TFY';
        }
        else if (product.division === 'Motorcycle/Powersports') {
            divisionLogo = '/resource/MyGarage/img/thumbnail_powersports.png'; //'/cms/delivery/media/MCQJUU7MKCERCYBL77NG7CTXBDQU';
        }
        else if (product.division === 'Powerequipment') {
            divisionLogo = '/resource/MyGarage/img/thumbnail_powerequipment.png'; //'/cms/delivery/media/MCMFYJERXT4ZD6XDGL6HZ7GGNZ4U';
        }
        else if (product.division === 'Marine') {
            divisionLogo = '/resource/MyGarage/img/thumbnail_marine.png'; //'/cms/delivery/media/MCRIYJTYRG7FB23N4324ABJESWL4';
        }
        product.image = divisionLogo;
    }

    if (garage && garage.products) {
        product.productId = (garage.products.length + 1).toString();
        garage.products.unshift(product);
    } else {

        product.productId = ([product].length).toString();
        garage.products = [product];
    }
    //console.log('productID', product.productId);
    localStorage.setItem('garage', JSON.stringify(garage));
    //localStorage.setItem('tempgarage', JSON.stringify(garage));
    sessionStorage.setItem('getContextProductId', '');
    //console.log('setting garage!');
    //console.log(localStorage.getItem('garage'));

    let contextInput = {
        // 'level1': getGarageURL(product.division),
        // 'level2': product.productId,
        'productTab': 'Overview',
        'productId': product.productId,
        'product': product
    };
    localStorage.setItem('context', JSON.stringify(contextInput));
    // setContextMenuL2_fromBrowser(contextInput);

    // const result = {
    //     'isSuccess': true,
    //     'message': 'Product added to Garage (session)',
    //     'product': product
    // };
    // returnSuccessResult(result);
    let path = window.location.href;
    let endpoint = path.substring(path.lastIndexOf('/') + 1);
    //console.log('endpoint ----> ', endpoint);
    let fromRecallCard = sessionStorage.getItem('fromRecallCard');
    if (!isGuest && product.divisionId != 'P') {
        fromServer_updateConnectedFlag({ productIdentifier: product.vin, divisionId: product.divisionId }).then((res) => {
            //console.log('res :: ', res);
            if (endpoint == 'hondalink-product-compatibility') {
                //console.log('------------In Honda-------------');
                sessionStorage.setItem('frompage', 'HondaLink');
                navigate('/honda-product-compatibility-result?fb=true');
            } else if (endpoint == 'acuralink-product-compatibility') {
                //console.log('------------In Acura-------------');
                sessionStorage.setItem('frompage', 'AcuraLink');
                navigate('/acura-product-compatibility-result?fb=true');
            } else if (document.title == 'Recall Search') {
                navigate('/recalls-detail');
            }else if (document.title == 'Warranty Search') {
                navigate('/warranty-info');
            } else if (document.title == 'Enter VIN') {
                //console.log('fromRecallCard1', fromRecallCard);
                if (fromRecallCard == 'true') {
                    sessionStorage.removeItem('fromRecallCard');
                    navigate('/recalls-detail');
                }
                else {
                    history.back();
                }
            }else if(endpoint.includes('manuals-search')){
                sessionStorage.setItem('frompage', "Owner's Manuals Search");
                navigate('/owners-manuals');
            }   
            else {
                navigate(getGarageURL(product.division));
            }
        }).catch((error) => {
            //console.log('error', JSON.stringify(error));
        });
    } else {
        if (endpoint == 'hondalink-product-compatibility') {
            //console.log('------------In Honda-------------');
            sessionStorage.setItem('frompage', 'HondaLink');
            navigate('/honda-product-compatibility-result?fb=true');
        } else if (endpoint == 'acuralink-product-compatibility') {
            //console.log('------------In Acura-------------');
            sessionStorage.setItem('frompage', 'AcuraLink');
            navigate('/acura-product-compatibility-result?fb=true');
        } else if (document.title == 'Recall Search') {
            navigate('/recalls-detail');
        }else if (document.title == 'Warranty Search') {
            navigate('/warranty-info');
        } else if (document.title == 'Enter VIN') {
            if (fromRecallCard == 'true') {
                sessionStorage.removeItem('fromRecallCard');
                navigate('/recalls-detail');
            }
            else {
                history.back();
            }
        } else if(window.location.search == '?page=recalls'){
            navigate('/recalls-detail');
        }else if(window.location.search == '?page=warranties'){
            navigate('/warranty-info');
        }else if(endpoint.includes('manuals-search')){
            sessionStorage.setItem('frompage', "Owner's Manuals Search");
            navigate('/owners-manuals');
        }  
        else {
            navigate(getGarageURL(product.division));
        }
    }
}


function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function addProduct_fromBrowser(product) {
    const garage = localStorage.getItem('garage') ? JSON.parse(localStorage.getItem('garage')) : {};

    let divisionLogo;
    if (product.division === 'Honda') {
        divisionLogo = '/resource/MyGarage/images/thumbnail_honda.png'; //'/cms/delivery/media/MCYYDI357BSZDS5FXGPSPN5AH4AQ';
    }
    else if (product.division === 'Acura') {
        divisionLogo = '/resource/MyGarage/images/thumbnail_acura.png'; //'/cms/delivery/media/MCZYP2ZIWGIJCNTB5TO4LRLE4TFY';
    }
    else if (product.division === 'Motorcycle/Powersports') {
        divisionLogo = '/resource/MyGarage/images/thumbnail_powersports.png'; //'/cms/delivery/media/MCQJUU7MKCERCYBL77NG7CTXBDQU';
    }
    else if (product.division === 'Powerequipment') {
        divisionLogo = '/resource/MyGarage/images/thumbnail_powerequipment.png'; //'/cms/delivery/media/MCMFYJERXT4ZD6XDGL6HZ7GGNZ4U';
    }
    else if (product.division === 'Marine') {
        divisionLogo = '/resource/MyGarage/images/thumbnail_marine.png'; //'/cms/delivery/media/MCRIYJTYRG7FB23N4324ABJESWL4';
    }
    product.image = divisionLogo;

    if (garage && garage.products) {
        product.productId = (garage.products.length + 1).toString();
        garage.products.unshift(product);
    } else {
        product.productId = ([product].length).toString();
        garage.products = [product];
    }
    localStorage.setItem('garage', JSON.stringify(garage));
    const contextInput = {
        // 'Level1': getGarageURL(product.division),
        // 'Level2': product.productId,
        'productTab': 'Overview',
        'productId': product.productId,
        'product': product
    };
    localStorage.setItem('context', JSON.stringify(contextInput));
    //    setContextMenuL2(contextInput);

    // const result = {
    //     'isSuccess': true,
    //     'message': 'Product added to Garage (session)',
    //     'product': product
    // };
    // returnSuccessResult(result);
    navigate(getGarageURL(product.division));
}

function addProduct_fromServer(product) {
    fromServer_addProduct({
        product: product
    })
        .then((result) => {
            if (result.isSuccess && result.message && result.product && result.product.productId) {
                // Alexander Dzhitenov (Wipro), DOE-4843: Removed all 'success' toast messages.
                //returnSuccessResult(result);
                navigate(getGarageURL(product.division));
            } else if (!result.isSuccess) {
                //console.log('productadded ', JSON.stringify(result));
                returnErrorMessageResult(result);
            }
        })
        .catch((error) => {
            //console.log('productadded error ', JSON.stringify(error));
            returnErrorResult(error);
        })
}

function updateProduct_fromBrowser(product) {
    const garage = localStorage.getItem('garage') ? JSON.parse(localStorage.getItem('garage')) : {};
    const result = {
        'isSuccess': false,
        'message': 'Not found',
        'product': product
    };
    if (garage && garage.products) {
        garage.products.forEach(element => {
            if (element.productId === product.productId) {
                element.nickname = product.nickname;
                localStorage.setItem('garage', JSON.stringify(garage));
                const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
                context.product = product;
                localStorage.setItem('context', JSON.stringify(context));
                result.isSuccess = true;
                result.message = 'Product updated to Garage';
                // Alexander Dzhitenov (Wipro), DOE-4843: Removed all 'success' toast messages.
                //returnSuccessResult(result);
                publishToChannel(result);
            }
        });
    }
    return result;
}
async function updateProduct_fromServer(product) {
    await fromServer_updateProduct({
        product: product
    })
        .then((result) => {
            if (result.isSuccess && result.message && result.product && result.product.productId) {
                // Alexander Dzhitenov (Wipro), DOE-4843: Removed all 'success' toast messages.
                //returnSuccessResult(result);
                publishToChannel(result);
            } else if (!result.isSuccess) {
                returnErrorMessageResult(result);
            }
        })
        .catch((error) => {
            returnErrorResult(error);
        })
}

function removeProduct_fromBrowser(productId) {
    const garage = localStorage.getItem('garage') ? JSON.parse(localStorage.getItem('garage')) : {};
    const result = {
        'isSuccess': false,
        'message': 'Not found',
        'product': {}
    };
    if (garage && garage.products) {
        Object.keys(garage.products).forEach((index) => {
            if (garage.products[index] && garage.products[index].productId === productId) {
                garage.products.splice(parseInt(index), 1);
                localStorage.setItem('garage', JSON.stringify(garage));
                result.isSuccess = true;
                result.message = 'Product removed from Garage';
                // Alexander Dzhitenov (Wipro), DOE-4843: Removed all 'success' toast messages.
                //returnSuccessResult(result);
            }
        });
        if (garage.products && garage.products.length > 0) {
            const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
            // context.Level1 = '/garage-' + garage.products[0].division.toLowerCase();
            // context.Level2 = garage.products[0].productId;
            context.productId = garage.products[0].productId;
            context.product = garage.products[0];
            localStorage.setItem('context', JSON.stringify(context));
            navigate(getGarageURL(garage.products[0].division));
        } else {
            const context = {};
            localStorage.setItem('context', JSON.stringify(context));
            navigate(getGarageURL(null));
        }
    }
    return result;
}
async function removeProduct_fromServer(productId) {
    await fromServer_removeProduct({
        productId: productId
    })
        .then((result) => {
            if (result.isSuccess && result.message) {
                // Alexander Dzhitenov (Wipro), DOE-4843: Removed all 'success' toast messages.
                //returnSuccessResult(result);
                if (result.product && result.product.division) {
                    navigate(getGarageURL(result.product.division));
                } else {
                    navigate(getGarageURL(null));
                }
            }
        })
        .catch((error) => {
            returnErrorResult(error);
        })
}

//=======================
//= Context
//=======================

function getContext_fromBrowser(productId) {
    //console.log('getContextProductId', sessionStorage.getItem('getContextProductId'));
    //console.log('GARAGE PRODUCTS :: ');
    if (sessionStorage.getItem('getContextProductId')) {
        //console.log('IN GARAGE PRODUCTS :: ');
        productId = sessionStorage.getItem('getContextProductId') ? sessionStorage.getItem('getContextProductId') : productId;
        const garage = localStorage.getItem('garage') ? JSON.parse(localStorage.getItem('garage')) : {};
        const contextOutput = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
        contextOutput.productId = productId;
        contextOutput.productTab = 'Overview';
        //console.log('GARAGE PRODUCTS :: ', garage);
        if (garage && garage.products) {
            garage.products.forEach(element => {
                if (element.productId === contextOutput.productId) {
                    contextOutput.product = element;
                }
            });
        }
        localStorage.setItem('context', JSON.stringify(contextOutput));
    }
    const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
    return context;
}

async function getContext_fromServer(productId) {
    //console.log('productId', productId);
    //console.log('getContextProductId', sessionStorage.getItem('getContextProductId'));
    productId = sessionStorage.getItem('getContextProductId') ? sessionStorage.getItem('getContextProductId') : productId;
    //console.log('after - productId', productId);
    let context = {};
    await fromServer_getContext({
        productId: productId
    })
        .then((result) => {
            context = result;
            //console.log('context from controller', context)
        })
        .catch((error) => {
            //console.log('contextError from controller', error)
        })
        .finally(() => { });
    //console.log('ownDataUtils: Context retrieved: ' + JSON.stringify(context));
    return context;
}

function refreshContext_fromBrowser(productId) {
    return getContext_fromBrowser(productId);
}

function refreshContext_fromServer(productId) {
    getContext_fromServer(productId);
}

// function setContextMenuL1_fromBrowser(contextInput) {
//     const garage = localStorage.getItem('garage') ? JSON.parse(localStorage.getItem('garage')) : {};
//     const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
//     context.Level1 = contextInput.Level1;
//     context.Level2 = contextInput.productId;
//     context.productId = contextInput.productId;
//     if (garage && garage.products) {
//         garage.products.forEach(element => {
//             if (element.productId === context.productId) {
//                 context.product = element;
//             }
//         });
//     }
//     localStorage.setItem('context', JSON.stringify(context));
//     const result = {
//         'isSuccess': true,
//         'message': 'Level 1 updated to Context',
//         'context': context
//     };
//     returnSuccessResult(result);
//     navigate(context.Level1);
// }

// function setContextMenuL1_fromServer(context) {
//     fromServer_setContextMenuL1({
//             context: context
//         })
//         .then((result) => {
//             if (result.isSuccess && result.message && result.context) {
//                 returnSuccessResult(result);
//                 navigate(context.Level1);
//             }
//         })
//         .catch((error) => {
//             returnErrorResult(error);
//         })
// }

// function setContextMenuL2_fromBrowser(contextInput) {
//     localStorage.setItem('context', JSON.stringify(contextInput));
// }

// function setContextMenuL2_fromServer(context) {

//     fromServer_setContextMenuL2({
//             context: context
//         })
//         .then((result) => {
//             if (result.isSuccess && result.message && result.context) {
//                 returnSuccessResult(result);
//             }
//         })
//         .catch((error) => {
//             console.log('Error from SetContext L2 from Server:' + error);
//             returnErrorResult(error);
//         })
// }

function setProductContextUser_fromBrowser(contextInput) {
    const garage = localStorage.getItem('garage') ? JSON.parse(localStorage.getItem('garage')) : {};
    const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
    context.productId = contextInput.productId;
    context.productTab = contextInput.productTab;
    if (garage && garage.products) {
        garage.products.forEach(element => {
            if (element.productId === context.productId) {
                context.product = element;
            }
        });
    }
    localStorage.setItem('context', JSON.stringify(context));
    // const result = {
    //     'isSuccess': true,
    //     'message': 'User updated to Product Context',
    //     'context': context
    // };
    // Alexander Dzhitenov (Wipro), DOE-4843: Removed all 'success' toast messages.
    // returnSuccessResult(result);
}

function setProductContextUser_fromServer(contextInput) {
    fromServer_setProductContextUser({
        context: contextInput
    })
        .then((result) => {
            if (result.isSuccess && result.message && result.context) {
                // Alexander Dzhitenov (Wipro), DOE-4843: Removed all 'success' toast messages.
                //returnSuccessResult(result);
            }
        })
        .catch((error) => {
            returnErrorResult(error);
        })
}

//=======================
//= Help Center
//=======================

async function search_fromServer(searchKey, category, sortBy, maxResults) {
    let results = [];
    await fromServer_search({
        searchKey: searchKey,
        category: category,
        sortBy: sortBy,
        maxResults: maxResults
    })
        .then((result) => {
            results = result;
        })
        .catch((error) => { })
        .finally(() => { });
    return results;
}

async function getKnowledgeArticles_fromServer(category, maxResults) {
    let results = [];
    await fromServer_getKnowledgeArticles({
        category: category,
        maxResults: maxResults
    })
        .then((result) => {
            results = result;
        })
        .catch((error) => { })
        .finally(() => { });
    return results;
}

async function getPopularKnowledgeArticles_fromServer(category, maxResults) {
    let results = [];
    await fromServer_getPopularKnowledgeArticles({
        category: category,
        maxResults: maxResults
    })
        .then((result) => {
            results = result;
        })
        .catch((error) => { })
        .finally(() => { });
    return results;
}

async function getPopularTipsArticles_fromServer(brand, maxResults) {
    let results = [];
    await fromServer_getPopularTipsArticles({
        brand: brand,
        maxResults: maxResults
    })
        .then((result) => {
            results = result;
        })
        .catch((error) => { })
        .finally(() => { });
    return results;
}

async function getKnowledgeArticle_fromServer(articleId, guestId) {
    let results = {};
    await fromServer_getKnowledgeArticle({
        articleId: articleId,
        guestId: guestId
    })
        .then((result) => {
            results = result;
        })
        .catch((error) => { })
        .finally(() => { });
    return results;
}

async function getKnowledgeArticleByUrlName_fromServer(urlName) {
    let results = {};
    await fromServer_getKnowledgeArticleByUrlName({
        urlName: urlName
    })
        .then((result) => {
            results = result;
        })
        .catch((error) => { })
        .finally(() => { });
    return results;
}

async function getRelatedArticles_fromServer(searchKey, category, maxResults) {
    let results = {};
    await fromServer_getRelatedArticles({
        searchKey: searchKey,
        category: category,
        maxResults: maxResults
    })
        .then((result) => {
            results = result;
        })
        .catch((error) => { })
        .finally(() => { });
    return results;
}

async function addKnowledgeArticleVote_fromServer(articleId, vote, guestId,comment) {
    let results = {};
    await fromServer_addKnowledgeArticleVote({
        articleId: articleId,
        vote: vote,
        guestId: guestId,
        comment: comment
    })
        .then((result) => {
            results = result;
        })
        .catch((error) => { })
        .finally(() => { });
    return results;
}

async function getGUID_fromServer(articleId, vote) {
    let results = {};
    await fromServer_getGUID()
        .then((result) => {
            results = result;
        })
        .catch((error) => { })
        .finally(() => { });
    return results;
}

//=======================
//= Connected Features
//=======================

async function productIdentifierLookUp_fromServer(productIdentifier, divisionId) {
    let results = [];
    await fromServer_productIdentifierLookUp({
        productIdentifier: productIdentifier,
        divisionId: divisionId
    })
        .then((result) => {
            results = result;
        })
        .catch((error) => { })
        .finally(() => { });
    return results;
}

//=======================
//= Managed Content
//=======================

async function getManagedContentByTopicsAndContentKeys_fromServer(contentKeys, topics, pageSize, managedContentType) {
    let results = [];
    await fromServer_getManagedContentByTopicsAndContentKeys({
        contentKeys: contentKeys,
        topics: topics,
        pageSize: pageSize,
        managedContentType: managedContentType
    })
        .then((result) => {
            results = result;
        })
        .catch((error) => { })
        .finally(() => { });
    return results;
}

//=======================
//= Product Context
//=======================

function getProductContext_fromBrowser(productId) {
    const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
    return context;
}

async function getProductContext_fromServer(productId) {
    let context = {};
    await fromServer_getProductContext({
        productId: productId
    })
        .then((result) => {
            context = result;
        })
        .catch((error) => {
            //console.log('context error  :-  ', error);
        })
        .finally(() => { });
    return context;
}

//=======================
//= Get My Products
//=======================

async function getMyProducts_fromServer(productId) {
    let myProducts = {};
    await fromServer_getMyProducts({
        productId: productId
    })
        .then((result) => {
            myProducts = result;
        })
        .catch((error) => { })
        .finally(() => { });
    return myProducts;
}

function returnErrorMessageResult(result) {
    showToast(result.message, 'error', 'dismissable');
}

function returnSuccessResult(result) {
    showToast(result.message, 'success', 'dismissable');
}

function returnErrorResult(error) {
    const result = {
        'isSuccess': false,
        'message': reduceErrors(error).join(', ')
    };
    showToast(result.message, 'error', 'dismissable');
}

function getTitle(mode) {
    return mode === 'error' ? 'Error!' :
        mode === 'warning' ? 'Warning!' :
            mode === 'success' ? 'Success!' :
                'Information!';
}

function showToast(message, variant, mode) {
    const title = getTitle(variant);
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
    });
    dispatchEvent(evt);
}

function publishToChannel(result) {
    //const ownBase = new OwnBaseElement();
    const message = {
        'type': result.hasOwnProperty('product') ? 'product' : 'context',
        'result': result
    };
    //ownBase.publishToChannel(message);
    OwnDataUtils.publishMC(message);
}

function navigate(url) {
    window.location = basePath + url;
}

function getGarageURL(division) {
    return division ? '/garage-' + (division.includes(POWERSPORTS_NAME) ? POWERSPORTS_NAME.toLowerCase() : division.toLowerCase()) : '/';
}

function getGarageServiceMaintenanceURL(division) {
    switch (division) {
        case 'Acura':
            return '/acura-service-maintenance';

        case 'Honda':
            return '/honda-service-maintenance';

        case 'Powersports':
            return '/honda-powersports-service-maintenance';

        case 'Motorcycle/Powersports':
            return '/honda-powersports-service-maintenance';

        case 'Powerequipment':
            return '/honda-power-equipment-service-maintenance';

        case 'Marine':
            return '/honda-marine-service-maintenance';


    }
    return null;
}

/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {
                // UI API read errors
                if (Array.isArray(error.body)) {
                    return error.body.map((e) => e.message);
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message;
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
    );
}

async function getCategoryCd(productIdentifier, divisionId, divisionName){
    let categoryCode;
    await getCategoryCode({vinNumber : productIdentifier, poiType : divisionId, divisionName : divisionName})
        .then(result => {
            //console.log('ownTips:: ' + result)
            categoryCode = result;
        })
        .catch(error => {
            //console.log(error);
        })
    return categoryCode;
}
//Imtiyaz - RECALLS Start
export function getDate(subtract_days, date){
    date = date ? date : new Date();
    if(subtract_days){
      date.setDate(date.getDate() - subtract_days);
    }
    return Intl.DateTimeFormat('en-US', {year: 'numeric', month: '2-digit', day: '2-digit'}).format(date);
}

import getUserDetail from '@salesforce/apex/ownMessageController.getUserDetail';
import Show_Console_Logs from '@salesforce/label/c.Show_Console_Logs';
export async function contextDetail(return_context){
    if(showConsoleLogs()){
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        let context;
        if(fromProductChooser) {
            context = await getProductContext('', true);
        }else{
            context = await getProductContext('', false);
        }
        if(return_context){
            return context;
        }
        context = JSON.parse(JSON.stringify(context));
        if(!ISGUEST){
            let user = await getUserDetail();
            //console.groupCollapsed('$HP-USER');
            //console.log(JSON.parse(JSON.stringify(user)));
            //console.groupEnd('$HP-USER');
            Object.keys(user).forEach((prop)=> context.product[prop] = user[prop]);
        }
        if (context && context.product) {
            //console.groupCollapsed('$HP-CONTEXT-DETAIL');
            Object.keys(context.product).forEach((prop)=> createConsoles('$HP-', prop + ': ', context.product[prop]));
           // console.groupEnd('$HP-CONTEXT-DETAIL');
        }
    }
    
}

export function showConsoleLogs(){
    return Show_Console_Logs.toLowerCase() == 'true' ? true : false;
}

export function createConsoles(main, head, value, color1, color2, color3){
    color1 = color1 ? color1 : 'gray';color2 = color2 ? color2 : 'darkslategray';color3 = color3 ? color3 : '#881290';value = value ? value : 'no_data';
    //console.log('%c' + main + '%c' + head + '%c' + value ,'color: ' + color1 + ';font-weight:bold;font-size: 13px','color: ' + color2 + ';font-weight:bold;font-size: 13px', 'color: ' + color3 + ';');
}

//Imtiyaz - RECALLS End