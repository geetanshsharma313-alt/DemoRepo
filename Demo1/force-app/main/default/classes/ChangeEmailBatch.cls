Global class ChangeEmailBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT ID , email FROM Contact WHERE email != Null AND email Like \'%@oldcompany.com\'');
    }
    
    global Void execute(Database.BatchableContext bc , List<Contact> conList){
        List<Contact> conToUpdateList = new List<Contact>();
        for(Contact con : conList){
            if(con.email!= Null){
                String prefix = con.email.substringBefore('@');
                String UpdatedEmail = prefix + '@' + 'newDomain.com' ;
            if(con.email!= Null && con.email != UpdatedEmail){
                con.email = UpdatedEmail;
                conToUpdateList.add(con);
            }
       }
            }
             
        if(!conToUpdateList.isEmpty()){
            Database.Update(conToUpdateList, false);
        }
    }
    global void finish(Database.BatchableContext bc){
     
    }
}