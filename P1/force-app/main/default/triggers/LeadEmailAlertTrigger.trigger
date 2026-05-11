trigger LeadEmailAlertTrigger on Lead (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        LeadEmailAlertHandler.sendEmailToOwnerManager(Trigger.new);
    }
}