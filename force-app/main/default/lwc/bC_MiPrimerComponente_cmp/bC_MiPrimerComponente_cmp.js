import { LightningElement } from 'lwc';
import LightningConfirm from 'lightning/confirm';
import generateData from './generateData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Bc_MiPrimerComponente_cmp extends LightningElement {

    data = [];

    mostrarBoton = false;
    isModalOpen = false;

    handleClick() {
        this.isModalOpen = true;
        this.mostrarBoton = !this.mostrarBoton;

        setTimeout(() => {
            this.isModalOpen = false;
        }, 1000);

        this.dispatchEvent(new ShowToastEvent({
            title: 'Éxito',
            message: this.mostrarBoton
                ? 'El mensaje del botón se ha mostrado correctamente.'
                : 'El mensaje del botón se ha ocultado correctamente.',
            variant: 'success'
        }));
    }

    async handleConfirmation() {
        const result = await LightningConfirm.open({
            message: 'Este es un mensaje de Confirmación',
            label: 'Deseas continuar?',
            theme: 'warning',
        });
        console.log('ejemplo de log en javascript LWC', result);
    }

    connectedCallback() {
        const data = generateData({ amountOfRecords: 100 });
        this.data = data;
    }
}