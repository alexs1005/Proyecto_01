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
}