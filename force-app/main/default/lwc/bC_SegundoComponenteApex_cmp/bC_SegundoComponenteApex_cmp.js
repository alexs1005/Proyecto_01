import {LightningElement, wire, api} from 'lwc';
import getCasesFromAccount from '@salesforce/apex/BC_SegundoClaseControladorea_ctr.getCasesFromAccount';

const COLS = [
    {label: 'Nombre de case', fieldName: 'CaseNumber'},
    {label: 'Nombre de la cuenta', fieldName: 'AccountName'},
    {label: 'Fecha de creacion', fieldName: 'AccountCreatedDate'},
    {label: 'Asunto', fieldName: 'Subject'},
    {label: 'Tipo', fieldName: 'Type'},
    {label: 'Prioridad', fieldName: 'Priority'}    
];

export default class BC_SegundoComponenteApex_cmp extends LightningElement {
    @api recordId;
    cases = [];
    colums = COLS;

    @wire(getCasesFromAccount,{accountId:'$recordId'})
    wireCases({error,data}) {
        if(data) {
            console.log('Id de la cuenta: ', this.recordId);
            console.log('Lista de casos: ', data);
            this.cases = data.map(c =>
                ({
                    CaseNumber: c.CaseNumber,
                    AccountName: c.Account.Name,
                    AccountCreatedDate: c.Account.CreatedDate,
                    Subject: c.Subject || "SIN ASUNTO",
                    Type: c.Type || "SIN TIPO",
                    Priority: c.Priority
                })
            );
            this.error = undefined;
        }
        else if(error) {
            console.error('Ha ocurrido un error al cargar los casos',error);
            this.error = error;
            this.cases = [];
        }
    }

}