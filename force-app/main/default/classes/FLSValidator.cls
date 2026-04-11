public inherited sharing class FLSValidator {

    //Remueve campos a los eque no tiene acceso el usuario
    public static Loan__c stripInaccessibleForWrite(Loan__c loan) {
        SObjectAccessDecision decision =
            Security.stripInaccessible(
                AccessType.UPDATABLE,
                new List<SObject>{ loan }
            );
        return (Loan__c) decision.getRecords()[0];
    }

    //Se valida acceso de escritura a objeto Loan
    public static void assertWritable() {
        if (!Schema.sObjectType.Loan__c.isCreateable()) {
            throw new NoAccessException();
        }
    }

}