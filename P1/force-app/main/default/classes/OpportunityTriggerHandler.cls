public class OpportunityTriggerHandler {

    public static void updateAccountAnnualRevenue(List<Opportunity> oppList, Map<Id,Opportunity> oldMap) {
        Set<Id> accountIds = new Set<Id>();

        
        if (oppList != null) {
            for (Opportunity opp : oppList) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                   
                }
            }
        }

        
        if (oldMap != null) {
            for (Opportunity opp : oldMap.Values()) {
                if (opp.AccountId != oldMap.get(opp.Id).AccountId){
                    accountIds.add(opp.AccountId);
                    accountIds.add(oldMap.get(opp.Id).AccountId); 
                    
                }
                else{
                    accountIds.add(opp.AccountId);
                    
                    }
            }
        }

        if (accountIds.isEmpty()) return;

        Map<Id, Account> accMap = new Map<Id, Account>();
        for (AggregateResult ar : [SELECT AccountId accId, SUM(Amount) totalAmount FROM Opportunity
                                   WHERE AccountId IN :accountIds
                                   GROUP BY AccountId])
        {
            Account acc = new Account();
            acc.Id = (Id)ar.get('accId');
            acc.AnnualRevenue = (Decimal)ar.get('totalAmount');
            accMap.Put(acc.Id,acc);
            
            
        }
        
        if (!accMap.isEmpty()) {
            update accMap.Values();
            
        }
    

}
    public static void createTaskAssociatedWithAccount(List<Opportunity> OppNewList,  Map<Id,Opportunity> oppOldMap){
        Set<Id>AccId = new Set<Id>();
        for(Opportunity opp : OppNewList){
            if(opp.accountId != null && opp.StageName != oppOldMap.get(opp.id).StageName && opp.StageName =='Closed Won' ){
                AccId.add(opp.accountId);
                if(opp.accountId != oppOldMap.get(opp.id).accountId && oppOldMap.get(opp.id).accountId  != null ){
                    AccId.add(oppOldMap.get(opp.id).accountId);
                    System.debug('6');
                }
            }
        }
        if(!AccId.isEmpty()){
            
            List<AggregateResult> OppAGR = [SELECT count(Id), AccountId FROM Opportunity 
                                            WHERE CloseDate =LAST_N_DAYS:30 AND AccountId IN:AccId 
                                            AND StageName = 'Closed Won'  
                                            GROUP BY accountId HAVING count(id)>=3];
            
            Map<Id,Account > accMap = new Map <Id, Account>([SELECT Id,Account.OwnerId,Description 
                                                             FROM Account WHERE Id In :AccId ]);
            
            List<Task> tasks = [SELECT Id , WhatId ,subject FROM Task WHERE CreatedDate = LAST_N_DAYS:30 
                                AND WhatId IN : AccId 
                                AND subject ='Review Rapid Revenue Growth'];
            
            Set<Id> AlreadyTaskAccount = new Set<Id>();
            if(!tasks.isEmpty()){
               
                
                for(task tsk : tasks){
                    AlreadyTaskAccount.add(tsk.WhatId);
                    
                } 
            }
            
            if(!OppAGR.isEmpty()){
                List <Account> toUpdateAccount = new List<account>();
                List <Task> toInsertTask = new List<Task>();
                
                for(AggregateResult agr : OppAGR ){
                    if(accMap.get((Id)agr.get('AccountId')).Description != 'High Revenue Velocity Account'){
                    Account acc = new account();
                    acc.Id = (Id)agr.get('AccountId');
                    acc.Description='High Revenue Velocity Account';
                    toUpdateAccount.add(acc);
                       
                    }
                    if(!AlreadyTaskAccount.contains((Id)agr.get('AccountId'))){
                        
                        Task t = new Task();
                        t.Subject = 'Review Rapid Revenue Growth';
                        t.WhatId = (Id)agr.get('AccountId');
                        t.OwnerId = accMap.get((Id)agr.get('AccountId')).ownerId;
                        t.Priority = 'High';
                        t.Status = 'Not Started';
                        t.ActivityDate = Date.today().addDays(1);
                        toInsertTask.add(t);
                       
                        }
                    
                    
                }
                
                if(!toUpdateAccount.isEmpty()){
                    Update toUpdateAccount;
                    
                }
                if(!toInsertTask.isEmpty()){
                    Insert toInsertTask;
                    
                }
                
            }
            
        }
}
    
    public static void preventAnnualRevenue(List<Opportunity>OppNewList ,Map<id,Opportunity> oppOldMap){
        Set<Id>AccId = new Set<Id>();
        for(Opportunity opp : OppNewList){
            if(opp.accountId != null && opp.StageName != oppOldMap.get(opp.id).StageName && opp.StageName =='Closed Won' ){
                AccId.add(opp.accountId);
                
            }
        }
        
        if(!AccId.isEmpty()){
            Map<Id , Decimal> AccountAndAmount = new Map <Id ,Decimal>();
            List<AggregateResult> agrOpp = [SELECT AccountId, SUM(Amount)total FROM Opportunity WHERE StageName = 'Closed Won' AND CloseDate = THIS_FISCAL_YEAR AND AccountId IN :AccId GROUP BY AccountId];
            if(!agrOpp.isEmpty()){
                for(AggregateResult agr : agrOpp){
                    AccountAndAmount.put((Id)agr.get('AccountId') ,(Decimal)agr.get('total')); 
                }
            }
           
            
            for(Opportunity opp :OppNewList){
                
               
                    DECIMAL var = AccountAndAmount.containsKey(opp.AccountId)? AccountAndAmount.get(opp.AccountId) : 0;
                     AccountAndAmount.put(opp.AccountId ,var+opp.Amount);                  
                system.debug(var);
                 system.debug(AccountAndAmount);
                
                                 
                if(AccountAndAmount.get(opp.AccountId) > 10000000){
                    opp.addError('Revenue threshold exceeded. Finance approval required');
                }
            }        
        }             
    }   
    
}