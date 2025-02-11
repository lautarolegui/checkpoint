import { LightningElement, wire, api, track } from 'lwc';
import searchProyectos from '@salesforce/apex/ProyectoController.searchProyectos';
import getAllProyectos from '@salesforce/apex/ProyectoController.getAllProyectos';
import deleteProyecto from '@salesforce/apex/ProyectoController.deleteProyecto';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const COLUMNS = [
    { label: 'Nombre', fieldName: 'Name', type: 'text' },
    { label: 'Contacto relacionado', fieldName: 'contactName', type: 'text' },
    { label: 'Presupuesto', fieldName: 'Presupuesto__c', type: 'number' },
    { label: 'Estado', fieldName: 'Estado__c', type: 'text' },
    {
        type: "button", label: 'Delete', initialWidth: 110, typeAttributes: {
            label: 'Delete',
            name: 'delete',
            title: 'Delete',
            disabled: false,
            value: 'delete',
            iconPosition: 'left',
            iconName: 'utility:delete',
            variant: 'destructive'
        }
    }
];

export default class ListadoProyectos extends LightningElement {
    columns = COLUMNS;
    @api accountId;
    @track proyectos = [];
    @track error;

    // Wire para obtener proyectos basados en la cuenta seleccionada
    @wire(searchProyectos, { cuentaABuscar: '$accountId' })
    wiredProyectos(result) {
        this.wireResult = result; // Almacenar el resultado para usar refreshApex
        const { data, error } = result;
        if (data) {
            this.proyectos = data.map(proyecto => ({ //proyecto es el nombre que le doy al objeto que estoy iterando por cada proyecto retorna un .json, y lo que esta luego de => son las operaciones que realizo sobre el parametro
                ...proyecto, //desarma el objeto proyecto con sus pares clave valor
                contactName: proyecto.Contact__r ? proyecto.Contact__r.Name : '' // Agrega una propiedad extra, contactName. Busca si hay un contacto, luego su nombre, si no hay se asigna un vacío ''
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.proyectos = [];
        }
    }

    // Cargar todos los proyectos al iniciar el componente
    connectedCallback() {
        this.loadAllProyectos();
    }

    // Método para cargar todos los proyectos
    loadAllProyectos() {
        getAllProyectos()
            .then(result => {
                this.proyectos = result;
            })
            .catch(error => {
                console.error('Error al cargar todos los proyectos', error);
            });
    }

    // Manejar la acción de eliminar
    handleDeleteRow(event) {
        const proyectoId = event.detail.row.Id; // Usar 'Id' en lugar de 'id'
        deleteProyecto({ proyectoId: proyectoId }) // Pasar el parámetro como un objeto
            .then(() => {
                // Mostrar mensaje de éxito
                this.showToast('Éxito', 'Proyecto eliminado correctamente', 'success', 'dismissable');

                // Actualizar la lista de proyectos
                this.proyectos = this.proyectos.filter(proyecto => proyecto.Id !== proyectoId);

                // Refrescar los datos si se usa @wire
                return refreshApex(this.wireResult);
            })
            .catch(error => {
                // Mostrar mensaje de error
                this.showToast('Error', 'No se pudo eliminar el proyecto', 'error', 'dismissable');
                console.error('Error al eliminar el proyecto:', error);
            });
    }

    // Método para mostrar mensajes Toast
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
}