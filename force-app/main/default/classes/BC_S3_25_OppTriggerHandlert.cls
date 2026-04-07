public with sharing class BC_OppTriggerHandlert {
    public static void beforeInsert(List<Opportunity> newList) {

        BC_OppTriggerHelper.ValAmount(newList);
        BC_OppTriggerHelper.UpdateDescription(newList);
    }
    public static void beforeUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {

        BC_OppTriggerHelper.ValAmount(newList);
        BC_OppTriggerHelper.UpdateDescription(newList);
        BC_OppTriggerHelper.updateStageName(newList, oldMap);
    }
    public static void afterInsert(List<Opportunity> newList) {
        BC_OppTriggerHelper.insertTasks(newList);
    }
    public static void afterUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        BC_OppTriggerHelper.UpdateLastAmount(newList, oldMap);
    }
}