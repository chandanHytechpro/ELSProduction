trigger CampResJuncTrigger on Campaign_Reservation_Junction__c (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CampResJuncTriggerHandler.afterInsert(Trigger.newMap);
        } else if (Trigger.isDelete) {
            CampResJuncTriggerHandler.afterDelete(Trigger.oldMap);
        }
    }
}