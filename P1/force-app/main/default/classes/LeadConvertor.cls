public class LeadConvertor {

    public static void createLeadandCovertPersonAccount() {
        
        // Query forleads with no company (person accounts)
        List<Lead> leads = [SELECT Id, Company FROM Lead WHERE Company = NULL AND CreatedDate = THIS_WEEK LIMIT 1];

        // Check if the list is empty
        if (leads.isEmpty()) {
            System.debug('No leads found for conversion');
            return;
        }
			
        //insert Person Lead
        
        // first lead ( only one record is returned)
        Lead leadToConvert = leads[0];

        // converted lead status
        LeadStatus convertedStatus = [
            SELECT MasterLabel
            FROM LeadStatus
            WHERE IsConverted = true
            LIMIT 1
        ];

        System.debug('Lead ID: ' + leadToConvert.Id);

        // Prepare the lead conversion
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadToConvert.Id);
        lc.setConvertedStatus(convertedStatus.MasterLabel);
        lc.setDoNotCreateOpportunity(true); // Ensure no opportunity is created

        // Convert the lead
        Database.LeadConvertResult result = Database.convertLead(lc);

        // Validate conversion
        if (!result.isSuccess()) {
            throw new AuraHandledException('Person Lead conversion failed');
        }

        System.debug('Person Account Lead created and converted successfully');
    }
}