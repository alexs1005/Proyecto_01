public with sharing class BC_ListaDeOppAsociadosCuenta_ctr {

    public string recordId{get;set;}

    public List<Opportunity> getListOpp{
        get {
            if(recordId == null) {
                return new List<Opportunity>();
            }
            List<Opportunity> listOppor = [SELECT Id, Name, Amount, CloseDate 
            FROM Opportunity WHERE AccountId = :recordId and Amount > 100
            ORDER BY CreatedDate DESC];
            return listOppor;
        }
        set;
    }

    public Integer getTotalOppor{
        get{
            return getListOpp.size();
        }
        set;
    }
}