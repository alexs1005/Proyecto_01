public with sharing class BC_CaseTriggerHandler {
    public static void beforeInsert(List<Case> newList) {
        // Lógia para manejar la inserción de nuevos casos
        //BC_CaseTriggerHelper.updatePriorityCaseReason(newList);
        //BC_CaseTriggerHelper.upsertCase(newList);
        BC_CaseTriggerHelper.valinsertcase(newList);
        
    }
    public static void beforeUpdate(List<Case> newList, Map<Id, Case> oldMap) {
        // Lógica para manejar la actualización de casos existentes
        //BC_CaseTriggerHelper.updateDescription(newList, oldMap);
        //BC_CaseTriggerHelper.upsertCase(newList, oldMap);
    }

    public static void afterInsert(List<Case> newList) {
        BC_CaseTriggerHelper.taskcase(newList);
    }

    public static void afterUpdate(List<Case> newList, Map<Id, Case> oldMap) {
        //Lógica para manejar la actualización de casos existentes
        BC_CaseTriggerHelper.updateIndustryCase(newList);
    }
}