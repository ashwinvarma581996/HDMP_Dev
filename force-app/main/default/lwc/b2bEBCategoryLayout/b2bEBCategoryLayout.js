import { LightningElement, api,  wire, track } from 'lwc';
import {subscribe, unsubscribe, APPLICATION_SCOPE,MessageContext} from 'lightning/messageService';
import categorySelected from '@salesforce/messageChannel/Category_Selected__c';

export default class B2bEBCategoryLayout extends LightningElement {
   /**
    * Gets or sets the unique identifier of a category.
    * @type {String}
    */
    @api recordId
    
    /**
    * Number of Tiles to Display for each row in the category grid
    * @type {String}
    */
    @api gridMaxColumnsDisplayed = 3;

    /**
     * Font Color of Category Title
     * @type {Color}
     */
    @api fontColor

    /**
     * Font Size of Category Title
     * @type {String}
     */
      @api fontSize

      /**
       * Message for when no products are associated to mega category
       * @type {String}
       */
      @api noResultMessage

      @api ctaNoVehicle

      @api ctaVehicleSelected

      @api ctaFontSize

      subscription = null;
      @track noCategoryKey;
  
      @wire(MessageContext) 
      messageContext;
  
      // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
      subscribeToMessageChannel() {
          if (!this.subscription) {
              this.subscription = subscribe(
                  this.messageContext,
                  categorySelected,
                  (message) => this.handleMessage(message),
                  { scope: APPLICATION_SCOPE }
              );
          }
      }
  
      unsubscribeToMessageChannel() {
          unsubscribe(this.subscription);
          this.subscription = null;
      }
  
      // Handler for message received by component
      handleMessage(message) {
          this.noCategoryKey = message.categoryKey;
      }
  
      // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
      connectedCallback() {
          this.subscribeToMessageChannel();
      }
  
      disconnectedCallback() {
        //   this.unsubscribeToMessageChannel();
      }
}