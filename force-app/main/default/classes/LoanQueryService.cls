public inherited sharing class LoanQueryService {

    
    public static Wrapper_Loan getLoansSecure() {
        List<Loan__c> loans = [
            SELECT Id, Name, Status__c, Amount__c,
                InterestRate__c, CreditScore__c, InternalRiskNotes__c
            FROM Loan__c
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.READABLE,
            loans
        );

        List<Loan__c> securedLoans =
            (List<Loan__c>) decision.getRecords();

        Map<String, Set<String>> removedFields =
            decision.getRemovedFields();

        return new Wrapper_Loan(securedLoans, removedFields);
    }


    public static Loan__c getLoanById(Id loanId) {
        List<Loan__c> loans = [
            SELECT Id, Name, Status__c, Amount__c,
                   InterestRate__c, CreditScore__c, InternalRiskNotes__c
            FROM Loan__c
            WHERE Id = :loanId
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.READABLE,
            loans
        );

        List<Loan__c> result = (List<Loan__c>) decision.getRecords();
        return result[0];
    }
}