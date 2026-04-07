import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/OpportunityAccountController_ctr.getAccounts';

export default class BcListaOportunidadPadre extends LightningElement {

    accounts = [];
    accountOptions = [];
    selectedAccountId;
    selectedOpportunityMessage = '';
    errorMessage = '';

    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            // Guardamos todas las cuentas
            this.accounts = data;

            // Convertimos cuentas a opciones para el combobox
            this.accountOptions = data.map(account => ({
                label: account.Name,
                value: account.Id
            }));

            // Si no hay cuenta seleccionada, seleccionamos la primera
            if (!this.selectedAccountId && data.length > 0) {
                this.selectedAccountId = data[0].Id;
            }

            this.errorMessage = '';
        } 
        else if (error) {
            this.errorMessage = 'Error al cargar las cuentas';
            this.accounts = [];
            this.accountOptions = [];
        }
    }

    handleAccountChange(event) {
        this.selectedAccountId = event.target.value;
        this.selectedOpportunityMessage = '';
    }

    handleOpportunitySelected(event) {
        const { opportunityId, opportunityName } = event.detail;
        this.selectedOpportunityMessage =
            `Oportunidad seleccionada ==> ${opportunityName} (${opportunityId}) para la cuenta ${this.selectedAccountName}`;
    }

    get selectedAccount() {
        return this.accounts.find(
            account => account.Id === this.selectedAccountId
        );
    }

    get selectedAccountName() {
        return this.selectedAccount ? this.selectedAccount.Name : '';
    }
}