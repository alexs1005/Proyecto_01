public with sharing class BC_S4_WorkOrderByCase_ctr {

    public string recordId{get;set;}

    public List<WorkOrder> getListWO{
        get {
            if(recordId == null) {
                return new List<WorkOrder>();
            }
            List<WorkOrder> listWO = [SELECT WorkOrderNumber, Owner.Name, Duration , 
            Priority, CurrencyIsoCode, StartDate, EndDate FROM WorkOrder
            WHERE CaseId = :recordId
            LIMIT 10];
            return listWO;
        }
        set;
    }

    public Integer getTotalWO{
        get{
            return getListWO.size();
        }
        set;
    }
}

