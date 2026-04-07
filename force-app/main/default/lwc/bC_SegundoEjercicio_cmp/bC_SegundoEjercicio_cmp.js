import { LightningElement, wire } from 'lwc';
import getAccountsByIndustry from '@salesforce/apex/BC_SegundoEjercicioLWC_ctr.getAccountByIndustry';



export default class BC_SegundoEjercicio_cmp extends LightningElement {
    industry = 'Technology';

    accounts;

    errorMessage;
    isLoading = false;


    columns = [
        {label: 'Nombre', fieldName: 'Name'},
        {label: 'Industry', fieldName: 'Industry'},
    ]

    industryOptions = [
        {label: 'Technology', value: 'Technology'},
        {label: 'Banking', value: 'Banking'},
        {label: 'Biotechnology', value: 'Biotechnology'},
        {label: 'Construction', value: 'Construction'},
        {label: 'prueba', value: 'prueba'}
    ]

    
    @wire(getAccountsByIndustry, {Industry: '$industry'})
    wiredAccounts({error, data}) {
        this.isLoading = false;
        if(data) {
            this.accounts = data;
            this.error = undefined;
        } else if(error) {
            this.accounts = undefined;
            this.errorMessage = this.normalizeErrors(error);
            console.log(error);
        }
    }

    handleIndustryChange(event) {
        console.log('Valor de la industria: ', event.detail.value);
        this.industry = event.detail.value;
        this.isLoading = true;
    }

    normalizeErrors(error) {
        if(Array.isArray(error.body)) {
            return error.body.map(e => e.message);
        }
        return error?.body?.message || error?.message || 'Error desconocido';
    }
}