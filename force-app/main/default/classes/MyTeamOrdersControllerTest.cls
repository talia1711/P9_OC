
/***
 * Author: Talia Ajaz
 * Date: March 2024
 */
@isTest
public with sharing class MyTeamOrdersControllerTest {

    //to setup data used in test methods
    @testSetup
    static void setupData() {
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

    //test the population of data reord from the controller
    @isTest
    static void getDataAgentsAndTotal() {
        //preparte the controller object
        MyTeamOrdersController controller = new MyTeamOrdersController();

        //execute test
        Test.startTest();
        List<MyTeamOrdersController.Data> data  = controller.getData();
        Test.stopTest();

         //Assert for result
        Assert.areEqual('Talia Ajaz', data[0].agent, 'The agent should be rtegrthth');
        Assert.areEqual(120.0, data[0].total, 'The agent should be 120.0');

    }
}