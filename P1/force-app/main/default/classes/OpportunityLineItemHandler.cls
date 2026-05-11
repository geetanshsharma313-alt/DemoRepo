public class OpportunityLineItemHandler {
    Public static void updateGrandParent(List<OpportunityLineItem> itemList){
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        List<Account> accList = new List<Account>();
        
        for(OpportunityLineItem oli : itemList){
            if(oli.OpportunityId!= Null){
                oppIdSet.add(oli.OpportunityId);
            }
            
        }
        
        if(oppIdSet.size()> 0){
            List<Opportunity> oppList = [SELECT Id , accountId FROM Opportunity WHERE ID IN : oppIdSet ];
            if(oppList.size()>0){
                for(Opportunity opp : oppList){
                    if(opp.accountId != Null){
                        accIdSet.add(opp.accountId);
                    }
                }
            }
        }
        
           Map<Id,INTEGER> accountMap = new Map<Id, INTEGER>();
           List<Opportunity> opportunityList = [SELECT Id , accountId, (SELECT Id FROM OpportunityLineItems)
                                                FROM Opportunity WHERE AccountId IN : accIdSet];
           for(Opportunity op : opportunityList){
               if(accountMap.ContainsKey(op.AccountId)){
                   accountMap.Put(op.AccountId, accountMap.get(op.AccountId) + op.OpportunityLineItems.size());
               }else{
                   accountMap.Put(op.AccountId,op.OpportunityLineItems.size());
               }
            
        }
        if(accountMap.size()>0){
            for(Account acc : [SELECT Id , 	Number_Of_OLI__c FROM Account WHERE Id IN : accountMap.KeySet()]){
                acc.Number_Of_OLI__c = accountMap.get(acc.Id);
                accList.add(acc);
            }
        }
        if(accList.size()>0){
            try{
                update accList;
            }catch(exception e){
                System.Debug('error message+'+ e.getMessage());
                
            }
        }
            
        }
    }