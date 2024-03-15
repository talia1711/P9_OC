@isTest
public class OrderTriggerTest {
    
    @testSetup
    static void setupData(){
        //create 200 accounts
        List<Account> accList  = new List<Account>();
        for(Integer i=0;i<200;i++){
            accList.add(new Account(Name = 'OC'+i));
        }
        insert accList;
        
        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise');
        Insert pd1;
        
        //Create one order per account
        List<Order> orderList = new List<Order>();
        for(Account acc : accList){
            orderList.add(new Order(AccountId = acc.Id, 
                                   EffectiveDate = Date.newInstance(2024, 1, 1), 
                                   Status = 'Draft', 
                                   Pricebook2Id = Test.getStandardPriceBookId(),
                                   ShipmentCost__c = 20));
        }
        
        insert orderList;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        insert pbe;
        
        //create one order item per order
		List<OrderItem> orderItemList = new List<OrderItem>();
        for(Order oo : orderList){
            oo.Status = 'Ordered';
            orderItemList.add(new OrderItem(OrderId = oo.Id, PricebookEntryId = pbe.Id, Quantity=1, UnitPrice = 120));
        }
		
		insert orderItemList;
        update orderList;
    }
    
    @isTest
    static void calculateNetAmountTest() {
        Order newOrder = [SELECT AccountId, Status, ShipmentCost__c FROM Order LIMIT 1];
            
        Test.startTest();
        	newOrder.Status = 'Ordered';
            update newOrder;
        Test.stopTest();
        
        Order updatedOrder = [SELECT NetAmount__c FROM Order WHERE Id =:newOrder.Id LIMIT 1];
        Assert.areEqual(100.00, updatedOrder.NetAmount__c, 'The net amount should be 100');
    }
    
    @isTest
    static void calculateNetAmountBatchTest() {
        List<Order> orderList = [SELECT AccountId, Status, ShipmentCost__c FROM Order];
        for(Order order: orderList){
            order.Status = 'Ordered';
        }
        
        Test.startTest();
        	update orderList;
        Test.stopTest();
        
        for(Order updatedOrder : [SELECT NetAmount__c FROM Order WHERE Id IN:orderList]){
            Assert.areEqual(100.00, updatedOrder.NetAmount__c, 'The net amount should be 100');
        }
    }
    
    @isTest
    static void calculateAccountTurnOverTest() {
        Order newOrder = [SELECT AccountId, Status, ShipmentCost__c FROM Order LIMIT 1];
      
        Test.startTest();
        	newOrder.Status = 'Ordered';
            update newOrder;
        Test.stopTest();
        
        Account newAccounts = [SELECT Turnover__c FROM Account WHERE Id = :newOrder.AccountId];
        Assert.areEqual(120.00, newAccounts.Turnover__c, 'The account turnover should be 120');
    }
    
    @isTest
    static void calculateAccountTurnOverBatchTest() {
        Set<Id> accountIds = new Set<Id>();
        List<Order> orderList = [SELECT AccountId, Status, ShipmentCost__c FROM Order];
        for(Order order: orderList){
            order.Status = 'Ordered';
            accountIds.add(order.AccountId);
        }

        Test.startTest();
            update orderList;
        Test.stopTest();
        
        for(Account newAccounts : [SELECT Turnover__c FROM Account WHERE Id IN:accountIds]){
            Assert.areEqual(120.00, newAccounts.Turnover__c, 'The account turnover should be 120');
        }
    }
}