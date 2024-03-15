/***
 * Author: Talia Ajaz
 * Date: March 2024
 */
public class MyTeamOrdersController {
    
    //data class list declaration and initalization
    List<Data> data = new List<Data>();
    
    public MyTeamOrdersController(){
        //set to store all the user id
        Set<Id> usersIds = new Set<Id>();
        List<AggregateResult> groupedResults =[SELECT OwnerId, SUM(TotalAmount)total FROM Order Group By OwnerId];
        
        for(AggregateResult a : groupedResults){
            usersIds.add((Id)a.get('OwnerId'));
        }
        
        //populate the map of user id and user record that contains first and last name
        Map<Id, User> mapIdUsers = new Map<Id, User>([SELECT FirstName, LastName FROM User WHERE Id in:usersIds]);
        //populate the data record based on the ordert table query and get the user name from the map by providing user id
        for(AggregateResult a : groupedResults){
            Id userId = (Id)a.get('OwnerId');
            String fullName = mapIdUsers.get(userId).FirstName + ' ' + mapIdUsers.get(userId).LastName;
            data.add(new Data(fullName, (Decimal)a.get('total')));
        }
    }
    
    //getter of the data list that is visible on vfp markup
    public List<Data> getData(){
        return this.data;
    }

     //data class to store the woner id and order total amount pair
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