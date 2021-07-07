trigger RawUnitTrigger on RawUnit__c (before insert, before update) {
	RawUnitTriggerHandler objCall = new RawUnitTriggerHandler();
    objCall.recordBeforeInsert(trigger.new);
}