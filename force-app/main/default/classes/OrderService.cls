public class OrderService {
    public static void calculateNetAmount(List<Order> updatedOrders){
        for(Order orderRecord : updatedOrders) {
            if(orderRecord.Status == 'Ordered' && orderRecord.TotalAmount != null && orderRecord.ShipmentCost__c != null) {
                orderRecord.NetAmount__c = orderRecord.TotalAmount - orderRecord.ShipmentCost__c;
            }
        }
    }
    
    public static void calculateAccountTurnOver(List<Order> updatedOrders) {
        Set<Id> accountIds = new Set<Id>();
        for(Order orderRecord : updatedOrders) {
         	accountIds.add(orderRecord.AccountId);
        }
        
        System.debug('accountIds: '+ accountIds);
        

        Map<Id, Account> mapIdAccount = new Map<Id, Account>([SELECT Id, Turnover__c FROM Account WHERE Id IN:accountIds]);
              
        AggregateResult[] groupedResults = [SELECT AccountId, SUM(TotalAmount)total FROM Order WHERE AccountId IN:accountIds GROUP By AccountId];
        
        for(AggregateResult result : groupedResults){
            Id accId = (Id) result.get('AccountId');
            Decimal total = (Decimal) result.get('total');
            mapIdAccount.get(accId).Turnover__c = total;
        }
		update mapIdAccount.values();
    }
}