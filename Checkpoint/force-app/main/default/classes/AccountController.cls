public with sharing class AccountController {
    public static List<Account> obtenerCuentasAfectadas(List<Proyecto> listaProyectos){ //listo, a testear
        List<Account> listaCuentas = [SELECT Id, Name, Proyectos_Activos__c, Limite_Proyectos_Activos__c 
                                        FROM Account 
                                        WHERE Id IN (SELECT Account__c FROM listaProyectos)];
        return listaCuentas;
    }
    
    public static void controlarActivos(List <Account> listaCuentas, List<Proyecto__c> listaProyectos){ //listo, a testear
        
        List<Proyecto__c> proyectosAInsertar = new List<Proyecto__c>();
        List<Proyecto__c> proyectosExcedidos  = new List<Proyecto__c>();
        List<Account> cuentasAUpdatear = new List<Account>();

        for(Proyecto__c p: listaProyectos){
            for(Account a: listaCuentas){
                if(p.Account__c == a.Id){
                    if(a.Limite_Proyectos_Activos__c > a.Proyectos_Activos__c){
                        proyectosAInsertar.add(p);
                        a.Proyectos_Activos__c += 1;
                        cuentasAUpdatear.add(a);
                    } else {
                        proyectosExcedidos.add(p);
                    }
                }
            }
        }
        if(proyectosAInsertar.size() > 0) {
            insert proyectosAInsertar;
            update cuentasAUpdatear;
        } 
        if(proyectosExcedidos.size() > 0) {
            delete proyectosExcedidos;
        }
    }

    public static void eliminarProyectosViejos(List <Proyecto__c> proyectos){ //listo, a testear
        List<Proyecto__c> proyectosAEliminar  = new List<Proyecto__c>();
        for(Proyecto__c p: proyectos){
            if(p.Estado__c == 'Planeado' && p.Fecha_de_Inicio__c.addYears(1) <= Date.today()){
                proyectosAEliminar.add(p);
            }
        }
        if(proyectosAEliminar.size() > 0) {delete proyectosAEliminar;}
    }
}