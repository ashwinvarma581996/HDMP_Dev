//============================================================================
// Title:    Honda Owners Experience - Footer
//
// Summary:  Owners Garage Find - Honda Auto Body logic of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the own garage find honda body component for all community pages.
//
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { LightningElement, track } from 'lwc';
import { getContext } from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';
import { ISGUEST } from 'c/ownDataUtils';

export default class OwnGarageDetailsMarine extends OwnBaseElement {
    @track context;
    @track viewMode = true;
    @track editMode = false;
    @track isGuest = ISGUEST;

    initialize = async () => {
        this.context = await getContext('');
    };

    connectedCallback() {
        this.initialize();
        this.subscribeToChannel((message) => {           
            this.handleMessage(message);
        });
    }

    handleMessage(message){
        if(message.type === 'product'){
            this.context.product = message.result.product;
            this.setViewMode();
        }
    }

    handleMode(event){
        if(event.detail.mode === 'edit'){
            this.setEditMode();
        }
        if(event.detail.mode === 'view'){
            this.setViewMode();
        }
    }

    setViewMode(){
        this.editMode = false;
        this.viewMode = true;
    }

    setEditMode(){
        this.editMode = true;
        this.viewMode = false;
    }
}