/***
 * Author: Talia Ajaz
 * Date: March 2024
 * Trigger on Order object
 */
trigger OrderTrigger on Order (before update) {
    if(trigger.isBefore && trigger.isUpdate) {
        OrderService.calculateNetAmount(trigger.new);
        OrderService.calculateAccountTurnOver(trigger.new);
    }
}