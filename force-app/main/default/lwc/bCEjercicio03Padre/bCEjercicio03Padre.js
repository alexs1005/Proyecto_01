import { LightningElement, wire } from 'lwc';
import getContact from '@salesforce/apex/BC_Ejercicio03ControlApex.getContact';

export default class BCEjercicio03Padre extends LightningElement {
    contacts = [];
    errorMessage = '';
    showContacts = false;

    @wire(getContact)
    wiredContacts({ error, data }) {
        if (data) {
            this.contacts = data;
            this.errorMessage = '';
        } else if (error) {
            this.errorMessage = 'Error al cargar los contactos';
            this.contacts = [];
        }
    }

    handleClick() {
        this.showContacts = !this.showContacts;;
    }
    
    get labelBoton() {
        return this.showContacts ? 'Ocultar Contactos' : 'Mostrar Contactos';
    }

}