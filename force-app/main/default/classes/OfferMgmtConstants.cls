//****************************************************************************** 
// File Name:       OfferMgmtConstants.cls
// Summary:         Constants class for Offer Mgmt
// Created On:      03-31-2023
// Created By:      Rama Iyer
// Test Classes:   
// Data I/O:        
// Honda Jira Story: 
//*******************************************************************************
public class OfferMgmtConstants {

    public static final String OUTBOUNDINTEGRATION = 'POSTOUTBOUNDINTEGRATION';
    /*Sales Program Code mapping */
    public static final map<string,string> SALES_PRGM_MAP_FOR_FINANCE_AND_LEASE= new map<string,string>{'CPO_Special_Finance'=>'R','CPO_Special_Lease'=>'L','CPO_Standard_Lease'=>'SL','CPO_Standard_Finance'=>'SR','New_Special_Lease'=>'L','New_Special_Finance'=>'R','New_Standard_Finance'=>'SR','New_Standard_Lease'=>'SL'};
    public static final map<string,string> SALES_PRGM_MAP_FOR_PROGRAMS=new map<string,string>{'Customer Cash'=>'CC','Loyalty-Conquest'=>'LC','Loyalty'=>'LY','Conquest'=>'CQ','Special Limited Offer'=>'SO','First Responder & Healthcare Professional Appreciation Offer'=>'FR','Loyalty-Upgrade Opportunity'=>'LU','Loyalty-Targeted Conquest'=>'LT','Upgrade Opportunity'=>'UO','Military'=>'ML','Graduate'=>'GD','No cash Offer'=>'NC','Lease Loyalty'=>'LL','HFS Lease Loyalty'=>'HL'};
    public static final map<string,string> SALES_PRGM_MAP_FOR_POWERSPORTS = new map<string,string>{'Power_Sports_AHFC'=>'R','Power_Sports_Bonus_Bucks'=>'BB','Power_Sports_Generic'=>'GA','Power_Sports_Honda_Card'=>'HC'};
    /*Sets for different offer rec type names*/
    public static final set<string> CPO_RECTYPE_NAMES = new set<string>{'CPO_Special_Finance','CPO_Special_Lease','CPO_Special_Program','CPO_Standard_Finance','CPO_Standard_Lease'};
    public static final set<string> AIG_RECTYPE_NAMES = new set<string>{'New_Special_Finance','New_Special_Lease','New_Standard_Finance','New_Special_Lease','New_Special_Program'};
    public static final set<string> PS_RECTYPE_NAMES = new set<string>{'Power_Sports_AHFC','Power_Sports_Bonus_Bucks','Power_Sports_Generic','Power_Sports_Honda_Card'};
    /*OM Integration Setting */
    public static final string STANDARDSPECIALS_INTEGRATION ='STANDARDSPECIALS_INTEGRATION';
    public static final string SPECIALS_INTEGRATION ='SPECIALS_INTEGRATION';
    /*special category mapping */
    public static final map<string,string> SPL_CATEGORY_MAP_FOR_HONDA_ACURA = new map<string,string>{'A'=>'AHFC','B'=>'AHFC'};
    public static final map<string,string> SPL_CATEGORY_MAP_FOR_PS = new map<string,string>{'Power_Sports_AHFC'=>'R','Power_Sports_Bonus_Bucks'=>'BB','Power_Sports_Generic'=>'GA','Power_Sports_Honda_Card'=>'HC'};
}