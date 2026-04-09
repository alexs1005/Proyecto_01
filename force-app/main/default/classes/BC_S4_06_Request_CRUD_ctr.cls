public with sharing class BC_S4_06_Request_CRUD_ctr {

    @AuraEnabled
    public static List<Request__c> getRequests() {
        try{
            List<Request__c> listRequest = [SELECT subject__c, Status__c, Priority__c, DueDate__c, Descriptin__c, 
                                            Requester__c, OwnerId FROM request__c];
            return listRequest;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    @AuraEnabled
    public static void deleteRequest(Id recordId) {
        if (!Schema.sObjectType.Account.isDeletable()) {
            throw new AuraHandledException('No tienes permisos para eliminar Accounts.');
        }

        // WITH SECURITY_ENFORCED valida acceso al registro antes de borrar
        List<Account> recs = [
            SELECT Id FROM Account
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED LIMIT 1
        ];
        if (recs.isEmpty()) {
            throw new AuraHandledException('Registro no encontrado o sin acceso para eliminarlo.');
        }

        try {
            delete recs[0];
        } catch (DmlException e) {
            throw new AuraHandledException(formatDmlError(e));
        }
    }
}