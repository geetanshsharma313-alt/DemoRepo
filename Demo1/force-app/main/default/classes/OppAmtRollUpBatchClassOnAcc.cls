global class OppAmtRollUpBatchClassOnAcc implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator('SELECT ID FROM Account');
    }
     global Void execute(Database.BatchableContext bc , List<Account> accList){
      Set<Id> accId = new Set <ID>();
         For(Account acc : accList){
             accId.add(acc.Id);
         }
      Map<Id, Decimal> oppAmtMap = new Map<Id, Decimal>();
      List<Account> updateAccList = new List<Account>();
      For(AggregateResult ar : [SELECT AccountId id , Sum(Amount) amt FROM Opportunity 
                                WHERE StageName = 'Closed Won' And AccountId In : accId Group By AccountId
                               ]){
                              oppAmtMap.put((Id)ar.get('id'), (Decimal)ar.get('amt'));    
 }
         For(Account acc : accList){
             Decimal Amount = oppAmtMap.ContainsKey(acc.Id) ? oppAmtMap.get(acc.Id) : 0;
             acc.Total_Won_Amount__c = Amount;
             updateAccList.add(acc);
  }
         System.Debug('Batch Ran Successfully');
         if(!updateAccList.isEmpty()){
               Database.update(updateAccList, False);
         }
          System.Debug(' Alpha Batch Ran Successfully');
    }
     global Void finish(Database.BatchableContext bc){
        
    }
}