public with sharing class BC_Ejercicio02ControlApex {

    @AuraEnabled(cacheable=true)
    public static List<Case> getCases() {
        return [SELECT Id, CaseNumber, Priority, Status, OwnerId, Origin FROM Case
        WHERE CreatedDate  = THIS_YEAR
        ORDER BY CreatedDate ASC LIMIT 10];
    }

    @AuraEnabled(cacheable = true)
    public static List<Case> getCasesFromAccount(String AccountId) {
        return [SELECT Id, CaseNumber, Account.Name, Account.CreatedDate FROM Case Where AccountId = :AccountId];
    }
}