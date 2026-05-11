trigger ContactTrigger on Contact (before insert , after insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        ContactTriggerHandler.contactCheck(Trigger.New);
    }
    
}