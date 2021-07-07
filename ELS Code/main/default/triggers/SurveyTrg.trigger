trigger SurveyTrg on Survey__c (after insert)
{
    Map<id,Contact> MapOfContacts = new Map<id,Contact>();
    
    for(Survey__c sur:Trigger.New){
        if(sur.Contact__c != null){
            Contact newContact = new Contact(Id = sur.Contact__c, Sync_with_Pardot__c = true);
            if(!MapOfContacts.containsKey(sur.Contact__c)){
                MapOfContacts.put(sur.Contact__c,newContact);
            }
        }
    }
    if(MapOfContacts.size() > 0){
        update MapOfContacts.values();
    }
}