@IsTest
public with sharing class ProyectoControllerTest {
    @IsTest
    static void searchProyectosTestPoblado(){
        //GIVEN
        Account cuentaTest = new Account(Name = 'Cuenta 1');
        insert cuentaTest;

        Contact contactoTest = new Contact(FirstName = 'Soyde', LastName = 'Prueba', AccountId = cuentaTest.Id);
        insert contactoTest;

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
        
        Proyecto__c proyectoInsertado2 = new Proyecto__c(
            Name = 'Proyecto de prueba 2', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today(),
            Presupuesto__c = 17000, 
            Estado__c = 'En Progreso',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'Puede ser insertado',
            Contact__c = contactoTest.Id
        );
        insert proyectoInsertado2;

        //WHEN
        Test.startTest();
        List<Proyecto__c> resultado = ProyectoController.searchProyectos(cuentaTest.Id);
        Test.stopTest();

        //THEN
        Assert.areEqual(2, resultado.size(), 'Cantidad de proyectos distinta a 2');
    }

    @IsTest
    static void searchProyectosTestVacio(){
        //GIVEN
        Account cuentaTest = new Account(Name = 'Cuenta 1');
        insert cuentaTest;

        //WHEN
        Test.startTest();
        List<Proyecto__c> resultado = ProyectoController.searchProyectos(cuentaTest.Id);
        Test.stopTest();

        //THEN
        Assert.areEqual(0, resultado.size(), 'La cuenta no deberia tener ningun proyecto asociado');
    }

    @IsTest
    static void getAllProyectosTestPositivo(){
        //GIVEN
        Account cuentaTest = new Account(Name = 'Cuenta 1');
        insert cuentaTest;

        Contact contactoTest = new Contact(FirstName = 'Soyde', LastName = 'Prueba', AccountId = cuentaTest.Id);
        insert contactoTest;

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

        Id idProyectoInsertado = proyectoInsertado.Id;

        //WHEN
        Test.startTest();
        List<Proyecto__c>  resultado = ProyectoController.getAllProyectos();
        Test.stopTest();

        //THEN
        Boolean encontroId = false;
        for(Proyecto__c proyecto : resultado)
        {
            if(proyecto.Id == idProyectoInsertado){
                encontroId = true;
            }
        }
        Assert.isTrue(encontroId, 'No se obtuvo ningun proyecto de los insertados');
    }

    @IsTest
    static void deleteProyectoTestPositivo() {
        // GIVEN
        Account cuentaTest = new Account(Name = 'Cuenta 1');
        insert cuentaTest;

        Contact contactoTest = new Contact(FirstName = 'Soyde', LastName = 'Prueba', AccountId = cuentaTest.Id);
        insert contactoTest;

        // Buscar un usuario con el perfil "System Administrator"
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];

        // Ejecutar el test como el usuario administrador (que ya tiene el permiso)
        System.runAs(adminUser) {
            Proyecto__c proyectoABorrar = new Proyecto__c(
                Name = 'Proyecto de prueba', 
                Account__c = cuentaTest.Id, 
                Fecha_de_Inicio__c = System.today().addYears(-2), // bypass hecho
                Presupuesto__c = 17000, 
                Estado__c = 'Planeado',
                Numero_de_Recursos__c = 3, 
                Descripcion__c = 'Puede ser borrado',
                Contact__c = contactoTest.Id
            );
            insert proyectoABorrar;

            Id idproyectoABorrar = proyectoABorrar.Id;

            // WHEN
            Test.startTest();
            ProyectoController.deleteProyecto(idproyectoABorrar);
            Test.stopTest();

            // THEN
            List<Proyecto__c> resultado = [SELECT Id FROM Proyecto__c WHERE Id =: idproyectoABorrar];
            System.assertEquals(0, resultado.size(), 'No se borraron los proyectos esperados');
        }
    }

    @IsTest
    static void deleteProyectoTestNegativo(){ //llamar explicitamente a los metodos del controlador
        //GIVEN
        Account cuentaTest = new Account(Name = 'Cuenta 1');
        insert cuentaTest;

        Contact contactoTest = new Contact(FirstName = 'Soyde', LastName = 'Prueba', AccountId = cuentaTest.Id);
        insert contactoTest;


        // Buscar un usuario con el perfil "System Administrator"
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];

        // Ejecutar el test como el usuario administrador (que ya tiene el permiso)
        System.runAs(adminUser) {
            Proyecto__c proyectoABorrar = new Proyecto__c(
            Name = 'Proyecto de prueba', 
            Account__c = cuentaTest.Id, 
            Fecha_de_Inicio__c = System.today().addYears(-2), //bypass hecho
            Presupuesto__c = 17000, 
            Estado__c = 'En Progreso',
            Numero_de_Recursos__c = 3, 
            Descripcion__c = 'No puede ser borrado',
            Contact__c = contactoTest.Id
        );
            insert proyectoABorrar;

            Id idproyectoABorrar = proyectoABorrar.Id;

            //WHEN
            Test.startTest();
            try{
                ProyectoController.deleteProyecto(idproyectoABorrar);
            } catch(Exception e){
                System.debug('No se pudo borrar el proyecto: ' + e.getMessage());
            }
            Test.stopTest();

            //THEN
            List<Proyecto__c> resultado = [SELECT Id FROM Proyecto__c WHERE Id =: idproyectoABorrar];
            Assert.areEqual(1, resultado.size(), 'Se borro incorrectamente el proyecto');
        }
    }
}