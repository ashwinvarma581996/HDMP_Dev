import {
    LightningElement,
    api,
    track
} from 'lwc';
import commonResources from "@salesforce/resourceUrl/Owners";
import {
    OwnBaseElement
} from 'c/ownBaseElement';


export default class OwnProductSettingsImage extends OwnBaseElement {
    @api image;

    @api productOwnerId;
    camera_icon = commonResources + '/Icons/garage_camera.svg';
    @track customImage;
    @track customImageURL;
    customImageName;
    @track warningicon;
    @api showImageError;
    @track uploadImageError = 'Image should be JPG, GIF or PNG File. Maximum file size is 3 MB';
    @api division;
/*     @api get customImageURLProp() {
        return this.customImageURL;
    }
    set customImageURLProp(value) {
        console.log('SETTING PROPERTY');
        this.customImageURL = value;
        this.launchImageUploadEvent(value);
    } */

    connectedCallback(){
        this.customImage = {};
        this.warningicon = this.myGarageResource() + '/ahmicons/warning.png';
    }

    handleUserImageUpload(event) {
        this.showImageError = false;
        const customImageUpload = event.target.files[0];

        this.customImage.name = customImageUpload.name;
        this.customImage.type = customImageUpload.type;
        this.customImage.size = customImageUpload.size;

        console.log('TYPE: ' + this.customImage.type);

        let imgReaderURL = new FileReader()

        imgReaderURL.onload = (event => {
            if(this.customImage.type.includes('image')){
                this.customImage.dataURL = event.target.result;
                this.launchUploadEvt(this.customImageURL);
            }else{
                this.showImageError = true;
                this.dispatchEvent(new CustomEvent('disablesavebutton', {  }));    
            }
        });
        imgReaderURL.onerror = (event => {
            this.showImageError = true;
            this.dispatchEvent(new CustomEvent('disablesavebutton', {  }));
            console.log('URL reader error: ' + JSON.stringify(event.target.error));
        });

        imgReaderURL.readAsDataURL(customImageUpload);

/*        let imgReader = new FileReader();

        imgReader.onload = (event => {
            //this.customImage = new Blob([event.target.result]);
            this.customImage.blob = new Blob([event.target.result]);
            //console.log('OBJECTURL BLOB ');
            //console.log(URL.createObjectURL(this.customImage));
            if (this.customImage.dataURL) {
                this.launchUploadEvt(this.customImage, this.customImageURL);
            }
        });
        imgReader.onerror = (event => {
            console.log('URL reader error: ' + JSON.stringify(event.target.error));
        });

        imgReader.readAsArrayBuffer(customImageUpload);
        //imgReader.readAsBinaryString(customImageUpload);

        let imgReaderURL = new FileReader()

        imgReaderURL.onload = (event => {
            this.customImage.dataURL = event.target.result;
            if (this.customImage.blob) {
                this.launchUploadEvt(this.customImage, this.customImageURL);
            }
        });
        imgReaderURL.onerror = (event => {
            console.log('URL reader error: ' + JSON.stringify(event.target.error));
        });

        imgReaderURL.readAsDataURL(customImageUpload); */

    }

    launchUploadEvt(imgDataURL) {
        //console.log('imgBlob', imgBlob);
        //sessionStorage.setItem('imgBlob', imgBlob);
        const uploadedData = {
            'name': this.customImageName,
            'dataURL': imgDataURL
        };
        this.dispatchEvent(new CustomEvent('productimageupload', {
            detail: this.customImage
        }));
    }

    handleErrorClose(){
        this.showImageError = false;
    }
}