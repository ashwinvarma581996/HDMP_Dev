import { LightningElement, api, track, wire } from 'lwc';
import getRecordList from '@salesforce/apex/DeleteBoilerplate.deleteBoilerplate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import ErrorOnDelete from '@salesforce/label/c.Error_On_Boilerplate_Deletion';

export default class DeleteBoilerplate extends NavigationMixin(LightningElement) {
  @api recordId;
  @track isLoaded;

  invoke() {
    console.log(`this.recordId: ${this.recordId}`);
  }

  label = {
    ErrorOnDelete
  }
  showToast() {
    const event = new ShowToastEvent({
      title: 'Record Deleted Success',
      message: 'Record Deleted Successfully',
      variant: 'success',
      mode: 'dismissable',
    });
    this.dispatchEvent(event);
    this.isLoaded = true;
    setTimeout(() => {
      this.isLoaded = false;
      this.handleListViewNavigation();
    }, 1000);
  }

  handleListViewNavigation() {
    this.isLoaded = false;
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: 'Boilerplate__c',
        actionName: 'list',
      },
      state: {
        filterName: 'Recent',
      },
    });
  }

  showWarningToast() {
    const evt = new ShowToastEvent({
      title: 'Boilerplate cannot be deleted',
      message: this.label.ErrorOnDelete,
      variant: 'warning',
      mode: 'dismissable',
    });
    this.dispatchEvent(evt);
    this.isLoaded = false;
    this.navigateToOfferRecordPage();
  }

  navigateToOfferRecordPage() {
    this.isLoaded = false;
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.recordId,
        objectApiName: 'Boilerplate__c',
        actionName: 'view',
      },
    });
  }

  renderedCallback() {
    console.log(`this.recordId: ${this.recordId}`);
    if (this.recordId) {
      getRecordList({ recordID: this.recordId })
        .then((result) => {
          console.log(`result: ${result}`);
          console.log(`result Stringify: ${JSON.stringify(result)}`);
          if (result) {
            this.showToast();
          } else {
            this.showWarningToast();
          }
        })
        .catch((error) => {
          console.log(`In renderedCallback error: ${JSON.stringify(error)}`);
        });
    }
  }
}