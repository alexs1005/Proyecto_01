public with sharing class BC_AccountTriggerHelper {
    //Cuando se cree un Account, el campo Name debe ser obligatorio.
    //Si viene vacío o en blanco, se debe impedir el guardado del registro
    public static void validateAccountNames(List<Account> newAccounts) {
        for (Account objAccount :newAccounts) {
            if(String.isBlank(objAccount.Phone)) {
                objAccount.addError('El campo Phone es obligatorio');
            }
        }
    }
    //02
    public static void updateAnnualRevenue(List<Account> newAccounts) {
        for (Account objCase : newAccounts) {
            if(objCase.AnnualRevenue > 1000000) {
                objCase.Type = 'VIP';
            }
        }
    }

    //03
    public static void updateIndustry(List<Account> newAccounts, Map<Id, Account> oldMap) {
        for (Account objAccount : newAccounts) {
            Account oldAccount = oldMap.get(objAccount.Id);
            if(objAccount.Type == 'VIP' && oldAccount.Industry != objAccount.Industry) {
                objAccount.addError('Si el Type es VIP no se puede modificar el campo Industry');
            }
        }
    }

    //04
    public static void ValPriority(List<Account> newAccounts) {
        for (Account objAccount :newAccounts) {
            if(String.isBlank(objAccount.CustomerPriority__c)) {
                objAccount.addError('El campo Priority es obligatorio');
            }
        }
    }

    //05
    public static void insertTasks(List<Account> newAccounts) {
        List<Task> Tasks = New List<Task>();
        for (Account objCase : newAccounts) {
            if(objCase.AnnualRevenue > 1000000) {
                Task tas = new Task();
                tas.Subject = 'Seguimiento del caso';
                tas.Status = 'Not Started';
                tas.ActivityDate = Date.today().addDays(1);
                tas.WhatId = objCase.Id;
                Tasks.add(Tas);
            }
        }
        insert Tasks;
    }
}