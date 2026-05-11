public class AccountTriggerHandler {

    public static void handleAfterInsert(List<Account> accList){

        Set<Id> accIds = new Set<Id>();

        for(Account acc : accList) {
            accIds.add(acc.Id);
        }

        if(!accIds.isEmpty()) {

            System.enqueueJob(new QBOCustomerQueueable(accIds));
        }
    }
}