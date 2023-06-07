import { api, LightningElement, track, wire } from 'lwc';
import { getCMSContent } from 'c/ownCMSContent';
import { ISGUEST, getProductContext, getOrigin, getContext, getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import AcuraRoadsideAssistance from '@salesforce/resourceUrl/AcuraRoadsideAssistance';
import getManageSubscriptions from '@salesforce/apex/OwnAPIController.getManageSubscriptions';
import productIdentifierLookUp from '@salesforce/apex/OwnAPIController.productIdentifierLookUp';

export default class ownRoadsideAssistance extends LightningElement {
    @api contentTopicHonda;
    @api accordianTopicHonda;
    @api contentTopicAcura;
    @api accordianTopicAcura;
    @track accordianSections;
    @track roadsideAssistance = {};
    @track contents;
    @track context;
    @track imageUrl;
    @track isproductbadge = true;
    @track brand;
    @track contx;


    //Need to set Telematics from TelematicsFlag which needs to be added to the context or pulled else where
    @track hasTelematics;
    @track hasClarity;
    @track hasStandard;
    @track showStandard = true;
    @track canShowTelematics = false;

    breadcrumb;
    isGuest = ISGUEST;
    baseURL = window.location.href.substring(0, window.location.href.indexOf("/s"));
    @track productSubTitle = '';
    async connectedCallback() {
        let frmPC = getOrigin() === 'ProductChooser' ? true : false;
        if (frmPC) {
            this.contx = await getProductContext('', true);
        } else {
            this.contx = await getContext('');
        }
        //console.log("$RSA: Context-", JSON.parse(JSON.stringify(this.contx)));
        if (this.contx && this.contx.product) {
            if (this.contx.product.model && this.contx.product.model.toLowerCase().includes('clarity')) {
                this.hasClarity = true;
            }
            let vinNumber;
            if (this.contx.product.productIdentifier || (this.contx.product.vin && this.contx.product.vin != '-')) {
                vinNumber = this.contx.product.productIdentifier ? this.contx.product.productIdentifier : this.contx.product.vin;
                productIdentifierLookUp({ productIdentifier: vinNumber, divisionId: this.contx.product.divisionId }).then((result) => {
                    //console.log('$RSA: result-', result);
                    //console.log('$RSA: isGuest-', this.isGuest);
                    let telematicsUnit = result.vehicle && result.vehicle.telematicsUnit ? result.vehicle.telematicsUnit : '';
                    let enrollment = result.vehicle && result.vehicle.enrollment ? result.vehicle.enrollment : '';
                    //console.log('$RSA: telematicsUnit-', telematicsUnit);
                    //console.log('$RSA: enrollment-', enrollment);
                    // telematicsUnit = 'y';
                    // enrollment = 'y';
                    if (this.isGuest) {
                        if (telematicsUnit.toLowerCase() == 'y'/* && !this.hasClarity*/) {
                            this.hasTelematics = true;
                        }
                    }
                    if (!this.isGuest) {
                        if (telematicsUnit.toLowerCase() == 'y' && enrollment.toLowerCase() == 'y') {
                            this.hasTelematics = true;
                        }
                    }
                    if (!this.hasClarity) {
                        this.hasStandard = true;
                    }
                }).catch((err) => {
                    if (!this.hasClarity) {
                        this.hasStandard = true;
                    }
                    //console.log('$RSA: err-', err);
                });
            } else {
                if (!this.hasClarity) {
                    this.hasStandard = true;
                }
            }
        }

        this.breadcrumb = JSON.parse(localStorage.getItem('breadcrumb'));
        let fromProductChooser = getOrigin() === 'ProductChooser' && !this.isGuest ? true : false;
        //console.log('product Chooser Roadside Assistance-------', fromProductChooser);
        this.context = await getContext('');
        ////console.log('Context1---',JSON.parse(JSON.stringify(this.context)));
        //console.log('Context ', JSON.stringify(this.context));


        //DOE-2701
        if (this.context.product) {
            try {
                if (this.context.product.telematicsFlag == 'Y') {
                    if (this.context.product.enrollment == 'Y') {
                        this.canShowTelematics = true;
                        //console.log('canShowTelematics', this.canShowTelematics);
                    }
                }
            }
            catch {
                //console.log('no telematics');
            }
        }

        if (this.context.product) {
            if (!this.context.product.nickname || this.context.product.nickname == '') {
                this.context.product.nickname = this.context.product.year + " " + this.context.product.model + " " + this.context.product.trim;
            }
        }

        //DOE-2701
        if (this.context.product) {
            let manageSubs = await getManageSubscriptions({ productIdentifier: this.context.product.vin, divisionId: this.context.product.divisionId })
            //console.log('ManageSubscriptions', JSON.stringify(manageSubs));
            try {
                this.role = manageSubs.manageSubscriptions.devices[0].programs[0].role;
                //console.log('Role ', JSON.stringify(this.role));
            }
            catch {
                this.role = null;
            }
        }
        else {
            this.role = null;
        }
        //console.log('Context2---', JSON.parse(JSON.stringify(this.context)));
        //this.productSubTitle = this.context.product.year + " " + this.context.product.model + " " + this.context.product.trim; 
        //console.log('Breadcrumb', this.breadcrumb);
        if (this.breadcrumb) {
            if (this.breadcrumb.value == 'Help Honda') {
                this.getContentByBrand('Honda');
                this.imageUrl = this.baseURL + '/resource/MyGarage/img/thumbnail_honda.png';
                this.context.product = { Level2: '1', nickname: '' };
                this.context.product = { nickname: '' };
                this.brand = 'Honda';
            } else if (this.breadcrumb.value == 'Help Acura') {
                this.getContentByBrand('Acura');
                this.imageUrl = this.baseURL + '/resource/MyGarage/img/thumbnail_acura.png';
                this.context.product = { Level2: '1', nickname: '' };
                this.context.product = { nickname: '' };
                this.brand = 'Acura';
            } else if (this.breadcrumb.value == 'Service & Parts') {
                if (fromProductChooser) {
                    let product = JSON.parse(localStorage.getItem('garage')).products[0];
                    if (!product.nickname || product.nickname == '') {
                        product.nickname = product.year + " " + product.model + " " + product.trim;
                    }
                    //console.log('Product at 0', product);
                    this.getContentByBrand(product.division);
                    this.brand = product.division;
                    this.context.product = { Level2: '1', nickname: product.nickname };
                    if (product.image.startsWith('/cms')) this.imageUrl = this.baseURL + product.image;
                    this.imageUrl = this.baseURL + product.image; //DOE-2701 Ravindra Ravindra (Wipro)

                    //DOE-2701 Brett Spokes (Wipro)
                    //console.log('Garage Context ' + JSON.stringify(this.context));
                    if (product.telematicsFlag && product.telematicsFlag == 'Y' && this.isGuest == false) {
                        if (product.enrollment == 'Y') {
                            if (this.role != null && this.role == 'PRIMARY') {
                                this.showStandard = false;
                                this.hasStandard = false;
                                //console.log('canShowTelematics', this.canShowTelematics);
                            }
                        }
                    }

                } else {
                    //console.log('----------', JSON.parse(localStorage.getItem('garage')));
                    this.getContentByBrand(this.context.product.division);
                    this.brand = this.context.product.division;
                    this.getProductImage();
                    //DOE- 2701 Ravindra Ravindra(wipro)                 
                    if (this.canShowTelematics && this.isGuest == false) {
                        if (this.role != null && this.role == 'PRIMARY') {
                            this.showStandard = false;
                            this.hasStandard = false;
                            //console.log('this has telematics enrollment and primary role');
                        }
                    }
                }
            }
        }
        ////console.log('Telematix flag at the end ', this.hasTelematics);
        // this.getImageUrl(await getProduct(this.context.Level2, ''));
    }
    async getContentByBrand(brand) {
        if (brand == 'Honda') {
            this.getContents(await getCMSContent([this.contentTopicHonda]));
            this.getAccordians(await getCMSContent([this.accordianTopicHonda]));
        } else {
            this.getContents(await getCMSContent([this.contentTopicAcura]));
            this.getAccordians(await getCMSContent([this.accordianTopicAcura]));
        }
    }

    getProductImage() {
        //console.log('getProductImage is being called');
        if (this.context.product && (this.context.product.division == 'Honda' || this.context.product.division == 'Acura')) {
            //console.log('THIS IS IMAGE 1', this.imageUrl);
            this.imageUrl = this.context.product.customerUploadedImage ?? this.context.product.productDefaultImage ?? this.context.product.image;
            //console.log('THIS IS IMAGE 2', this.imageUrl);
            this.imageUrl = this.imageUrl.startsWith('/mygarage') || this.imageUrl.startsWith('https') ? this.imageUrl : '/mygarage' + this.imageUrl;
            //console.log('THIS IS IMAGE 3', this.imageUrl);
        } else {
            this.imageUrl = '/mygarage/resource/Owners/images/garage_hondadefault.svg';
            this.context.product = { Level2: '1', nickname: '' };
        }

        //console.log('THIS IS IMAGE', this.imageUrl);
    }
    /*getProductImage() {
        if (this.context.product && (this.context.product.division == 'Honda' || this.context.product.division == 'Acura')) {
            this.imageUrl = this.context.product.customerUploadedImage ?? this.context.product.productDefaultImage ?? this.context.product.image;
            this.imageUrl = this.imageUrl.startsWith('/mygarage') || this.imageUrl.startsWith('https') ? this.imageUrl : '/mygarage' + this.imageUrl;
        } else {
            this.imageUrl = '/mygarage/resource/Owners/images/garage_hondadefault.svg';
            this.context.product = { Level2: '1', nickname: '' };
        }
    }*/
    getImageUrl(prod) { this.imageUrl = prod ? prod.image : ''; }
    getContents(content) {
        //console.log('$RSA: content-', content);
        //console.log('CONTEXT-----------', this.context);
        this.contents = JSON.parse(JSON.stringify(content[0].contentNodes));
        this.contents.subtitle = this.contents.sub_title ? this.contents.sub_title.value : '';
        this.contents.body = this.htmlDecode(this.contents.body ? this.contents.body.value : '');
        this.contents.phone2_heading = this.contents.phone2_label ? this.contents.phone2_label.value : '';
        this.contents.phoneLabel = this.contents.description2_label ? this.contents.description2_label.value : '';
        this.contents.accordianHeading = this.contents.description_label ? this.contents.description_label.value : '';
        //console.log('$RSA: this.breadcrumb.value-', this.breadcrumb.value);
        let backlinkurl = sessionStorage.getItem('backlink');
        if (backlinkurl) {
            backlinkurl = JSON.parse(backlinkurl);
            if (backlinkurl.label && backlinkurl.label.includes("Help Center")) {
                this.hasStandard = true;
            }
            if (backlinkurl.label && backlinkurl.label.includes("Help Center: Honda")) {
                this.hasClarity = true;
            }
        }
        //console.log('$RSA: backlinkurl-', backlinkurl);
        if (this.breadcrumb.value == 'Help Honda') {
            // this.contents.hasClarity = true;
            // this.hasClarity = true;
            this.contents.hasAuto = true;
            if (this.contents.phone_number) {
                this.contents.phone_number_href = { value: 'tel:' + this.contents.phone_number.value };
            }
            if (this.contents.phone2_number) {
                this.contents.phone2_number_href = { value: 'tel:' + this.contents.phone2_number.value };
            }
        } else {
            if (this.context.product.nickname.toLowerCase().includes('clarity')) {
                // this.contents.hasClarity = true;
                // this.hasClarity = true;
                this.contents.hasAuto = false;
                if (this.contents.phone2_number) {
                    this.contents.phone2_number_href = { value: 'tel:' + this.contents.phone2_number.value };
                }
            } else {
                this.contents.hasAuto = true;
                // this.contents.hasClarity = false;
                // this.hasClarity = false;
                if (this.contents.phone_number) {
                    this.contents.phone_number_href = { value: 'tel:' + this.contents.phone_number.value };
                }
            }
        }
        this.contents.phoneSupportedText = this.contents.phone_label ? this.contents.phone_label.value : '';
        this.contents.phoneDescription = this.htmlDecode(this.contents.description2_content ? this.contents.description2_content.value : '');
        this.contents.downloadButtonLabel = this.contents.section_label.value ?? '';
        this.contents.downloadLink = this.contents.video && this.contents.video.value ? this.contents.video.value : '';
        this.contents.termsAndConditions = this.htmlDecode(this.contents.section_content ? this.contents.section_content.value : '');

        this.contents.telematicsNumber = this.htmlDecode(this.contents.description_content ? this.contents.description_content.value : '');
        //console.log(this.contents.telematicsNumber);

        var telematicsHolder = this.contents.telematicsNumber;
        telematicsHolder = telematicsHolder.replace('<p>', '');
        telematicsHolder = telematicsHolder.replace('Call ', '');
        telematicsHolder = telematicsHolder.replace('</p>', '');
        //console.log(telematicsHolder);

        this.contents.telematicsNumber = telematicsHolder;
        this.contents.phone_telematics_number_href = { value: 'tel:' + this.contents.telematicsNumber };
        //console.log('Phone Number Telematics: ' + this.contents.phone_telematics_number_href.value);
        //console.log('$RSA: contents-', JSON.parse(JSON.stringify(this.contents)));
        // console.log('$RSA: hasClarity-',hasClarity);
        // console.log('$RSA: this.contents.hasClarity-',this.contents.hasClarity);
    }
    getAccordians(accordian) {
        //console.log('accordians', accordian);
        this.accordianSections = [];
        accordian.forEach(currentItem => {
            let body_obj = JSON.parse(JSON.stringify(currentItem.contentNodes.body));
            body_obj.value = this.htmlDecode(body_obj.value);
            this.accordianSections.push(
                {
                    body: body_obj,
                    title: currentItem.contentNodes.title,
                    key: currentItem.contentKey,
                    order: currentItem.contentNodes.order ? currentItem.contentNodes.order.value : '0'
                }
            );
        });
        //console.log('this.accordianSections ', JSON.parse(JSON.stringify(this.accordianSections)));
        this.accordianSections = this.accordianSections.sort(function (a, b) { return parseInt(a.order) - parseInt(b.order) });
        //console.log('this.accordianSections: Sorted ', JSON.parse(JSON.stringify(this.accordianSections)));
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
    handlePdfDownload() {
        let link = this.contents.video.value;
        //console.log('@@this.link'+link);
        //console.log('@@this.brand'+this.brand);

        if (link.includes(".pdf") && this.brand == 'Acura' && link.includes("AcuraRoadsideAssistance")) {
            let url = window.location.origin + AcuraRoadsideAssistance;
            window.open(url, "_blank");
        } else {
            window.open(this.contents.video.value, "_blank");
        }
    }
}