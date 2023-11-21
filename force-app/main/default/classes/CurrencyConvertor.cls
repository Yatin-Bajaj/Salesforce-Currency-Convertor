public with sharing class CurrencyConvertor {
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getSymbols(){
        ExchangeAPI__mdt foreignExchangeAPIInfo= ExchangeAPI__mdt.getInstance('ForeignExchangeAPI');
        String BASE_URL = String.valueOf(foreignExchangeAPIInfo.get('API_Endpoint__c'));
        String API_KEY = String.valueOf(foreignExchangeAPIInfo.get('API_Key__c'));

        String endpoint = BASE_URL+'/symbols';
        Map<String,Object> data;
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new http();

            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setHeader('apikey', API_KEY);
            response = http.send(request);
            if(response.getStatusCode() == 200){
                System.debug('Response = '+ response);
                data = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                System.debug(data);
            }else {
                System.debug(response.getStatusCode());
                
            }
            
        } catch (Exception e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }

        return data; 
    }

    @AuraEnabled
    public static Double convertAmount(String source,Integer amount, String target){
        ExchangeAPI__mdt foreignExchangeAPIInfo= ExchangeAPI__mdt.getInstance('ForeignExchangeAPI');
        String BASE_URL = String.valueOf(foreignExchangeAPIInfo.get('API_Endpoint__c'));
        String API_KEY = String.valueOf(foreignExchangeAPIInfo.get('API_Key__c'));
        String currentDate = String.valueOf(System.today());
        String endpoint = BASE_URL +'/convert'+'?from='+source+'&to='+target+'&amount='+amount+'&date='+currentDate;
        Decimal convertedAmount;
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new http();

            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setHeader('apikey', API_KEY);
            response = http.send(request);
            if(response.getStatusCode() == 200){
                System.debug('Response = '+ response.getBody());
                Map<String,Object> convertedResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                System.debug(convertedResponse.get('result'));
                convertedAmount = (Double)convertedResponse.get('result');
                System.debug(convertedAmount);
            }else {
                System.debug(response.getStatusCode());
            }

        } catch (Exception e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());

        }
        return convertedAmount;
    }

    @AuraEnabled
    public static Double getOppAmount(String recordId){
        try {
            Opportunity opp =  [select Id,Amount from Opportunity where Id=: recordId];
            return opp.Amount;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
