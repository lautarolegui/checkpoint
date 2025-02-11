import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PROJECT_OBJECT from '@salesforce/schema/Proyecto__c';
import ACCOUNT_FIELD from '@salesforce/schema/Proyecto__c.Account__c';
import CONTACT_FIELD from '@salesforce/schema/Proyecto__c.Contact__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Proyecto__c.Descripcion__c';
import STATUS_FIELD from '@salesforce/schema/Proyecto__c.Estado__c';
import DATE_FIELD from '@salesforce/schema/Proyecto__c.Fecha_de_Inicio__c';
import RESOURCES_FIELD from '@salesforce/schema/Proyecto__c.Numero_de_Recursos__c';
import BUDGET_FIELD from '@salesforce/schema/Proyecto__c.Presupuesto__c';
import NAME_FIELD from '@salesforce/schema/Proyecto__c.Name';

export default class CreadorProyectos extends LightningElement {
    objectApiName = PROJECT_OBJECT;
    fields = [ACCOUNT_FIELD, CONTACT_FIELD, DESCRIPTION_FIELD, STATUS_FIELD, DATE_FIELD, RESOURCES_FIELD, BUDGET_FIELD, NAME_FIELD];

    @track formKey = 0; // Usado para forzar la recarga del formulario

    handleSuccess(event) {
        // Mostrar mensaje de éxito
        const evt = new ShowToastEvent({
            title: 'Proyecto creado',
            message: 'Record ID: ' + event.detail.id,
            variant: 'success',
        });
        this.dispatchEvent(evt);

        const editForm = this.template.querySelector('lightning-record-form');
        editForm.recordId = null;
    }
}

    