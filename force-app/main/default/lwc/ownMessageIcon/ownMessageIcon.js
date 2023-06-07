import { LightningElement, track, api, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/MyGarage";
import getUnreadMessageCount from '@salesforce/apex/OwnRecallsController.getUnreadMessageCount';
import {ISGUEST} from 'c/ownDataUtils';

export default class OwnMessageIcon extends OwnBaseElement {

    messageIcon = commonResources + '/ahmicons/email.svg';
    @track unreadMessageCount = 0;
    @track isGuest = ISGUEST;

    connectedCallback(){
        if (!this.isGuest) {
            this.initialize();
            this.subscribeToChannel((message) => {
                //console.log('MESSAGE: ' + JSON.stringify(message));
               if(message.recallDataLoaded){
                   //console.log('Recall Channel Sub');
                   this.initialize();
               }
            });
        }
    }

    initialize = async () => {
        this.unreadMessageCount = await getUnreadMessageCount();
    }
    
    @api
    get displayMessageCount(){
        //console.log(this.unreadMessageCount);
        return this.unreadMessageCount > 0 ? true : false;
    }
    handleclick(){
        this.navigate('/messages', {});
    }

/*     @wire(getUnreadMessageCount)
    getUnreadMessageCount({ error, data }){
        if (data){
            this.unreadMessageCount = data;
        }
        else if (error){
            console.log(JSON.stringify(error));
        }
    } */

}