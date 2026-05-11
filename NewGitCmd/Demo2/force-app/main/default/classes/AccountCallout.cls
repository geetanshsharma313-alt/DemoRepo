public class AccountCallout {
    
    // INSERT Accounts Into Target Org
    public static void sendAccounts(List<Account> accountJSON) {
        
        String requestBody = JSON.serialize(accountJSON);

        String targetEndpoint =
            'callout:NamedCred3/services/apexrest/AccountInt';

        HttpRequest req = new HttpRequest();

        req.setEndpoint(targetEndpoint);

        req.setMethod('POST');

        req.setHeader(
            'Authorization',
            'Bearer ' + UserInfo.getSessionId()
        );

        req.setHeader('Content-Type', 'application/json');

        System.debug('accountsJson=====>' + requestBody);

        req.setBody(requestBody);

        Http http = new Http();

        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {

            System.debug(
                'Error sending accounts: ' + res.getBody()
            );

        } else {

            System.debug(
                'Accounts sent successfully:' + res.getBody()
            );
        }
    }


    // DELETE Accounts From Target Org
    public static void deleteAccounts(List<Id> accountIds) {

        HttpRequest req = new HttpRequest();

        req.setEndpoint(
            'callout:SalesforceNewNamedCred/services/apexrest/DeleteAccount'
        );

        req.setMethod('DELETE');

        req.setHeader('Content-Type', 'application/json');

        req.setBody(JSON.serialize(accountIds));

        Http http = new Http();

        HttpResponse res = http.send(req);

        System.debug(
            'Delete Response ===> ' + res.getBody()
        );
    }
}



// Apex called