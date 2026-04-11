/*
📋 Escenario
Una empresa usa Salesforce para aprobar contratos (objeto Contract). Las reglas son: 
(1) Un vendedor solo puede ver sus propios contratos (OWD=Private). 
(2) El proceso de aprobación automática debe evaluar TODOS los contratos pendientes, independientemente del vendedor. 
(3) El servicio que formatea el correo de notificación debe comportarse según quien lo llame. 
(4) El LWC de revisión de contratos solo debe mostrar los contratos del usuario logueado.

Instrucciones:
•	Implementa las 4 clases del diagrama siguiente, eligiendo la declaración de sharing correcta para cada una y justificándola en un comentario al inicio de cada clase.
•	ContractController (para LWC): getMyContracts() — debe respetar OWD.
•	ApprovalEngineService: processPendingApprovals() — debe ver todos los contratos.
•	NotificationFormatter: formatApprovalEmail(Contract c) — debe adaptarse al caller.
•	Escribe un test que pruebe que ContractController retorna 0 contratos para un usuario que no es dueño de ningún contrato, y que ApprovalEngineService retorna todos.

*/
// CLASE 1 — Para LWC (elige sharing apropiado y justifica)
public with sharing class ContractController {
    @AuraEnabled(cacheable=true)
    public static List<Contract> getMyContracts() {
        // TODO
        if(!Schema.sObject.Contract.isAccessible()) {   
            throw new AuraHandledException('No tiene acceso de lectura a Contratos');   
        }
        List<Contract> cont = [select Id, name  FROM Contract WITH SECURITY_ENFORCED LIMIT 20];
        return cont;
    }
}

// CLASE 2 — Motor de aprobaciones (elige sharing apropiado y justifica)
public without sharing class ApprovalEngineService {
    public static void processPendingApprovals() {
        // TODO: consultar TODOS los contratos con Status='Pending'
        // y actualizar a 'Approved' si Amount < 10000
        List<Contract> cont = [select Id, Status  FROM Contract WHERE Amount < 1000 and Status = 'Pending'];
        for(Contract c: cont){
            c.Status = 'Approved';
        }
        update(cont);
    }
}

// CLASE 3 — Formateador de notificaciones (elige sharing apropiado y justifica)
public with sharing class NotificationFormatter {
    public static String formatApprovalEmail(Contract c) {
        // TODO: retornar string con el cuerpo del email
        if(!Schema.sObject.Contract.isAccessible()) {   
            throw new AuraHandledException('No tiene acceso de lectura a Contratos');   
        }
        Contract cont = [select Id, email  FROM Contract WHERE Id = :c.Id WITH SECURITY_ENFORCED LIMIT 1];
        return cont.email;

    }
}

// CLASE 4 — Test class
@isTest
public class ContractSharingTest {

    // TODO: crear User sin acceso, crear contratos con otro owner,
    @testSetup
    static void setupData() {

        // Obtener perfil Standard User
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];
        List<User> us = New List<User>();

        for(i,i<2,i++){
            User u = new User(
            Alias = 'stdusr'+i,
            Email = 'standarduser'+i+'@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Standard'+i,
            LanguageLocaleKey = 'es_PE',
            LocaleSidKey = 'es_PE',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Lima',
            UserName = 'standarduser'+ i + System.currentTimeMillis() + '@test.com'
            );
            us.add(u)
        }
        

        insert us;


        // Contrato 
        Contract cont = new Contract(
            Name = 'contract',
            OwnerId = us[0].Id
        );
        insert cont;
    }

    @isTest
    static void testSharingBehavior() {
        
        // usar System.runAs() para verificar comportamiento

        User u = [SELECT Id FROM User WHERE Alias = 'stdusr1' LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            List<Contract> cont = 
                ContractController.getMyContracts('Prospecting');
            Test.stopTest();

            System.assertEquals(0, cont.Size(), 'La lista debe ser null');
        }
    }
}
