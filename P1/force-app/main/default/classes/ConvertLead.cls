public class ConvertLead {
   

    public static void createLeadAndConvertPersonAccount() {

       
        List<Lead> leads = [
            SELECT Id, Company
            FROM Lead
            WHERE Company = NULL
            AND CreatedDate = LAST_WEEK
            AND IsConverted = false
        ];

        if (leads.isEmpty()) {
            System.debug('No unconverted leads found for this week');
            return;
        }

        
        LeadStatus convertedStatus = [
            SELECT MasterLabel
            FROM LeadStatus
            WHERE IsConverted = true
            LIMIT 1
        ];

        
        for (Lead ld : leads) {
            try {
                
                                
                if (ld.Company == null) {
                    throw new AuraHandledException('Test Error: Lead has no Company, forced error for logging.');
                }

                
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(ld.Id);
                lc.setConvertedStatus(convertedStatus.MasterLabel);
                lc.setDoNotCreateOpportunity(true);

                Database.LeadConvertResult result = Database.convertLead(lc);

                if (!result.isSuccess()) {
                    
                    AuraHandledException ex = new AuraHandledException(result.getErrors()[0].getMessage());
                    ErrorLog.logError(ex);
                } else {
                    System.debug('Lead converted successfully | LeadId: ' + ld.Id);
                }

            } catch (Exception e) {
                
                ErrorLog.logError(e);

               
                System.debug('Error converting lead ' + ld.Id + ': ' + e.getMessage());
            }
        }
    }


}