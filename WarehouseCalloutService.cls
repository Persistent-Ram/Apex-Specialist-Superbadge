public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {
    
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment/';
    
    public static HttpResponse makeGetCallout() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
            // Cast the values in the 'animals' key as a list
            System.debug('Received the following equipments:' + results);
            /*for(Product2 equipment: results) {
                System.debug(equipment);
            }*/
        }
        return response;
    }
    
    public void execute(QueueableContext context) {
        HttpResponse response = makeGetCallout();
        // List<Product2> eqpList = (List<Product2>) JSON.deserialize(response.getBody(), List<Product2>.class);
        List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
        List<Product2> skuListToUpdate = new List<Product2>();
        for(Object entry : results) {
            Map<String,Object> p = (Map<String,Object>) entry;
			Product2 newP = new Product2(Warehouse_SKU__c= String.valueOf(p.get('_id')),
                                         Cost__c= Decimal.valueOf(p.get('cost')+''),
                                         Lifespan_Months__c= Decimal.valueOf(p.get('lifespan')+''),
                                         Maintenance_Cycle__c= Decimal.valueOf(p.get('maintenanceperiod')+''),
                                         Name= String.valueOf(p.get('name')),
                                         QuantityUnitOfMeasure= String.valueOf(p.get('quantity')),
                                         Replacement_Part__c= Boolean.valueOf(p.get('replacement')),
                                         StockKeepingUnit= String.valueOf(p.get('sku')));
            skuListToUpdate.add(newP);
        }
        upsert skuListToUpdate Warehouse_SKU__c; 
    }
}