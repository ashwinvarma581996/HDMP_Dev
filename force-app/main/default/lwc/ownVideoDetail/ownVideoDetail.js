import { LightningElement, track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys, ISGUEST, getOrigin, getProductContext } from 'c/ownDataUtils';


export default class OwnVideoDetail extends OwnBaseElement {
    @track contentId;
    @track contentId1;
    @track contentId2;
    @track contentId3;
    @track contentId4;
    @track fromCollision = false;
    @track fromHondaAcuraLink = false;
    videoLink;
    @track subtitle;
    @track icon1 = "play.svg";
    videos;
    @track context;
    @track content;
    @api acuraMainMinderContentId;
    @api hondaMainMinderContentId;
    @api acuraVideo1;
    @api acuraVideo2;
    @api hondaVideo1;
    @api hondaVideo2;

    @track maintenanceContentId;
    @track videoContentId;

    connectedCallback(){
        this.initialize();
    }
    
    initialize = async () => {
        if (getOrigin() == 'ProductChooser') {
            this.context = await getProductContext('', true);
            //console.log('this.context-->',this.context);
        } else {
            this.context = await getProductContext('', false);
            //console.log('this.context-->',this.context);
        }
        if (this.context && this.context.product) {
            this.brand = this.context.product.division;
        }
        let fromPage = sessionStorage.getItem('frompage');
        //console.log('from page ???',sessionStorage.getItem('frompage'));
        let contentId = this.getUrlParamValue(window.location.href, 'key');
        if(fromPage =='collisionRepair' && sessionStorage.getItem('collisionVideos')){
            this.fromCollision = true;
            let videoContent = JSON.parse(sessionStorage.getItem('collisionVideos'));
            //console.log('videoContentIds?',videoContent);
            this.videos = JSON.parse(JSON.stringify(videoContent.videos));
            this.videos = this.videos.filter((item) =>{
                return  item && item !== contentId;
            })
            this.brand = videoContent.brand;
            this.subtitle = 'More ' + this.brand + ' Collision Videos';
            //console.log('this.videos!', this.videos);
        }
        else if(fromPage =='Service & Maintenance'){
            this.fromServiceMaintenance = true;
            this.subtitle = 'More '+this.brand+' Service Resources';
           if(this.brand =='Honda'){
                this.maintenanceContentId = this.hondaMainMinderContentId;
                if(contentId == this.hondaVideo1){
                    this.videoContentId = this.hondaVideo2;
                }else{
                    this.videoContentId = this.hondaVideo1;
                }
            }
        }       
        
        let contentKeys = [];
        contentKeys.push(contentId);
        //console.log('contentKeys?',contentKeys);
        let results = await getManagedContentByTopicsAndContentKeys(contentKeys, null, '1', null);
        //console.log('res!', results);
        results.forEach(   r => {
            this.content = r.body ? this.htmlDecode(r.body.value) : '';
            if(r.videoLink){
                this.videoLink = r.videoLink ? r.videoLink.value.replaceAll('&amp;','&'): '';
            }else if(r.phone2Label && r.phone2Number){
                this.videoLink = r.phone2Number ? this.htmlDecode(r.phone2Number.value) : '';
            }
               
        });

    }

    
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }
   
    handleVideo(event) {
        //console.log('handleVideo->', event.currentTarget.contentId);
        let contentId = event.currentTarget.contentId;
        this.navigate("/video-detail-page" + '?key='+contentId, {});
    }
}