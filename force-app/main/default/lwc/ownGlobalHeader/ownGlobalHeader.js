//============================================================================
// Title:    Honda Owners Experience - Header
//
// Summary:  global header logic at the help center of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the header component for all help center pages.
//
//
// History:
// June 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { ISGUEST, getContext, getGarageURL, getProductContext, setProductContextUser, getRecalls, getOrigin } from 'c/ownDataUtils';  //Ravindra Ravindra(Wipro)  DOE-4345
import { loadStyle } from "lightning/platformResourceLoader";
import userId from '@salesforce/user/Id';
import checkFirstTimeUser from '@salesforce/apex/OwnGarageController.checkFirstTimeUser';
import handleUserLogin from '@salesforce/apex/OwnGarageController.handleUserLogin';
import update_UserIsRecallsEnabled from '@salesforce/apex/OwnRecallsController.update_UserIsRecallsEnabled';
import update_UserHasWarranty from '@salesforce/apex/OwnWarrantyController.update_UserHasWarranty';
import mygarageurl from '@salesforce/label/c.MyGarageURL';
import QualtricsKey from '@salesforce/label/c.QualtricsKey';
import QualtricsURL from '@salesforce/label/c.QualtricsURL';

export default class OwnGlobalHeader extends OwnBaseElement {
    @track isGuest = ISGUEST;
    @track logo = this.ownerResource() + '/Logos/owners_logo.svg';
    @track menuSmall = this.ownerResource() + '/Icons/burger_menu.svg';
    @track leftArrow = this.ownerResource() + '/Icons/left_arrow.svg';
    @track close = this.ownerResource() + '/Icons/close.svg';
    @track header = {
        showMenuLogo: true,
        showLeftArrow: false,
        showLogo: false,
        showClose: false,
        label: undefined,
        showMenu: undefined
    };
    @track menu = {
        showMainMenu: true,
        showSubMenu: false
    };
    @track showFirstTimeLoginModal = false;
    @track alternativeText
    @track size;
    @track variant;
    @track showSpinner = false;
    @track context;
    renderedCallback() {
        //console.log('$RECALLS: ownGlobalHeader renderedCallback');
        /*setTimeout(() => {
            this.template.querySelector('.loader-wrapper').style.display = 'none';
        }, 3000);*/
    }

    connectedCallback() {
        //console.log('$RECALLS: ownGlobalHeader connectedCallback');
        //console.log('GlobalHeader connectedCallback');
        loadStyle(this, `${this.commonStyle()}/main.css`);
        loadStyle(this, `${this.commonStyle()}/variable.css`);

        //DOE-4714 Ravindra Ravindra(Wipro)

        let currentPage = window.location.href;
        if (!currentPage.includes('/in-progress')) {
            this.invokeSpinner();
        }

        //Ravindra Ravindra (wipro) DOE-4547
        if (!this.isGuest) {
            this.handleLogin();
        }
        this.loadQualtricsScript();
        this.redirectForNoContext();
    }

    loadQualtricsScript() {
        (function () {
            var g = function (e, h, f, g) {
                this.get = function (a) { for (var a = a + "=", c = document.cookie.split(";"), b = 0, e = c.length; b < e; b++) { for (var d = c[b]; " " == d.charAt(0);)d = d.substring(1, d.length); if (0 == d.indexOf(a)) return d.substring(a.length, d.length) } return null };
                this.set = function (a, c) { var b = "", b = new Date; b.setTime(b.getTime() + 6048E5); b = "; expires=" + b.toGMTString(); document.cookie = a + "=" + c + b + "; path=/; " };
                this.check = function () { var a = this.get(f); if (a) a = a.split(":"); else if (100 != e) "v" == h && (e = Math.random() >= e / 100 ? 0 : 100), a = [h, e, 0], this.set(f, a.join(":")); else return !0; var c = a[1]; if (100 == c) return !0; switch (a[0]) { case "v": return !1; case "r": return c = a[2] % Math.floor(100 / c), a[2]++, this.set(f, a.join(":")), !c }return !0 };
                this.go = function () { if (this.check()) { var a = document.createElement("script"); a.type = "text/javascript"; a.src = g; document.body && document.body.appendChild(a) } };
                this.start = function () { var t = this; "complete" !== document.readyState ? window.addEventListener ? window.addEventListener("load", function () { t.go() }, !1) : window.attachEvent && window.attachEvent("onload", function () { t.go() }) : t.go() };
            };
            try { (new g(100, "r", QualtricsKey, QualtricsURL)).start() } catch (i) { }
        })();
    }
    
    async redirectForNoContext() {
        let pathNames = ['garage-honda',
            'garage-acura',
            'garage-powersports',
            'garage-powerequipment',
            'garage-marine',
            'honda-product-connected-features',
            'acura-product-connected-features',
            'powersports-product-connected-features',
            'powerequipment-product-connected-features',
            'marine-product-connected-features',
            'honda-service-maintenance',
            'acura-service-maintenance',
            'honda-powersports-service-maintenance',
            'honda-power-equipment-service-maintenance',
            'honda-marine-service-maintenance',
            'honda-financial-services',
            'acura-financial-services',
            'power-sports-financial-services',
            'power-equipment-financial-services',
            'marine-financial-services',
            'honda-resources-downloads',
            'acura-resources-downloads',
            'honda-powersports-resources-downloads',
            'honda-power-equipment-resources-downloads',
            'honda-marine-resources-downloads',
            'honda-marketplace',
            'acura-marketplace',
            'honda-powersports-marketplace',
            'honda-power-equipment-marketplace',
            'honda-marine-marketplace'];
        let pathName = document.location.pathname;
        const match = pathNames.find(element => {
            if (pathName.includes(element)) {
                return true;
            }
        });
        if (match) {
            let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
            let context;
            if (fromProductChooser) {
                context = await getProductContext('', true);
            } else {
                context = await getProductContext('', false);
            }
            if (!context.product) {
                let mygarageURLLabel = mygarageurl === '/' ? '' : mygarageurl;
                window.open(mygarageURLLabel + '/s', "_Self");
            }
        }
    }

    //Ravindra Ravindra (wipro) DOE-4547
    handleLogin() {
        let url = sessionStorage.getItem("RelayState");

        //Alex Dzhitenov (Wipro) DOE-4433
        //Modified Ravindra Ravindra (wipro) DOE-4547
        if (sessionStorage.getItem('isUserLogin') && userId) {
            checkFirstTimeUser()
                .then(result => {
                    //console.log('Checking first time user');
                    let isFirstTimeUser = false;
                    if (result === true) {
                        //console.log('First time user');
                        isFirstTimeUser = true;
                        // Start spinner/loading screen
                        this.showFirstTimeLoginModal = true;
                    }
                    else if (result === false) {
                        //console.log('Not first time user');
                        isFirstTimeUser = false;

                    }

                    // Start spinner if user is logging in for first time (will write method for this)
                    handleUserLogin({ isFirstTimeUser: isFirstTimeUser })
                        .then(result => {
                            //console.log('recallsLoaded: ' + result.recallsLoaded);
                            //console.log(result);
                            if (result.recallsLoaded) {
                                //console.log('Publishing to channel');
                                this.publishToChannel({ "recallDataLoaded": true });
                                //console.log('Published');
                            }
                            //console.log('Login sequence redirect URL: ', url);
                            //console.log('Apex result: ' + JSON.stringify(result));
                            if (isFirstTimeUser) {
                                // end spinner
                                if (!result.hasProducts) {
                                    // First-time user with products in ECRM or Connected—redirect to garage, displaying most recent product
                                    url = '/';
                                }

                                let garage;
                                //console.log('GLOBAL HEADER DEBUG 1: ' + result);
                                if (localStorage.getItem('garage')) {
                                    garage = JSON.parse(localStorage.getItem('garage'));
                                    result.garage.products.forEach(product => {
                                        garage.products.push(product);
                                    })
                                }
                                else {
                                    garage = result.garage;
                                }
                                //console.log('GARAGE BEFORE SETITEM' + JSON.stringify(garage));
                                localStorage.setItem('garage', JSON.stringify(garage));
                                //console.log('GLOBAL HEADER DEBUG: ' + localStorage.getItem('garage'));
                                //localStorage.setItem(JSON.stringify(garageProducts));
                                //sessionStorage.setItem('getContextProductId', result.productId);
                                //console.log('Returning from user login');
                            }
                            else {
                                let garage;
                                if (localStorage.getItem('garage')) {
                                    garage = JSON.parse(localStorage.getItem('garage'));
                                    //console.log('RETRIEVED LOCAL STORAGE GARAGE WITH ' + JSON.stringify(garage));
                                    //console.log('UNSHIFTING GARAGE WITH ' + JSON.stringify(result.garage.products));
                                    result.garage.products.forEach(product => {
                                        garage.products.push(product);
                                    })
                                    //console.log('RESULT: ' + JSON.stringify(garage));
                                }
                                else {
                                    //console.log('SETTING GARAGE TO GARAGE');
                                    garage = result.garage;
                                }
                                localStorage.setItem('garage', JSON.stringify(garage));
                                //console.log('GLOBAL HEADER DEBUG: ' + localStorage.getItem('garage'));
                            }
                            sessionStorage.setItem('userLoginSequence', true);
                            this.pageRedirection(url);
                            sessionStorage.removeItem('isUserLogin');
                        })
                        .catch(error => { 
                            //console.log(JSON.stringify(error));
                         })
                })
                .catch(error => {
                    //console.log(JSON.stringify(error))
                });
            //console.log('Exiting Apex block');
            //console.log('Login sequence redirect URL: ', url);
            //this.pageRedirection(url);
            //sessionStorage.removeItem('isUserLogin');
        }
    }



    //Ravindra Ravindra(Wipro)  DOE-4345
    pageRedirection = async (url) => {
        //console.log('Beginning pageRedirection');
        let context = await getContext('');
        //console.log('Context retrieved: ' + JSON.stringify(context))
        // 
        let isSMpage = url.includes('service-maintenance') ? true : false;
        //console.log('isSMpage', isSMpage);
        if (isSMpage) {
            this.showSpinner = true;
            if (context && context.product) {
                if (context.product.recallCount) {
                    let hasRecalls = context.product.recallCount > 0 ? true : false;
                    await update_UserIsRecallsEnabled({ hasRecalls: hasRecalls }).then((res) => {
                    }).catch((err) => { });
                } else {
                    let recallsData = await getRecalls(context);
                    let hasRecalls = recallsData.length > 0 ? true : false;
                    await update_UserIsRecallsEnabled({ hasRecalls: hasRecalls }).then((res) => {
                    }).catch((err) => {
                         //console.log(err); 
                    });
                }
            }
        }
        // 
        let urlString = window.location.href;
        let baseURL = urlString.substring(0, urlString.indexOf("/s"));
        let homePage = baseURL + '/s/';
        if (url !== null) {
            if ((homePage === url) && context.product) {
                //Updating connected Features Flag on user Object and redirecting to PDP
                localStorage.setItem('origin', '');
                //console.log('Updating connected Features Flag on user Object and redirecting to PDP');
                const contextInput = {
                    'productId': context.productId,
                    'productTab': context.productTab
                };
                await setProductContextUser(contextInput);
                await this.sleep(2000);
                //console.log('Flag Updated')
                url = getGarageURL(context.product.division);
                sessionStorage.removeItem('RelayState');
                this.showFirstTimeLoginModal = false;
                this.navigate(url, {});
            }
            else {
                //console.log('Running else');
                this.showFirstTimeLoginModal = false;
                // window.location.assign(url);
                sessionStorage.removeItem('RelayState');
            }
        }
        if (isSMpage)
            window.location.reload();
    }

    //Ravindra Ravindra(Wipro)  for timeout
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    handleMenuSelect(event) {
        let header = {};
        if (event.detail.showSubMenu) {
            header = {
                showMenuLogo: false,
                showLeftArrow: true,
                showLogo: false,
                showClose: true,
                label: event.detail.label,
                showMenu: true
            }
        } else if (event.detail.closeMenu) {
            header = {
                showMenuLogo: true,
                showLeftArrow: false,
                showLogo: false,
                showClose: false,
                label: undefined,
                showMenu: undefined,
            }
        } else if (event.detail.showMainMenu) {
            header = {
                showMenuLogo: false,
                showLeftArrow: false,
                showLogo: true,
                showClose: true,
                label: undefined,
                showMenu: true
            }
        }
        this.header = header;
    }

    handleCloseClick() {
        let header = {
            showMenuLogo: true,
            showLeftArrow: false,
            showLogo: false,
            showClose: false,
            label: undefined,
            showMenu: undefined
        }
        this.header = header;
    }

    handleLeftArrowClick() {
        let header = {
            showMenuLogo: false,
            showLeftArrow: false,
            showLogo: true,
            showClose: true,
            label: undefined,
            showMenu: true
        }
        this.header = header;
        this.menu = {
            showMainMenu: true,
            showSubMenu: false
        }
    }


    //DOE-4714 Ravindra Ravindra(Wipro)
    async invokeSpinner(alternativeText = 'Loading the page', size = 'large', variant = '') {
        this.showSpinner = document.URL.includes('my-account') ? false : true;
        this.alternativeText = alternativeText;
        this.size = size;
        this.variant = variant;

        await this.sleep(3000);

        this.showSpinner = false;
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    handleClick() {
        this.handleCloseClick();
        this.navigate('/', {});
    }
}