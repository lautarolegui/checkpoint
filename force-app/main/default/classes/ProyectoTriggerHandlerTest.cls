@IsTest
private class ProyectoTriggerHandlerTest {
    @TestSetup //se agrega el test setup para los test, para optimizar el codigo
    static void cargaCuentas() {
        Account cuentaTest = new Account(Name = 'Cuenta 1');
        insert cuentaTest;

        Contact contactoTest = new Contact(FirstName = 'Soyde', LastName = 'Prueba', AccountId = cuentaTest.Id);
        insert contactoTest;
    }

    @IsTest
    static void eliminarProyectosViejosTestPositivo() {
        //GIVEN
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Cuenta 1' LIMIT 1];

        Contact contactoTest = [SELECT Id FROM Contact WHERE FirstName = 'Soyde' LIMIT 1];

        // Buscar un usuario con el perfil "System Administrator"
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];

        // Ejecutar el test como el usuario administrador (que ya tiene el permiso)
        System.runAs(adminUser) {
            Proyecto__c proyectoAEliminar = new Proyecto__c(
            Name = 'Proyecto Viejo', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today().addYears(-2), //bypass hecho
            Presupuesto__c = 10000, 
            Estado__c = 'Planeado', 
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Descripción de prueba',
            Contact__c = contactoTest.Id
        );
        insert proyectoAEliminar;

        List<Proyecto__c> proyectos = [SELECT Id FROM Proyecto__c WHERE Id = :proyectoAEliminar.Id];

        //WHEN
        Test.startTest();
        delete proyectos; //no hace falta instanciar el handler, ya que se ejecuta con el trigger, y pasa la info automaticamente
        Test.stopTest();

        //THEN
        List<Proyecto__c> proyectosPostEliminacion = [SELECT Id FROM Proyecto__c WHERE Id = :proyectoAEliminar.Id];
        Assert.areEqual(0, proyectosPostEliminacion.size(), 'Deberian haber 0 proyectos con esa Id');
        }
    }

    @IsTest
    static void eliminarProyectosViejosTestNegativoFecha() {
        //GIVEN
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Cuenta 1' LIMIT 1];

        Contact contactoTest = [SELECT Id FROM Contact WHERE FirstName = 'Soyde' LIMIT 1];

        Proyecto__c proyectoAEliminar = new Proyecto__c(
            Name = 'Proyecto Nuevo', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 10000, 
            Estado__c = 'Planeado', 
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Descripción de prueba',
            Contact__c = contactoTest.Id
        );
        insert proyectoAEliminar;

        List<Proyecto__c> proyectos = [SELECT Id FROM Proyecto__c WHERE Id = :proyectoAEliminar.Id];

        //WHEN
        Test.startTest();
        try{
            delete proyectos; //no hace falta instanciar el handler, ya que se ejecuta con el trigger, y pasa la info automaticamente
        }catch(Exception e){
            System.debug('No se pudo eliminar el proyecto: ' + e.getMessage());
        }
        Test.stopTest();

        //THEN
        List<Proyecto__c> proyectosPostEliminacion = [SELECT Id FROM Proyecto__c WHERE Id = :proyectoAEliminar.Id];
        Assert.areEqual(1, proyectosPostEliminacion.size(), 'Deberia haber 1 proyecto con esa Id');
    }

    @IsTest
    static void eliminarProyectosViejosTestNegativoEstado() {
        //GIVEN
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Cuenta 1' LIMIT 1];

        Contact contactoTest = [SELECT Id FROM Contact WHERE FirstName = 'Soyde' LIMIT 1];


        // Buscar un usuario con el perfil "System Administrator"
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];

        // Ejecutar el test como el usuario administrador (que ya tiene el permiso)
        System.runAs(adminUser) {
            Proyecto__c proyectoAEliminar = new Proyecto__c(
            Name = 'Proyecto Nuevo', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today().addYears(-2), //bypass hecho
            Presupuesto__c = 10000, 
            Estado__c = 'Finalizado', 
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Descripción de prueba',
            Contact__c = contactoTest.Id
        );
        insert proyectoAEliminar;

        List<Proyecto__c> proyectos = [SELECT Id FROM Proyecto__c WHERE Id = :proyectoAEliminar.Id];

        //WHEN
        Test.startTest();
        try{
            delete proyectos; //no hace falta instanciar el handler, ya que se ejecuta con el trigger, y pasa la info automaticamente
        }catch(Exception e){
            System.debug('No se pudo eliminar el proyecto: ' + e.getMessage());
        }
        Test.stopTest();

        //THEN
        List<Proyecto__c> proyectosPostEliminacion = [SELECT Id FROM Proyecto__c WHERE Id = :proyectoAEliminar.Id];
        Assert.areEqual(1, proyectosPostEliminacion.size(), 'Deberia haber 1 proyecto con esa Id');
        }
    }

    @IsTest
    static void obtenerCuentasAfectadasTestListaVacia(){
        //GIVEN
        List<Proyecto__c> listaProyectos = new List<Proyecto__c>();
        //WHEN
        Test.startTest();
        List<Account> listaCuentasAfectadas = ProyectoTriggerHandler.obtenerCuentasAfectadas(listaProyectos);
        Test.stopTest();
        //THEN
        Assert.areEqual(0, listaCuentasAfectadas.size(), 'La lista retornada no esta vacia');
    }

    @IsTest
    static void obtenerCuentasAfectadasTestListaPoblada(){
        //GIVEN
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Cuenta 1' LIMIT 1];

        Contact contactoTest = [SELECT Id FROM Contact WHERE FirstName = 'Soyde' LIMIT 1];

        List<Proyecto__c> listaProyectos = new List<Proyecto__c>();
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Proyecto de prueba', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 10000, 
            Estado__c = 'Planeado', 
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Descripción de prueba',
            Contact__c = contactoTest.Id
        );
        
        listaProyectos.add(proyecto);

        insert listaProyectos;
        
        //WHEN
        Test.startTest();
        List<Account> listaCuentasAfectadas = ProyectoTriggerHandler.obtenerCuentasAfectadas(listaProyectos);
        Test.stopTest();
        //THEN
        Assert.areEqual(1, listaCuentasAfectadas.size(), 'La lista retornada no contiene 1 elemento');
    }

    @IsTest
    static void controlarActivosTestPositivo(){
        //GIVEN
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Cuenta 1' LIMIT 1];

        Contact contactoTest = [SELECT Id FROM Contact WHERE FirstName = 'Soyde' LIMIT 1];

        List<Proyecto__c> listaProyectos = new List<Proyecto__c>();
        Proyecto__c proyectoAInsertar = new Proyecto__c(
            Name = 'Proyecto de prueba', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 10000, 
            Estado__c = 'Planeado',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Puede ser insertado',
            Contact__c = contactoTest.Id
        );
        
        listaProyectos.add(proyectoAInsertar);

        //WHEN
        Test.startTest();
        insert listaProyectos;
        Test.stopTest();

        //THEN
        List<Proyecto__c> listaProyectosInsertados = [SELECT Id FROM Proyecto__c WHERE Id IN :listaProyectos];
        Assert.areEqual(1, listaProyectosInsertados.size(), 'Deberia haber 1 proyecto insertado');

    }

    @IsTest
    static void controlarActivosTestNegativo(){
        //GIVEN
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Cuenta 1' LIMIT 1];

        Contact contactoTest = [SELECT Id FROM Contact WHERE FirstName = 'Soyde' LIMIT 1];

        Proyecto__c proyectoAInsertar = new Proyecto__c(
            Name = 'Proyecto de prueba', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 10000, 
            Estado__c = 'En Progreso',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Puede ser insertado',
            Contact__c = contactoTest.Id
        );
        insert proyectoAInsertar; //inserto un proyecto activo

        Proyecto__c proyectoExcedido = new Proyecto__c(
            Name = 'Proyecto de prueba', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 10000, 
            Estado__c = 'Planeado',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'No puede ser insertado',
            Contact__c = contactoTest.Id
        );
        
        List<Proyecto__c> listaProyectos = new List<Proyecto__c>();
        listaProyectos.add(proyectoExcedido); //creo una lista con los proyectos que no se deberian poder insertar

        //WHEN
        Test.startTest();
        try{
            insert listaProyectos; //trato de insertar los proyectos excedidos
        }catch(Exception e){
        System.debug('No se pudo insertar el proyecto: ' + e.getMessage());
        }
        Test.stopTest();

        //THEN
        List<Proyecto__c> listaProyectosExcedidos = [SELECT Id FROM Proyecto__c WHERE Id IN :listaProyectos]; //busco si se pudieron insertar los proyectos excedidos
        Assert.areEqual(0, listaProyectosExcedidos.size(), 'No deberian haber nuevos proyectos insertados para esa cuenta');

    }

    @IsTest
    static void controlarActivosTestMixto(){
        //GIVEN
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Cuenta 1' LIMIT 1];

        Contact contactoTest = [SELECT Id FROM Contact WHERE FirstName = 'Soyde' LIMIT 1];
        
        Proyecto__c proyectoInsertado = new Proyecto__c(
            Name = 'Proyecto de prueba 1', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 10000, 
            Estado__c = 'En Progreso',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Puede ser insertado',
            Contact__c = contactoTest.Id
        );

        insert proyectoInsertado;

        Proyecto__c proyectoPendienteInsercion = new Proyecto__c(
            Name = 'Proyecto de prueba 2', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 10000, 
            Estado__c = 'En Progreso',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'puede ser insertado',
            Contact__c = contactoTest.Id
        );

        Proyecto__c proyectoExcedido = new Proyecto__c(
            Name = 'Proyecto de prueba 3', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 10000, 
            Estado__c = 'Planeado',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'No puede ser insertado',
            Contact__c = contactoTest.Id
        );

        List<Proyecto__c> listaProyectos = new List<Proyecto__c>();
        listaProyectos.add(proyectoPendienteInsercion);
        listaProyectos.add(proyectoExcedido);

        //WHEN
        Test.startTest();
        try{
            insert listaProyectos;
        }catch(Exception e){
        System.debug('No se pudo insertar el proyecto: ' + e.getMessage());
        }
        Test.stopTest();

        //THEN
        List<Proyecto__c> listaProyectosInsertados = [SELECT Id FROM Proyecto__c WHERE Account__c = :cuentaTest.Id]; //busco si se pudieron insertar los proyectos excedidos
        Assert.areEqual(1, listaProyectosInsertados.size(), 'No se deberia haber insertado ningun proyecto de la lista');
    }


    @IsTest
    static void actualizarPromedioTestCeroInsert(){ //si inserto alguno que no este "En Progreso" que no se modifique el promedio
        //GIVEN
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Cuenta 1' LIMIT 1];

        Contact contactoTest = [SELECT Id FROM Contact WHERE FirstName = 'Soyde' LIMIT 1];

        Proyecto__c proyectoAInsertar = new Proyecto__c(
            Name = 'Proyecto de prueba', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 10000, 
            Estado__c = 'Planeado',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Puede ser insertado',
            Contact__c = contactoTest.Id
        );

        //WHEN
        Test.startTest();
        insert proyectoAInsertar;
        Test.stopTest();

        //THEN
        Account cuentaFinal = [SELECT Id, Presupuesto_Promedio__c FROM Account WHERE Id = :cuentaTest.Id LIMIT 1]; //hay que cargar los datos de la cuenta de nuevo
        Assert.areEqual(0, cuentaFinal.Presupuesto_Promedio__c, 'El presupuesto promedio de los proyectos activos es distinto a 0');
    }

    @IsTest
    static void actualizarPromedioTestCeroUpdate(){ //testea si luego de cambiar el estado del unico proyecto activo de una cuenta a "Finalizado" se acutaliza el presupuesto a 0.
        //GIVEN
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Cuenta 1' LIMIT 1];

        Contact contactoTest = [SELECT Id FROM Contact WHERE FirstName = 'Soyde' LIMIT 1];

        Proyecto__c proyectoAInsertar = new Proyecto__c(
            Name = 'Proyecto de prueba', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 10000, 
            Estado__c = 'En Progreso',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Puede ser insertado',
            Contact__c = contactoTest.Id
        );
        insert proyectoAInsertar;

        proyectoAInsertar.Estado__c = 'Finalizado';

        //WHEN
        Test.startTest();
        update proyectoAInsertar;
        Test.stopTest();

        //THEN
        Account cuentaFinal = [SELECT Id, Presupuesto_Promedio__c FROM Account WHERE Id = :cuentaTest.Id LIMIT 1]; //hay que cargar los datos de la cuenta de nuevo
        Assert.areEqual(0, cuentaFinal.Presupuesto_Promedio__c, 'El presupuesto promedio de los proyectos activos es distinto a 0');
    }

    @IsTest
    static void actualizarPromedioTestCeroDelete(){ //si borro un proyecto viejo, que no modifique el promedio
        //GIVEN
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Cuenta 1' LIMIT 1];

        Contact contactoTest = [SELECT Id FROM Contact WHERE FirstName = 'Soyde' LIMIT 1];

        // Buscar un usuario con el perfil "System Administrator"
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];

        // Ejecutar el test como el usuario administrador (que ya tiene el permiso)
        System.runAs(adminUser) {
            Proyecto__c proyectoAEliminar = new Proyecto__c(
            Name = 'Proyecto Viejo', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today().addYears(-2),//bypass hecho
            Presupuesto__c = 10000, 
            Estado__c = 'Planeado', 
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Descripción de prueba',
            Contact__c = contactoTest.Id
        );
        insert proyectoAEliminar;

        //WHEN
        Test.startTest();
        delete proyectoAEliminar;
        Test.stopTest();

        //THEN
        Account cuentaFinal = [SELECT Id, Presupuesto_Promedio__c FROM Account WHERE Id = :cuentaTest.Id LIMIT 1]; //hay que cargar los datos de la cuenta de nuevo
        Assert.areEqual(0, cuentaFinal.Presupuesto_Promedio__c, 'El presupuesto promedio de los proyectos activos es distinto a 0');
        }
    }

    @IsTest
    static void actualizarPromedioTestInsertEnProgreso(){ //si inserto un proyecto "En Progreso" y hay otro "En Progreso", hay que actualizar el promedio
        //GIVEN
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Cuenta 1' LIMIT 1];

        Contact contactoTest = [SELECT Id FROM Contact WHERE FirstName = 'Soyde' LIMIT 1];

        Proyecto__c proyectoInsertado = new Proyecto__c(
            Name = 'Proyecto de prueba', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 20000, 
            Estado__c = 'En Progreso',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Puede ser insertado',
            Contact__c = contactoTest.Id
        );
        insert proyectoInsertado;

        Proyecto__c proyectoAInsertar = new Proyecto__c(
            Name = 'Proyecto de prueba', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 10000, 
            Estado__c = 'En Progreso',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Puede ser insertado',
            Contact__c = contactoTest.Id
        );

        //WHEN
        Test.startTest();
        insert proyectoAInsertar;
        Test.stopTest();

        //THEN
        Account cuentaFinal = [SELECT Id, Presupuesto_Promedio__c FROM Account WHERE Id = :cuentaTest.Id LIMIT 1]; //hay que cargar los datos de la cuenta de nuevo
        Assert.areEqual(15000, cuentaFinal.Presupuesto_Promedio__c, 'El presupuesto promedio de los proyectos activos es distinto a 0');
    }

    @IsTest
    static void actualizarPromedioTestInsertPlaneado(){ //si inserto un proyecto "Planeado", que no modifique el promedio
        //GIVEN
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Cuenta 1' LIMIT 1];

        Contact contactoTest = [SELECT Id FROM Contact WHERE FirstName = 'Soyde' LIMIT 1];

        Proyecto__c proyectoInsertado = new Proyecto__c(
            Name = 'Proyecto de prueba', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 20000, 
            Estado__c = 'En Progreso',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Puede ser insertado',
            Contact__c = contactoTest.Id
        );
        insert proyectoInsertado;

        Proyecto__c proyectoAInsertar = new Proyecto__c(
            Name = 'Proyecto de prueba', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 10000, 
            Estado__c = 'Planeado',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Puede ser insertado',
            Contact__c = contactoTest.Id
        );

        //WHEN
        Test.startTest();
        insert proyectoAInsertar;
        Test.stopTest();

        //THEN
        Account cuentaFinal = [SELECT Id, Presupuesto_Promedio__c FROM Account WHERE Id = :cuentaTest.Id LIMIT 1]; //hay que cargar los datos de la cuenta de nuevo
        Assert.areEqual(20000, cuentaFinal.Presupuesto_Promedio__c, 'El presupuesto promedio de los proyectos activos es distinto a 0');
    }

    @IsTest
    static void actualizarPromedioTestUpdateEnProgreso(){ //si cambio el estado de un proyecto "En Progreso" a "Finalizado" y hay otro "En Progreso", hay que actualizar el promedio
        //GIVEN
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Cuenta 1' LIMIT 1];

        Contact contactoTest = [SELECT Id FROM Contact WHERE FirstName = 'Soyde' LIMIT 1];

        Proyecto__c proyectoInsertado = new Proyecto__c(
            Name = 'Proyecto de prueba', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 17000, 
            Estado__c = 'En Progreso',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Puede ser insertado',
            Contact__c = contactoTest.Id
        );
        insert proyectoInsertado;

        Proyecto__c proyectoAUpdatear = new Proyecto__c(
            Name = 'Proyecto de prueba', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 10000, 
            Estado__c = 'En Progreso',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Puede ser insertado',
            Contact__c = contactoTest.Id
        );
        insert proyectoAUpdatear;

        proyectoAUpdatear.Estado__c = 'Finalizado';
        
        //WHEN
        Test.startTest();
        update proyectoAUpdatear;
        Test.stopTest();

        //THEN
        Account cuentaFinal = [SELECT Id, Presupuesto_Promedio__c FROM Account WHERE Id = :cuentaTest.Id LIMIT 1]; //hay que cargar los datos de la cuenta de nuevo
        Assert.areEqual(17000, cuentaFinal.Presupuesto_Promedio__c, 'El presupuesto promedio de los proyectos activos es distinto al esperado');
    }
}