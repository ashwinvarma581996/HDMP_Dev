import { LightningElement ,track} from 'lwc';
import B2B_Braintree_Error_Message from '@salesforce/label/c.B2B_Braintree_Error_Message';
import B2B_Braintree_Success_Message from '@salesforce/label/c.B2B_Braintree_Success_Message';
import BT_Dealer_Enrollment_URL from '@salesforce/label/c.BT_Dealer_Enrollment_URL';
import updateAccountByMerchant from '@salesforce/apex/B2B_BrainTreeUtils.updateAccountByMerchant';
import updateBTDetailsByAccount from '@salesforce/apex/B2B_BrainTreeUtils.updateBTDetailsByAccount';


export default class DealerBTEnrollment extends LightningElement {
    @track merchantId;
    @track code;
    @track state;
    @track isLoading = true;    
    @track message = '';
  
    connectedCallback(){
        this.merchantId = this.getUrlParameter("merchantId");
        this.code = this.getUrlParameter("code");
        this.state = this.getUrlParameter("state");
        //console.log('merchantId : ',this.merchantId);
        //console.log('code : ',this.code);
        //console.log('state : ',this.state);
        if(this.merchantId && this.code && this.state){
            updateAccountByMerchant({merchantId : this.merchantId.toString(), code : this.code.toString(), state : this.state.toString()}).then(result => {
                console.log('Account result : ',result);  
                // this.message = 'Testing in QA';    
               // this.isLoading = false;        
                if(result != null){
                    updateBTDetailsByAccount({objAccount : result, code : this.code.toString()}).then(result => {
                        console.log('updateBTDetailsByAccount result : ',result); 
                        if(result == 'Updated'){
                            //this.message = B2B_Braintree_Success_Message;
                            window.open(BT_Dealer_Enrollment_URL + '/oauth-confirmation','_self');
                        }else {
                           // this.message = B2B_Braintree_Error_Message;
                           window.open(BT_Dealer_Enrollment_URL + '/oauth-error','_self');
                        }
                        //this.isLoading = false;
                    }).catch(error => {
                        //this.message = B2B_Braintree_Error_Message;
                        window.open(BT_Dealer_Enrollment_URL + '/oauth-error','_self');
                        //this.isLoading = false;
                        console.log('Error : ',error);
                    });
                   
                }else {
                    //this.message = B2B_Braintree_Error_Message;
                    window.open(BT_Dealer_Enrollment_URL + '/oauth-error','_self');
                    //this.isLoading = false;
                }               
            }).catch(error => {
                //this.message = B2B_Braintree_Error_Message;
                window.open(BT_Dealer_Enrollment_URL + '/oauth-error','_self');
                //this.isLoading = false;
                console.log('Error : ',error);
            })
        }
    }
    
    getUrlParameter(name) {
        name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
        var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
        var results = regex.exec(location.search); 
        return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
    } 

    handleCloseClick(){
        
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        window.open(baseURL, '_self', ''); 
        // window.close();

    }
    
}