public with sharing class BC_PrimerEjercicioApex_ctr {

    @AuraEnabled(cacheable = true)
    public static List<Opportunity> OporFromAccount(Id accountId) {
        System.debug('accountId: '+accountId);
        try {
            return [SELECT Id, Name, CreatedDate  FROM Opportunity 
                    Where AccountId = :accountId 
                    AND CreatedDate = THIS_YEAR
                    order by CreatedDate DESC
                    ];
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}