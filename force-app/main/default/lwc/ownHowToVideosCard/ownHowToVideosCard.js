import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';

export default class OwnHowToVideosCard extends OwnBaseElement {
    @track localIcon = 'utility:question_mark';
    @api contentId;
    @api brand;
    @api icon;
    @api title;
    @api titlecolor;
    @api headerlink;
    @api actionbuttonlabel;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track cmsResults;
    @track body;
    @track videos =[];
    @api video1;
    @api video2;
    @api video3;
    @api video4;
    @api video5;
    @api video6;

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.brand = this.brand.toLowerCase();
        this.initialize();
        this.getVideos();
    }

    initialize = async () => {
        this.contentKeys.push(this.contentId);
        this.cmsResults = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.cmsResults.forEach(r => {
            this.title = !this.title ? this.htmlDecode(r.title.value) : this.title;
            this.body = r.body ? this.htmlDecode(r.body.value).trim() : '';
        });
        //console.log('DummyData :: ', JSON.stringify(this.brand));
    };

    getVideos = async () => {
        this.contentKeys = [this.video1, this.video2, this.video3, this.video4, this.video5];
        if(this.video6){
            this.contentKeys.push(this.video6);
        }
        let cmsResults = await getManagedContentByTopicsAndContentKeys(this.contentKeys, null, this.pageSize, this.managedContentType);
        //console.log('cmsResults :: ', cmsResults);
        cmsResults.forEach(r => {
            let order = 0;
            if(r.phoneLabel && r.phoneLabel.value.toLowerCase() =='order'){
                order = r.phoneNumber ? r.phoneNumber.value : 0;
            }
            this.videos.push({
                id : r.key,
                title : r.title ? this.htmlDecode(r.title.value) : '',
                order : order
            });
        });
        this.videos.sort((a,b) =>{
            const A = a.order;
            const B = b.order;
            if (A < B) {
                return -1;
            }
            if (A > B) {
                return 1;
            }
            return 0;
        })
    };

    handleVideoClick(event) {
        
        let url =  event.currentTarget.dataset.key;
        let videoId = url.substring(url.lastIndexOf('/') + 1);
        url ='/guide-video-detail?key='+videoId;
        let label;
        let link;
        let image;
        if(document.location.pathname.includes('help-acura')){
            label = 'Acura Autos Help Center';
            link = '/help-acura';
            image = 'thumbnail_acura.png';
        }else if(document.location.pathname.includes('help-honda')){
            label = 'Honda Autos Help Center';
            link = '/help-honda';
            image = 'thumbnail_honda.png';
        }
        else if(document.location.pathname.includes('help-powersports')){
            label = 'Powersports Help Center';
            link = '/help-powersports';
            image = 'thumbnail_powersports.png';
        }else if(document.location.pathname.includes('help-powerequipment')){
            label = 'Power Equipment Help Center';
            link = '/help-powerequipment';
            image = 'thumbnail_powerequipment.png';
        }
        else if(document.location.pathname.includes('help-marine')){
            label = 'Marine Help Center';
            link = '/help-marine';
            image = 'thumbnail_marine.png';
        }
        let fromPage = [];
        if(document.location.pathname.includes('help')){
            fromPage = [{ label: label, url: link, image:image, from :'help-center' }];
        }else if(document.location.pathname.includes('resources-downloads')){
            fromPage = [{ label: 'Resources & Downloads', url: '/'+document.location.pathname.substring(document.location.pathname.lastIndexOf('/') + 1), }];
        }
        sessionStorage.setItem('fromhowtoguides',JSON.stringify(fromPage));
        this.navigate(url, {});
    }

    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    handleBrowseClick() {
        this.navigate('https://www.youtube.com/c/Honda', {});
    }

    handleClickHeader() {
        this.navigate(this.headerlink, {});
    }

}