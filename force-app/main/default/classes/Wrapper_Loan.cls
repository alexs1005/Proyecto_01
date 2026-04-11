public class Wrapper_Loan {
    @AuraEnabled public List<Loan__c> loans { get; set; }
    @AuraEnabled public Map<String, Set<String>> removedFields { get; set; }

    public Wrapper_Loan(
        List<Loan__c> loans,
        Map<String, Set<String>> removedFields
    ) {
        this.loans = loans;
        this.removedFields = removedFields;
    }
}
