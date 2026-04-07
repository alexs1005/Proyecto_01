import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Contact from '@salesforce/schema/Contact';
import LastName from '@salesforce/schema/Contact.LastName';
import FirstName from '@salesforce/schema/Contact.FirstName';
import Email from '@salesforce/schema/Contact.Email';
export default class AccountCreator extends LightningElement {
    objectApiName = Contact;
    fields = [LastName, FirstName, Email];
    handleSuccess(event) {
        const toastEvent = new ShowToastEvent({
            title: "Account created",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
    }
}