public with sharing class AccountTriggerHandler {

    public static void handAfterInsert(List<Account> newAccounts) {
        if (newAccounts == null || newAccounts.isEmpty()) {
            return;
        }
        CarePlanService.createCarePlans(newAccounts);
    }
}

