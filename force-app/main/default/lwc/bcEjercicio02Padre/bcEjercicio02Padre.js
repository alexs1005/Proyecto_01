import { LightningElement, wire } from 'lwc';
import getCases from'@salesforce/apex/BC_Ejercicio02ControlApex.getCases';

export default class BcEjercicio02Padre extends LightningElement {
    cases = [];
    clickedButtonLabel;

    @wire(getCases)
    wiredCases({ error, data }) {
        if (data) {
            this.cases = data;
            console.log('Casos cargados:', this.cases);
        } else if (error) {
            this.errorMessage = 'Error al cargar las cuentas';
            this.cases = undefined;
        }
    }

    handleClick(event) {
        this.clickedButtonLabel = event.target.label;
    }

}