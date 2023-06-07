import { LightningElement, track, api } from 'lwc';
import markItRead from '@salesforce/apex/ownMessageController.markItRead';
export default class OwnInbox extends LightningElement {
    @api messages = [];
    @api recalls = [];
    @api messagedetail;
    @track selectedMessage = {};
    // @api category;

    connectedCallback() {
        this.initialize();
    }
    initialize() {
        //console.log('inbox', this.messages.length)
        //console.log('inbox', JSON.parse(JSON.stringify(this.messages)))
        //console.log('$RECALLS: ownInbox messages: ',JSON.parse(JSON.stringify(this.messages)));
    }

    handleClick(event) {
        //console.log("clicked")
        //console.log("inbox", event.currentTarget.dataset.body)
        if (event.currentTarget.dataset.readStatus == 'false') {
            //console.log("inbox", event.currentTarget.dataset.readStatus)
            markItRead({ id: event.currentTarget.dataset.id });
        }

        this.selectedMessage = event.currentTarget.dataset.body;
        this.selectedMessage = {
            body: event.currentTarget.dataset.body,
            title: event.currentTarget.dataset.title,
            date: event.currentTarget.dataset.date
        }
        //console.log("inbox selectedMessage", JSON.parse(JSON.stringify(this.selectedMessage)))
        // this.recall1 = event.currentTarget.dataset;
        // let recall = {};
        // recall = {
        //     recallNo: event.currentTarget.dataset.recallNo,
        //     campaignID: event.currentTarget.dataset.campaignId,
        //     campaignDescription: event.currentTarget.dataset.campaignDescription,
        //     date: event.currentTarget.dataset.date,
        //     recallStatus: event.currentTarget.dataset.recallStatus,
        //     summary: event.currentTarget.dataset.summary,
        //     safetyRisk: event.currentTarget.dataset.safetyRisk,
        //     remedy: event.currentTarget.dataset.remedy,

        // }
        // this.selectedMessage = recall;
        // console.log("recall1----", this.selectedMessage.date)
        // console.log("recall2----", JSON.stringify(event.currentTarget.dataset.campaignId))
        this.messagedetail = true;
        let id = event.currentTarget.dataset.id
        const selectedEvent = new CustomEvent("messagedetailshow", {
            detail: {
                messageDetail: true,
                id: event.currentTarget.dataset.id,
                msgType: event.currentTarget.dataset.msgType,
            }
        });
        //console.log("messagedetail;", this.messagedetail)
        //console.log("id;", id)
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        //console.log("dispatched")
    }
    // get isAllMessages() { return this.category === 'All Messages'; }
    // get isRecall() {
    //     return this.category === 'Recalls';
    // }
}