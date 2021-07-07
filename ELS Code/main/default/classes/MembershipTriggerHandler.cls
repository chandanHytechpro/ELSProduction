/** The Helper class for MembershipTrigger logic
* West Monroe Partners. September 2016
*/
public with sharing class MembershipTriggerHandler {
    
    public static void handleAfterInsert(List<Membership__c> newMemberships) {
        updateContactFirstFields(newMemberships);
        updateMembershipOnContact(newMemberships);
        Set<Id> contactIdsForPrimaryClientIdCalculation = new Set<Id>();
        
        for(Membership__c mem : newMemberships) {
            contactIdsForPrimaryClientIdCalculation.add(mem.Contact__c);
        }
        
        if(contactIdsForPrimaryClientIdCalculation.size() > 0) {
            PrimaryClientIDUtil.assignPrimaryClientID(contactIdsForPrimaryClientIdCalculation);
        }
    }
    
    public static void handleAfterUpdate(Map<Id, Membership__c> oldMap, Map<Id, Membership__c> newMap) {
        updateContactFirstFields(newMap.values());
        Set<Id> contactIdsForPrimaryClientIdCalculation = new Set<Id>();
        //Set<Id> clientIDsForPrimaryClientIdCalculation = new Set<Id>();
        
        for(Membership__c newMembership : newMap.values()) {
            Membership__c oldMembership = oldMap.get(newMembership.Id);
            
            /* Not a current use case
if(newMembership.ClientID__c != oldMembership.ClientID__c) {
clientIDsForPrimaryClientIdCalculation.add(newMembership.ClientID__c);
clientIDsForPrimaryClientIdCalculation.add(oldMembership.ClientID__c);
} */
            
            /* Not a current use case
if(newMembership.Contact__c != oldMembership.Contact__c) {
contactIdsForPrimaryClientIdCalculation.add(newMembership.Contact__c);
contactIdsForPrimaryClientIdCalculation.add(oldMembership.Contact__c);
}*/
            if(newMembership.Active__c != oldMembership.Active__c) {
                contactIdsForPrimaryClientIdCalculation.add(newMembership.Contact__c);
            }
            //Does activation date change???
        }
        
        /*if(clientIDsForPrimaryClientIdCalculation.size() > 0) {
for(ClientID__c clientId : [Select Id, Contact__c from ClientID__c Where Id in: clientIDsForPrimaryClientIdCalculation]) {
contactIdsForPrimaryClientIdCalculation.add(clientId.Contact__c);
}
}*/
        
        if(contactIdsForPrimaryClientIdCalculation.size() > 0) {
            PrimaryClientIDUtil.assignPrimaryClientID(contactIdsForPrimaryClientIdCalculation);
        }
    }
    public static void updateMembershipOnContact(List<Membership__c> newMemberships){
        Map<Id,Contact> contactToUpdate = new Map<Id,Contact>();
        if(newMemberships.size()>0){
            for(Membership__c objMemebership : newMemberships){
                if(objMemebership.Contact__c !=null && objMemebership.Active__c){
                    contactToUpdate.put(objMemebership.Contact__c,new contact(id=objMemebership.Contact__c , Membership_Lookup__c =objMemebership.Id ));
                }
            }
        }
        if(contactToUpdate.size()>0){
            update contactToUpdate.values();
        }
    }
    
    public static void updateContactFirstFields(List<Membership__c> newMemberships){
        system.debug('Enter updateContactFirstFields');
        Map<id,list<Membership__c>> mapContactTrailDate = new Map<id,list<Membership__c>> ();   
        set<Id> contactId = new set<Id>();
        
        if(newMemberships.size()>0){
            for(Membership__c objMemebership : newMemberships){
                if(objMemebership.Contact__c !=null){
                    contactId.add(objMemebership.Contact__c);
                }
            }
            
            if(contactId.size()>0){
                
                list<Membership__c> memlist = [select id ,Name,Trails_Collection_Add_Date__c,Contact__c from  Membership__c where Contact__c IN :contactId order by createdDate]; 
                if(memlist.size()>0){
                    for(Membership__c objmem :memlist){
                        if(!mapContactTrailDate.containsKey(objmem.contact__c)){
                            mapContactTrailDate.put(objmem.contact__c,new list<Membership__c>());
                        }
                        mapContactTrailDate.get(objmem.contact__c).add(objmem);
                    }
                }
                
                list<Contact> listContacts = [Select id,Trails_Collection_AddDate_History__c,Original_Trails_Collection_Add_Date__c from Contact Where id IN :contactId];
                if(listContacts.size()>0){
                    for(Contact ObjCOn :listContacts){
                        boolean addDateFlag=false;
                        for(Membership__c objmem :mapContactTrailDate.get(ObjCOn.id)){
                            if(!addDateFlag){
                                addDateFlag = true;
                                if(ObjCOn.Original_Trails_Collection_Add_Date__c != objmem.Trails_Collection_Add_Date__c ){
                                    ObjCOn.Original_Trails_Collection_Add_Date__c = objmem.Trails_Collection_Add_Date__c;
                                   /* if(objCon.Trails_Collection_AddDate_History__c!=null){
                                        system.debug('test'+objCon.Trails_Collection_AddDate_History__c.countMatches('--'));
                                        if(objCon.Trails_Collection_AddDate_History__c.countMatches('--')<3){
                                            objCon.Trails_Collection_AddDate_History__c = objmem.Name + '::' + objmem.Trails_Collection_Add_Date__c.format() + ' -- ' + objCon.Trails_Collection_AddDate_History__c ;
                                        }else{
                                            objCon.Trails_Collection_AddDate_History__c = objCon.Trails_Collection_AddDate_History__c.substringBeforeLast('--');
                                            objCon.Trails_Collection_AddDate_History__c = objmem.Name + ' :: ' + objmem.Trails_Collection_Add_Date__c.format() + ' -- ' +  objCon.Trails_Collection_AddDate_History__c ;
                                        }
                                    }else{
                                        objCon.Trails_Collection_AddDate_History__c =  objmem.Name + ' :: ' + objmem.Trails_Collection_Add_Date__c.format();
                                    }*/
                                    objCon.Trails_Collection_AddDate_History__c =  objmem.Name + ' :: ' + objmem.Trails_Collection_Add_Date__c.format();
                                }
                            } 
                        } 
                    }
                    update listContacts;
                }
            }   
        }
    }
}