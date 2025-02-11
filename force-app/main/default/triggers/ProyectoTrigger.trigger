trigger ProyectoTrigger on Proyecto__c (before insert, before delete, after insert, after update, after delete) {
    
    ProyectoTriggerHandler handler = new ProyectoTriggerHandler(Trigger.new, Trigger.old); //se instancia el trigger handler, pasando los nuevos y viejos registros
    
    //asigna los valores de contexto del trigger original a nuestro handler
    handler.isBefore = Trigger.isBefore;
    handler.isAfter = Trigger.isAfter;
    handler.isInsert = Trigger.isInsert;
    handler.isUpdate = Trigger.isUpdate;
    handler.isDelete = Trigger.isDelete;
    //ejecuta el handler
    handler.execute();
}
