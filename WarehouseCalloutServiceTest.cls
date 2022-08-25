@isTest
private class WarehouseCalloutServiceTest {
    // implement your mock callout test here
    @isTest
    static void testGetcallout() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock()); 
        Test.startTest();
        WarehouseCalloutService upsertJob = new WarehouseCalloutService();
        System.enqueueJob(upsertJob);
        Test.stopTest();
		
        Product2 p = [SELECT Id, QuantityUnitOfMeasure FROM Product2 WHERE Warehouse_SKU__c = '55d66226726b611100aaf742'];

        // String expectedValue = '[{"_id":"55d66226726b611100aaf742","replacement":true,"quantity":183,"name":"Cooling Fan","maintenanceperiod":0,"lifespan":0,"cost":300,"sku":"100004"}]';
        String expectedValue = '183';
        System.assertEquals(expectedValue, p.QuantityUnitOfMeasure);
    }
}