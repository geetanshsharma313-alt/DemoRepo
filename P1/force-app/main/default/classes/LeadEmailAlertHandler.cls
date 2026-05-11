public class LeadEmailAlertHandler {

    public static void sendEmailToOwnerManager(List<Lead> newLeads) {

        if (newLeads == null || newLeads.isEmpty()) {
            return;
        }

        // Collect OwnerIds (only Users)
        Set<Id> ownerIds = new Set<Id>();
        for (Lead l : newLeads) {
            if (l.AnnualRevenue != null && l.AnnualRevenue > 100000 &&
                String.valueOf(l.OwnerId).startsWith('005')) {
                ownerIds.add(l.OwnerId);
            }
        }

        if (ownerIds.isEmpty()) {
            return;
        }

        // Get Owners with Managers
        Map<Id, User> ownerMap = new Map<Id, User>(
            [SELECT Id, Name, ManagerId, Manager.Email, Manager.Name
             FROM User
             WHERE Id IN :ownerIds]
        );

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Lead l : newLeads) {

            if (l.AnnualRevenue == null || l.AnnualRevenue <= 100000) {
                continue;
            }

            User owner = ownerMap.get(l.OwnerId);

            // SAFETY CHECKS (prevents 0 recipients error)
            if (owner == null ||
                owner.ManagerId == null ||
                owner.Manager.Email == null) {
                continue;
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ owner.Manager.Email });
            mail.setSubject('Important Lead Generated – Immediate Attention Required');

            String body =
                'Hello ' + owner.Manager.Name + ',\n\n' +
                'An important lead has been generated and requires your attention.\n\n' +
                'Lead Details:\n' +
                '• Lead Name: ' + l.Name + '\n' +
                '• Annual Revenue: ' + l.AnnualRevenue + '\n' +
                '• Lead Owner: ' + owner.Name + '\n\n' +
                'Regards,\nSalesforce System';

            mail.setPlainTextBody(body);
            emails.add(mail);
        }

        // Send emails ONLY if recipients exist
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}