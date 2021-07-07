trigger ZapierLogTrigger on Zapier_logs__c (After insert) {
    
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            ZapierLogTriggerHandler.handleAfterInsert(trigger.NewMap);
        }
    }
}