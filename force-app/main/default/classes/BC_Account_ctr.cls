public with sharing class BC_Account_ctr {

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name, Phone, 
        Industry, BillingStreet, Rating FROM Account
        ORDER BY CreatedDate ASC LIMIT 10];
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts2(){
        try {
            return [SELECT Id, Name, Phone, Industry, BillingStreet FROM Account Where Phone != null and Industry != null and BillingStreet != null];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<Account> getAccountByIndustry(String Industry) {
        try {
            return [SELECT Id, Name, Industry FROM Account
                    Where Industry = :Industry 
                    order by Name DESC
                    ];
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<Account> searchAccount(String serachKey) {
        return [SELECT Id, Name, BillingStreet, Industry, Phone  FROM Account Where Name LIKE :'%'+serachKey+'%' Limit 10];
    }
}