public with sharing class BC_AccountTriggerHandlert {
    public static void beforeInsert(List<Account> newList) {
        // Lógia para manejar la inserción de nuevos casos
        //BC_AccountTriggerHelper.validateAccountNames(newList);
        
        BC_AccountTriggerHelper.ValPriority(newList);
        BC_AccountTriggerHelper.updateAnnualRevenue(newList);
        BC_AccountTriggerHelper.insertTasks(newList);
        
    }
    public static void beforeUpdate(List<Account> newList,Map<Id, Account> oldMap) {
        // Lógica para manejar la actualización de casos existentes
        BC_AccountTriggerHelper.ValPriority(newList);
        BC_AccountTriggerHelper.updateAnnualRevenue(newList);
        BC_AccountTriggerHelper.updateIndustry(newList, oldMap);
    }
}