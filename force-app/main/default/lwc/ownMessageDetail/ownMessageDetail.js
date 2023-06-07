import { LightningElement, api, track } from 'lwc';
import { getDate } from 'c/ownDataUtils';
import getRecallsByProductIdentifier from '@salesforce/apex/OwnAPIController.getRecallsByProductIdentifier';
export default class OwnMessageDetail extends LightningElement {
    @api message;
    @track title;
    @track brand;
    @track divisionId;
    @track contentKey;
    @track noRecalls = true;
    connectedCallback(){
        //console.log('$RECALLS: message: ',JSON.parse(JSON.stringify(this.message)));
        if(this.message){
            this.title = this.message.title;
            //console.log('$RECALLS: title: ',this.title);
            let getAllRecallsFromObj = localStorage.getItem('getAllRecallsFromObj');
            if(getAllRecallsFromObj){
                getAllRecallsFromObj = JSON.parse(getAllRecallsFromObj);
                //console.log('$RECALLS: getAllRecallsFromObj: ',getAllRecallsFromObj);
                let element = getAllRecallsFromObj.find(element => {
                    return element.title == this.title;
                });
                //console.log('$RECALLS: element: ',element);

                if(element && element.vin && element.vin != '-' && element.divisionId == 'P'){
                    this.initialize(element.vin, element.divisionId);
                }

                // this.brand = element.divisionId == 'A' ? 'Honda' : element.divisionId == 'B' ? 'Acura' : element.divisionId == 'M' ? 'Powersports' : element.divisionId == 'P' ? 'Powerequipment' : 'Marine';
                if(element && (element.divisionId == 'A' || element.divisionId == 'B' || element.divisionId == 'M')){
                    this.brand = element.divisionId == 'A' ? 'Honda' : element.divisionId == 'B' ? 'Acura' : 'Powersports';
                    this.divisionId = element.divisionId;
                    this.contentKey = element.contentKey;
                    //console.log('$RECALLS: brand: ',this.brand);
                    //console.log('$RECALLS: divisionId: ',this.divisionId);
                    //console.log('$RECALLS: contentKey: ',this.contentKey);
                }else{
                    //console.log('$RECALLS: PE Or Marine');
                }
            }
        }
    }
    
    initialize = async ( productIdentifier, divisionId ) => {
        let isMarine = false;
        await getRecallsByProductIdentifier({ productIdentifier: productIdentifier, divisionId: divisionId }).then((res) => {
            try{
                isMarine = res.response.recalls_response.response.recall.Subdivision_name == 'Marine';
            }catch(error){
               //console.error('$error: ', error);
            }
        }).catch((error) => {
            //console.error('$error: ',error);
        });

        //console.log('$isMarine: ',isMarine);
    }

    //Imtiyaz - CRRS Start
    get isRecallMessage(){
        // return sessionStorage.getItem('ActiveTab') && sessionStorage.getItem('ActiveTab') == 'Recalls';
        return this.contentKey ? true : false;
    }
    get getDate(){
        return getDate(7);
    }
    //Imtiyaz - CRRS End
}