
# FASHA Salesforce Solution

Problems:

- Batches (code programmed each week), which take a very long time to update the account turnovers after product prices have been updated.
- Application, which hangs when users are in the process of modifying information about accounts and orders.
- Poorly organized code: no naming conventions, classes too long.

Requirements:
- Optimise the application
- Re-organize the code


## Optimizations

#### Batches (code programmed each week), which take a very long time to update the account turnovers after product prices have been updated.
Solution: Created a batch to massively update the Accounts turn over witn Ordered orders.

This batch can be triggered manually after Account data import and can be scheduled to run every monday at 6am.


#### Application, which hangs when users are in the process of modifying information about accounts and orders.
Solution: Removed the SOQL querty inside the for loop that leads to limit exception => results in all the transation to fallback into initial state.
The initial logic was processing only the first order, ignoring any all other multiple orders updated. The improvement was performed to create a single trigger to process for both scenarios, account turnover update and calculate order net amount for multiple orders


#### Poorly organized code: no naming conventions, classes too long.
Classes names were modigfied as follow:
- OrderTrigger: trigger on Order object for all the scenarios
- OrderService: methods used by the Order trigger
- OrderServiceTest: test class for the OrderService
- UpdateAccountsBatchSchedule: nbatch and scdhulable to update accounts turnover
- UpdateAccountsBatchScheduleTest: test class for UpdateAccountsBatchSchedule
- MyTeamOrders: visual force page
- MyTeamOrdersController: custom controller for the MyTeamOrders visual force page
- MyTeamOrdersControllerTest: test class for MyTeamOrdersController


## Deployment

To deploy this project run
```bash
sfdx force:source:deploy -x manifest/package.xml -u P9 -l RunLocalTests
```

Schedule the Account Update Batch (run every monday at 6 AM)
```bashUpdateAccountsBatchSchedule ba = new UpdateAccountsBatchSchedule();
Id jobid= Database.executeBatch(ba,200);
```


## Authors

- [@talia1711](https://www.github.com/talia1711)