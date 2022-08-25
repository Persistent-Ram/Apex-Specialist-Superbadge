@isTest
public with sharing class MaintenanceRequestHelperTest {
    // implement scheduled code here
    
    @testSetup
    private static void setup() {
        List<Case> caseList = new List<Case>();
        List<Equipment_Maintenance_Item__c> mainEqpList = new List<Equipment_Maintenance_Item__c>();
        
        Vehicle__c v = new Vehicle__c(Name = 'Test Vehicle');
        insert v;
        
        Product2 p = new Product2(Name = 'Test', Maintenance_Cycle__c = 10, Replacement_Part__c = True);
        insert p;
        
        for(Integer i=0; i<300; i++) {
            caseList.add(new Case(Status = 'New', Origin = 'Web', Type = 'Routine Maintenance', Vehicle__c = v.Id));
        }
        insert caseList;
        
        for(Case c : caseList) {
            mainEqpList.add(new Equipment_Maintenance_Item__c(Maintenance_Request__c = c.Id, Equipment__c = p.Id));
        }
        insert mainEqpList;
    }
    
    @isTest 
    private static void test() {
        List<Case> updatedCaseList = [SELECT Id FROM Case WHERE Type = 'Routine Maintenance' LIMIT 300];
        List<Id> parentIdList = new List<Id>();
        
        for(Case c: updatedCaseList) {
            c.Status = 'Closed';
            parentIdList.add(c.Id);
        }
        update updatedCaseList;
        
        Integer count = 0;
        for(Case c: [SELECT Id, parentId FROM Case WHERE parentId IN :parentIdList]) {
            count += 1;
        }
        
        System.assertEquals(count, updatedCaseList.size());
    }     
}