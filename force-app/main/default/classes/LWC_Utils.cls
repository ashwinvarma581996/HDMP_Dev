/**
 * Created By   : Mammet Dovgeldiyev (mammet.dovgeldiyev2@wipro.com)  
 * Description  : This class is invoked from headerComponent LWC & updates the Org Platform Cache 
 * 				  with Local Ip as key with guestCartId as value
**/
public class LWC_Utils {
      @AuraEnabled(cacheable=true)
      public static String getExternalIp(String currentGuestCartId) {
          //Check if user is created before accessing the platform cache feature
          if(String.isNotBlank(currentGuestCartId) && !Auth.CommunitiesUtil.isGuestUser()){
          List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId =: currentGuestCartId];  
            if(!cartItems.isEmpty()){
                //Adding the GuestCartId to Platform Cache
                String tempKey = 'local.CartMergeCache.'+String.valueOf(Auth.SessionManagement.getCurrentSession().get('SourceIp')).replace('.','z');
                Cache.Org.put(tempKey,currentGuestCartId);
            }  
          }
          return '';
      } 
}