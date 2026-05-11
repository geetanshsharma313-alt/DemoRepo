public class LeadCreator {

    public static void createMultipleLeads(Integer count) {
        List<Lead> leadList = new List<Lead>();
        
        for (Integer i = 0; i < count; i++) {
            leadList.add(new Lead(
                LastName = 'Bulk Lead ' + (i + 1),
                //Company = 'Softshala',
                Status = 'Open - Not Contacted'
            ));
        }
        
        try {
            // Using Database.insert with false allows partial success if one lead fails
            Database.insert(leadList, false); 
        } catch (DmlException e) {
            System.debug('Bulk insert failed: ' + e.getMessage());
        }
    }
}