import { LightningElement, wire, api } from 'lwc';
import getOpportunitiesByAccountId from '@salesforce/apex/OpportunityAccountController_ctr.getOpportunitiesByAccountId';

const COLS = [
    { label: 'Nombre', fieldName: 'Name', type: 'text' },
    { label: 'Etapa', fieldName: 'StageName', type: 'text' },
    { label: 'Fecha de cierre', fieldName: 'CloseDate', type: 'date' },
    { label: 'Importe', fieldName: 'Amount', type: 'currency' },
    { label: 'Prioridad', fieldName: 'Priority', type: 'text' }
]

export default class BcListaOportunidadHijo extends LightningElement {
    @api accountId;
    columns = COLS;
    opportunities = [];
    errorMessage = '';
    
    @wire(getOpportunitiesByAccountId, { accountId: '$accountId' })
    wiredOpportunities({ error, data }) {
        if (data) {
            this.opportunities = data;
            this.errorMessage = '';
        } else if (error) {
            this.errorMessage = 'Error al cargar las oportunidades';
            this.opportunities = [];
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            const selectedOpportunity = selectedRows[0];
            this.dispatchEvent( new CustomEvent('opportunityselected', { 
                detail: {
                    opportunityId: selectedOpportunity.Id,
                    opportunityName: selectedOpportunity.Name
                },
                bubbles: true,
                composed: true
         }));
        }
    }

    get hasOpportunities() {
        return this.opportunities && this.opportunities.length > 0;
    }

    get hasAccountId() {
        return !!this.accountId;
    }
}
