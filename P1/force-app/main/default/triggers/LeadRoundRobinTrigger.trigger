trigger LeadRoundRobinTrigger on Lead (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        HandlerLeadAssignment.assignLeads(Trigger.new);
    }
}