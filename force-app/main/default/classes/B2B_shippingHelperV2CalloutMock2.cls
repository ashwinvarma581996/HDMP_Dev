/**********************************************************************
Name: B2B_shippingHelperV2CalloutMock2
-------------------------------------------------------------------------
Purpose: This class is used send mock response to UPSS.USPs shipping calculations.
@version : 54.0
@created Date : 26/05/2022
@Created By : Saikiran velugundula <sa40135127@wipro.com>
@modified
*************************************************************/
@isTest
global class B2B_shippingHelperV2CalloutMock2 implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
       HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/xml');
        String reqBody = request.getBody();
        if(reqBody.contains('RateV4&XML=')){
            string body = '<?xml version="1.0" encoding="UTF-8"?><RateV4Response><Package ID="0"><ZipOrigination>22201</ZipOrigination><ZipDestination>22201</ZipDestination><Pounds>70</Pounds><Ounces>0</Ounces><Machinable>FALSE</Machinable><Zone>1</Zone><Postage CLASSID="3"><MailService>Priority Mail Express 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt;</MailService><Rate>184.30</Rate></Postage><Postage CLASSID="2"><MailService>Priority Mail Express 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Hold For Pickup</MailService><Rate>184.30</Rate></Postage><Postage CLASSID="13"><MailService>Priority Mail Express 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Flat Rate Envelope</MailService>';
            body+='<Rate>26.35</Rate></Postage><Postage CLASSID="27"><MailService>Priority Mail Express 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Flat Rate Envelope Hold For Pickup</MailService>';
            body+='<Rate>26.35</Rate></Postage><Postage CLASSID="30"><MailService>Priority Mail Express 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Legal Flat Rate Envelope</MailService><Rate>26.50</Rate></Postage><Postage CLASSID="31"><MailService>Priority Mail Express 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Legal Flat Rate Envelope Hold For Pickup</MailService><Rate>26.50</Rate></Postage><Postage CLASSID="62"><MailService>Priority Mail Express 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Padded Flat Rate Envelope</MailService>';
            body+='<Rate>26.95</Rate></Postage><Postage CLASSID="63"><MailService>Priority Mail Express 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Padded Flat Rate Envelope Hold For Pickup</MailService>';
            body+='<Rate>26.95</Rate></Postage><Postage CLASSID="1"><MailService>Priority Mail 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt;</MailService><Rate>49.00</Rate></Postage><Postage CLASSID="22"><MailService>Priority Mail 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Large Flat Rate Box</MailService><Rate>21.90</Rate></Postage><Postage CLASSID="17"><MailService>Priority Mail 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Medium Flat Rate Box</MailService><Rate>15.50</Rate></Postage><Postage CLASSID="16"><MailService>Priority Mail 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Flat Rate Envelope</MailService><Rate>7.95</Rate></Postage><Postage CLASSID="44"><MailService>Priority Mail 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Legal Flat Rate Envelope</MailService><Rate>8.25</Rate></Postage><Postage CLASSID="29"><MailService>Priority Mail 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Padded Flat Rate Envelope</MailService><Rate>8.55</Rate></Postage><Postage CLASSID="38"><MailService>Priority Mail 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Gift Card Flat Rate Envelope</MailService><Rate>7.95</Rate></Postage><Postage CLASSID="40"><MailService>Priority Mail 1-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt; Window Flat Rate Envelope</MailService><Rate>7.95</Rate></Postage><Postage CLASSID="6"><MailService>Media Mail Parcel</MailService><Rate>46.66</Rate></Postage><Postage CLASSID="7"><MailService>Library Mail Parcel</MailService><Rate>44.43</Rate></Postage></Package></RateV4Response>';
         	response.setStatusCode(404);
            response.setBody(body); 
            
        }
         return response;
    }
}