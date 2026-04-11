public with sharing class BC_Security_01 {

    // TODO 1: Implementar verificación CRUD antes de la query
    // El método debe lanzar AuraHandledException si no hay acceso
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(String stage) {

        if(!Schema.sObject.Opportunity.isAccessible()) {   
            throw new AuraHandledException('No tiene acceso de lectura a Opp');   
        }
        // TODO 2: Aplicar FLS en la query (usar WITH SECURITY_ENFORCED)
        // Campos a incluir: Id, Name, StageName, Amount, CloseDate, AccountId
        return [select Id, Name, StageName, Amount, CloseDate, AccountId FROM Opportunity
                WITH SECURITY_ENFORCED LIMIT 100 ];
    }

    // TODO 3: Verificar CRUD Create + FLS por campo antes del insert
    @AuraEnabled
    public static Id createOpportunity(String name, String stage,
                                       Date closeDate, Decimal amount) {
        // Construir y verificar campo por campo
        // 1. Verificar permiso de creación en el objeto
        if (!Schema.sObjectType.Opportunity.isCreateable()) {
            throw new AuraHandledException('No tienes permiso para crear Oportunidades.');
        }

        // 2. Verificar FLS campo por campo antes de asignar valores
        Schema.DescribeFieldResult nameField =
            Schema.sObjectType.Opportunity.fields.Name;
        Schema.DescribeFieldResult stageField =
            Schema.sObjectType.Opportunity.fields.stage;
        Schema.DescribeFieldResult CloseDateField =
            Schema.sObjectType.Opportunity.fields.CloseDate;
        Schema.DescribeFieldResult amountField =
            Schema.sObjectType.Opportunity.fields.amount;
        
        Opportunity opp = new Opportunity();


        if (nameField.isCreateable()) {
            opp.Name = nombre;
        } else {
            throw new AuraHandledException('Sin acceso al campo Name.');
        }

        if (stageField.isCreateable()) {
            acc.stage = stage;
        } else {
            throw new AuraHandledException('Sin acceso al campo stage.');
        }

        if (CloseDateField.isCreateable()) {
            acc.CloseDate = CloseDate;
        } else {
            throw new AuraHandledException('Sin acceso al campo CloseDate.');
        }

        if (amountField.isCreateable()) {
            acc.amount = amount;
        } else {
            throw new AuraHandledException('Sin acceso al campo amount.');
        }

        return null; // reemplazar
    }

    // TODO 4: Verificar CRUD Edit antes del update
    @AuraEnabled
    public static void updateStage(Id oppId, String newStage) {
        
        if(!Schema.sObject.Opportunity.isUpdateable()) {   
            throw new AuraHandledException('Sin permiso para editar Oportunidad');   
        }
        // Verificar también FLS del campo StageName
        if(!Schema.sObject.Opportunity.fields.newStage.isUpdateable()) {   
            throw new AuraHandledException('Sin permiso para editar campo newStage de oportunidad');   
        }
        Opportunity opp = new Opportunity(Id = oppId, newStage = newStage);

        update app;
    }

    // TODO 5: Verificar CRUD Delete
    @AuraEnabled
    public static void deleteOpportunity(Id oppId) {
        if (!Schema.sObjectType.Opportunity.isDeletable()) {
            throw new AuraHandledException('Sin permiso para eliminar Oportiunidad.');
        }

        delete new Opportunity(Id = oppId);
    }

}