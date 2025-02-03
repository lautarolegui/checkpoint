trigger ProyectoTrigger on Proyecto (before insert, before delete, after insert, after update, after delete) {
    List<Proyecto__c> proyectosNuevos = Trigger.new;
    List<Account> cuentasAfectadas = accountController.obtenerCuentasAfectadas(proyectosNuevos);
    if (Trigger.isBefore){
        if(Trigger.isInsert){//before insert
        AccountController.controlarActivos(cuentasAfectadas, proyectosNuevos);//evitar superar el limite de proyectos activos por cuenta
        }
        else if(Trigger.isDelete){//before delete
        AccountController.eliminarProyectosViejos(Trigger.old);//solo eliminar proyectos que sigan en "Planeado", e iniciados hace más de un año
        }
    
    }
    else if (Trigger.isAfter){//after
        //obtenerProyectosCuenta()
        //filtrar En Progreso y traer presupuestos
        //calcularPromedio
    }
}