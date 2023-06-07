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
import { api, LightningElement, track } from 'lwc';
import { getContext } from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';
import { ISGUEST } from 'c/ownDataUtils';
import { getCMSContent } from 'c/ownCMSContent';
import basePath from '@salesforce/community/basePath';

export default class OwnGarageDetailsPowersports extends OwnBaseElement {
    @track context;
    @track viewMode = true;
    @track editMode = false;
    @track isGuest = ISGUEST;

    //Added By : Abhishek Salecha on 8th October 2021
    @api
    protectionPlanCardTopic;
    //Added By : Abhishek Salecha on 8th October 2021
    @track
    protectionPlanCardContent;

    initialize = async () => {
        this.context = await getContext('');
    };

    async connectedCallback(){
        this.initialize();
        this.subscribeToChannel((message) => {           
            this.handleMessage(message);
        });

        //Added By : Abhishek Salecha on 8th October 2021
        let topics = [this.protectionPlanCardTopic];
       
        let content = await getCMSContent(topics);
        //console.log('content .. ',content);
        content.forEach(element => {
            element.associations.topics.forEach(topic => {
               // console.log('element.contentNodes .. ',element.contentNodes);
                if(topic.name === this.protectionPlanCardTopic){
                    this.protectionPlanCardContent = JSON.parse(JSON.stringify(element.contentNodes));
                    this.protectionPlanCardContent.body.value = this.convertRichTextToHTML(this.protectionPlanCardContent.body.value);
                }
            });
        });
        //console.log('This protectionPlanCardContent : ', this.protectionPlanCardContent);
        //Ends - Added By : Abhishek Salecha on 8th October 2021 
       
    }

    convertRichTextToHTML(contentText){
        contentText = String(contentText).replaceAll('&lt;', '<');
        contentText = contentText.replaceAll(/(&quot\;)/g,"\"");
        contentText = contentText.replaceAll('&gt;', '>');
        contentText = contentText.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
        return contentText;
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