trigger CaseTrigger on Case (After Update , after Insert , after Delete) {
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            CaseTriggerHandler.updateUser(Trigger.New);
        }
    }
    if(Trigger.isInsert){
        if(Trigger.isAfter){
            CaseTriggerHandler.updateAccountCaseCount(Trigger.New);
        }
    }
     if(Trigger.isDelete){
        if(Trigger.isAfter){
            CaseTriggerHandler.updateAccountCaseCount(Trigger.Old);
        }
    }

}