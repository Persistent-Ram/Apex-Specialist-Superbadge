public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> newList, Map<Id,Case> oldMap) {
        // TODO: Complete the method to update workorders
        
        // Map<Id,Case> mList = new Map<Id,Case>();
        List<Id> caseId = new List<Id>();
        List<Case> casesToBeInserted = new List<Case>();
        
        for(Case cs: newList) {
            if(oldMap != NULL && cs.Status == 'Closed' && (cs.Type == 'Repair' || cs.Type == 'Routine Maintenance')) {
                // mList.put(cs.Id,cs);
                caseId.add(cs.Id);
            }
        }
        
        List<Equipment_Maintenance_Item__c> eqpList = [SELECT Id, Equipment__r.Maintenance_Cycle__c FROM Equipment_Maintenance_Item__c 
                                                       WHERE Maintenance_Request__r.Id =: caseId ORDER BY Equipment__r.Maintenance_Cycle__c LIMIT 1];
        
        for(Case cs: [SELECT Id FROM Case WHERE Status = 'Closed' AND (Type = 'Repair' OR Type = 'Routine Maintenance') AND Id IN :newList LIMIT 200]) {
            Case reqToUpdate = new Case(Status = 'New', 
                                        Origin = 'Web', 
                                        Type = 'Routine Maintenance', 
                                        Vehicle__c = oldMap.get(cs.Id).Vehicle__c,
                                        // Vehicle__c = cs.Vehicle__c,
                                        Subject = 'This is a new Maintenance Request',
                                        Date_Reported__c = System.today(),
                                        parentId = cs.Id,
                                        Date_Due__c = System.today() + (Integer) eqpList[0].Equipment__r.Maintenance_Cycle__c); 
            casesToBeInserted.add(reqToUpdate);
        }
        insert casesToBeInserted;
        
        // Map<Id,Equipment_Maintenance_Item__c> empListToUpdate = new Map<Id,Equipment_Maintenance_Item__c>();
        List<Equipment_Maintenance_Item__c> empList = new List<Equipment_Maintenance_Item__c>();
        
        for(Case cs:[SELECT Id, (SELECT Id, Maintenance_Request__c FROM Equipment_Maintenance_Items__r) FROM Case WHERE Id IN :caseId]) {
                for(Equipment_Maintenance_Item__c emp :cs.Equipment_Maintenance_Items__r) {
                    // emp.Maintenance_Request__c = caseList.CaseNumber;
                    // Equipment_Maintenance_Item__c e = emp.clone();
                    // e.Maintenance_Request__c = caseList.Id;
                    // empListToUpdate.put(cs.Id,e);
                    empList.add(emp);
                }
            }
        
        List<Equipment_Maintenance_Item__c> newEmp = new List<Equipment_Maintenance_Item__c>();
        
        for(Case caseList : casesToBeInserted) {
            for(Equipment_Maintenance_Item__c e: empList) {
                if(caseList.ParentId == e.Maintenance_Request__c) {
                    // e.Maintenance_Request__c = caseList.Id;
                    Equipment_Maintenance_Item__c emp = e.clone();
                    emp.Maintenance_Request__c = caseList.Id;
                    newEmp.add(emp);
                }
            }
        }
        
        insert newEmp;
    }        
}