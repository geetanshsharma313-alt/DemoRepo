public class CaseTriggerHandler {
    public static void updateUser(List<Case> csList){
        Set<Id> userId = new Set<Id>();
        for(Case cs : csList){
            if(cs.OwnerId != Null){
                userId.add(cs.OwnerId);
            }
            
        }
        if(userId.isEmpty())return;
        Map<Id, Integer> totalCaseCount = new Map<Id, Integer>();
        Map<Id, Integer> closedCaseCount = new Map<Id, Integer>();
        
        List<Case> allCaseList = new List<Case>([SELECT OwnerId , Status 
                                                 FROM Case 
                                                 WHERE OwnerId IN : userId 
                                                 ]);
        
        for(Case c : allCaseList){
             if (!totalCaseCount.containsKey(c.OwnerId)) {
                totalCaseCount.put(c.OwnerId, 0);
                closedCaseCount.put(c.OwnerId, 0);
             }else{
                  totalCaseCount.put(c.OwnerId, totalCaseCount.get(c.OwnerId) + 1);
             }
            if (c.Status == 'Closed') {
                closedCaseCount.put(c.OwnerId, closedCaseCount.get(c.OwnerId) + 1);
            }
            
        }
         List<User> usersToUpdate = new List<User>();

        for (Id userIds : totalCaseCount.keySet()) {
            if (totalCaseCount.get(userIds) == closedCaseCount.get(userIds)) {
                User u = new User();
                u.Id = userIds;
                u.IsAvailable__c = true;
                usersToUpdate.add(u);
            }
        }
         if (!usersToUpdate.isEmpty()) {
            update usersToUpdate;
        }
        
}
    public static void updateAccountCaseCount(List<Case> csList){
      Set<Id> accId = new Set<Id>();
        if(csList!=Null){
            for(Case cs : csList){
                if(cs.AccountId != Null){
                    accId.add(cs.AccountId);
                }
            }
        }
        List<Account> accList = [SELECT Id , Total_Case_Count__c , (SELECT Id FROM Cases) FROM Account
                                WHERE Id IN : accId];
        if(accList!=Null){
             for(Account acc : accList){
                 acc.Total_Case_Count__c = acc.Cases.Size();
        }
            
        }
        if(accList!=Null){
            Update accList;
        }
        
       
    }  
    
    
    
    
    
    
    
    
    
    
    
    
    

}