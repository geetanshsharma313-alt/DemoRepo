@IsTest
public class OpportunityLineItemHandlerTest {

    // Runs once, data reused by all test methods
    @testSetup
    static void setupData() {

        // 1️⃣ Create Account
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        // 2️⃣ Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(10),
            AccountId = acc.Id
        );
        insert opp;

        // 3️⃣ Get Standard Pricebook
        Pricebook2 stdPb = [
            SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1
        ];

        // 4️⃣ Create Product
        Product2 prod = new Product2(
            Name = 'Test Product',
            IsActive = true
        );
        insert prod;

        // 5️⃣ Create Pricebook Entry
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPb.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // 6️⃣ Create Opportunity Line Items (Trigger fires)
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        for (Integer i = 0; i < 3; i++) {
            oliList.add(new OpportunityLineItem(
                OpportunityId = opp.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                TotalPrice = 100
            ));
        }
        insert oliList;
    }

    // ✅ REAL TEST METHOD
    @IsTest
    static void testOLICountUpdatedOnAccount() {

        Test.startTest();

        Account acc = [
            SELECT Id, Number_Of_OLI__c
            FROM Account
            WHERE Name = 'Test Account'
            LIMIT 1
        ];

        Test.stopTest();

        // ✅ Assertion
        System.assertEquals(
            3,
            acc.Number_Of_OLI__c,
            'Account should have correct count of Opportunity Line Items'
        );
    }
}