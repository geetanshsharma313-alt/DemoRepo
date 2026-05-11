public class OpportunityLineItemTriggerHandler {
  public static void beforeInsertAndUpdate(List<OpportunityLineItem> lineItems,Map<Id, OpportunityLineItem> oldLineItemMap){
        Set<Id> productIds = new Set<Id>(), opportunityIds = new Set<Id>();
         for(OpportunityLineItem li : lineItems){
            if(li.Product2Id != null) productIds.add(li.Product2Id);
            if(li.OpportunityId != null) opportunityIds.add(li.OpportunityId);
        }
  Map<Id, Product2> productStockMap = new Map<Id, Product2>([SELECT Available_Stock__c FROM Product2 WHERE Id IN :productIds]);
  Map<Id, Decimal> total = new Map<Id, Decimal>();
      for(OpportunityLineItem oppLi : [SELECT Product2Id, Quantity FROM OpportunityLineItem WHERE OpportunityId IN :opportunityIds]){
        if(oppLi.Product2Id != null && oppLi.Quantity != null)
         total.put(oppLi.Product2Id,(total.containsKey(oppLi.Product2Id) ? total.get(oppLi.Product2Id) : 0)+ oppLi.Quantity);
        }
    for(OpportunityLineItem li : lineItems){
     if(li.Product2Id == null || li.Quantity == null) continue;
     Decimal previousQuantity = (oldLineItemMap != null && oldLineItemMap.containsKey(li.Id) && oldLineItemMap.get(li.Id).Quantity != null)
                             ? oldLineItemMap.get(li.Id).Quantity : 0;
     total.put(li.Product2Id,(total.containsKey(li.Product2Id) ? total.get(li.Product2Id) : 0)- previousQuantity + li.Quantity);
        }
      for(OpportunityLineItem li : lineItems){
            Product2 p = productStockMap.get(li.Product2Id);
            if(p != null && p.Available_Stock__c != null &&
               total.get(li.Product2Id) > p.Available_Stock__c){
                   li.addError('Insufficient Stock. Available: ' + p.Available_Stock__c);
            }
        }
    }
}