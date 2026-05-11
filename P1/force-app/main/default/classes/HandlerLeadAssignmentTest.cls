@IsTest
public class HandlerLeadAssignmentTest {

    @IsTest
    static void testJaipurLeadAssignmentViaTrigger() {

        
        Profile p = [
            SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1
        ];

        User u1 = new User(
            Alias = 'u1',
            Email = 'u1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            UserName = 'u1' + System.currentTimeMillis() + '@test.com'
        );

        User u2 = new User(
            Alias = 'u2',
            Email = 'u2@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            UserName = 'u2' + System.currentTimeMillis() + '@test.com'
        );

        insert new List<User>{ u1, u2 };

       
        Lead__c cs = new Lead__c();
        cs.SetupOwnerId = UserInfo.getOrganizationId();
        cs.User_Id__c = u1.Id + ',' + u2.Id;
        cs.Counter__c = 0;
        insert cs;

       
        List<Lead> leads = new List<Lead>{
            new Lead(LastName='Lead1', Company='Test', City='Jaipur'),
            new Lead(LastName='Lead2', Company='Test', City='Jaipur')
        };

        Test.startTest();
            insert leads; 
        Test.stopTest();

       
        List<Lead> insertedLeads = [
            SELECT OwnerId FROM Lead WHERE Id IN :leads
        ];

        System.assertEquals(u1.Id, insertedLeads[0].OwnerId);
        System.assertEquals(u2.Id, insertedLeads[1].OwnerId);

        
        Lead__c updatedCS = Lead__c.getOrgDefaults();
        System.assertEquals(2, updatedCS.Counter__c);
    }
}