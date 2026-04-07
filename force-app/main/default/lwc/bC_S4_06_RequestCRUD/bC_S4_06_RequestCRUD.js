import { LightningElement } from 'lwc';
import getRequets from '@salesforce/apex/BC_S4_06_Request_CRUD_ctr.getRequests';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

import SUBJECT_FIELD from "@salesforce/schema/Request__c.Subject__c";
import STATUS_FIELD from "@salesforce/schema/Request__c.Status__c";

const columns = [
    { label: 'subject', fieldName: 'Subject__c', editable: true },
    { label: 'Status', fieldName: 'Status__c', editable: true},
    { label: 'Priority', fieldName: 'Priority__c', editable: true},
    { label: 'DueDate', fieldName: 'DueDate__c', type: 'date',editable: true },
    { label: 'Description', fieldName: 'Descriptin__c',editable: true },
    { label: 'Requester', fieldName: 'Requester__c',editable: true },
    { label: 'OwnerId', fieldName: 'OwnerId',editable: true },
];

const columns2 = [SUBJECT_FIELD, STATUS_FIELD];

export default class BC_S4_06_RequestCRUD extends LightningElement {
    data = [];
    columns = columns;
    showForm = false;
    rowOffset = 0;
    draftValues = [];

    connectedCallback() {
        getRequets()
        .then(result => {
            this.data = result;
        })
    }

    handleNewRequest(){
        this.showForm = true;
    }

    
    handleSuccess(event) {
            this.showForm = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Éxito',
                    message: 'Request creado con Id: ' + event.detail.id,
                    variant: 'success'
                })
            );
        }

    
    closeModal() {
        this.showForm = false;
    }


    
    async handleSave(event) {
        const drafts = event.detail.draftValues;

        // Cada draft trae Id + campos editados
        const recordInputs = drafts.map(draft => ({
            fields: { ...draft }
        }));

        try {
            await Promise.all(recordInputs.map(input => updateRecord(input)));

            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Éxito',
                message: 'Registros actualizados',
                variant: 'success'
            })
            );

            // Limpia los cambios pendientes
            this.draftValues = [];

            // Recarga la tabla (como ya lo haces en connectedCallback)
            const result = await getRequets();
            this.data = result;

        } catch (error) {
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'No se pudo guardar',
                variant: 'error'
            })
            );
        }
    }



}