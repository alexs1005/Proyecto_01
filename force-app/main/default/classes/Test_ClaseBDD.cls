@isTest
public class Test_ClaseBDD {
    
    //Story 01 - Escenario 01: Case llega a 48h sin resolverse
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
}