@isTest
public with sharing class Test_Security_01 {

    // TEST SETUP – Usuario con perfil estándar + datos base
    @testSetup
    static void setupData() {

        // Obtener perfil Standard User
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        User u = new User(
            Alias = 'stdusr',
            Email = 'standarduser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Standard',
            LanguageLocaleKey = 'es_PE',
            LocaleSidKey = 'es_PE',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Lima',
            UserName = 'standarduser' + System.currentTimeMillis() + '@test.com'
        );

        insert u;

        // Account base
        Account acc = new Account(
            Name = 'Cuenta Test'
        );
        insert acc;

        // Opportunity base
        Opportunity opp = new Opportunity(
            Name = 'Opp Test',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 1000,
            AccountId = acc.Id
        );
        insert opp;
    }

    // ----------------------------------------------------------------
    // TEST getOpportunities
    // ----------------------------------------------------------------
    @IsTest
    static void testGetOpportunities() {

        User u = [SELECT Id FROM User WHERE Alias = 'stdusr' LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            List<Opportunity> opps =
                BC_Security_01.getOpportunities('Prospecting');
            Test.stopTest();

            System.assertNotEquals(null, opps, 'La lista no debe ser null');
            System.assert(opps.size() > 0, 'Debe devolver oportunidades');
        }
    }

    // ----------------------------------------------------------------
    // TEST createOpportunity
    // ----------------------------------------------------------------
    @IsTest
    static void testCreateOpportunity() {

        User u = [SELECT Id FROM User WHERE Alias = 'stdusr' LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            Id oppId = BC_Security_01.createOpportunity(
                'Nueva Opp',
                'Prospecting',
                Date.today().addDays(15),
                5000
            );
            Test.stopTest();

            System.assertNotEquals(null, oppId, 'Debe retornar el Id creado');

            Opportunity opp = [
                SELECT Name, StageName, Amount
                FROM Opportunity
                WHERE Id = :oppId
            ];

            System.assertEquals('Nueva Opp', opp.Name);
            System.assertEquals('Prospecting', opp.StageName);
            System.assertEquals(5000, opp.Amount);
        }
    }

    // ----------------------------------------------------------------
    // TEST updateStage
    // ----------------------------------------------------------------
    @IsTest
    static void testUpdateStage() {

        User u = [SELECT Id FROM User WHERE Alias = 'stdusr' LIMIT 1];
        Opportunity opp =
            [SELECT Id FROM Opportunity LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            BC_Security_01.updateStage(opp.Id, 'Closed Won');
            Test.stopTest();

            Opportunity updatedOpp =
                [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];

            System.assertEquals(
                'Closed Won',
                updatedOpp.StageName,
                'El Stage debe actualizarse'
            );
        }
    }

    // ----------------------------------------------------------------
    // TEST deleteOpportunity
    // ----------------------------------------------------------------
    @IsTest
    static void testDeleteOpportunity() {

        User u = [SELECT Id FROM User WHERE Alias = 'stdusr' LIMIT 1];
        Opportunity opp =
            [SELECT Id FROM Opportunity LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            BC_Security_01.deleteOpportunity(opp.Id);
            Test.stopTest();

            Integer countOpps =
                [SELECT COUNT() FROM Opportunity WHERE Id = :opp.Id];

            System.assertEquals(
                0,
                countOpps,
                'La oportunidad debe haberse eliminado'
            );
        }
    }
}
