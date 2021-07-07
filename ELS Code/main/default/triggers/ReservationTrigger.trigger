trigger ReservationTrigger on Reservation__c (before insert,after insert, after update,before update) {
    
    if(trigger.isAfter) {
        if(trigger.isInsert) {  
            System.debug('AfterCreateRez');          
            ReservationTriggerHandler.handleAfterInsert(trigger.newMap);
            ReservationTriggerHandler.checkJunction(null,Trigger.newMap);
        }
        else if(trigger.isUpdate) {            
            ReservationTriggerHandler.handleAfterUpdate(trigger.oldMap, trigger.newMap);
            ReservationTriggerHandler.checkJunction(Trigger.oldMap,Trigger.newMap);
        }
    }else{
        if(trigger.isInsert) {
            system.debug('Hello');
            ReservationTriggerHandler.handlebeforeInsert(trigger.new);
        }else if(trigger.isUpdate){
            ReservationTriggerHandler.handleBeforeUpdate(trigger.oldMap, trigger.newMap);
        }
    }
}