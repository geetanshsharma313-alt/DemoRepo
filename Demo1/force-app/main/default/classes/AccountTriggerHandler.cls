public class AccountTriggerHandler{
  public static void BeforeUpdate(List<Account> accList ,Map<Id, Account> oldMap){
     Set<Id> accId = new Set<Id>();
      for(Account acc : accList){
        accId.add(acc.Id);
  }
  Map<Id, Decimal> conCountMap = new Map<Id, Decimal>();
    if(!accId.isEmpty()){
      for(AggregateResult ar : [SELECT AccountId Id , COUNT(Id) Size FROM Contact WHERE AccountId IN : accId Group By AccountId]){
         conCountMap.Put((Id)ar.get('Id') , (Decimal)ar.get('Size'));
          }
     } 
  For(Account acc : accList){
     if(!conCountMap.isEmpty() && conCountMap.get(acc.Id)>=5 ){
                acc.addError('Cannot edit field');
      }
  }
 }
}