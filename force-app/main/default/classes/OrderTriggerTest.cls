@isTest
public class OrderTriggerTest {
    
    @testSetup
    static void setupData(){
        Account acc = new Account(Name = 'OC');
     	insert acc;
        
        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise');
        Insert pd1;
        
        Order newOrder = new Order(AccountId = acc.Id, 
                                   EffectiveDate = Date.newInstance(2024, 1, 1), 
                                   Status = 'Draft', 
                                   Pricebook2Id = Test.getStandardPriceBookId(),
                                   ShipmentCost__c = 20);
        insert newOrder;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        insert pbe;
        
        OrderItem oi1 = new OrderItem(OrderId = newOrder.Id, PricebookEntryId = pbe.Id, Quantity=1, UnitPrice = 120);
        insert oi1;
    }
    
    @isTest
    static void calculateNetAmountTest() {
        Order newOrder = [SELECT AccountId, Status, ShipmentCost__c FROM Order];
            
        Test.startTest();
        	newOrder.Status = 'Ordered';
            update newOrder;
        Test.stopTest();
        
        Order updatedOrder = [SELECT NetAmount__c FROM Order WHERE Id =:newOrder.Id LIMIT 1];
        Assert.areEqual(100.00, updatedOrder.NetAmount__c, 'The net amount should be 100');
    }
    
    @isTest
    static void calculateAccountTurnOverTest() {
        Order newOrder = [SELECT AccountId, Status, ShipmentCost__c FROM Order];
      
        Test.startTest();
        	newOrder.Status = 'Ordered';
            update newOrder;
        Test.stopTest();
        
        Account newAccounts = [SELECT Turnover__c FROM Account];
        Assert.areEqual(120.00, newAccounts.Turnover__c, 'The account turnover should be 120');
    }
}