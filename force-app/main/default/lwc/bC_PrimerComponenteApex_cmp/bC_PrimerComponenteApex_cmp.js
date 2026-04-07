import { LightningElement, wire } from 'lwc';
import getAccounts from  '@salesforce/apex/BC_PrimerEjemploApexLWC_cls.getAccounts';

const COLS = [
    {label: 'Nombre', fieldName: 'Name'},
    {label: 'Telefono', fieldName: 'Phone'},
    {label: 'Industria', fieldName: 'Industry'},
    {label: 'Tipo', fieldName: 'Type'},
    {label: 'Direccion', fieldName: 'BillingStreet'}
];

export default class BC_PrimerComponenteApex_cmp extends LightningElement {
    columns = COLS;

    accounts = [];
    /*
    conectedCallback() {
        getAccounts()
            .then(result => {
                this.accounts = result;
            })
            .catch(error => {
                console.log(error);
            });
    }
    */
    @wire(getAccounts)
    wiredAccounts({error, data}) {
        if(data) {
            this.accounts = data;
            this.error = undefined;
        }
        else if(error) {
            this.error = error;
            this.accounts = undefined;
        }
    }

}