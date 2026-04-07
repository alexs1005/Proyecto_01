import { LightningElement, api } from 'lwc';

export default class BcEjercicios03Hijo extends LightningElement {
    @api contacts;

    get existecontact() {
        return this.contacts && this.contacts.length > 0;
    }

}