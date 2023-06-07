import { LightningElement,track,wire } from 'lwc';
import getProdDetails from '@salesforce/apex/B2BGetInfo.getProdDetails';
export default class ProductDetailComponent extends LightningElement {
  @track productId;  
connectedCallback() {
    console.log('hello');
      var jsonString  = '[{"Parts": [{ "PartID": "392359", "IllustrationReferenceCode": "001", "QuantityRequired": "001", "EngineFrameTransmissionTypeCode": "E", "LoUnVisSerialGroup": "", "HighUnVisSerialGroup": "", "HondaCode": "9712981", "PartNumber": "16400-59B-003", "PartDescription": "THROTTLE BODY, ELECTRONIC CONTROL (GMG9A) (A) (THROTTLE ACTUATOR / POSITION (TP) SENSOR)", "PartControlCode": "", "SRACode": "E", "MostForwardSupersession": "", "ForwardSupersession": "", "BackwardSupersession": "", "MultiOrderQuantity": "1", "DealerNetPriceAmount": "103.61", "SuggestedRetailPriceAmount": "172.68", "CoreCostAmount": "0.00", "PriceChangeFlag": "", "PartStatusCode": "Z", "VDFlag": "N", "WholsaleCompFlag": "", "PartModificationCode": "", "NATABCQuantityCode": "F", "PartSizeCode": "", "CRSShipCode": "", "CommonPartFlag": "", "Height": "00213", "Length": "00213", "GradeID": 0, "GradeDescription": "EX (2WD/E.LIBERTY)", "AreaID": 0, "AreaDescription": "ALL", "OriginID": 0, "OriginDescription": "USA", "TransmissionID": 0, "TransmissionDescription": "ALL", "ColorLabelID": 0, "ColorLabelDescription": "", "IllustrationReferenceCodeOrderBy": "001", "IllustrationReferenceCode2": "48", "PartDescriptionMasterFile": "THROTTLE BODY, ELECTRONIC CONTROL (GMG9A)" }] }]';
       var productDetails = JSON.parse(jsonString)[0].Parts[0];
       this.productDetailJson = productDetails;
       console.log('##productDetails',productDetails);
        console.log('##productDetailJson',this.productDetailJson);
        this.productId = this.productDetailJson.PartID;
         console.log('##productId',this.productId);
    }
 
    @wire(getProdDetails, { productId: '$productId' })
    wiredProdDetails({ error, data }) {
      if (data) {
        console.log('Data', JSON.parse(data));
        
      } else if (error) {
         console.error('Error:', error);
      }
    }
}