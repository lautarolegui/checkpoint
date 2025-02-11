public with sharing class ProyectoController {
    @AuraEnabled(cacheable=true scope='global')
    public static List<Proyecto__c> getAllProyectos() {
        return [SELECT Name, Contact__r.Name , Presupuesto__c, Estado__c FROM Proyecto__c WITH SECURITY_ENFORCED];
    }

    @AuraEnabled(cacheable=true scope='global')
    public static List<Proyecto__c> searchProyectos(Id cuentaABuscar) {
        return [SELECT Name, Contact__r.Name , Presupuesto__c, Estado__c FROM Proyecto__c WHERE Account__c = :cuentaABuscar WITH SECURITY_ENFORCED];
    }

    @AuraEnabled
    public static void deleteProyecto(Id proyectoId) {
        try {
            Proyecto__c proyecto = [SELECT Id FROM Proyecto__c WHERE Id = :proyectoId WITH SECURITY_ENFORCED LIMIT 1];
            delete proyecto;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('No se pudo eliminar el proyecto: ' + e.getMessage());
        }
    }
}
