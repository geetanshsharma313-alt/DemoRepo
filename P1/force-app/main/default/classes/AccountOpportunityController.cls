public class AccountOpportunityController {
    

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String searchKey) {
        return [
            SELECT Id, Name,
                   (SELECT Id FROM Opportunities)
            FROM Account
            WHERE Name LIKE :('%' + searchKey + '%')
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(String searchKey) {
        return [
            SELECT Id, Name, AccountId, Account.Name
            FROM Opportunity
            WHERE Name LIKE :('%' + searchKey + '%')
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];
    }

    @AuraEnabled
    public static void linkOpportunities(Map<Id, Id> oppAccountMap) {
        List<Opportunity> opps = new List<Opportunity>();

        for (Id oppId : oppAccountMap.keySet()) {
            opps.add(new Opportunity(
                Id = oppId,
                AccountId = oppAccountMap.get(oppId)
            ));
        }
        update opps;
    }
}