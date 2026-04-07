trigger BC_AccountTrigger on Account (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            BC_AccountTriggerHandlert.beforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            BC_AccountTriggerHandlert.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            
        } else if (Trigger.isUpdate) {
            
        }
    }    
}