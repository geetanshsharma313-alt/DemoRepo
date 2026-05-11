trigger UserTrigger on User (before update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        UserTriggerHandler.preventLastRoleUserDeactivation( Trigger.new,Trigger.oldMap);
    }
}