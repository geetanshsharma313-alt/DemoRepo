global class IntuitAuthProvider extends Auth.AuthProviderPluginClass {

    global String getCustomMetadataType() {
        return null;
    }

    global PageReference initiate(Map<String,String> config, String stateToPropagate) {
        String url = 'https://appcenter.intuit.com/connect/oauth2'
            + '?client_id=' + config.get('Consumer_Key')
            + '&response_type=code'
            + '&scope=com.intuit.quickbooks.accounting openid profile email'
            + '&redirect_uri=' + EncodingUtil.urlEncode(config.get('Callback_URL'), 'UTF-8')
            + '&state=' + stateToPropagate;
        return new PageReference(url);
    }

    global Auth.AuthProviderTokenResponse handleCallback(
            Map<String,String> config, Auth.AuthProviderCallbackState callbackState) {

        Map<String,String> params = callbackState.queryParameters;
        String code = params.get('code');

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String credentials = EncodingUtil.base64Encode(
            Blob.valueOf(config.get('Consumer_Key') + ':' + config.get('Consumer_Secret')));
        req.setHeader('Authorization', 'Basic ' + credentials);
        req.setBody('grant_type=authorization_code'
            + '&code=' + code
            + '&redirect_uri=' + EncodingUtil.urlEncode(config.get('Callback_URL'), 'UTF-8'));

        Http http = new Http();
        HttpResponse res = http.send(req);
        Map<String,Object> tokenData = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

        return new Auth.AuthProviderTokenResponse(
            'IntuitAuthProvider',
            (String) tokenData.get('access_token'),
            (String) tokenData.get('refresh_token'),
            params.get('state')
        );
    }

    global Auth.UserData getUserInfo(Map<String,String> config,
            Auth.AuthProviderTokenResponse response) {
        return new Auth.UserData('intuit-user', 'QBO', 'User',
            'QBO User', 'qbo@intuit.com', null, 'qbouser',
            'en_US', 'IntuitAuthProvider', null, new Map<String,String>());
    }
}