import { LightningElement, wire } from 'lwc';
import LastName from '@salesforce/schema/Contact.LastName';
import FirstName from '@salesforce/schema/Contact.FirstName';
import Email from '@salesforce/schema/Contact.Email';
import getContacts from '@salesforce/apex/ContactController.getContacts';
import { reduceErrors } from 'c/ldsUtils';
const COLUMNS = [
    { label: 'Apellido', fieldName: LastName.fieldApiName, type: 'text' },
    { label: 'Nombre', fieldName: FirstName.fieldApiName, type: 'text' },
    { label: 'Email', fieldName: Email.fieldApiName, type: 'text' }
];

export default class ContactList extends LightningElement {
    columns = COLUMNS; 
    contacts = [];
    errors = '';
    @wire(getContacts)
    wiredContacts({ data, error }) {
    if (data) {
        this.contacts = data;
    } else if (error) {
        this.errors = error;
        this.contacts = undefined;
    }
    }

    get errors() {
    return (this.errors) ?
        reduceErrors(this.errors) : [];
    }
}