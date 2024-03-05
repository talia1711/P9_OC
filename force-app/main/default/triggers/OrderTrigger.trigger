trigger OrderTrigger on Order (before update) {
    if(trigger.isBefore && trigger.isUpdate) {
        OrderService.calculateNetAmount(trigger.new);
        OrderService.calculateAccountTurnOver(trigger.new);
    }
}