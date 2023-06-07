public class B2B_IntegrationUtil {
    
    public static String fetchCurrentTime(){
        Long beforeAPI = DateTime.now().getTime();
        return String.ValueOf(beforeAPI);
    }
    
    public static String calInMilliSeconds(Long beforeApi, Long afterAPI){
        Long timeDuration =(afterAPI-beforeApi);
        return String.ValueOf(timeDuration);
    }
}