public without sharing class PrimaryClientIDUtil {
    
    
    public static Boolean runPrimaryClientIDAssignment = true; //This is used in certain test methods to improve processing time for setting up test data
    public static Boolean postMergePrimaryClientIDCalculation = false; //This is used in the contact merge scenarios to ensure that the correct primary client id is applied to the contact
    
    
    public static void assignPrimaryClientID(Set<Id> contactIds) {
        System.debug('CPA In method assignPrimaryClientID. Set contactIds size is: ' + contactIds.size());
        System.debug('CPA contactIds is: ' + contactIds);
        
        if(runPrimaryClientIDAssignment) { 
            Map<Id, Id> contactIdToPrimaryClientID = new Map<Id, Id>();
            Map<Id, String> PrimaryClientIDReason = new Map<Id, String>();
            
            //Calculate all cancelled membership clientID
            set<Id> CancelledMembershipClientId = new set<Id>();
            if(contactIds.size()>0){
                list<Membership__c> listCancelledMemberships = new list<Membership__c>(); 
                list<ClientID__c> listCancelledMembershipClientId = new list<ClientID__c>();
                listCancelledMembershipClientId = [Select Id from ClientID__c where Contact__c IN: contactIds];
                
                if(listCancelledMembershipClientId.size()>0){
                    listCancelledMemberships = [Select id,ClientID__c from Membership__c where ClientID__c IN :listCancelledMembershipClientId AND Active__c = false];
                }
                
                if(listCancelledMemberships.size()>0){
                    for(Membership__c objMem :listCancelledMemberships){
                        CancelledMembershipClientId.add(objMem.ClientID__c);   
                    }
                    system.debug('CancelledMembershipClientId>>'+CancelledMembershipClientId);
                }
            }
            
            // First criteria is active memberships, tie to most recent activation date
            List<Membership__c> memberships = [SELECT Id, Contact__c, ClientID__c, Activation_Date__c
                                               FROM Membership__c
                                               WHERE Active__c = true
                                               AND ClientID__r.Deleted_by_Digi__c = false
                                               AND Contact__c IN: contactIds
                                               AND ClientID__c NOT IN:CancelledMembershipClientId
                                               ORDER BY Activation_Date__c DESC];
            Set<Id> membershipClientIds = new Set<Id>();
            for(Membership__c membership : memberships) {
                membershipClientIds.add(membership.ClientID__c);
                if(!contactIdToPrimaryClientID.containsKey(membership.Contact__c)) {
                    contactIdToPrimaryClientID.put(membership.Contact__c, membership.ClientID__c);
                    PrimaryClientIDReason.put(membership.ClientID__c,'Latest Membership');
                }
            }
            
            //Excluding the currently mapped contacts, we will only be searching for client Ids for contacts we know do not have an active membership
            Set<Id> contactIdClone = contactIds.clone();
            contactIdClone.removeAll(contactIdToPrimaryClientID.keySet());
            Map<Id,ClientID__c> mostResClientId = new Map<Id,ClientID__c>([SELECT Id, Contact__c, CreatedDate
                               FROM ClientID__c
                               WHERE Contact__c IN :contactIdClone
                               AND Id NOT IN :CancelledMembershipClientId
                               AND Deleted_by_Digi__c = false
							   AND Client_Type__c='Retail'                                                                          
                               ORDER BY CreatedDate DESC]);
            
            list<AggregateResult> mostrez = new list<AggregateResult>();
            if(mostResClientId.size()>0){    
                mostrez = [Select count(Id) cou,ClientID__c  from Reservation__c where ClientID__c IN: mostResClientId.keyset() group by ClientID__c order by count(Id) desc];
            }
            system.debug('mostrez'+mostrez);
            for(AggregateResult res : mostrez){
                system.debug(res.get('ClientID__c'));
                system.debug(res.get('cou'));
                system.debug(mostResClientId.get((Id)res.get('ClientID__c')).Contact__c);
                if(mostResClientId.containsKey((Id)res.get('ClientID__c')) && !contactIdToPrimaryClientID.containsKey(mostResClientId.get((Id)res.get('ClientID__c')).Contact__c) && (Integer)res.get('cou') >0){
                    contactIdToPrimaryClientID.put(mostResClientId.get((Id)res.get('ClientID__c')).Contact__c, (Id)res.get('ClientID__c'));
                    PrimaryClientIDReason.put((Id)res.get('ClientID__c'),'Latest Client ID with Most Reservations');
                }
            }
            
            //new changes to add recent Client Id ---
            Set<Id> contactIdCloneforlatestContact = contactIds.clone();
            contactIdCloneforlatestContact.removeAll(contactIdToPrimaryClientID.keySet());
            list<ClientID__c> listofRelatedClient = [select id,Contact__c,Client_Type__c from ClientID__c where Id NOT IN :CancelledMembershipClientId AND Contact__c IN:contactIdCloneforlatestContact AND Deleted_by_Digi__c = false AND Client_Type__c='Retail' ORDER BY createdDate desc]; 
            if(listofRelatedClient.size()>0){
                for(ClientID__c ObjClientId : listofRelatedClient){
                    if(!contactIdToPrimaryClientID.containsKey(ObjClientId.Contact__c)){
                        contactIdToPrimaryClientID.put(ObjClientId.Contact__c, ObjClientId.Id);
                        PrimaryClientIDReason.put(ObjClientId.Id,'Latest Client ID when no reservation and membership');
                    }
                }
            }
            
            //We need to update any contacts that do not have a primary client id. NOTE: This should not actually happen in practice with every Contact having a "Retail Client ID"
            Map<Id,ClientID__c> mapClientName = new Map<Id,ClientID__c>([Select id,Name from ClientID__c where id IN : contactIdToPrimaryClientID.values()]);
            List<Contact> updateContacts = new List<Contact>();
            for(Id contactId : contactIds) {
                Contact newContact = new Contact(Id = contactId);
                if(contactIdToPrimaryClientID != null && contactIdToPrimaryClientID.containsKey(contactId)) {
                    newContact.Primary_Client_ID__c = mapClientName.get(contactIdToPrimaryClientID.get(contactId)).Name;
                    newContact.Primary_ClientID_Processed__c = true;
                }
                
                if(newContact.Primary_Client_ID__c != null){
                    updateContacts.add(newContact);
                }
            }
            
            if(updateContacts.size() > 0) {
                update updateContacts;
            }
            
            //All of the Client Ids related to the Conacts need to have their Primary indicator updated
            List<ClientID__c> updateClientIds = new List<ClientID__c>();
            
            for(ClientID__c clientId : [Select Id, Contact__c, Primary_ClientID__c From ClientID__c Where Contact__c in: contactIds]) {
                System.debug('updating cid');
                System.debug(clientId);
                System.debug(contactIdToPrimaryClientID.get(clientId.Contact__c));
                Boolean primary = (contactIdToPrimaryClientID.get(clientId.Contact__c) == clientId.Id);
                if(clientId.Primary_ClientID__c != primary){
                    clientId.Primary_ClientID__c = primary;
                }
                if(PrimaryClientIDReason.containskey(clientId.Id)){
                    clientId.Primary_Reason__c = PrimaryClientIDReason.get(clientId.Id);
                }else{
                    clientId.Primary_Reason__c ='';
                }
                updateClientIds.add(clientId);
            }
            
            if(updateClientIds.size() > 0) {
                update updateClientIds;
            }
        }
    }
}