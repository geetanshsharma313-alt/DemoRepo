public with sharing class SearchAccountController {
    public static List<Account> searchAccount(String SearchKey) {
        if(string.isBlank(SearchKey)){
            return [SELECT ID, Name, Industry, Phone FROM Account];
        }
        
        return[SELECT ID ,Name, Industry, Phone FROM Account WHERE Name Like : ('%' + SearchKey + '%') Limit 20 ];

    }
}