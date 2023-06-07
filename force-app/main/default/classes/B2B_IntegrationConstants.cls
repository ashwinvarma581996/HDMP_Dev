/*******************************************************************************
Name: B2B_IntegrationConstants
Business Unit: HDM
Date: 28/04/2022
Developer: Soumya Sahoo
Description: This class is used for storing constant values
*******************************************************************************
MODIFICATIONS – V1 | 29/03/2022 | Soumya | Integration Constants
*******************************************************************************/
public class B2B_IntegrationConstants {
	public static final STRING STATE = 'mainDivision';
 	public static final STRING POSTALCODE= 'postalCode';
    public static final STRING FEDEX_LABEL= 'FEDEX';
    public static final STRING USPS_LABEL= 'USPS';
    public static final STRING UPS_LABEL= 'UPS';
    public static final STRING COUNTRY= 'country';
    public static final STRING COUNTRY_VALUE = 'US';
    public static final STRING SHIPPINGSTREET = 'shippingStreet';
    public static final STRING CITY = 'city';
    public static final STRING TYPE_VALUE = 'Cart';
    public static final STRING SHIPPING_LABEL = 'Get the delivery methods, silly';
    public static final STRING SHIPPING_DESCRIPTION = 'Runs a synchronous version of delivery method preparation';
    public static final STRING SHIPPING_CATEGORY = 'B2B Commerce';
    public static final STRING ERROR_MESSAGE_SRC_DEST_SAME = '{"serviceTypewithChargeMap":{},"responseCode":"","isSuccess":false,"errorMessage":"Destination and Customer Postal Code is same"}';
    public static final STRING ERROR_MESSAGE_SHIPPING_AMOUNT_NULL = 'Preffered Speed not available in response';
    public static final STRING ERROR_MESSAGE_STATUS_CODE_500 = 'Dynamic backend host not specified';
    public static final STRING ERROR_MESSAGE_CHECKOUT = 'Shipping cost calculation error';
    public static final STRING ERROR_MESSAGE_DESCRIPTION = 'B2B_ShippingHelper';
    public static final STRING ERROR_MESSAGE_METHOD_NAME = 'startCartProcessAsync';
    public static final STRING ERROR_MESSAGE_ADDRESS_INVALID = 'We’re unable to calculating shipping for this address.  Please review and verify the correct information is entered';
    public static final STRING ERROR_MESSAGE_API_DOWN = 'We’re experiencing technical difficulties, please select a different delivery option or try again later';
    public static final STRING ERROR_MESSAGE_NO_HONDASHIPPING_SPEED = 'We’re experiencing technical difficulties. Please select a different delivery option or try again later';
    public static final INTEGER USPS_FIRST_INDEX = 0;
    public static final INTEGER USPS_LAST_iNDEX = 5;
    public static final STRING USPS_ERROR_NUMBER='Number';
    public static final DECIMAL SHIPPING_AMOUNT_DEFAULT=0.00;
    public static final STRING ERROR_RESPONSE_CODE = '500';
    public static final STRING SHIPPING_EXCEPTION='An exception of type';
    public static final STRING SHIPPING_STATEMENT='has occurred:';
    public static final STRING ERROR_CORRECT_ADDRESS='Please Provide Correct Addresses.';
    public static final STRING FEDEX_XML_URL='http://fedex.com/ws/rate/v28';
    public static final INTEGER DEFAULT_VALUE=0;
    public static final INTEGER CONVERSATIONRATE=16;
    public static final STRING ERRORMESSAGE_TAX='A cart id must be included to B2BSyncTax';
    public static final STRING SOME_JOB='Some Job';
    public static final STRING TAX_ERROR_MESSAGE_CHECKOUT='Tax calculation error';
    public static final STRING TAX_ERROR_MESSAGE_DESCRIPTION='B2B_TaxHelperV2';
    public static final STRING JOB_INFO='jobInfo';
    public static final STRING TAXES='Taxes';
    public static final STRING QUOTATION='quotation';
    public static final STRING TAX_XML_URL='urn:vertexinc:o-series:tps:9:0';
    public static final STRING BlankVariable='';
    public static final STRING NULLVARIABLE=Null;
    public static final STRING STREETADDRESS='streetAddress';
    public static final STRING LINENUMBER='Line Number';
    public static final STRING RATERESPONSE='RateResponse';
    public static final STRING RESPONSE='Response';
    public static final STRING RESPONSESTATUS='ResponseStatus';
    public static final STRING DESCRIPTION='Description';
    public static final STRING SUCCESS='success';
    public static final STRING TOTALCHARGES='TotalCharges';
    public static final STRING SERVICE='Service';
    public static final STRING CODE='Code';
    public static final STRING FEDEX_ADDRESS_WRONG_CODE='556';
    public static final STRING MONETARYVALUE='MonetaryValue';
    public static final STRING RATEDSHIPMENT='RatedShipment';
    public static final STRING USPS_SERVICE='ALL';
    public static final INTEGER REVISION=2;
    public static final STRING MAILSERVICE='MailService';
    public static final STRING RATE='Rate';
    public static final INTEGER CONSTANTVALUE=100;
    public static final STRING RATEREPLY='RateReply';
    public static final STRING NOTIFICATIONS='Notifications';
    public static final STRING SEVERITY='Severity';
    public static final STRING MESSAGE='Message';
    public static final STRING RATEREPLYDETAILS='RateReplyDetails';
    public static final STRING RATEDSHIPMENTDETAILS='RatedShipmentDetails';
    public static final STRING SHIPMENTRATEDETAIL='ShipmentRateDetail';
    public static final STRING PAYORLISTPACKAGE='PAYOR_LIST_PACKAGE';
    public static final STRING TOTALNETCHARGEWITHOUT='TotalNetChargeWithDutiesAndTaxes';
    public static final STRING AMOUNT='Amount';
    public static final STRING RATETYPE='RateType';
    public static final STRING SERVICETYPE='ServiceType';
    public static final INTEGER Max_USPS_QUANTITY=25;
    public static final STRING USPS_QUANTITY_ERROR_MESSAGE='Sorry, we can ship maximum of ('+Max_USPS_QUANTITY+') quantity in an order. Please choose "Pick up at Dealer" to proceed further.';
    public static final INTEGER Max_UPS_QUANTITY=25;
    public static final STRING UPS_QUANTITY_ERROR_MESSAGE='Sorry, we can ship maximum of ('+Max_UPS_QUANTITY+') quantity in an order. Please choose "Pick up at Dealer" to proceed further.';
    public static final INTEGER Max_FEDEX_QUANTITY=25;
    public static final STRING Sections='Sections';
    public static final STRING errormessage='errorMessage';
    public static final STRING errormessageForMaintainenceAPIDown = 'We are sorry, an error occurred. Please try again later.';
    public static final INTEGER STATUSCODE=200;
    public static final STRING IS_DEALER_INSTALLATION = 'isDealerInstallation';
    public static final STRING ORDER_INVOICE = 'Order Invoice';
    public static final STRING ORDER_RETURN = 'Order Return';
    public static final STRING ORDER_PLACE = 'Order Place';
    //HDMP-8617- Error handling -Below 3 variables created for this Jira ticket
    public static final STRING ERROR_TYPE='Integration';
    public static final STRING INTEGRATION_SEVERITY='Critical';
    public static final STRING INTEGRATION_ERROR_TYPE='	http api callout';
    // end of error handling changes
    public static final STRING INVOICE_OBJ = 'invoiceObj';
    public static final STRING INVOICE_ITEMS = 'invoiceItems';
    
    //For HDMP-8716 
    public static final STRING ORDER_TRAN_OBJ = 'objOrderTransaction';
    public static final STRING ORDER_TRAN_ITEMS = 'lstOrderTranItems';
   	public static final STRING DEALER_API_DOWN_MESSAGE = 'We’re experiencing technical difficulties, please try again later or select a different delivery method'; 
    public static final STRING USPS_WRONGADDRESS_ERROR_CODE = '-2147219385';
    public static final STRING VERTEX_API_DOWN_MESSAGE='We’re experiencing technical difficulties, please try again later';
}