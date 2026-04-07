import { LightningElement, wire } from 'lwc';
import searchContact from '@salesforce/apex/BC_Ejercicio3_ctr.searchContact';

const COLS = [
    {label: 'Nombre', fieldName: 'Name'},
    {label: 'Email', fieldName: 'Email'},
    {label: 'Telefono', fieldName: 'Phone'},

];

export default class BC_Ejercicio3_Apex_cmp extends LightningElement {
    contacts = [];
    columns = COLS;
    searchKey = '';

    @wire(searchContact, {searchKey: '$searchKey'})
    wiredContacts({data, error}) {
        if(data) {
            this.contacts = data;
        } else if(error) {
            console.log(error);
            this.contacts = undefined;
        }
    }

    handleOnChange(event) {
        this.searchKey = event.target.value;
    }
}