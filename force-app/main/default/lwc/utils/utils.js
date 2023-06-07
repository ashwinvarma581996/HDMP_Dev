/**
 * Added by Rajrishi on 23-02-2023
 * @returns GetCompleteDetails common method to use in components for motocompacto.
*/
//for motocompacto starts
import getCompleteDetail from '@salesforce/apex/B2B_EconfigIntegration.getCompleteDetail';
import getProduct from '@salesforce/apex/B2BGuestUserController.getProduct';
export async function getCompleteDetails(modelId, poiType) {
    let productId;
    let partNumber
    await getCompleteDetail({ modelId: modelId, poiType: poiType })
        .then(result => {
            if (result) {
                let response = JSON.parse(result);
                if (!response.isError) {
                    let accessoriesDetail = JSON.parse(response.accessoryResult);
                    accessoriesDetail.Accessory = JSON.parse(JSON.stringify(accessoriesDetail.Accessories));
                    let selectedAcc = accessoriesDetail.Accessory[0];
                    createCookie('selectedAccessorie', JSON.stringify(selectedAcc), 1);
                    sessionStorage.setItem('accessories', JSON.stringify(accessoriesDetail));
                    sessionStorage.removeItem('fromcart');
                    let colors = accessoriesDetail.Accessory[0].Colors;
                    colors = JSON.parse(JSON.stringify(colors));
                    if (colors && colors.length && colors[0].part_number) {
                        partNumber = colors[0].part_number
                        console.log('partNumber : ', partNumber);                        
                        //let product2Id = '01t01000004KedIAAS';
                        //window.location.href = '/s/product/' + product2Id;
                    }
                }else{
                    return false;
                }
            }
        }).catch(error => {
            console.log('error : ', error);
        });
    
    if(partNumber){
        await getProduct({ productId: partNumber }).then(result => {
            if (result) {
                console.log('product : ', result);
                let product = JSON.parse(JSON.stringify(result)); 
                productId = product.Id;                            
            }
        }).catch(error => {
            console.log('get product error : ', error);
        })
    }
    
    return productId;
}


export function createCookie(name, value, days) {
    var expires;
    if (days) {
        const date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 100));
        expires = ";expires=" + date.toGMTString();
    } else {
        expires = "";
    }
    document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
}
// motocompacto ends

/**
 * Added by imtiyaz on 20-DEC-2022
 * @exporting GetDealerPrice common method to use in components.
*/
import Get_DealerPrice from '@salesforce/apex/B2B_INSystemIntegration.GetDealerPrice';
export async function GetDealerPrice(dealerNo, divisionId, partNumbers, accessories){
    let data;
    await Get_DealerPrice({
        dealerNo: dealerNo,
        divisionId: divisionId,
        partNumbers: JSON.stringify(partNumbers),
        accessories: JSON.stringify(accessories)
    }).then((result) => {
        data = result;
    }).catch((error) => {
        console.error(error);
    });
    return data;
}
/**
 * Get the current dealer id from the local storage.
 * @returns the current dealer id.
 */
 export function getCurrentDealerId(){
    let dealerId;
    let brand = window.location.href.includes('/s/cart/') ? localStorage.getItem('cartBrand') : sessionStorage.getItem('vehicleBrand');
    let brands = [];
    if(localStorage.getItem('effectiveDealer')){
        brands = JSON.parse(localStorage.getItem('effectiveDealer'))['brands'];
        if(brands){
            brands.forEach(element => {
                if(brand === element.brand){
                    dealerId = element.id;
                }
            });
        }
    }
    return dealerId;
}

export function getCurrentDealer(){
    let dealer;
    let brand = window.location.href.includes('/s/cart/') ? localStorage.getItem('cartBrand') : sessionStorage.getItem('vehicleBrand');
    let brands = [];
    if(localStorage.getItem('effectiveDealer')){
        brands = JSON.parse(localStorage.getItem('effectiveDealer'))['brands'];
        if(brands){
            brands.forEach(element => {
                if(brand === element.brand){
                    dealer = element;
                }
            });
        }
    }
    return dealer;
}

export function getCurrentVehicle(){
    let vehicle;
    let brand = window.location.href.includes('/s/cart/') ? localStorage.getItem('cartBrand') : sessionStorage.getItem('vehicleBrand');
    console.log('$CI: UTILS : brand: ',brand);
    let brands = [];
    let divisionId;
    let productType;
    if(localStorage.getItem("effectiveVehicle")){
        console.log('$IA: utils-46: effectiveVehicle - ', JSON.parse(localStorage.getItem("effectiveVehicle")));
        console.log('$CI: UTILS : effectiveVehicle - ', JSON.parse(localStorage.getItem("effectiveVehicle")));
        brands = JSON.parse(localStorage.getItem("effectiveVehicle"))['brands'];
        if(brands){
            brands.forEach(element => {
                if(brand === element.brand){
                    vehicle = element;
                }
            });
        }
    }
    return vehicle;
}

/**
 * Added by faraz on 01-March-2023
 * @exporting getReturnPolicyMarkupMdt common method to use in components.
*/
import getReturnPolicyMarkupMdt from '@salesforce/apex/B2B_DealerReturnPolicyController.getReturnPolicyMarkupMdt';
export async function getReturnPolicyMarkup() {
    let data;
    await getReturnPolicyMarkupMdt().then((result) => {
        data = result;
    }).catch((error) => {
        console.error('Error : ',error);
    });
    return data;
}