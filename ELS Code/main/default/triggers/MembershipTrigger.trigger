/** The Trigger for the Membership__c object
* West Monroe Partners. September 2016
*/
trigger MembershipTrigger on Membership__c (before insert, before update, after insert, after update) {
    
	if(trigger.isAfter) {
		if(trigger.isInsert) {
			MembershipTriggerHandler.handleAfterInsert(trigger.new);
		}

		else if(trigger.isUpdate) {
			MembershipTriggerHandler.handleAfterUpdate(trigger.oldMap, trigger.newMap);
		}
	}
}