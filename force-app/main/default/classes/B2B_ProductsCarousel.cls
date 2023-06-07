public without sharing class B2B_ProductsCarousel {
    
    
    @AuraEnabled(cacheable=true)
    public static Object getProducts(String categoryName, String accountId) 
    {
        
        ProductCategory cat = [select id,name from ProductCategory where name=:categoryName limit 1];
        /*List<product> products = new List<product>([select id, name from ProductCategoryProduct  ]);*/
        webstore store = [select id from webstore limit 1];
        
        HttpRequest httpRequest = new HttpRequest();
        Object response;

        httpRequest.setMethod('POST');
        httpRequest.setHeader(
            'Content-Type',
            'application/json;  charset=utf-8'
        );
        httpRequest.setEndpoint(
            'callout:ReferenceComponents/services/data/v' +
            51.0 +
            '/commerce/webstores/' +
            store.Id +
            '/search/product-search'
        );
        Map<String, Object> searchQueryMap =  new Map<String, Object>();// searchQueryMap(Map<String,Object>)JSON.deserializeUntyped(searchQuery);
      searchQueryMap.put('includePrices', true);
      searchQueryMap.put('categoryId', cat.id);
        
        //"fields": ["Name", "Description", "StockKeepingUnit", "Size__c", "Arch__c"],
        //
      //searchQueryMap.put('fields', '["id","Name", "Description", "DealerPrice__c"]');
        
      String searchQuery = JSON.serialize(searchQueryMap);

        httpRequest.setBody(searchQuery);
        system.debug('searchQuery::'+searchQuery);

        try {
            Http http = new Http();
            system.debug('request::'+httpRequest);
            HttpResponse httpResponse = http.send(httpRequest);
            Integer statusCode = httpResponse.getStatusCode();
            Set<Id> products = new set<id>();

            if (statusCode >= 200 && statusCode <= 204) { 
                response = JSON.deserializeUntyped(httpResponse.getBody());
                 system.debug(response);
            } else {
                System.debug(' httpResponse ' + httpResponse.getBody());
                throw new CalloutException(httpResponse.getBody());
            }
        } catch (System.Exception e) {
            System.debug('ERROR: ' + e);
            throw e;
        }

        return response;
    }

        
        
        
    
    
    

}