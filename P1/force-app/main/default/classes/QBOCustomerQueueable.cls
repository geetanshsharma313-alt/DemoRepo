public class QBOCustomerQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> accIds;

    public QBOCustomerQueueable(Set<Id> accIds){
        this.accIds = accIds;
    }

    public void execute(QueueableContext qc) {

        List<Account> accList = [SELECT Id,Name,Phone,BillingCity,QBO_Customer_ID__c FROM Account WHERE Id IN :accIds];

        List<Account> updateAccounts =  new List<Account>();

        for(Account acc : accList){

            try{

                String customerId = QBOService.createCustomer(acc);

                acc.QBO_Customer_ID__c =customerId;

            }catch(Exception e){

                System.debug('QBO Error: ' + e.getMessage());
            }

            updateAccounts.add(acc);
        }

        if(!updateAccounts.isEmpty()) {
            update updateAccounts;
        }
    }
}