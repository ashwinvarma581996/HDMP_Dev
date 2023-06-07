//****************************************************************************** 
// File Name:       EshoppingExpiredRequestWrapper.cls
// Summary:         This is request wrapper class for Standard Special offers for Expired request
// Created On:      14-04-2023
// Created By:      Manohar 
// Test Classes:   
// Data I/O:        
// Honda Jira Story: 
//*******************************************************************************
public class EshoppingExpiredRequestWrapper {
    public cls_StandardSpecial StandardSpecial;
   
    public class cls_StandardSpecial  
    {
        public String StandardSpecialId; //holds header id
        public String Action; // holds Delete flag
    }
}