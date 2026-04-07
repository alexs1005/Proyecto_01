import { LightningElement, api, track, wire } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import TYPE_FIELD from '@salesforce/schema/Account.Type';
import WEBSITE_FIELD from '@salesforce/schema/Account.Website';
import RATING_FIELD from '@salesforce/schema/Account.Rating';

const FIELDS = [NAME_FIELD, INDUSTRY_FIELD, PHONE_FIELD, TYPE_FIELD, WEBSITE_FIELD, RATING_FIELD];

const COLS = [
    {label: 'Nombre', fieldName: 'Name'},
    {label: 'Industria', fieldName: 'Industry'},
    {label: 'Telefono', fieldName: 'Phone'},
    {label: 'Tipo', fieldName: 'Type'},
    {label: 'Sitio Web', fieldName: 'Website'},
    {label: 'Rating', fieldName: 'Rating'}
];


export default class AccountViewer extends LightningElement {
    @api recordId;

    @track columns = COLS;

    @track showDetalis = false;
    @track accountData;
    error;

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    wiredAccount({error, data}) {
        if(data) {
            this.accountData = data;
            this.error =  undefined;
        }
        else if(error) {
            this.error = error;
            this.accountData = undefined;
        }
    }

    get accountName() {
        return this.accountData.fields.Name.value;
    }
    get industry() {
        return this.accountData.fields.industry.value;
    }
    get phone() {
        return this.accountData.fields.phone.value;
    }
    get rating() {
        return this.accountData.fields.rating.value;
    }
    get website() {
        return this.accountData.fields.website.value;
    }

    get type () {
        return this.accountData.fields.type.value;
    }
    get rating() {
        return this.accountData.fields.rating.value;
    }
    
    get botonEtiqueta() {
        return this.showDetails ? 'ocultar Detalles' : 'Mostrar Detalles';;
    }
    handleClick() {
        this.showDetalis = !this.showDetails;
    }

}
