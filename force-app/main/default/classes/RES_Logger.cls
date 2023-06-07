/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 03-30-2022
 * @last modified by  : mbunch@gorillagroup.com
**/

@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class RES_Logger {

    private static LoggingLevel logLevel = LoggingLevel.ERROR ;
    @TestVisible 
    private static List<Res_Log__c> logRecords ;

    static {
        try {
            if ( !RES_Settings.getSettings().Enable_Logging__c )
            {
                logLevel = LoggingLevel.NONE ;
            }
            else {
                logLevel = LoggingLevel.valueOf(RES_Settings.getSettings().Logging_Level__c)  ;
            }
        }
        catch(Exception e)
        {
            logLevel = LoggingLevel.ERROR ;
        }
        logRecords = new List<RES_Log__c>() ;
    }

    public static void Log(String message)
    {
        log(logLevel, message, false) ;
    }

    public static void Log(LoggingLevel level, String message)
    {
        Log(level, message, false) ;
    }

    public static void Log(LoggingLevel level, String message, Boolean isInCallout)  {
        log(level, message, null, null, null, null, isInCallout) ;
    }
    
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static void log(LoggingLevel level, String message, String className, String reservationId, String label, Exception innerEx, Boolean isInCallout)
    {
        try {
            if ( logLevel == LoggingLevel.NONE || level.ordinal() < logLevel.ordinal() )
            {
                return ;
            }
            RES_Log__c logRec = new Res_Log__c(Log_data__c = message, Level__c = String.valueof(level) , Reservation__c = reservationId , Component__c = className, Label__c = label, 
                                                Line__c = innerEx?.getLineNumber(), StackTrace__c = innerEx?.getStackTraceString(), InnerMessage__c = innerEx?.getMessage()) ;
            if ( isInCallout )
            {
                logRecords.add(logRec) ;
            }
            else {
                insert logRec ;
            }
        }
        catch(Exception e){ //NOPMD
            // don't throw while logging
        }
        System.debug(level, message) ;
    }

    public static void logException(Exception e){
        log(LoggingLevel.ERROR,e.getMessage(),null,null,'Exception',e,false) ;
    }

    public static void flush()
    {
        if ( ! logRecords.isEmpty())
        {
            insert logRecords ;
            logRecords.clear() ;
        }
    }

}