@isTest
private with sharing class CarePlanAutoGenerationTest {

    @TestSetup
    static void makeData() {
        //User de perfil "clinian"

    }

    //Escenario 01
    @isTest
    static void GiveNewPatientAccount_WhenInserted__ThenCarePlanDraftCreate(){
        //Given
        Id PatientId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();

        Account patient = new Account(
            Name = 'BDD Patient Test',
            RecordType = PatientId
        );

        //When
        Test.startTest();
        insert patient
        Test.stopTest();

        //Then
        List<HealthCloundGA_carePaln__c> plans = [SELECT Id, Status__c FROM HealthCloundGA_carePaln__c WHERE HealthCloundGA_carePaln__c = :Patient.Id];
        Assert.areEqual(1,plans.size(),'BDD FAIL: Debe existir 1 care plan asociado al paciente')
        Assert.areEqual('Draft',plans[0].OwnerId, 'DBB FAIL: ..............')
        Assert.areEqual(UserInfo.getUserId(),plans[0].OwnerId,'DBB FAIL:...........' )
    }

    //Escenario 02
    @IsTest
    static void givenNonPatientAccount_whenInserted_thenNoCarePlanCreated() {

        //GIVEN
        Id CustomerRTId = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('Customer')
            .getRecordTypeId();

        Account customer = new Account(
            Name = 'BDD customer Test',
            RecordTypeId = CustomerRTId
        );

        //WHEN
        Test.startTest();
        insert customer;
        Test.stopTest();

        //THEN
        Integer planCount = [
            SELECT COUNT()
            FROM HealthCloudGA_CarePlan__c
            WHERE HealthCloudGA_Patient__c = :customer.Id
        ];

        Assert.areEqual(
            0,
            planCount,
            'BDD FAIL: No debe existir care plan asociado al customer'
        );
    }

    //Escenario 03
    @IsTest
    // Run Test | Debug Test
    static void given50NewPatientAccounts_whenInsertedInBulk_then50CarePlanDraftsCreated() {

        //GIVEN
        Id PatientRTId = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('Patient')
            .getRecordTypeId();

        List<Account> patients = new List<Account>();

        for (Integer i = 0; i < 50; i++) {
            patients.add(new Account(
                Name = 'BDD Patient Bulk ' + i,
                RecordTypeId = PatientRTId
            ));
        }

        //WHEN
        Test.startTest();
        insert patients;
        Test.stopTest();

        //THEN
        Integer planCount = [
            SELECT COUNT()
            FROM HealthCloudGA_CarePlan__c
            WHERE Status__c = 'Draft'
        ];

        Assert.areEqual(
            50,
            planCount,
            'BDD FAIL: Deben existir 50 care plans asociados a los pacientes'
        );
    }


}