public with sharing class BC_OppTriggerHelper {
    public static void InsertOpp(List<Opportunity> newOpps) {
        List<Task> Tasks = New List<Task>();
        for (Opportunity objOpp : newOpps) {
            if(objOpp.Amount > Decimal.valueOf(Label.Monto_Opp) && objOpp.Amount != null) {
                Task Tas = New Task();
                Tas.Subject = 'Seguimiento a oportunidad de alto valor';
                Tas.WhatId = objOpp.Id;
                Tas.OwnerId = objOpp.OwnerId;
                Tasks.add(Tas);
            }
        }
        if(!Tasks.isEmpty()){
            Insert(Tasks);
        }   
    }

    //01
    public static void ValAmount(List<Opportunity> newOpps) {
        for (Opportunity objOpp :newOpps) {
            if(objOpp.Amount < 0 || objOpp.Amount == null) {
                objOpp.addError('El Amount debe ser mayor a 0 y no nulo');
            }
        }
    }

    //02
    public static void UpdateDescription(List<Opportunity> newOpps) {
        for (Opportunity objOpp : newOpps) {
            if(objOpp.Amount >= 100000 && objOpp.Description == null) {
                objOpp.Description = 'Oportunidad estratégica';
            }
        }
    }

    //03
    public static void insertTasks(List<Opportunity> newOpps) {
        List<Task> Tasks = New List<Task>();
        for (Opportunity objOpp : newOpps) {
            if(objOpp.Amount >= 100000) {
                Task tas = new Task();
                tas.Subject = 'Seguimiento del caso - Opotunidad';
                tas.Status = 'Not Started';
                tas.ActivityDate = Date.today().addDays(1);
                tas.WhatId = objOpp.Id;
                Tasks.add(Tas);
            }
        }
        insert Tasks;
    }

    //04
    public static void updateStageName(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        for (Opportunity objOpp : newOpps) {
            Opportunity oldOpp = oldMap.get(objOpp.Id);
            if(objOpp.StageName == 'Closed Won' && objOpp.Amount != oldOpp.Amount) {
                objOpp.addError('Si el Stage Name es Closed Won no se puede modificar el campo Amount');
            }
        }
    }



    //Cuando se gana una opp, copia el monto de la opp a la cuenta
    //Debe tener una cuenta relacionada y monto mayor a 0

    //Exception
    public class InvalidStageException extends Exception {}

    //05
    public static void UpdateLastAmount(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        List<Account> accs = New List<Account>();
        for (Opportunity objOpp : newOpps) {
            Opportunity oldOpp = oldMap.get(objOpp.Id);
            if(objOpp.AccountId == null){
                throw new InvalidStageException('La cuenta no debe ser nula');
            }
            if(objOpp.Amount <= 0 || objOpp.Amount == null){
                throw new InvalidStageException('El monto debe ser mayor a 0 y no nulo');
            }
            if(objOpp.StageName == 'Closed Won' && objOpp.Amount != oldOpp.Amount) {
                Account acc = New Account();
                acc.Id = objOpp.AccountId;
                acc.Last_Invoiced_Amount__c = objOpp.Amount;
                accs.add(acc);
            }
        }
        Update(accs);
    }
}