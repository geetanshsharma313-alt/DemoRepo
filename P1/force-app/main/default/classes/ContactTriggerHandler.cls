public class ContactTriggerHandler {
    Public static void contactCheck(List<Contact> conList){
        Set<Id> accId = new Set<Id>();
        if(conList!=Null){
            for(Contact con : conList){
                if(con.AccountId!=Null){
                    accId.add(con.AccountId);
                }
            }
        }
        Map<Id, Integer> contactCountMap = new Map<Id,Integer>();
        if(accId!=Null){
            for(AggregateResult ar : [SELECT AccountId , COUNT(Id) countContact
                                      FROM Contact WHERE AccountId In: accId GROUP BY AccountId]){
                contactCountMap.Put((ID)ar.get('AccountId'), (Integer)ar.get('countContact'));
            }
        }
        if(conList!=Null){
             for(Contact c : conList){
                 if(c.AccountId!=Null && contactCountMap.get(c.AccountId)>=2){
                     c.addError('Cannot Create Contacts');
                 }
            
        }
        }
       
    }
}