@isTest
public class Test_ClaseBDD {
    
    //Story 01 - Escenario 01: Case llega a 48h sin resolverse --> Status se marca como Escaled
    @IsTest
    static void Story01_Boundary() {
        // GIVEN
        Case test_case = new Case(
            Status      = 'New',
            Priority = 'High',
            CreatedDate   = Date.today().addHours(-48) 
        );
 
        // WHEN
        Test.startTest();
        insert test_case;
        Test.stopTest();
 
        // THEN
        System.assertEquals('Escaled', test_case.Status,
            'BDD FAIL: El caso con 48h de creación debe tener Estatus = Escaled');
    }


    //Story 02 - Escenario 01: Al crear un paciente se genere un plan con Status = 'Draft'
    @IsTest
    static void Story01_Happy_Path() {
        // GIVEN
        Patient test_patient = new Patient(
            Name      = 'John Doe',
        );
 
        // WHEN
        Test.startTest();
        insert test_patient;
        Test.stopTest();
 
        // THEN
        CarePlan__c result = [select Id, Status from CarePlan__c where Patient__c = :test_patient.Id limit 1]
        System.assertEquals('Draft', result.Status,
            'BDD FAIL: El Plan debe tener Status = Draft');
    }



    ///Ejercio PM
@IsTest
private class CaseEscalationBatchTest {

    @TestSetup
    static void makeData() {
        // GIVEN
        Lead openLead = new Lead(
            Company = 'BCP',
            Rating = 'Hot'
        );
        insert openLead;

    }


    @IsTest
    static void givenCaseOpenOver48h_whenBatchRuns_thenCaseIsEscalated() {
        Lead le = [SELECT Id FROM Lead WHERE Company = 'BCP' and Rating = 'Hot'];

        // WHEN
        Test.startTest();
        Database.executeBatch(new LeadEscalationBatch(), 100);
        Test.stopTest();

        // THEN
        List<Case> result = [SELECT Count FROM Account WHERE Id = :c.Id];
        System.assertEquals('Escalated', result.Status,
            'BDD FAIL: Case abierto >48h debe estar Escalated');

        List<Task> Leads = [SELECT Subject FROM Task WHERE WhatId = :c.Id];
        System.assertEquals(1, Leads.size(),
            'BDD FAIL: Debe crearse exactamente 1 Task');
        System.assertEquals('SLA Breach Review', tasks[0].Subject,
            'BDD FAIL: Subject de Task incorrecto');
    }
}

}