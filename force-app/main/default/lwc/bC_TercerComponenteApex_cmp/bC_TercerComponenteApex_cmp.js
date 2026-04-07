import { LightningElement } from 'lwc';
import searchAccount from '@salesforce/apex/BC_TercerComponenteApex_ctr.searchAccount';

const COLS = [
    {label: 'Nombre', fieldName: 'Name'},
    {label: 'Direccion', fieldName: 'BillingStreet'},
    {label: 'Empresa', fieldName: 'Industry'},
    {label: 'Telefono', fieldName: 'Phone'}
];

export default class BC_TercerComponenteApex_cmp extends LightningElement {
    accounts = [];
    columns = COLS;
    searchKey = '';

    handleOnChange(event) {
        this.searchKey = event.target.value;
        console.log('Valor de la busqueda: ', JSON-stringify(this.serachKey));
        this.cargarCuentas();
    }

    cargarCuentas() {
        searchAccount({serachKey: this.searchKey})
        .then(result => {
            this.accounts = result;
            console.log('Cuentas encontradas: ', JSON.stringify(accounts));
        })
        .catch(error => {
            console.log(error);
        });
    }

}