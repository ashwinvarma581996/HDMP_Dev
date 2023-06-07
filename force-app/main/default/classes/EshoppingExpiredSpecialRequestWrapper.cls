//****************************************************************************** 
// File Name:       EshoppingExpiredRequestWrapper.cls
// Summary:         This is request wrapper class for  Special offers for Expired request
// Created On:      14-04-2023
// Created By:      Manohar 
// Test Classes:   
// Data I/O:        
// Honda Jira Story: 
//*******************************************************************************
public class EshoppingExpiredSpecialRequestWrapper {
    public cls_Special Specials; 
   
    public class cls_Special 
    { 
        public String SpecialId; //holds header Id
        public String Action;// holds Delete flag
    }
}