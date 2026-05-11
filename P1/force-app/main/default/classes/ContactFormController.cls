public with sharing class ContactFormController {

    @AuraEnabled
    public static void createContact(
        String firstName,
        String lastName,
        String phone,
        String email
    ) {
        Contact con = new Contact();

        con.FirstName = firstName;
        con.LastName  = lastName;
        con.Phone     = phone;
        con.Email     = email;

        insert con;
    }
}