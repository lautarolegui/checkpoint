@isTest
private class BuscadorControllerTest {
    @isTest
    static void getAllAccountsTestPositivo() {
        //GIVEN
        Account cuentaTest = new Account(Name = 'Cuenta de prueba');
        insert cuentaTest;
        
        Id idCuentaTest = cuentaTest.Id;

        //WHEN
        Test.startTest();
        List<Account> lista = BuscadorController.getAllAccounts();
        Test.stopTest();

        //THEN
        Boolean encontroId = false;
        for(Account cuenta : lista) {
            if(cuenta.Id == idCuentaTest) {
                encontroId = true;
            }
        }
        Assert.isTrue(encontroId, 'No trajo la cuenta insertada');
    }

    @isTest
    static void searchAccountsTestConNombre() {
        //GIVEN
        Account cuentaTest = new Account(Name = 'Cuenta de prueba');
        insert cuentaTest;
        
        Id idCuentaTest = cuentaTest.Id;

        //WHEN
        Test.startTest();
        List<Account> lista = BuscadorController.searchAccounts('Cuenta de prueba');
        Test.stopTest();

        //THEN
        Boolean encontroId = false;
        for(Account cuenta : lista) {
            if(cuenta.Id == idCuentaTest) {
                encontroId = true;
            }
        }
        Assert.isTrue(encontroId, 'No trajo la cuenta insertada');
    }

    @isTest
    static void searchAccountsTestVacio() {
        //GIVEN
        Account cuentaTest1 = new Account(Name = 'Cuenta de prueba');
        insert cuentaTest1;
        
        Id idCuentaTest1 = cuentaTest1.Id;

        Account cuentaTest2 = new Account(Name = 'Cuenta de prueba 2');
        insert cuentaTest2;
        
        Id idCuentaTest2 = cuentaTest2.Id;

        //WHEN
        Test.startTest();
        List<Account> lista = BuscadorController.searchAccounts('');
        Test.stopTest();

        //THEN
        Boolean encontroId1 = false;
        Boolean encontroId2 = false;
        for(Account cuenta : lista) {
            if(cuenta.Id == idCuentaTest1) {
                encontroId1 = true;
            }
            if(cuenta.Id == idCuentaTest2) {
                encontroId2 = true;
            }
        }
        Assert.isTrue(encontroId1 && encontroId2, 'No trajo las cuentas insertadas');
    }
}