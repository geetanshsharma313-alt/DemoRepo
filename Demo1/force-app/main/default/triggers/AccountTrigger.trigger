Trigger AccountTrigger on Account(Before Update){
 
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
           AccountTriggerHandler.BeforeUpdate(Trigger.New , Trigger.oldMap);
         
  }
 }
}