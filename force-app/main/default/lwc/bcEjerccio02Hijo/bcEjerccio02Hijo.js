import { LightningElement, api } from 'lwc';

export default class BcEjerccio02Hijo extends LightningElement {
    @api cases1;

    get existeCaso() {
        return this.cases1 && this.cases1.length > 0;
    }

}