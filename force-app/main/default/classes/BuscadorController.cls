public with sharing class BuscadorController {
    @AuraEnabled (cacheable=true scope='global')
    public static List<Account> getAllAccounts(){
        return [SELECT Name, Presupuesto_Total__c, Numero_de_Recursos_Totales__c FROM Account WITH SECURITY_ENFORCED LIMIT 200];
    }

    @AuraEnabled (cacheable=true scope='global')
    public static List<Account> searchAccounts(string searchTerm){
        List<Account> accountList = new List<Account>();
        if(searchTerm != ''){
            String accountName = '%' + searchTerm + '%';
            accountList = [SELECT Name, Presupuesto_Total__c, Numero_de_Recursos_Totales__c FROM Account WHERE Name LIKE :accountName WITH SECURITY_ENFORCED];
        }
        else {
            accountList = getAllAccounts();
        }
        return accountList;    
    }
}
