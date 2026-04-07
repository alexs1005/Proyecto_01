public with sharing class BC_Contact_ctr {
    
    @AuraEnabled(cacheable = true)
    public static List<Contact> searchContact(String searchKey) {

        if(String.isBlank(searchKey)) {
            return new List<Contact>();
        }

        try {
            return [SELECT Id, Name, Email, Phone  FROM Contact Where Name LIKE :'%'+searchKey+'%' Limit 20];
        } catch (Exception e) {
            throw new AuraHandledException('Error al buscar nombre');
        }
        
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContact() {
        return [SELECT Id, Name,Title, Phone, Email, Account.Name, LeadSource, Owner.Name, FORMAT(CreatedDate)  FROM Contact
        WHERE AccountId  != null AND CreatedDate = THIS_MONTH 
        ORDER BY CreatedDate ASC LIMIT 10];
    }

}