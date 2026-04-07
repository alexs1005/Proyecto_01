import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/BC_ControladorApexComunicacion.getAccounts';

export default class BcComponentePadre extends LightningElement {
    accounts = [];
    accountOptions = [];
    selectedAccount = null;
    message = '';
    errorMessage = '';

    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data;
            this.accountOptions = data.map(acc => ({
                label: acc.Name,
                value: acc.Id
            }));

            if (data.length > 0){
                this.selectedAccount = data[0];
            }

            this.errorMessage = '';
        } else if (error) {
            this.errorMessage = 'Error al cargar las cuentas';
            this.accounts = [];
            this.accountOptions = [];
            this.selectedAccount = null;
        }
    }

    handleAccountChange(event) {
        const selectedId = event.detail.value;
        this.selectedAccount = this.accounts.find(acc => acc.Id === selectedId);
        this.message = '';
    }

    handleConfirmSelection(event) {
        const { accountId, accountName } = event.detail;
        this.message = 'Cuenta seleccionada: ${accountName} Id de la cuenta: ${accountId}';
    }

    get selectedAccountId() {
        return this.selectedAccount ? this.selectedAccount.Id : null;
    }

}