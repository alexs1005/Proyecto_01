public with sharing class BC_ListaDeCasosAsociadosCuenta_ctr {

    public string recordId{get;set;}

    public List<Case> getListCases{
        get {
            if(recordId == null) {
                return new List<Case>();
            }
            List<Case> listCases = [SELECT Id, CaseNumber, Subject, Status, Priority, Origin, CreatedDate 
            FROM Case WHERE AccountId = :recordId
            ORDER BY CreatedDate DESC];
            return listCases;
        }
        set;
    }

    public Integer getTotalCases{
        get{
            return getListCases.size();
        }
        set;
    }
}