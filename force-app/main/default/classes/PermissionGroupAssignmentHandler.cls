//****************************************************************************** 
// File Name:       PermissionGroupAssignmentHandler.cls
// Summary:         Apex Class for Assigning Permission Group to Honda Site Users
// Created On:      02-2-2022
// Created By:      Ravindra Ravindra (Wipro)
// Test Classes:    PermissionGroupAssignmentHandler.cls
// Data I/O:        
// Honda Jira Story: DOE-4360 Site user permissions
//===============================================================================
// Modification Log: 
//*******************************************************************************
public class PermissionGroupAssignmentHandler {
    
    @InvocableMethod (label='Assign Permission Group')
    public Static void assignPermissionGroup(List<Id> userIds){ 
    	PermissionGroupAssignmentHandler.asyncMethodForAssignment(userIds);  
    }
    
    @future
    static void asyncMethodForAssignment(List<Id> userIds) {
        PermissionSetGroup hondaSitesUserGroup = [SELECT Id,  MasterLabel FROM PermissionSetGroup where MasterLabel = 'Honda Sites User Permission Group' Limit 1];
        List<PermissionSetAssignment> assignmentList = new List<PermissionSetAssignment>();
        if(hondaSitesUserGroup.Id != NULL){
            for(Id userId : userIds){
                assignmentList.add(new PermissionSetAssignment(
                    PermissionSetGroupId = hondaSitesUserGroup.Id,
                    AssigneeId  = userId
                ));
            }
        }
        
        if(!assignmentList.isEmpty()) {
            insert assignmentList;  
        }
    }
}