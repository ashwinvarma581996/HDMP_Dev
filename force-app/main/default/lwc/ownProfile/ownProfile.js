//============================================================================
// Title:    Honda Owners Experience - Header
//
// Summary:  logo logic at the help center of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the logo component for all help center pages.
//
//
// History:
// June 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import Id from '@salesforce/user/Id';
import FIRST_NAME_FIELD from '@salesforce/schema/User.FirstName';
import PROFILE_PHOTO_FIELD from '@salesforce/schema/User.SmallPhotoUrl';
import basePath from "@salesforce/community/basePath";
import getProfilePhoto from '@salesforce/apex/OwnContextController.getProfilePhoto';
import { setOrigin } from 'c/ownDataUtils';
import hidasTokenRevoke from '@salesforce/apex/OwnAPIController.hidasTokenRevoke';
import mygarageurl from '@salesforce/label/c.MyGarageURL';

const fields = [FIRST_NAME_FIELD, PROFILE_PHOTO_FIELD];

export default class OwnProfile extends OwnBaseElement {
    userId = Id;
    @track image;

    @wire(getRecord, { recordId: '$userId', fields })
    user;

    get firstName() {
        return getFieldValue(this.user.data, FIRST_NAME_FIELD);
    }

    // get image() {
    //     return getFieldValue(this.user.data, PROFILE_PHOTO_FIELD);
    // }

    get smallPhotoUrl() {
        return getFieldValue(this.user.data, SMALL_PHOTO_URL_FIELD);
    }

    get logoutLink() {
        const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
        return sitePrefix + "/secur/logout.jsp";
    }

    connectedCallback() {
        this.subscribeToChannel( async (message) => {
            if (message.profileImageUpdate) {
               await this.sleep(2000);
               this.getImage();
                console.log('After Get Image')
            }
        });
        this.getImage();
    }

    getImage() {
        getProfilePhoto().then((res) => {
            //console.log('Image Cansole. ', res)
            this.image = res;
        })
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }


    handleLogOutClick() {
        console.log('It is Logged Out');
        hidasTokenRevoke()
        .then((result) => {
            //console.log('Result : ',result);
            setOrigin('');
            localStorage.removeItem('garage');
            localStorage.removeItem('context');
            window.open(this.logoutLink, "_Self");
            
        })
        .catch((error) => {
            //console.log('Error : ',error);
            setOrigin('');
            localStorage.removeItem('garage');
            localStorage.removeItem('context');
            window.open(this.logoutLink, "_Self");
        });

        
    }

    handleAvtarClick() {
        let mygarageURLLabel = mygarageurl === '/' ? '' : mygarageurl;
        window.open(mygarageURLLabel + '/s/my-account', "_Self");

        //this.navigate('',{});
    }
}