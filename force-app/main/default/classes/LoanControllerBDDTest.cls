@IsTest
private class LoanControllerBDDTest {

    @TestSetup
    static void setup() {
		      
        
        // Obtener perfil Standard User
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        //Crear usuarios Loan Officers y  Loan Officers
        List<User> us = new List<User>();

        User UserLO = new User(
            Alias = 'LOfficer',
            Email = 'Loan_Officers@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Standard',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Lima',
            UserName = 'standarduser1' + System.currentTimeMillis() + '@test.com'
        );

        us.add(UserLO);

        User UserCSR = new User(
            Alias = 'CS_Rep',
            Email = 'C_Service_Rep@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Standard',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Lima',
            UserName = 'standarduser2' + System.currentTimeMillis() + '@test.com'
        );

        us.add(UserCSR);
        insert us;

        //Obtener Permission Set
        PermissionSet PSLoanOfficer = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'LoanOfficers'
        ];

        PermissionSet PSCustomer_Service_Rep = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'Customer_Service_Rep'
        ];

        
        // Asignar Permission Set al usuario
        List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
        PermissionSetAssignment psaLO = new PermissionSetAssignment(
            AssigneeId = UserLO.Id,
            PermissionSetId = PSLoanOfficer.Id
        );
        psa.add(psaLO);
        PermissionSetAssignment psaCSR = new PermissionSetAssignment(
            AssigneeId = UserCSR.Id,
            PermissionSetId = PSCustomer_Service_Rep.Id
        );
        psa.add(psaCSR);
        insert(psa);


 		//Crear Loan
        System.runAs(userLO) {
            insert new Loan__c(
                Name = 'Loan Test',
                Status__c = 'Active',
                Amount__c = 10000,
                InterestRate__c = 8,
                CreditScore__c = 700
            );
         }
        
        System.runAs(UserCSR) {
            insert new Loan__c(
                Name = 'CSR Test',
                Status__c = 'Active',
                Amount__c = 10000
            );
         }
        
    }

    //Escenario 01: Happy Path - El user 'Loan Officers' crea un préstamo
    @IsTest
    static void givenLoanOfficer_whenCreateLoan_thenAllFieldsStored() {
        //GIVEN Dado que el user 'Loan Officers' prepara un Load
        User officer = [SELECT Id FROM User WHERE Alias = 'LOfficer' Limit 1];


        //WHEN El Lead es insertado        
        System.runAs(officer) {
            Loan__c loan = new Loan__c(
                Name = 'Loan Officer Loan',
                Amount__c = 20000,
                InterestRate__c = 10,
                CreditScore__c = 800
            );

            //se inserta Load quitando los campos al que no tiene acceso el usuario
            Loan__c created = LoanController.createLoan(loan);

            //THEN Todos los campos deben almacenarse correctamente.
            System.assertEquals(10, created.InterestRate__c);
            System.assertEquals(800, created.CreditScore__c);
        }
    }

    //Escenario 02: Security FLS Read - El user 'Customer Service Reps'  consulta los préstamos
    @IsTest
    static void givenCSR_whenGetLoans_thenSensitiveFieldsHidden() {
        //GIVEN Dado que el user 'Customer Service Reps'  
        User CSR = [SELECT Id FROM User WHERE Alias = 'CS_Rep' Limit 1];

        //WHEN Consulta los préstamos
        System.runAs(CSR) {
            Wrapper_Loan result = LoanController.getLoans();
            Loan__c loan = result.loans[0];
            Set<String> removedForThisLoan = result.removedFields.get('Loan__c');

            //THEN Los campos confidenciales no deben ser visibles.
            System.assert(removedForThisLoan.contains('CreditScore__c'),'CreditScore__c debe haber sido removido por FLS');
            System.assert(removedForThisLoan.contains('InterestRate__c'),'InterestRate__c debe haber sido removido por FLS');
        }
    }

    //Escenario 03: Security CRUD - Usuario 'Customer Service Reps' sin permisos elimina Load
    @IsTest
    static void givenUserWithoutDelete_whenDelete_thenExceptionThrown() {

        //GIVEN Dado que el user 'Customer Service Reps' sin permiso de 'Delete' en Lead
        User CSR = [SELECT Id FROM User WHERE Alias = 'CS_Rep' Limit 1];

        System.runAs(CSR) {
            try {
                //WHEN El usuario elimina un préstamo
                LoanController.deleteLoan([SELECT Id FROM Loan__c LIMIT 1].Id);
                System.assert(false, 'Exception expected');
            } catch (NoAccessException ex) {
                //THEN Se debe generar una excepción 'NoAccessException' 
                System.assert(true);
            }
        }
    }

    //Escenario 04: FLS Write - User 'Customer Service Reps' actualiza campo 'InterestRate__c'
    @IsTest
    static void givenCSR_whenUpdateInterestRate_thenIgnored() {

        //GIVEN Dado que el user 'Customer Service Reps' sin permiso de update a campos sensibles
        User CSR = [SELECT Id FROM User WHERE Alias = 'CS_Rep' Limit 1];

        System.runAs(CSR) {
            //WHEN Actualiza la tasa de interés
            Wrapper_Loan result = LoanController.getLoans();
            Loan__c loan = result.loans[0];
            loan.InterestRate__c = 15;
            LoanController.updateStatus(loan.Id, 'Inactive');
        

        //THEN La tasa de interés no debe cambiar
        Loan__c reloaded = [SELECT InterestRate__c, Status__c FROM Loan__c WHERE Id = :loan.Id];
        System.assertNotEquals(15, reloaded.InterestRate__c);
        System.assertEquals('Inactive', reloaded.Status__c);
       }
    }
}