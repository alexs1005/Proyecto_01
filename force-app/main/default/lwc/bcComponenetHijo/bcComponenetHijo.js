import { LightningElement, api } from 'lwc';

export default class BcComponenetHijo extends LightningElement {
    @api account;

    get existeCuenta() {
        return this.account && this.account.Id;
    }

    handleClick() {
        const confirmEvenet = new CustomEvent('confirmarseleccion', {
            detail: {
            accountId: this.account.Id,
            accountName: this.account.Name
            } 
        });
        this.dispatchEvent(confirmEvenet);
    };
}