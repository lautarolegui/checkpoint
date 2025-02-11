import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchAccounts from '@salesforce/apex/BuscadorController.searchAccounts';
import getAllAccounts from '@salesforce/apex/BuscadorController.getAllAccounts';

const COLUMNS = [
    {label: 'Nombre', fieldName: 'Name', type: 'text'},
    {label: 'Presupuesto total', fieldName: 'Presupuesto_Total__c', type: 'number'},
    {label: 'Cantidad de Recursos', fieldName: 'Numero_de_Recursos_Totales__c', type: 'number'}
];

export default class Buscador extends LightningElement {
    columnas = COLUMNS;
    @track searchTerm = '';
    @track accounts = [];

    @wire(searchAccounts, { searchTerm: '$searchTerm' })
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data;

        } else if (error) {
            console.error('Error al cargar las cuentas', error);
        }
    }

    connectedCallback() {
        this.loadAllAccounts();
    }

    loadAllAccounts() {
        getAllAccounts()
            .then(result => {
                this.accounts = result;
            })
            .catch(error => {
                console.error('Error al cargar todas las cuentas', error);
            });
    }

    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;

        if(selectedRows.length > 1) {
            this.showNotification();
            event.detail.selectedRows = [];
        }
        if (selectedRows.length == 1) {
            this.selectedAccountId = selectedRows[0].Id;
            // Dispara un evento personalizado con el ID de la cuenta seleccionada
            this.dispatchEvent(new CustomEvent('accountselected', {
                detail: { accountId: this.selectedAccountId }
            }));
        }
    }
    showNotification() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Solo se puede seleccionar una cuenta',
            variant: 'warning',
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }
}
