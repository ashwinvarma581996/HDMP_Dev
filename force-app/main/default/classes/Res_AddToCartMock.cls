/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 09-25-2021
 * @last modified by  : mbunch@gorillagroup.com
**/
@IsTest
public with sharing class Res_AddToCartMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
//        Sting url = req.getEndpoint() ;
  //      pattern myPattern = pattern.compile('/carts\\/([a-zA-Z0-9]{18})\\/cart-items/gm'); 
    //    matcher myMatcher = myPattern.matcher(url);
     //   String cartId = myMatcher.group(1);

       // Map<String,Object payload = JSON.deserializeUntyped(req.getBody()) ;

      //  CartItem ci = new CartItem();
      //  ci.Type = 'Product';
      //  ci.cartId = cartId;
      //  ci.Product2Id = (String)payload.get('productId');
      //  ci.Quantity = (String)payload.quantity;
      //  insert ci;
        return new HttpResponse() ;
    }
}