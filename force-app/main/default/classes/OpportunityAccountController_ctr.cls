public with sharing class OpportunityAccountController_ctr {

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunitiesByAccountId(Id accountId) {
        if (accountId == null) {
            return new List<Opportunity>();
        }
        return [SELECT Id, Name, StageName, CloseDate, Amount FROM Opportunity WHERE AccountId = :accountId];
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name, Industry, Phone, Rating FROM Account
        ORDER BY CreatedDate ASC LIMIT 12];
    }

}