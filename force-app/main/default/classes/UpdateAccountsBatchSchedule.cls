global class UpdateAccountsBatchSchedule implements Database.Batchable<sObject>, Schedulable {
	
    public void execute(SchedulableContext sc) {
        // Initiate the batch process when the scheduled job executes.
        Database.executeBatch(this);
    }
    
    public static void scheduleWeekly() {
        // CRON scheduling Monday at 6 AM
        System.schedule('Weekly UpdateAccountsBatch',  '0 0 6 ? * MON', new UpdateAccountsBatchSchedule());
    }
    
   global Database.QueryLocator start(Database.BatchableContext info){ 
	 return Database.getQueryLocator('SELECT Id, Turnover__c FROM Account WHERE Id IN (SELECT AccountId FROM Order WHERE Status = \'Ordered\')');
   }
    
   global void execute(Database.BatchableContext info, List<Account> listAccount){   
       
        Map<Id, Account> mapIdAccount = new Map<Id, Account>();
        for(Account a : listAccount){
            mapIdAccount.put(a.Id, a);
        }
       
        AggregateResult[] groupedResults = [SELECT AccountId, SUM(TotalAmount)total FROM Order WHERE AccountId IN:listAccount GROUP By AccountId];
        for(AggregateResult result : groupedResults){
            Id accId = (Id) result.get('AccountId');
            Decimal total = (Decimal) result.get('total');
            mapIdAccount.get(accId).Turnover__c = total;
        }
       
       	update mapIdAccount.values(); 
   }    
    
   global void finish(Database.BatchableContext info){     
       
   } 
}