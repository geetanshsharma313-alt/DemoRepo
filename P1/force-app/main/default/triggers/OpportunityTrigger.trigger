trigger OpportunityTrigger on Opportunity ( after insert,after update,after delete,after undelete, before Update){
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            OpportunityTriggerHandler.updateAccountAnnualRevenue(Trigger.new,Trigger.oldMap);
            // OpportunityTriggerHandler.createTaskAssociatedWithAccount(Trigger.new,Trigger.oldMap);
        }
        if (Trigger.isDelete){
            OpportunityTriggerHandler.updateAccountAnnualRevenue(null,Trigger.oldMap);
        }
    }
      if(Trigger.isAfter && Trigger.isUpdate){
       OpportunityTriggerHandler.createTaskAssociatedWithAccount(Trigger.new,trigger.OldMap);
    }
     if(Trigger.isBefore && Trigger.isUpdate){
        OpportunityTriggerHandler.preventAnnualRevenue(Trigger.new,trigger.OldMap);
    }
}