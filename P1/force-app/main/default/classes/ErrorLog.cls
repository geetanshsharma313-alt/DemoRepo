public class ErrorLog {

    public static void logError(Exception e) {
        try {
            Error_Log_Detail__c log = new Error_Log_Detail__c();
            log.Error__c = e.getMessage();
            log.Occured_On__c= System.now();
            insert log;
        } catch (Exception ex) {
          
            System.debug('Error while saving error log: ' + ex.getMessage());
        }
    }
}