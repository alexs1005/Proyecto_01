trigger BC_CaseTrigger on Case (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            BC_CaseTriggerHandler.beforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            BC_CaseTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            BC_CaseTriggerHandler.afterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            BC_CaseTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}