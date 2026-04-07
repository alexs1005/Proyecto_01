trigger BC_OpportunityTrigger on Opportunity (after insert, before insert, before update, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            //BC_OppTriggerHandlert.beforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            //BC_OppTriggerHandlert.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            //BC_OppTriggerHandlert.afterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            BC_OppTriggerHandlert.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    } 
}