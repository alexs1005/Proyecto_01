public with sharing class BC_CaseTriggerHelper {

    // Cuando se cree un registro de caso, validar si el status es new y el subject está vacío
    // asignar la prioridad Hight y en el campo Case Rason asignar "Performance"
    public static void updatePriorityCaseReason(List<Case> newCases) {
        for (Case objCase : newCases) {
            if(objCase.Status == 'New' && String.isBlank(objCase.Subject)) {
                objCase.Priority = 'High';
                objCase.Reason = 'Performance';
            }
        }
    }
    
    // Si el campo Status cambia, asignar el valor "El estado del caso ha cambiado" en el campo Description
    public static void updateDescription(List<Case> newCases, Map<Id, Case> oldMap) {
        for (Case objCase : newCases) {
            Case oldCase = oldMap.get(objCase.Id);
            if(oldCase.Status != objCase.Status) {
                objCase.Description = 'El estado del caso ha cambiado';
            }
        }
    }

    //Cuando un registro de caso cambia a Status Closed, actualizar la cuneta relacionada y
    //asignar el valor "Tiene casos en estado cerrado" en el campo Descripcion de la cuenta
    public static void updateAccountDescriptionOnCaseClosed(List<Case> newCases, Map<Id, Case> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        for (Case objCase : newCases) {
            Case oldCase = oldMap.get(objCase.Id);
            if(objCase.Status != null && objCase.Status == 'Closed' && oldCase.Status == 'Closed') {
                accountIds.add(objCase.AccountId);
            }
        }
        if(!accountIds.isEmpty()){
            return;
        }
        List<Account> accountsToUpdate = [SELECT Id, Description FROM Account WHERE Id IN :accountIds];
        for (Account objAccount : accountsToUpdate) {
            objAccount.Description = 'Tiene casos en estado cerrado';

        }
        update accountsToUpdate;
    }
/*
    //Cuando se cree un registro de caso, actualizar la cuenta relacionada y asignar el valor "Tiene casos en estado New"
    // en el campo Descripcion de la cuenta y que el tipo sea Prospect de la cuenta
    public static void updateAccountDescriptionOnCaseNew(List<Case> newCases) {
        Set<Id> accountIds = new Set<Id>();
        for (Case objCase : newCases) {
            if(objCase.Status == 'New' && objCase.Status != null) {
                accountIds.add(objCase.AccountId);
            }
        }
        if(accountIds.isEmpty()){
            return;
        }
        List<Account> accountsToUpdate = [SELECT Id, Description, Type FROM Account WHERE Id IN :accountIds];
        for (Account objAccount : accountsToUpdate) {
            objAccount.Description = 'Tiene casos en estado New';
            objAccount.Type = 'Prospect';
        }
        update accountsToUpdate;
    }

    //Cuando se creen casos, validar si el campo Origin es Email, Priority es Higth y si tiene OwnerId, entonces
    //Crear un registro de Task relacionado al caso con el Subject "Seguimiento del caso", el Status "Not Started"
    //y Activity Data asignado para el día siguiente
    public static void createTaskForNewCases(List<Case> newCases) {
        Map<Id, CAse> tasksToInsert = new Map<Id, Case>();
        for (Case objCase : newCases) {
            if(objCase.Origin == 'Email' && objCase.Priority == 'High' && objCase.OwnerId != null) {
                tasksToInsert.put(objCase.Id, objCase);
            }
        }
        if(tasksToInsert.isEmpty()){
            return;
        }

        //Consultar tareas existentes relacionados a los casos válidos para evitar duplicidad
        Set<Id> caseIds = tasksToInsert.keySet();
        Map<Id, Case> casesMap = new Map<Id, Task>();
        List<Task> mapTareasExistentes = [SELECT Id, WhatId FROM Task WHERE WhatId IN :caseIds];
        for (Task objTask : mapTareasExistentes) {
            casesMap.put(objTask.WhatId, objTask);
        }
        List<Task> tasksToInsertList = new List<Task>();

        for (Id caseId : mapTareasExistentes.keySet()) {
            //Valida si el caso ya existe una tarea de siguiento, si no existe se crea una nueva tarea
            if(!casesMap.containsKey(caseId)) {
                Case regCase = casesMap.get(caseId);
                Task objTask = new Task();
                objTask.Subject = 'Seguimiento del caso' + regCase.Id;
                objTask.Priority = 'High';
                objTask.Priority = 'High';
                objTask.Status = 'Not Started';
                objTask.ActivityDate = Date.today().addDays(1);
                objTask.WhatId = caseId;
                tasksToInsertList.add(objTask);
            }
        }
    }
*/


//Last

    public static void valinsertcase(List<Case> newCases) {
        for (Case objCase : newCases) {
            if(objCase.Status == null) {
                objCase.Status= 'Working';
            }
            if(objCase.Origin == null) {
                objCase.Origin = 'Web';
            }
            if(objCase.Subject == null) {
                objCase.addError('El Subject no puede ser vacío');
            } 
        }
    }

    public static void taskcase(List<Case> newCases) {
        List<Task> tasks = new List<Task>();
        Set<Id> AccId = new Set<Id>();
        for (Case objCase : newCases) {
            if(objCase.Priority == 'High' && objCase.Origin == 'Email') {
                Task objTask = new Task();
                objTask.Subject = 'Seguimiento del caso';
                objTask.Status = 'Not Started';
                objTask.ActivityDate = Date.today().addDays(1);
                objTask.WhatId = objCase.Id;
                tasks.add(objTask);
            }
            if(objCase.AccountId != null){
                AccId.add(objCase.AccountId);
            }
        }
        List<Account> accounts = [SELECT Id FROM Account WHERE Id IN :AccId];
        List<Account> newaccs = new List<Account>();
        for (Account objAccount : accounts) {
            objAccount.Type = 'Customer';
            newaccs.add(objAccount);
        }
        Update(newaccs);
        insert(tasks);
    }

    public static void updateIndustryCase(List<Case> newCases) {
        Set<Id> AccId = new Set<Id>();
        for (Case objCase : newCases) {
            If(objCase.Status == 'Escalated'){
                AccId.add(objCase.AccountId);
            }
        }
        List<Account> accounts = [SELECT Id FROM Account WHERE Id IN :AccId];
        List<Account> newaccs = new List<Account>();
        for (Account objAccount : accounts) {
            objAccount.Industry = 'Support';
            newaccs.add(objAccount);
        }
        Update(newaccs);

        List<Case> cases = [SELECT Id FROM Case WHERE AccountId IN :AccId];
        List<Case> newcase = new List<Case>();
        for (Case objcase : cases) {
            objcase.Status = 'Closed';
            newcase.add(objcase);
        }
        Update(newcase);
    }
}
