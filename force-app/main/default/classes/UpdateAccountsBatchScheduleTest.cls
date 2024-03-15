/***
 * Author: Talia Ajaz
 * Date: March 2024
 * Test class for UpdateAccountsBatchSchedule
 */
@isTest
public class UpdateAccountsBatchScheduleTest {
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
        
        //Create one order per account, tottal 200 orders
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
    
    @isTest
    static void updateAccountBatchScheduleTest() {

        //execute test
        Test.startTest();
			UpdateAccountsBatchSchedule ba = new UpdateAccountsBatchSchedule();
        	Id jobid= Database.executeBatch(ba,200);
        Test.stopTest();


        //assert for the result
        for(Account acc : [SELECT Turnover__c FROM Account]) {
            Assert.areEqual(120.00, acc.Turnover__c, 'The account turnover should be 120');
        }
    }
}