public with sharing class ProyectoTriggerHandler {
    
    //listas de proyectos nuevos y viejos
    private List<Proyecto__c> newProjects {get; set;} 
    private List<Proyecto__c> oldProjects {get; set;}

    //propiedades del contexto del trigger
    public Boolean isInsert { get; set; } //desde el exterior, otro objeto puede obtener y setear estas propiedades
    public Boolean isUpdate { get; set; }
    public Boolean isDelete { get; set; }
    public Boolean isBefore { get; set; }
    public Boolean isAfter { get; set; }

    //constructor con el mismo nombre
    public ProyectoTriggerHandler(List<Proyecto__c> newProjects, List<Proyecto__c> oldProjects) {
        //inicializo los proyectos nuevos y viejos
        this.newProjects = newProjects;
        this.oldProjects = oldProjects;

        //inicializo las propiedades de contexto en falso (aunque luego puedan volverse a asignar en falso)
        this.isInsert = false;
        this.isUpdate = false;
        this.isDelete = false;
        this.isAfter = false;
        this.isBefore = false;
    }

    public void execute(){
        //ejecuto el before delete
        if(this.isBefore && this.isDelete){
            this.eliminarProyectosViejos();
        }
        if(this.isBefore && (this.isInsert || this.isUpdate)){
            this.controlarActivos(this.newProjects);
        }
        if(this.isAfter){
            if(this.isDelete){
                List<Account> cuentasAfectadas = obtenerCuentasAfectadas(this.oldProjects);
                this.actualizarPromedio(cuentasAfectadas);
            }
            else if(this.isInsert || this.isUpdate){
                List<Account> cuentasAfectadas = obtenerCuentasAfectadas(this.newProjects);
                this.actualizarPromedio(cuentasAfectadas);
            }
        }
    }

    //solo eliminar proyectos que esten en estado "Planeado" hace mas de un año
    private void eliminarProyectosViejos(){
        for(Proyecto__c p: this.oldProjects){
            if(p.Estado__c != 'Planeado' || p.Fecha_de_Inicio__c.addYears(1) > Date.today()){
                p.AddError('No se pudo eliminar el proyecto, ya que no sigue en planeado luego de 1 año');
            }
        }
    }

    //método para obtener cuentas afectadas por una lista de proyectos
    public List<Account> obtenerCuentasAfectadas(List<Proyecto__c> listaProyectos){ //ya no es estático, porque no es llamado desde el exterior
        if(listaProyectos.size() < 1){
            List<Account> listaCuentas = new List<Account>();
            return listaCuentas;
        }
        else{
            List<Id> listaIDCuentas = new List<Id>();
            for(Proyecto__c p: listaProyectos){
                    listaIDCuentas.add(p.Account__c);
            }
            List<Account> listaCuentas = [SELECT Id, Numero_Proyectos_Activos__c, Limite_Proyectos_Activos__c //ya no trae el Name, que no era usado para nada
                                            FROM Account
                                            WHERE Id IN :listaIDCuentas
                                            WITH SECURITY_ENFORCED 
                                            LIMIT 200]; //ver limites de salesforce
            return listaCuentas;
        }
    }

    //luego de un insert, update, o delete, actualiza el promedio de los presupuestos de los proyectos activos asociados a la cuenta
    private void actualizarPromedio(List<Account> listaCuentas){

        //creo mi lista de proyectos para cuentas
        Map<Id, List<Proyecto__c>> proyectosPorCuenta = new Map<Id, List<Proyecto__c>>();

        //agrego las Id de las cuentas afectadas
        for(Account a: listaCuentas){
            proyectosPorCuenta.put(a.Id, new List<Proyecto__c>());
        }

        //busco los proyectos en progreso asociados a esas cuenta 
        List<Proyecto__c> proyectosActivos = [SELECT Id, Account__c, Presupuesto__c
                                                FROM Proyecto__c 
                                                WHERE Account__c IN :proyectosPorCuenta.keySet()
                                                AND Estado__c = 'En Progreso'
                                                WITH SECURITY_ENFORCED];
        for(Proyecto__c p: proyectosActivos){
            if(proyectosPorCuenta.containsKey(p.Account__c)){
                proyectosPorCuenta.get(p.Account__c).add(p);
            }
        }
        
        //calcular el promedio de cada cuenta
        for(Account a: listaCuentas){ //va a recorrer una vez cada cuenta
            List<Proyecto__c> proyectosActivosDeLaCuenta = proyectosPorCuenta.get(a.Id);
            
            if(proyectosActivosDeLaCuenta.size() > 0){ //se agrega el distinto a null
                Decimal suma = 0;
                Integer contador = proyectosActivosDeLaCuenta.size();

                for(Proyecto__c p: proyectosActivosDeLaCuenta){ //va a recorrer solo los proyectos de la cuenta 
                        suma += p.Presupuesto__c;
                    }   
                a.Presupuesto_Promedio__c = suma / contador;
            } else {
                a.Presupuesto_Promedio__c = 0;
            }
        }
        update listaCuentas;
    }

    //controla que no sea posible crear proyectos para una cuenta que está en el límite de proyectos activos
    private void controlarActivos(List<Proyecto__c> listaProyectos){
        
        List<Account> listaCuentas = obtenerCuentasAfectadas(listaProyectos);
        Map<Id, List<Proyecto__c>> mapaProyectos = new Map<Id, List<Proyecto__c>>();
        for(Account a: listaCuentas){
            mapaProyectos.put(a.Id, new List<Proyecto__c>());
        }
        for(Proyecto__c p: listaProyectos){
            mapaProyectos.get(p.Account__c).add(p);
        }

        for(Account a: listaCuentas){
            Decimal contadorActivos = a.Numero_Proyectos_Activos__c;
            List<Proyecto__c> proyectosDeLaCuenta = mapaProyectos.get(a.Id);
            //
                for(Proyecto__c p: proyectosDeLaCuenta){
                    if(a.Limite_Proyectos_Activos__c <= contadorActivos){
                        p.AddError('No es posible crear mas proyectos para esta cuenta');                       
                    }else if(p.Estado__c == 'En Progreso'){
                        contadorActivos ++;
                    }
                }
        }
    }
}