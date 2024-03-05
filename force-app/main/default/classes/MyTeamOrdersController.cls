public class MyTeamOrdersController {
    
    List<Data> data = new List<Data>();
    
    public MyTeamOrdersController(){
        Set<Id> usersIds = new Set<Id>();
        List<AggregateResult> groupedResults =[SELECT OwnerId, SUM(TotalAmount)total FROM Order Group By OwnerId];
        
        for(AggregateResult a : groupedResults){
            usersIds.add((Id)a.get('OwnerId'));
        }
        
        Map<Id, User> mapIdUsers = new Map<Id, User>([SELECT FirstName, LastName FROM User WHERE Id in:usersIds]);
        
        for(AggregateResult a : groupedResults){
            Id userId = (Id)a.get('OwnerId');
            String fullName = mapIdUsers.get(userId).FirstName + ' ' + mapIdUsers.get(userId).LastName;
            data.add(new Data(fullName, (Decimal)a.get('total')));
        }
    }
    
    public List<Data> getData(){
        return this.data;
    }

    @TestVisible
    class Data{
        public String agent{set;get;}
        public Decimal total{set;get;}
        
        public Data(String agent, Decimal total){
            this.agent = agent;
            this.total = total;
        }
    }
}