trigger OpportunityLineItemTrigger on OpportunityLineItem(before insert, before update) {
     if(Trigger.isBefore){
        if(Trigger.isInsert){
            OpportunityLineItemTriggerHandler.beforeInsertAndUpdate(Trigger.new, null);
        }
         if(Trigger.isUpdate){
            OpportunityLineItemTriggerHandler.beforeInsertAndUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}