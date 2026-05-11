public with sharing class CustomReportController {
    @AuraEnabled(Cacheable= true)
    public static list<wrapperClass> getAccounts(){
        List<Account> accList = [SELECT ID , Name , Rating , (SELECT AccountId , Primary__c 
        FROM Contacts WHERE Primary__c = True LIMIT 1) , (SELECT AccountId , Name , Amount FROM Opportunities 
        ORDER BY Amount Desc Limit 1) FROM Account LIMIT 50];
        
        List<wrapperClass> wrList = new List<wrapperClass>();
        For(Account acc : accList){
        wrapperClass wc = new wrapperClass();
        wc.accountName = acc.Name;
        wc.accountRating = acc.Rating;
        wc.contactName = !acc.contacts.isEmpty() ? acc.Contacts[0].name : 'not available';
        wc.opportunityAmount = !acc.Opportunities.isEmpty() ? acc.Opportunities[0].Amount : 0;
        wrList.add(wc);

    }
    if(!wrList.isEmpty()){
        return wrList;
    }else{
        return null;
    }

    }

public class wrapperClass{
    @AuraEnabled public string accountName;
    @AuraEnabled public string accountRating;
    @AuraEnabled public string contactName;
    @AuraEnabled public Decimal opportunityAmount;
}

}