public with sharing class ApexContactController {
    @AuraEnabled(cacheable=true)
   
    public static List<Contact> getContacts() {
        return [SELECT Id, FirstName, LastName, Email FROM Contact Limit 10];

    }
}