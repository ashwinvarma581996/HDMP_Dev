import { LightningElement,api,track } from 'lwc';

export default class OwnCollisionVideoDetail extends LightningElement {
      @api icon1 = "play.svg";
    // @api titlecolor='Honda Red';
    // @api icon = "play.svg"; 
    @track videoIds;
    @track showVideos = false;
    @api contentid1 = "MCMYIKMG4KE5FQ3KNB2YGK3Q5KAE";
    @api contentid2 = "MCRVNXI5EETVHIBNCIM2EKWAWTXU";
    @api contentid3 = "MCQC2XGVAS7RANTAS2GG5OBU6QAA";
    @api contentid4 = "MCJVCEDXAZYVAZVIQTZHQISSV73M";

    initialize = async () => {
      //console.log('Fetching Ids' )
      //this.videoIds = JSON.parse(localStorage.getItem("Ids"));
      //console.log('Ids found', localStorage.getItem("Ids"));
      this.showVideos = true;
      
      let cntId = this.getUrlParamValue(window.location.href, 'key');
      //console.log('Content chosen, ', cntId);
      let videoList;
      if(cntId == this.contentid1){
        videoList = { Id2: this.contentid2, Id3: this.contentid3, Id4: this.contentid4 };
      } else
      if(cntId == this.contentid2){
        videoList = { Id2: this.contentid1, Id3: this.contentid3, Id4: this.contentid4 };
      } else
      if(cntId == this.contentid3){
        videoList = { Id2: this.contentid1, Id3: this.contentid2, Id4: this.contentid4 };
      } else
      if(cntId == this.contentid4){
        videoList = { Id2: this.contentid1, Id3: this.contentid2, Id4: this.contentid3 };
      }
      this.videoIds = videoList;
  };

  connectedCallback(){
    this.initialize();
    


  }

  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }
    
}