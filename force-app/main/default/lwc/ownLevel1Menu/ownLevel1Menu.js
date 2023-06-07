//============================================================================
// Title:    Honda Owners Experience - Sign Up and Log In
//
// Summary:  level 1 menu logic at the top of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the level 1 menu component for all help center pages.
//
//
// History:
// June 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { OwnBaseElement } from 'c/ownBaseElement';
import { api, LightningElement, track, wire } from 'lwc';
import { setOrigin, ISGUEST, getGarageURL, getGarage, getContext, setProductContextUser } from 'c/ownDataUtils';
import basePath from "@salesforce/community/basePath";
import getCIAMConfig from '@salesforce/apex/OwnUserHandler.getCIAMConfig';
import mygarageurl from '@salesforce/label/c.MyGarageURL';

export default class OwnLevel1Menu extends OwnBaseElement {
    loginUrl;
    signUpUrl;
    @track rightArrow = this.ownerResource() + '/Icons/right_arrow.svg';
    @api menu = {
        showMainMenu: true,
        showSubMenu: false
    };
    @track subMenus = [];

    @track context;

    @track menuId;

    @track menus = screen.width > 904 ? [{
        id: '1',
        label: 'My Products',
        //header: 'Find Resources for Your Honda Products',
        class: 'slds-truncate',
        url: undefined,
        large: true,
        items: [],
    },
    {
        id: '2',
        label: 'Help Center',
        header: 'Connect With Support and Search FAQs',
        class: 'slds-truncate',
        url: undefined,
        large: true,
        items: [{
            id: '1',
            label: 'Acura Autos',
            name: 'HelpCenterAcura',
            url: '/help-acura',
            icon: '',
        },
        {
            id: '2',
            label: 'Honda Autos',
            name: 'HelpCenterHonda',
            url: '/help-honda',
            icon: '',
        },
        {
            id: '3',
            label: 'Honda Powersports',
            name: 'HelpCenterPowersports',
            url: '/help-powersports',
            icon: '',
        },
        {
            id: '4',
            label: 'Honda Power Equipment',
            name: 'HelpCenterPowerequipment',
            url: '/help-powerequipment',
            icon: '',
        },
        {
            id: '5',
            label: 'Honda Marine',
            name: 'HelpCenterMarine',
            url: '/help-marine',
            icon: '',
        },
        {
            id: '6',
            label: 'Search All Help Articles & FAQs',
            name: 'search',
            url: '/help-center',
            icon: this.ownerResource() + '/Icons/search.svg',
        },
        ],
    },
    /*DOE-4256 Start (Code commented for Release 1 - Details: for hiding Find a dealer menu)*/
    {
        id: '3',
        label: 'Find a Dealer',
        header: 'Find a Servicing Dealer Near You',
        class: 'slds-truncate',
        url: undefined,
        large: true,
        items: [{
            id: '1',
            label: 'Acura Autos',
            name: 'Acura',
            url: '/find-a-dealer',
            icon: '',
        },
        {
            id: '2',
            label: 'Honda Autos',
            name: 'Honda',
            url: '/find-a-dealer',
            icon: '',
        },
        {
            id: '3',
            label: 'Honda Powersports',
            name: 'Powersports',
            url: '/find-a-dealer',
            icon: '',
        },
        {
            id: '4',
            label: 'Honda Power Equipment',
            name: 'Power Equipment',
            url: '/find-a-dealer',
            icon: '',
        },
        {
            id: '5',
            label: 'Honda Marine',
            name: 'Marine',
            url: '/find-a-dealer',
            icon: '',
        },
        ],
    }
        /*DOE-4256 End (Code commented for Release 1 - Details:For hiding find a dealer menu )*/
    ] :
        [{
            id: '1',
            label: 'My Products',
            //header: 'Find Resources for Your Honda Products',
            class: 'slds-truncate',
            url: undefined,
            large: true,
            items: [],
        },
        {
            id: '2',
            label: 'Help Center',
            header: 'Connect With Support and Search FAQs',
            class: 'slds-truncate',
            url: undefined,
            large: true,
            items: [{
                id: '1',
                label: 'Acura Autos',
                name: 'HelpCenterAcura',
                url: '/help-acura',
                icon: '',
            },
            {
                id: '2',
                label: 'Honda Autos',
                name: 'HelpCenterHonda',
                url: '/help-honda',
                icon: '',
            },
            {
                id: '3',
                label: 'Honda Powersports',
                name: 'HelpCenterPowersports',
                url: '/help-powersports',
                icon: '',
            },
            {
                id: '4',
                label: 'Honda Power Equipment',
                name: 'HelpCenterPowerequipment',
                url: '/help-powerequipment',
                icon: '',
            },
            {
                id: '5',
                label: 'Honda Marine',
                name: 'HelpCenterMarine',
                url: '/help-marine',
                icon: '',
            },
            {
                id: '6',
                label: 'Search all FAQs',
                name: 'search',
                url: '/help-center',
                icon: this.ownerResource() + '/Icons/search.svg',
            },
            ],
        },
        //DOE-4256 Start (Code commented for Release 1 - Details: for hiding Find a dealer menu)
        {
            id: '3',
            label: 'Find a Dealer',
            header: 'Find a Servicing Dealer Near You',
            class: 'slds-truncate',
            url: undefined,
            large: true,
            items: [{
                id: '1',
                label: 'Acura Autos',
                name: 'Acura',
                url: '/find-a-dealer',
                icon: '',
            },
            {
                id: '2',
                label: 'Honda Autos',
                name: 'Honda',
                url: '/find-a-dealer',
                icon: '',
            },
            {
                id: '3',
                label: 'Honda Powersports',
                name: 'Powersports',
                url: '/find-a-dealer',
                icon: '',
            },
            {
                id: '4',
                label: 'Honda Power Equipment',
                name: 'Power Equipment',
                url: '/find-a-dealer',
                icon: '',
            },
            {
                id: '5',
                label: 'Honda Marine',
                name: 'Marine',
                url: '/find-a-dealer',
                icon: '',
            },
            ],
        }
            //DOE-4256 End (Code commented for Release 1 - Details: for hiding Find a dealer menu)
        ];

    @track garage;

    get logoutLink() {
        const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
        return sitePrefix + "/secur/logout.jsp";
    }

    initialize = async () => {
        this.garage = await getGarage('');
        // console.log('this.garage .. ', JSON.stringify(this.garage) );
        this.context = await getContext('');
        this.handleGarageProducts();
    };

    //Imtiyaz - RECALLS Start
    connectedCallback() {
        this.callIn_connectedCallback(true);
        this.subscribeToChannel((message) => {
            this.callIn_connectedCallback(false);
        });
    }
    
    callIn_connectedCallback(flag){
        
        //console.log('$RECALLS: ownLevel1Menu callIn_connectedCallback');
        if(flag)
        this.getCIAMdetails();

        //Imtiyaz - RECALLS Start
        if(this.isPspOrPE){
            this.menus.push({
                id: '4',
                label: 'Recall Notification',
                header: '',
                class: 'slds-truncate recall-notification',
                url: '',
                large: false,
                items: null
            });
        }
        //Imtiyaz - RECALLS End
    
        //Imtiyaz - RECALLS Start
        if (ISGUEST) {
            this.menus.push({
                id: '5',
                label: 'Sign Up',
                header: '',
                class: 'slds-truncate menu-label-color',
                url: '/sign-up',
                large: false,
                items: null
            }, {
                id: '6',
                label: 'Log In',
                header: '',
                class: 'slds-truncate menu-label-color',
                url: '/login',
                large: false,
                items: null
            })
        } else {
            this.menus.push({
                id: '7',
                label: 'My Account', //Changed label FOR DOE-3444 Ravindra Ravindra (wipro)
                header: '',
                class: 'slds-truncate',
                url: '/my-account',
                large: false,
                items: null
            }, {
                id: '8',
                label: 'Logout',
                header: '',
                class: 'slds-truncate menu-label-color',
                url: this.logoutLink,
                large: false,
                items: null
            })
        }
        //Imtiyaz - RECALLS End
    }
    //Imtiyaz - RECALLS End
    getCIAMdetails = async () => {
        getCIAMConfig().then(result => {
            this.loginUrl = result.Ciam_Login_Url__c;
            this.signUpUrl = result.Ciam_SignUp_Url__c;
            this.initialize();
            this.subscribeToChannel((message) => {
                this.handleMessage(message);
            });
        });
    }

    handleMessage(message) {
        if (message.type === 'product') {
            this.menus.forEach(menu => {
                if (menu.id === '1') {
                    menu.items.forEach(item => {
                        if (item.id === message.result.product.productId) {
                            item.label = message.result.product.nickname;
                            item.name = message.result.product.nickname;
                        }
                    });
                }
            });
        }
    }

    handleGarageProducts() {
        this.menus.forEach(menu => {
            if (menu.id === '1') {
                if (this.garage && this.garage.products) {
                    for (let i = 0; i < 3; i++) {
                        if (this.garage.products[i]) {
                            menu.items.push({
                                id: this.garage.products[i].productId,
                                label: this.garage.products[i].nickname ? this.garage.products[i].nickname : (this.garage.products[i].year ? this.garage.products[i].year + ' ' + this.garage.products[i].model : this.garage.products[i].model),
                                name: this.garage.products[i].nickname,
                                url: getGarageURL(this.garage.products[i].division),
                                icon: '',
                            });
                        }
                    }

                    if (this.garage.products.length > 3 && !ISGUEST) {
                        menu.items.push({
                            id: this.garage.products[0].productId,
                            label: 'View All',
                            name: this.garage.products[0].nickname ? this.garage.products[0].nickname : this.garage.products[0].year + ' ' + this.garage.products[0].model,
                            url: getGarageURL(this.garage.products[0].division),
                            icon: '',
                        });
                    }
                }
                if (!ISGUEST) {
                    menu.items.push({
                        id: null,
                        label: 'Find a Product',
                        name: 'find',
                        url: '/',
                        icon: this.ownerResource() + '/Icons/zoomin.svg',
                    });
                }
                if (ISGUEST) {
                    menu.items.push({
                        id: null,
                        label: 'Find a Product',
                        name: 'getstarted',
                        url: '/',
                        //icon: this.ownerResource() + '/Icons/zoomin.svg',
                    });
                    menu.items.push({
                        id: null,
                        label: 'Log in to see your Products',
                        name: 'login',
                        url: this.loginUrl,
                        //url : this.domainName + '/mygarage/idp/login?app=' + this.appId, 
                        icon: this.ownerResource() + '/Icons/user.svg',
                    });
                }
            }
        });
    }

    async handleSaveContext(id, url) {
        if (!ISGUEST) {
            //console.log('settingOrigin');
            setOrigin('');
        }
        if ((id === undefined || id === null) && url) {
            this.navigate(url, {});
        } else {
            sessionStorage.setItem('firstItemIndex', 0);
            sessionStorage.setItem('getContextProductId', id);
            //this.navigate(url, {});
            /* if (!ISGUEST) { */
            const contextInput = {
                'productId': id,
                'productTab': 'Overview'
            };
            await setProductContextUser(contextInput);
            await this.sleep(2000);
            /* } */
            //window.open('/mygarage/s' + url, "_Self");
            let mygarageURLLabel = mygarageurl === '/' ? '' : mygarageurl;
            window.open(mygarageURLLabel + '/s' + url, "_Self");
        }
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    setContextForPDP = async () => {
        this.context = await getContext('');
        this.handleGarageProducts();
    };

    //Imtiyaz - RECALLS Start
    get isPSP(){
        let isPsp = false;
        if(window.location.pathname.includes('recall-search')){
            let param = new URL(window.location.href).searchParams.get('brand');
            isPsp = param && param == 'powersports';
        }else{
            isPsp = window.location.pathname.includes('find-powersports') || window.location.pathname.includes('garage-powersports') || window.location.pathname.includes('help-powersports') || window.location.pathname.includes('power-sports') || window.location.pathname.includes('-powersports');
        }
        return isPsp;
    }
    get isPE(){
        let isPe = false;
        if(window.location.pathname.includes('recall-search')){
            let param = new URL(window.location.href).searchParams.get('brand');
            isPe = param && param == 'powerequipment';
        }else{
            isPe = window.location.pathname.includes('find-powerequipment') || window.location.pathname.includes('garage-powerequipment') || window.location.pathname.includes('help-powerequipment') || window.location.pathname.includes('-powerequipment') || window.location.pathname.includes('power-equipment') || window.location.pathname.includes('powerequipment-');
        }
        return isPe;
    }
    get isPspOrPE(){
        return this.isPSP || this.isPE;
    }
    //Imtiyaz - RECALLS End

    navigateToRecallSearch(){
        if(this.isPSP){
            this.navigate('/recall-search?brand=powersports', {});
        }else if(this.isPE){
            this.navigate('/recall-search?brand=powerequipment', {});
        }
    }

    handleMainMenuSelect(event) {
        //Imtiyaz - RECALLS Start
        let label = event.target.dataset.label;
        //console.log('$label: ',label);
        if(label == 'Recall Notification'){
            //console.log('$RECALLS: return');
            this.navigateToRecallSearch();
            this.closeMenu();
            return;
        }
        //Imtiyaz - RECALLS End
        let id = event.currentTarget.dataset.id;
        this.menuId = id;
        this.menus.forEach(element => {
            if (element.id === id) {
                if (element.url !== undefined) {
                    this.closeMenu();
                    if (element.id === '7') {
                      //  window.location = element.url;
                      this.navigate(element.url, {});
                    } else if (element.url === '/login' || element.url === '/sign-up') {

                        if (element.url === '/login') {
                            let url = this.loginUrl;
                            window.open(url, '_self');
                        }
                        else {
                            let url = this.signUpUrl;
                            window.open(url, '_self');
                        }
                    } else {
                        this.navigate(element.url, {});
                    }
                } else {
                    let menu = {
                        showMainMenu: false,
                        showSubMenu: true,
                        header: element.header
                    }
                    this.menu = menu;
                    this.subMenus = element.items;
                    event.preventDefault();
                    const selectEvent = new CustomEvent('select', {
                        detail: {
                            showSubMenu: true,
                            label: element.label
                        }
                    });
                    this.dispatchEvent(selectEvent);
                }
            }
        });
    }

    handleSubMenuClick(event) {
        //console.log('ownLevel1Menu:: handleSubMenuClick');
        sessionStorage.setItem('referrer', document.location.href);
        let menuId = event.currentTarget.dataset.menuid;
        let url = event.currentTarget.dataset.url;
        let id = event.currentTarget.dataset.id;
        let name = event.currentTarget.dataset.name;
        if (menuId === '1' && id && url) {
            this.handleSaveContext(id, url);
        } else if (name === 'login') {
            // DOE-4345 Ravindra Ravindra
            var currentLocation = window.location;
            sessionStorage.setItem("RelayState", currentLocation.href);
            window.open(`${url}&RelayState=${window.location.href}`, "_self");
        } else if (menuId === '3') {
            let divisionId;
            switch (name) {
                case 'Honda':
                    divisionId = 'A';
                    break;
                case 'Acura':
                    divisionId = 'B';
                    break;
                case 'Powersports':
                    divisionId = 'M';
                    break;
                case 'Power Equipment': case 'Marine':
                    divisionId = 'P';
                    break;
            }
            sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: name, divisionId: divisionId }));
            this.closeMenu();
            this.navigate(url, {});
        } else {
            this.closeMenu();
            this.navigate(url, {});
        }
    }

    closeMenu() {
        const selectEvent = new CustomEvent('select', {
            detail: {
                closeMenu: true
            }
        });
        this.dispatchEvent(selectEvent);
    }
    renderedCallback(){
        //console.log('$RECALLS: ownLevel1Menu renderedCallback');
        //console.log('$RECALLS: menus: ',JSON.parse(JSON.stringify(this.menus)));
    }
}