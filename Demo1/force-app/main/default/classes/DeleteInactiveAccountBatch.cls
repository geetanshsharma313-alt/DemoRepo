Global class DeleteInactiveAccountBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
     String str = 'SELECT Id FROM Account WHERE isActive__c = false AND Id NOT IN ' + '(SELECT AccountId FROM Opportunity WHERE CreatedDate >= Last_N_Years:2)';
     return Database.getQueryLocator(str);
    }
    
    global Void execute(Database.BatchableContext bc , List<Account> accList){
        if(!accList.isEmpty()){
            Database.Delete(accList, False);
        }
       
    }
    global void finish(Database.BatchableContext bc){
        System.Debug('Inactive Account Got Deleted');
    }

}