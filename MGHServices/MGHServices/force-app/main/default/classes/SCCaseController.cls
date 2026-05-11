public with sharing class SCCaseController {
    
    @AuraEnabled
    public static String createCase(Case caseRecord){
        try {
            //Enable assignment rules
            Database.DMLOptions dmlOpts = new Database.DMLOptions();  
            dmlOpts.assignmentRuleHeader.useDefaultRule = TRUE;
            caseRecord.setOptions(dmlOpts);
            caseRecord.Origin = 'Web'; 
            
            Id userId = UserInfo.getUserId(); 
            
            List<User> currentUser = [SELECT Id, Contact.AccountId FROM User WHERE Id =: userId];
            
            if(currentUser != NULL && !currentUser.isEmpty() && currentUser[0].ContactId != NULL && currentUser[0].Contact.AccountId != NULL) {
                List<Entitlement> entRecords = [SELECT Id FROM Entitlement 
                                                WHERE AccountId =: currentUser[0].Contact.AccountId 
                                                AND Status ='Active' AND Type = 'Web Support' LIMIT 1];
                
                if(entRecords != NULL && !entRecords.isEmpty()) {
                    caseRecord.EntitlementId = entRecords[0].Id;
                }
            }
          
            insert as user caseRecord;
            return 'success';
        } catch ( Exception e ) {
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static List<Case> getMyCases(){
        
        List<Case> caseList = [
            SELECT Id, CaseNumber, Subject, Status, Priority, CreatedDate, IsEscalated, IsClosed, 
            (SELECT Id, CommentBody, CreatedDate, CreatedBy.Name FROM CaseComments ORDER BY LastModifiedDate desc) FROM Case 
            WHERE CreatedBy.Id =: UserInfo.getUserId() WITH USER_MODE ORDER BY LastModifiedDate desc
        ];
        
        if(caseList != NULL && !caseList.isEmpty()) {
            return caseList;
        }
        return NULL;
    }
    
    
}