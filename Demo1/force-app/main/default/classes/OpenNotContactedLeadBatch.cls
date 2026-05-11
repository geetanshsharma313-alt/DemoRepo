global class OpenNotContactedLeadBatch implements Database.Batchable<sObject>{
     global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Name, LastModifiedDate FROM Lead WHERE Status = \'Open - Not Contacted\' AND LastModifiedDate = LAST_N_DAYS:30 ');
    }
     global Void execute(Database.BatchableContext bc ,List<Lead> lList){
       List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
          for(Lead l : lList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{l.Email});
            mail.setSubject('Follow up reminder emil');
            mail.setPlainTextBody('Hi '+l.Name+ ',\n follow up Email Message for you');
            emails.add(mail);
        }
         if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
            
    global void finish(Database.BatchableContext bc){
     
    }
 }