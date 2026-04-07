import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/CaseAccountController_ctr.getAccounts';

export default class BcListaCasosPadre extends LightningElement {
    accounts = [];
    accountOptions = [];
    selectedAccountId;
    selectedCaseMessage = '';
    errorMessage = '';

    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {

            this.accounts = data;


            this.accountOptions = data.map(account => ({
                label: account.Name,
                value: account.Id
            }));


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
        this.selectedCaseMessage = '';
    }

    handleCaseSelected(event) {
        const { CaseId, CaseNumber } = event.detail;
        this.selectedCaseMessage =
            `Caso seleccionado ==> ${CaseNumber} (${CaseId}) para la cuenta ${this.selectedAccountName}`;
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