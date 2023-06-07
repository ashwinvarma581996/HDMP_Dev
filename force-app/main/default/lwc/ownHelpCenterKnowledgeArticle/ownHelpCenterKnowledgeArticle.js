//============================================================================
// Title:    Honda Owners Experience - Help Center
//
// Summary:  knowledge article logic at the help center of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the knowledge article component for all help center pages.
//
//
// History:
// June 16, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { CurrentPageReference } from 'lightning/navigation';
import { ISGUEST, getKnowledgeArticle, getRelatedArticles, brandDataCategoryMap, addKnowledgeArticleVote, getGUID } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE, getDataLayer } from 'c/ownAdobedtmUtils';

export default class OwnHelpCenterKnowledgeArticle extends OwnBaseElement {
    @track articleId;
    @track results;
    @track brand;
    @track brandName;
    @track brandLabel;
    @track categoryLabel;
    @track relatedResults;
    @track maxResults = 3
    @track hasResults = false;
    @track isGuest = ISGUEST;
    @track isVoted = false;
    @track guestId;
    @track isShowModal = false;
    @track isSubmitFeedBack = false;
    @track feedback = '';
    @track feedbackCharCount = 255;

    @api recordId;
    @api urlName;

    currentPageReference = null;
    urlStateParameters = null;

    connectedCallback() {
        if (ISGUEST) {
            if (!localStorage.getItem('guestId')) {
                this.initializeGetGUID();
            } else {
                this.guestId = localStorage.getItem('guestId');
            }
        }
        //console.log('Result recordId: ' + this.recordId);
        this.subscribeToChannel((message) => {
            if (message && message.eventType) {
                //console.log('@message', message)
                let eventMetadata = {};
                if (message.eventMetadata) {
                    eventMetadata = message.eventMetadata;
                }
                let delay = false;
                if (message.delay) {
                    delay = message.delay;
                }
                let page = {};
                if (message.page) {
                    page = message.page;
                }
                let dealer = {};
                if (message.dealer) {
                    dealer = message.dealer;
                }
                let findProductDetails = {};
                if (message.findProductDetails) {
                    findProductDetails = message.findProductDetails;
                }
                let adobedtmObj = { delay: delay, eventType: message.eventType, data: { page: page, eventMetadata: eventMetadata, dealer: dealer, findProductDetails: findProductDetails } };
                this.initializeAdobedtm(adobedtmObj);
            }
        });
        this.initialize();
    }

    initialize = async () => {
        this.isShowModal = false;
        this.results = await getKnowledgeArticle(this.recordId, this.guestId);
        //console.log('Result: ' + JSON.stringify(this.results) + this.recordId + this.guestId);
        if (this.results.hasOwnProperty('vote')) {
            this.isVoted = true;
        }
        this.brand = { label: this.results.title, value: this.results.id, type: 'article', articleBrand: this.brandName === 'Honda' ? null : this.brandName, url: '' };
        this.initializeRelatedArticles();
        this.brandLabel = this.brandName === 'Honda' ? 'Honda' : brandDataCategoryMap.get(this.brandName).label;
        if (this.brandName === 'Honda') {
            this.categoryLabel = 'Popular Articles & FAQs';
        } else {
            this.categoryLabel = this.results.categories[0].label;
        }
        sessionStorage.setItem('acticleBrand', this.results.hasOwnProperty('categories') ? JSON.stringify(this.results.categories) : JSON.stringify([]))
        let adobedtmObj = { delay: false, eventType: DATALAYER_EVENT_TYPE.LOAD, data: { eventMetadata: {} } };
        this.initializeAdobedtm(adobedtmObj);
    };

    initializeAdobedtm = async (adobedtmObj) => {
        if (adobedtmObj.delay) {
            await this.sleep(3000);
        }
        let dataLayer = await getDataLayer(adobedtmObj.data);
        const adobedtmEvent = new CustomEvent('adobedtm', {
            detail: {
                eventType: adobedtmObj.eventType,
                data: JSON.parse(JSON.stringify(dataLayer))
            },
            bubbles: true,
            composed: true
        });
        //console.log('@dataLayer', JSON.stringify(dataLayer))

        this.dispatchEvent(adobedtmEvent);
    };

    initializeRelatedArticles = async () => {
        this.relatedResults = await getRelatedArticles(this.results.title, this.brandName === 'Honda' ? null : this.brandName, this.maxResults);
        if (this.relatedResults.length > 0) {
            this.hasResults = true;
        } else {
            this.hasResults = false;
        }
    };

    initializeGetGUID = async () => {
        this.guestId = await getGUID();
        localStorage.setItem('guestId', this.guestId);
    };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.articleId = this.urlStateParameters.id || null;
        this.brandName = this.urlStateParameters.brand || null;
    }

    handleClick(event) {
        let id = event.currentTarget.dataset.id;
        let urlName = event.currentTarget.dataset.urlname;
        this.navigate('/article/' + urlName + '?' + 'brand=' + this.brandName, {});
    }

    handleVoteClick(event) {
        let vote = event.currentTarget.dataset.vote === 'true';
        if (vote == true) {
            this.initializeAddKnowledgeArticleVote(vote);
        } else {
            this.isShowModal = true;
        }
    }

    initializeAddKnowledgeArticleVote = async (vote) => {
        //console.log('@@Test' + this.recordId + '@@' + vote + '@@' + this.guestId + '@@' + this.feedback);
        let voteResults = await addKnowledgeArticleVote(this.recordId, vote, this.guestId, this.feedback);
        //console.log('@@Test' + JSON.stringify(voteResults));
        if (voteResults.hasOwnProperty('vote')) {
            if (this.isSubmitFeedBack == false) {
                this.isVoted = true;
            }
        }
    };
    hideModalBox() {
        this.isShowModal = false;
    }

    handleFeedback(event) {
        this.feedback = event.target.value;
        this.feedbackCharCount = 255 - event.target.value.length;
        // console.log('@@Test'+this.feedback,'@@',this.feedbackCharCount);
    }

    handleSubmit() {
        try {
            const isInputsCorrect = [
                ...this.template.querySelectorAll("lightning-textarea")
            ].reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
            if (this.feedback.trim().length > 0) {
                this.isSubmitFeedBack = true;
                this.initializeAddKnowledgeArticleVote(false);
            }
        } catch (e) {
            //console.log('@@Exception' + e);
        }
    }

    handleCloseWindow() {
        this.isVoted = true;
        this.isShowModal = false;
    }
}