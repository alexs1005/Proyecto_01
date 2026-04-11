public with sharing class CarePlanService {


    public static void createCarePlansForNewPatiens(List<Account> newAccounts) {
        //Buena practica de seguridad de acceso a objetos
        if (!Schema.sObjectType.HealthCloudGA__CarePlan__c.isCreateable()) {
            throw new System.NoAccessException();
        }

        //Obtener RecordTypeId de 'Patienet' dianamicamente - evita HardCodings
        Id patientRtId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();


        List<HealthCloudGA__CarePlan__c> Plans = new List<HealthCloudGA__CarePlan__c>();

        for (Account acc : newAccounts) {
            //Solo creamos Care plan si el Account es de tipo patient
            if (acc.RecordTypeId == patientRtId) {
                Plans.add(new HealthCloudGA__CarePlan__c(
                    name = 'Care Plan = '+acc.Name,
                    HealthCloudGA__Patient__c = acc.Id,
                    Status__c = 'Draft',
                    OwnerId = UserInfo.getUserId()
                ));
            }
        }

        if (!carePlans.isEmpty()) {
            insert carePlans;
        }
    }

}
