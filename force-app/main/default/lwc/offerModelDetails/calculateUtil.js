import { LightningElement, track, api, wire } from "lwc";

//Storing global messages for field validation
var gErrorMessage = "";
//Global Boolean variable to store the status of fields.
var gInvalidFields = false;
var gLineSeperator = "<br>";
var strValues ="";

export function leaseCalculation(sProductDivisionCD, 
    nBaseMonthlyPayment,
    nCapitalizedCostReduction, 
    nNetCapitalCost,
    nAcquistionFee,
    bHasSecurityDeposit,
    iTerm, 
    iAnnualMiles,
    nResidualFactor ,
    nDestinationHandlingCharge,
    nMSRP,
    nGrossMargin,
    nBonusCash1,
    nBonusCash2,
    nBonusCash3,
    nBonusCash4,
    nBonusCash5,
    nDealerContrib,
    nInvPriceWithDH,
    bZeroDue){

        
    //Validate input parameters
 	if ((sProductDivisionCD == null) || (sProductDivisionCD == ""))
 	{
 	    gErrorMessage += "Product Division Code is missing " + gLineSeperator;
        gInvalidFields = true;
 	}
 	else if ((sProductDivisionCD != "A") && (sProductDivisionCD != "B") )
 	{
 	    gErrorMessage += "Invalid Product Division Code " + gLineSeperator;
        gInvalidFields = true;
 	}
 	
 	IsNumeric(nBaseMonthlyPayment, "Base Monthly Payment");
    IsNumeric(nCapitalizedCostReduction, "Capitalized Cost Reduction");
   	IsNumeric(nNetCapitalCost, "Net Capital Cost");
 	IsNumeric(nAcquistionFee, "Acquistion Fee");
 	IsNumeric(iTerm, "Term");
 	IsNumeric(iAnnualMiles, "Annual Miles");
  	IsNumeric(nResidualFactor, "Residual Factor");
 	IsNumeric(nDestinationHandlingCharge, "Destination Handling Charge");
 	IsNumeric(nMSRP, "MSRP");
 	IsNumeric(nGrossMargin, "Gross Margin");
 	IsNumeric(nBonusCash1, "Bonus Cash1");
 	IsNumeric(nBonusCash2, "Bonus Cash2");
 	IsNumeric(nBonusCash3, "Bonus Cash3");
 	IsNumeric(nBonusCash4, "Bonus Cash4");
 	IsNumeric(nBonusCash5, "Bonus Cash5");
 	IsNumeric(nDealerContrib, "Dealer Contrib");
 	IsNumeric(nInvPriceWithDH, "Invoice Price With DH");
 	
    var calculatedArrayValues = new Array(4);

 	//Check all fields are valid to proceed further
 	if (gInvalidFields == false)
 	{
 	   	//Format to 2 decimal places
 	   	nBaseMonthlyPayment = (parseFloat(nBaseMonthlyPayment)).toFixed(2); 
 	   	nCapitalizedCostReduction = (parseFloat(nCapitalizedCostReduction)).toFixed(2);
        iTerm = parseInt(iTerm);
        iAnnualMiles = parseInt(iAnnualMiles);
        nResidualFactor = (parseFloat(nResidualFactor)).toFixed(2);
        nDestinationHandlingCharge = (parseFloat(nDestinationHandlingCharge)).toFixed(2);
        nMSRP = (parseFloat(nMSRP)).toFixed(2);
        nNetCapitalCost = (parseFloat(nNetCapitalCost)).toFixed(2);
        
        
        var intTotalMonthlyPayment, intTotalDueLeaseSign;
        var intRefundableSecurity, intResidualValue, intAdjustedResidualFactor, intNetPrice;

            
        //Calculate Refundable Security
        if (bHasSecurityDeposit == 0)
        {
            intRefundableSecurity = 0;
        }
        else
        {   //Rounded up to the nearest $25  
            intRefundableSecurity = Math.ceil(parseFloat(nBaseMonthlyPayment)/25) * 25;
        }
        
        //Default value for intAdjustedResidualFactor
        intAdjustedResidualFactor = parseFloat(nResidualFactor);
        
        switch (iAnnualMiles)
        {
            case 15000:
                intAdjustedResidualFactor = parseFloat(nResidualFactor);
                break;
            case 12000:
                if ((sProductDivisionCD == "A") || (sProductDivisionCD == "B"))
                {
                    if ((iTerm >=24) && (iTerm <=33))
                    {
                        intAdjustedResidualFactor = parseFloat(nResidualFactor) + 0.01;
                    }
                    if ((iTerm >=34) && (iTerm <=48))
                    {
                        intAdjustedResidualFactor = parseFloat(nResidualFactor) + 0.02;
                    }
                }
                break;
            case 10000:
                if ((sProductDivisionCD == "B") && (iTerm >=24) && (iTerm <=33))
                {
                    intAdjustedResidualFactor = parseFloat(nResidualFactor) + 0.02;
                }
                if ((sProductDivisionCD == "B") && (iTerm >=34) && (iTerm <=48))
                {
                    intAdjustedResidualFactor = parseFloat(nResidualFactor) + 0.03;
                }
                break;
            default:
                break;
        }

//        intNetPrice = parseFloat(nMSRP) + parseFloat(nDestinationHandlingCharge);
        intNetPrice = parseFloat(nMSRP);
        
        if (bZeroDue == 1)
        {
	        intTotalMonthlyPayment = (iTerm - 1) * parseFloat(nBaseMonthlyPayment);
	        intTotalDueLeaseSign = nCapitalizedCostReduction;
        }
        else
        {
            intTotalMonthlyPayment = iTerm * parseFloat(nBaseMonthlyPayment);
            intTotalDueLeaseSign = parseFloat(nBaseMonthlyPayment) + parseFloat(nCapitalizedCostReduction) + intRefundableSecurity ; //+ parseFloat(nAcquistionFee);
        }
        
        intResidualValue = parseFloat(intAdjustedResidualFactor) * parseFloat(intNetPrice);

        calculatedArrayValues[0] = ""; //Used for handling Error;
        calculatedArrayValues[1] = (Math.round(intTotalDueLeaseSign*100)/100).toFixed(2);
        calculatedArrayValues[2] = (Math.round(intResidualValue*100)/100).toFixed(2);
        calculatedArrayValues[3] = (Math.round(intTotalMonthlyPayment*100)/100).toFixed(2);

 	}
 	else
 	{
 	    calculatedArrayValues[0] = gErrorMessage.replace("\n","<br>");
 	    gInvalidFields = false;
 	    gErrorMessage = "";
 	    
 	}
	
	    strValues += "\n Calculation Result\n";
        strValues  += "Total Due at Lease Signing: $" + calculatedArrayValues[1];
        strValues  += "\n Residual Value: $" + calculatedArrayValues[2];
        strValues  += "\n Total Monthly Payments: $" + calculatedArrayValues[3];

	console.log('strValues==>'+strValues);
 	return calculatedArrayValues;

}

function IsNumeric(input, errFieldName) 
{
	strValues += errFieldName + ": " + input +"\n";
   /* if (((input - 0) == input && input.length > 0) == false)
   // if (input == null)
    {
        console.log("--------input name",errFieldName);
        console.log("input val",input);
        gErrorMessage += errFieldName + " is missing or incorrect " + gLineSeperator;
        gInvalidFields = true;   
    }*/
    console.log("--------input name",errFieldName);
         console.log("input val",input);
         if(errFieldName == "Invoice Price With D&H" || errFieldName == "MSRP"){
            if (input == 0 || input == undefined || input == null || input === 'NaN')
    // if (input == null)
     {
         
         gErrorMessage += errFieldName + " is missing or incorrect " + gLineSeperator;
         gInvalidFields = true;
     }
         } else{
    if (input == undefined || input == null || input === 'NaN')
    // if (input == null)
     {
         
         gErrorMessage += errFieldName + " is missing or incorrect " + gLineSeperator;
         gInvalidFields = true;
     }
    }

} 

export function calculateAdjustedResidualFactor(sProductDivisionCD, nResidualFactor, iTerm, iAnnualMiles)
{
    var calculatedArrayValues = new Array(2);
    var intAdjustedResidualFactor;

    if ((sProductDivisionCD == null) || (sProductDivisionCD == ""))
 	{
 	    gErrorMessage += "Product Division Code is missing " + gLineSeperator;
        gInvalidFields = true;
 	}
 	else if ((sProductDivisionCD != "A") && (sProductDivisionCD != "B") )
 	{
 	    gErrorMessage += "Invalid Product Division Code " + gLineSeperator;
        gInvalidFields = true;
 	}

    IsNumeric(nResidualFactor, "Residual Factor");

    IsNumeric(iTerm, "Term");
 		
 	IsNumeric(iAnnualMiles, "Annual Miles");
    if (gInvalidFields == false)
 	{
 	    iTerm = parseInt(iTerm);
        iAnnualMiles = parseInt(iAnnualMiles);
        nResidualFactor = (parseFloat(nResidualFactor)).toFixed(2);
        
        //Default value for intAdjustedResidualFactor
        intAdjustedResidualFactor = parseFloat(nResidualFactor);
        
        switch (iAnnualMiles)
        {
            case 15000:
                intAdjustedResidualFactor = parseFloat(nResidualFactor);
                break;
            case 12000:
                if ((sProductDivisionCD == "A") || (sProductDivisionCD == "B"))
                {
                    if ((iTerm >=24) && (iTerm <=33))
                    {
                        intAdjustedResidualFactor = parseFloat(nResidualFactor) + 0.01;
                    }
                    if ((iTerm >=34) && (iTerm <=48))
                    {
                        intAdjustedResidualFactor = parseFloat(nResidualFactor) + 0.02;
                        
                    }
                }
                break;
            case 10000:
                if ((sProductDivisionCD == "B") && (iTerm >=24) && (iTerm <=33))
                {
                    intAdjustedResidualFactor = parseFloat(nResidualFactor) + 0.02;
                }
                if ((sProductDivisionCD == "B") && (iTerm >=34) && (iTerm <=48))
                {
                    intAdjustedResidualFactor = parseFloat(nResidualFactor) + 0.03;
                }
                break;
            default:
                break;
        }
        
        calculatedArrayValues[0] = ""; //Used for handling Error;
        calculatedArrayValues[1] = intAdjustedResidualFactor.toFixed(2);
       
        
    }
    else
    {
   	    calculatedArrayValues[0] = gErrorMessage.replace("\n","<br>");
 	    gInvalidFields = false;
 	    gErrorMessage = "";

    }
 	
    return calculatedArrayValues;
}

export function calculateLease(sProductDivisionCD,
    nBaseMonthlyPayment,
    nCapitalizedCostReduction, 
    nNetCapitalCost,
    nAcquistionFee,
    bHasSecurityDeposit,
    iTerm, 
    iAnnualMiles,
    nResidualFactor ,
    nAdjustedMSRP,
    nGrossMargin,
    nBonusCash1,
    nBonusCash2,
    nBonusCash3,
    nBonusCash4,
    nBonusCash5,
    nDealerContrib,
    nInvPriceWithDH,
    bZeroDue,
    nMSRP)
{
//Validate input parameters

debugger;
IsNumeric(nBaseMonthlyPayment, "Base Monthly Payment");

IsNumeric(nCapitalizedCostReduction, "Capitalized Cost Reduction");

IsNumeric(nNetCapitalCost, "Net Capitalized Cost");

IsNumeric(nAcquistionFee, "Acquisition Fee");

IsNumeric(iTerm, "Lease Terms (Months)");

IsNumeric(iAnnualMiles, "Annual Miles");

IsNumeric(nResidualFactor, "Residual Factor");


IsNumeric(nAdjustedMSRP, "Adjusted MSRP with D&H");

IsNumeric(nGrossMargin, "Gross Margin");

IsNumeric(nDealerContrib, "Dealer Contribution");

IsNumeric(nInvPriceWithDH, "Invoice Price With D&H");
IsNumeric(nMSRP, "MSRP");   


var calculatedArrayValues = new Array(4);

//Check all fields are valid to proceed further
if (gInvalidFields == false)
{
//Format to 2 decimal places
nBaseMonthlyPayment = (parseFloat(nBaseMonthlyPayment)).toFixed(2); 
nCapitalizedCostReduction = (parseFloat(nCapitalizedCostReduction)).toFixed(2);
iTerm = parseInt(iTerm);
iAnnualMiles = parseInt(iAnnualMiles);
nResidualFactor = (parseFloat(nResidualFactor)).toFixed(2);
nAdjustedMSRP = (parseFloat(nAdjustedMSRP)).toFixed(2);
nNetCapitalCost = (parseFloat(nNetCapitalCost)).toFixed(2);


var intTotalMonthlyPayment, intTotalDueLeaseSign;
var intRefundableSecurity, intResidualValue, intAdjustedResidualFactor, intNetPrice;
intRefundableSecurity = 0;


//Calculate Refundable Security
if (bHasSecurityDeposit == 0)
{
   
intRefundableSecurity = 0;
}
else
{   //Rounded up to the nearest $25  
  
intRefundableSecurity = Math.ceil(parseFloat(nBaseMonthlyPayment)/25) * 25;
}

//Default value for intAdjustedResidualFactor
intAdjustedResidualFactor = parseFloat(nResidualFactor);

intNetPrice = parseFloat(nAdjustedMSRP);

if (bZeroDue == 1)
{
intTotalMonthlyPayment = (iTerm - 1) * parseFloat(nBaseMonthlyPayment);
intTotalDueLeaseSign = nCapitalizedCostReduction;
}
else
{
intTotalMonthlyPayment = iTerm * parseFloat(nBaseMonthlyPayment);
intTotalDueLeaseSign = parseFloat(nBaseMonthlyPayment) + parseFloat(nCapitalizedCostReduction) + intRefundableSecurity ; //+ parseFloat(nAcquistionFee);
}


intResidualValue = parseFloat(intAdjustedResidualFactor) * parseFloat(intNetPrice);

calculatedArrayValues[0] = ""; //Used for handling Error;
calculatedArrayValues[1] = (Math.round(intTotalDueLeaseSign*100)/100).toFixed(2);
calculatedArrayValues[2] = (Math.round(intResidualValue*100)/100).toFixed(2);
calculatedArrayValues[3] = (Math.round(intTotalMonthlyPayment*100)/100).toFixed(2);
}
else
{
calculatedArrayValues[0] = gErrorMessage.replace("\n","<br>");
gInvalidFields = false;
gErrorMessage = "";

}
return calculatedArrayValues;

}