public with sharing class CaseAccountController_ctr {

    @AuraEnabled(cacheable=true)
    public static List<Case> getCasesByAccountId(Id accountId) {
        if (accountId == null) {
            return new List<Case>();
        }
        return [SELECT Id, CaseNumber, CreatedDate, ClosedDate FROM Case
                WHERE ClosedDate = null and CreatedDate = THIS_YEAR AND AccountId = :accountId];
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name, Industry, Phone, Rating FROM Account
        ORDER BY CreatedDate ASC LIMIT 12];
    }
}