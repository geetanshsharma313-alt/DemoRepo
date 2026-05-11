public class QBOService {

// Replace with your REALM ID
    public static final String REALM_ID = '9341457046189219';

    public static String createCustomer(Account acc){
          Http http = new Http();
          HttpRequest req = new HttpRequest();
          req.setEndpoint('callout:NamedCred2QuickBook'+ '/v3/company/'+ REALM_ID + '/customer');
          req.setMethod('POST');
          req.setHeader('Content-Type','application/json');

 // JSON BODY
        Map<String, Object> body = new Map<String, Object>();
        body.put('DisplayName', acc.Name);
        body.put('CompanyName',acc.Name);
        body.put(
            'PrimaryPhone',
            new Map<String, Object>{
                'FreeFormNumber' => acc.Phone
            }
        );
        String requestBody = JSON.serialize(body);
        req.setBody(requestBody);
        HttpResponse res = http.send(req);
        String responseBody = res.getBody();
        System.debug('Response: '+ responseBody);
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
            Map<String, Object> responseMap =(Map<String, Object>)JSON.deserializeUntyped(responseBody);
            Map<String, Object> customer =(Map<String, Object>)responseMap.get('Customer');
            return String.valueOf(customer.get('Id'));
        }
        else {
                 throw new CalloutException('Customer creation failed: '+ responseBody);
        }
    }
}