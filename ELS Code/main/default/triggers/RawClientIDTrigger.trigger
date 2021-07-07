trigger RawClientIDTrigger on Raw_Client__c (before insert, before update) {
    RawClientIDTriggerHandler objCall=new RawClientIDTriggerHandler();
    if(trigger.isInsert || trigger.isUpdate){
        System.debug('Fire Trigger');
        objCall.beforeInsert(trigger.new);
    }
}