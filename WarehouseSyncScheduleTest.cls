@isTest
private with sharing class WarehouseSyncScheduleTest {
    // implement scheduled code here
    @isTest
    static void testSchedule() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String CRON_EXP = '0 0 1 * * ? 2022';
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new WarehouseSyncSchedule());
        List<Product2> p = [SELECT Id, QuantityUnitOfMeasure FROM Product2 WHERE Warehouse_SKU__c = '55d66226726b611100aaf742'];
        System.assertEquals(0, p.size(), 'Tasks exist before job has run');
        Test.stopTest();
        
    }
}