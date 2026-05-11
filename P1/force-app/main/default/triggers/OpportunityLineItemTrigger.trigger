trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert,after delete,after undelete){
    if (Trigger.isAfter) {

        if (Trigger.isInsert || Trigger.isUndelete) {
            OpportunityLineItemHandler.updateGrandParent(Trigger.new);
        }

        if (Trigger.isDelete) {
            OpportunityLineItemHandler.updateGrandParent(Trigger.old);
        }
    }
}