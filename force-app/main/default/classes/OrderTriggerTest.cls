/***
 * Author: Talia Ajaz
 * Date: March 2024
 * Test class for OrderService and OrderTrigger
 */
@isTest
public class OrderTriggerTest {
    //to setup data used in test methods
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
        
        //Create one order per account, total 200 orders
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
        
        //create one order item per order, total 200 order items
		List<OrderItem> orderItemList = new List<OrderItem>();
        for(Order oo : orderList){
            oo.Status = 'Ordered';
            orderItemList.add(new OrderItem(OrderId = oo.Id, PricebookEntryId = pbe.Id, Quantity=1, UnitPrice = 120));
        }
		
		insert orderItemList;
        update orderList;
    }
    
    //test the orders net amnount calculation during order update for 1 order
    @isTest
    static void calculateNetAmountTest() {
        //prepare data
        Order newOrder = [SELECT AccountId, Status, ShipmentCost__c FROM Order LIMIT 1];
            
        //execute test
        Test.startTest();
        	newOrder.Status = 'Ordered';
            update newOrder;
        Test.stopTest();
        
        //Assert for result
        Order updatedOrder = [SELECT NetAmount__c FROM Order WHERE Id =:newOrder.Id LIMIT 1];
        Assert.areEqual(100.00, updatedOrder.NetAmount__c, 'The net amount should be 100');
    }
    
    //test the orders net amnount calculation during order update for 200 orders
    @isTest
    static void calculateNetAmountBatchTest() {
        //prepare data
        List<Order> orderList = [SELECT AccountId, Status, ShipmentCost__c FROM Order];
        for(Order order: orderList){
            order.Status = 'Ordered';
        }
        
        //execute test
        Test.startTest();
        	update orderList;
        Test.stopTest();
        
        //Assert for result
        for(Order updatedOrder : [SELECT NetAmount__c FROM Order WHERE Id IN:orderList]){
            Assert.areEqual(100.00, updatedOrder.NetAmount__c, 'The net amount should be 100');
        }
    }

    //test the related order account turnover calculation for 1 order
    @isTest
    static void calculateAccountTurnOverTest() {
        //prepare data
        Order newOrder = [SELECT AccountId, Status, ShipmentCost__c FROM Order LIMIT 1];
      
        //execute test
        Test.startTest();
        	newOrder.Status = 'Ordered';
            update newOrder;
        Test.stopTest();
        
        //Assert for result
        Account newAccounts = [SELECT Turnover__c FROM Account WHERE Id = :newOrder.AccountId];
        Assert.areEqual(120.00, newAccounts.Turnover__c, 'The account turnover should be 120');
    }
    
    //test the related order account turnover calculation for 200 order
    @isTest
    static void calculateAccountTurnOverBatchTest() {
        //prepare data
        Set<Id> accountIds = new Set<Id>();
        List<Order> orderList = [SELECT AccountId, Status, ShipmentCost__c FROM Order];
        for(Order order: orderList){
            order.Status = 'Ordered';
            accountIds.add(order.AccountId);
        }

        //execute test
        Test.startTest();
            update orderList;
        Test.stopTest();
        
        //Assert for result
        for(Account newAccounts : [SELECT Turnover__c FROM Account WHERE Id IN:accountIds]){
            Assert.areEqual(120.00, newAccounts.Turnover__c, 'The account turnover should be 120');
        }
    }
}