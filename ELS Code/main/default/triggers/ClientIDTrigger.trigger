/** Trigger for the ClientID__c object
* Chintan Adhyapak, West Monroe Partners. August 09, 2016
*/
trigger ClientIDTrigger on ClientID__c (before insert, after insert, before update, after update, after delete) {
    
    list<ClientID__c> listToMaster = new list<ClientID__c>();
    
    if(trigger.isbefore){
        System.debug('Before Trigger');
        if(trigger.isInsert){
            System.debug('Enter Before Insert');
            ClientIDTriggerHandler.handlebeforeInsert(trigger.new);
        }
        else if(trigger.isUpdate){
            System.debug('Enter Before Update');
            ClientIDTriggerHandler.handlebeforeInsert(trigger.new);
            ClientIDTriggerHandler.beforeUpdateClientID(trigger.new, trigger.oldMap);
        }
    }
    
    
    if(trigger.New !=null){
        for(ClientID__c objClientId :trigger.New){
            if(objClientId.Contact__c!=null){
                listToMaster.add(objClientId);
            }
        }    
    }
    
    if(listToMaster.size()>0){
        GenerateLookupRollup.Context ctx = new GenerateLookupRollup.Context(Contact.SobjectType,ClientID__c.SobjectType,Schema.SObjectType.ClientID__c.fields.Contact__c,'Primary_ClientID__c=true');  
        ctx.add(new GenerateLookupRollup.RollupSummaryField(Schema.SObjectType.Contact.fields.Sum_of_Primary_Client_Id__c,
                                                            Schema.SObjectType.ClientID__c.fields.Id,
                                                            GenerateLookupRollup.RollupOperation.Count 
                                                           )); 
        list<Contact> lstContact = GenerateLookupRollup.rollUp(ctx, listToMaster);
        system.debug('lstContact-->'+lstContact);
        if(lstContact.size()>0){
            update lstContact;       
        }
    }
    System.debug('triggered: ' + Trigger.isAfter + ' | ' + Trigger.isInsert + ' | ' + Trigger.isUpdate);
    if(trigger.isAfter) {
        //if(!TriggerTracker.ranOnce){
        if(trigger.isDelete){
            ClientIDTriggerHandler.updateCustomContactRollups(trigger.old);
        }
        else{
            if (trigger.isInsert) {
                //Set Primary Client ID on contacts
                ClientIDTriggerHandler.handleAfterInsert(trigger.newMap);
            }
            else if(trigger.isUpdate) {
                //synchronize Contacts tied to Primary Client IDs
                ClientIDTriggerHandler.handleAfterUpdate(trigger.oldMap, trigger.newMap);
            }
            ClientIDTriggerHandler.updateCustomContactRollups(trigger.new);
        }
        //}
        TriggerTracker.ranOnce = true;
    }
}