import { LightningElement, track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys} from 'c/ownDataUtils';

export default class OwnHowToGuideVideoDetail extends OwnBaseElement {

    videoLink;
    @track subtitle;
    @track icon1 = "play.svg";
    videos;
    @track content;

    connectedCallback(){
        this.initialize();
        
    }
    
    initialize = async () => {
        let videoId = this.getUrlParamValue(window.location.href, 'key');
        //console.log('howtocategory ???',sessionStorage.getItem('howtocategory'));
        if(!videoId && sessionStorage.getItem('howtocategory')){
            let categoryData = JSON.parse(sessionStorage.getItem('howtocategory'));
            //console.log('categoryContent-->'+categoryData);
            this.videoLink = 'https://www.youtube.com/embed/'+ categoryData.data;
            this.content = categoryData.content;
            this.subtitle = 'More '+categoryData.title;
        }else if(videoId){
            let contentKeys = [];
            contentKeys.push(videoId);
            //console.log('contentKeys?',contentKeys);
            let results = await getManagedContentByTopicsAndContentKeys(contentKeys, null, '1', null);
            //console.log('res!', results);
            results.forEach(   r => {
                this.content = r.body ? this.htmlDecode(r.body.value) : '';
                if(r.videoLink){
                    this.videoLink = r.videoLink ? r.videoLink.value.replaceAll('&amp;','&'): '';
                }                
            });
            //console.log('this.videoLink?',this.videoLink);
        }

    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }
}