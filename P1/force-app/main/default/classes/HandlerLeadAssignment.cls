public class HandlerLeadAssignment {

    public static void assignLeads(List<Lead> newLeads) {

        if (newLeads == null || newLeads.isEmpty()) {
            return;
        }

       
        List<Lead> jaipurLeads = new List<Lead>();
        for (Lead l : newLeads) {
            if (l.City != null && l.City == 'Jaipur') {
                jaipurLeads.add(l);
            }
        }

        if (jaipurLeads.isEmpty()) {
            return;
        }

       
        Lead__c cs = Lead__c.getOrgDefaults();

        if (cs == null || String.isBlank(cs.User_Id__c)) {
            return;
        }

       
        List<String> userList = cs.User_Id__c.split(',');

        if (userList.isEmpty()) {
            return;
        }

        
        Integer counter = cs.Counter__c == null ? 0 : Integer.valueOf(cs.Counter__c);

      
        for (Lead l : jaipurLeads) {

            Integer index = Math.mod(counter, userList.size());
            String userIdStr = userList[index].trim(); // 🔥 IMPORTANT

            try {
                
                l.OwnerId = Id.valueOf(userIdStr);
                counter++;
            } catch (Exception e) {
               
                System.debug('Invalid User Id in Custom Setting: ' + userIdStr);
            }
        }

        
        cs.Counter__c = counter;
        update cs;
    }
}