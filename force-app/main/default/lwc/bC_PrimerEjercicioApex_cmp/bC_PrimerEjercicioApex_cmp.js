import { LightningElement, api, wire } from 'lwc';
import OporFromAccount from '@salesforce/apex/BC_PrimerEjercicioApex_ctr.OporFromAccount';

const COLS = [
    {label: 'Nombre de Oportunidad', fieldName: 'Name'},
    {label: 'Fecha de creacion', fieldName: 'CreatedDate'}
];

export default class BC_PrimerEjercicioApex_cmp extends LightningElement {
    @api recordId;
    columns = COLS;
    Oppor;
    error;

    @wire(OporFromAccount,{accountId:'$recordId'})
    wireCases({error,data}) {
        if(data) {
            console.log('Id de la cuenta: ', this.recordId);
            console.log('Lista de casos: ', data);
            this.Oppor = data;
            console.log('Lista de casos: ', this.Oppor);
            this.error = undefined;
        }
        else if(error) {
            this.error = 'Ha ocurrido un error al cargar los casos';
            this.Oppor = undefined;
        }
    }

}