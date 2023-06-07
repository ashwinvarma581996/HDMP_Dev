// Author : Bhawesh Asudani
// Date   : 12-01-2022
// Description : This component is used to display filtered sub category list on the page.
import { LightningElement,api, track } from 'lwc';
// Added By Bhawesh 24-01-2022 Bug No. HDMP- 6869 start
import No_Result_Found_Error_Message from '@salesforce/label/c.No_Result_Found_Error_Message';
const errorMsg = 'No search result found';
//End
export default class PartSearchPage extends LightningElement {

    @api partSearchResult;
    @track showErrorMsg = false; // Added By Bhawesh 19-01-2022 Bug No. HDMP- 6869
    @track noResultFound = No_Result_Found_Error_Message; // Added By Bhawesh 19-01-2022 Bug No. HDMP- 6869

    //Added by Faraz for 8676 on 18 April 2022
    connectedCallback(){
        if(this.partSearchResult.isError || this.partSearchResult.IllustrationGroups.length == 0){
            this.showErrorMsg = true;
            this.noResultFound = No_Result_Found_Error_Message.length ? No_Result_Found_Error_Message : errorMsg;
        }else{
            this.showErrorMsg = false;
        }
    }
    //End

    // Added By Bhawesh 19-01-2022 Bug No. HDMP- 6869 Start
    renderedCallback() {
        // Added by Bhawesh 20-01-2022 for HDMP-6869
        if(this.partSearchResult.isError || this.partSearchResult.IllustrationGroups.length == 0){
            this.showErrorMsg = true;
            this.noResultFound = No_Result_Found_Error_Message.length ? No_Result_Found_Error_Message : errorMsg;
        }else{
            this.showErrorMsg = false;
        }
    }
    //End
    // Added By Bhawesh 12-01-2022 Stroy R2 5084 start
    handleClickOnSubCategory(event){
        let subCategoryId = event.currentTarget.dataset.subcategoryrec;
        this.dispatchEvent(new CustomEvent('selectsubcategory', { detail: {partSearchResult : this.partSearchResult,subCategoryId  : subCategoryId }}));
    }
    // End
}