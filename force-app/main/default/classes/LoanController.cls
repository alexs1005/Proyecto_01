public with sharing class LoanController {

    public static Wrapper_Loan getLoans() {
        if (!Schema.sObjectType.Loan__c.isAccessible()) {
            throw new NoAccessException();
        }
        return LoanQueryService.getLoansSecure();
    }

    public static Loan__c createLoan(Loan__c loan) {
        //Se valida acceso de escritura a objeto Loan
        FLSValidator.assertWritable();

        //Remueve campos a los eque no tiene acceso el usuario
        Loan__c securedLoan = FLSValidator.stripInaccessibleForWrite(loan);

        insert securedLoan;
        return securedLoan;
    }

    public static Loan__c updateStatus(Id loanId, String newStatus) {
        Loan__c loan = LoanQueryService.getLoanById(loanId);
        loan.Status__c = newStatus;

        update loan;
        return loan;
    }

    public static void deleteLoan(Id loanId) {
        if (!Schema.sObjectType.Loan__c.isDeletable()) {
            throw new NoAccessException();
        }
        delete LoanQueryService.getLoanById(loanId);
    }
}