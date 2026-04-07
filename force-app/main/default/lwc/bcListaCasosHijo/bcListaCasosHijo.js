import { LightningElement, api, wire } from 'lwc';
import getCasesByAccountId from '@salesforce/apex/CaseAccountController_ctr.getCasesByAccountId';

const COLS = [
    { label: 'Numero de caso', fieldName: 'CaseNumber'},
    { label: 'Fecha de creación', fieldName: 'CreatedDate'},
    { label: 'Fecha de cierre', fieldName: 'CloseDate'}
]

export default class BcListaCasosHijo extends LightningElement {
    @api accountId;
    columns = COLS;
    cases = [];
    errorMessage = '';
    
    @wire(getCasesByAccountId, { accountId: '$accountId' })
    wiredCases({ error, data }) {
        if (data) {
            this.cases = data;
            this.errorMessage = '';
        } else if (error) {
            this.errorMessage = 'Error al cargar los casos';
            this.cases = [];
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            const selectedCase = selectedRows[0];
            this.dispatchEvent( new CustomEvent('caseselected', { 
                detail: {
                    CaseId: selectedCase.Id,
                    CaseNumber: selectedCase.CaseNumber
                },
                bubbles: true,
                composed: true
            }));
        }
    }

    get hasCases() {
        return this.cases && this.cases.length > 0;
    }

    get hasAccountId() {
        return !!this.accountId;
    }
}