/***
 * Author: Talia Ajaz
 * Date: March 2024
 */
public class OrderService {
    
    //calculate the net amount of an ordered order
    public static void calculateNetAmount(List<Order> updatedOrders){
        for(Order orderRecord : updatedOrders) {
            if(orderRecord.Status == 'Ordered' && orderRecord.TotalAmount != null && orderRecord.ShipmentCost__c != null) {
                orderRecord.NetAmount__c = orderRecord.TotalAmount - orderRecord.ShipmentCost__c;
            }
        }
    }
    
    //calculate the related order account turnover value
    public static void calculateAccountTurnOver(List<Order> updatedOrders) {
        //set ot grab all the related order account ids
        Set<Id> accountIds = new Set<Id>();
        for(Order orderRecord : updatedOrders) {
         	accountIds.add(orderRecord.AccountId);
        }

        //populate the map of account id and acount record that contains turnover field
        Map<Id, Account> mapIdAccount = new Map<Id, Account>([SELECT Id, Turnover__c FROM Account WHERE Id IN:accountIds]);
              
        AggregateResult[] groupedResults = [SELECT AccountId, SUM(TotalAmount)total FROM Order WHERE AccountId IN:accountIds GROUP By AccountId];
        
        //populate the account record based on the order table query and get the order total amount and updateb the related account turnover amount by providing the account if to the map
        for(AggregateResult result : groupedResults){
            Id accId = (Id) result.get('AccountId');
            Decimal total = (Decimal) result.get('total');
            mapIdAccount.get(accId).Turnover__c = total;
        }

        //update related account records
		update mapIdAccount.values();
    }
}