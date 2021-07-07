/** The handler class for all Contact trigger events
 * Alex Clark, West Monroe Partners. August 09, 2016
 */
public with sharing class ContactTriggerHandler {

    //Need to use persistant map to track changes in records across multiple triggers within a transaction
    public static Map<Id, Contact> oldMap {get {if(oldMap == null) oldMap = new Map<Id, Contact>(); return oldMap;} set;}
    public static string selectMethod(String phoneParamNumber,String countryParam){
        Set<String> clientContactCountryLabel=new Set<String>(String.valueOf(System.Label.Contact_Client_Phone_Cleaning).split(';'));
        phoneParamNumber=phoneParamNumber.replaceAll('[^0-9]', '');
        phoneParamNumber=phoneParamNumber.replaceAll('(\\s+)','');
        if(clientContactCountryLabel.contains(countryParam)){
            if((phoneParamNumber.length())==10){
                return matchAndFilter(phoneParamNumber); 
            }else{
                return '9999999999'; 
            }
        }else{
            if((phoneParamNumber.length())<9||(phoneParamNumber.length())>15){
                return '9999999999';
            }else{
                return matchAndFilter(phoneParamNumber);
            }
        }
    }
    public static string matchAndFilter(String phoneParam){
        List<String> propertyNumberchange=new List<String>(String.valueOf(System.Label.Property_Numbers_to_filter).split(';'));
        if(propertyNumberchange.contains(phoneParam)){
            return '9999999999';
        }
        Integer phoneSize=phoneParam.length();
        List<String> repetetiveDigits=new List<String>{'00000','11111','22222','33333','44444','55555','66666','77777','88888','99999'};
            for(String checkingRepetetive:repetetiveDigits) {
                Integer result = phoneParam.indexOf(checkingRepetetive);
                if(result>=0){
                    return '9999999999';
                }
            } 
        List<String> consecutiveDigits=new List<String>{'01234','12345','23456','34567','45678','56789','67890','78901','89012','90123','09876','98765','87654','76543','65432','54321','43210','32109','21098','10987'};
            for(String checkingConsecutive:consecutiveDigits) {
                Integer result = phoneParam.indexOf(checkingConsecutive);
                if(result>=0){
                    return '9999999999';
                }
            }  
        return phoneParam;
    }
    public static void handleBeforeInsert(List<Contact> newContacts) {
        setOriginatingSource(newContacts);
        
        //build map of zip codes to territories
        Map<String,ID> zipMap = new Map<String,ID>();
        Set<String> zipList = new Set<String>();
        for(Contact c : newContacts) {
            if(c.Primary_Client_ID__c==null){
                if(c.Phone!=null){
                    String phoneField=c.Phone;
                    c.Phone=selectMethod(phoneField,c.MailingCountry);
                    if(c.Phone!=null && (((c.Phone).substring(0,1))=='0' ||((c.Phone).substring(0,1))=='1')){
                        c.Phone='9999999999';
                    }
                }
                if(c.MobilePhone!=null){
                    String phoneField2=c.MobilePhone;
                    c.MobilePhone=selectMethod(phoneField2,c.MailingCountry);
                     if(c.MobilePhone!=null && (((c.MobilePhone).substring(0,1))=='0' ||((c.MobilePhone).substring(0,1))=='1')){
                        c.MobilePhone='9999999999';
                    }
                }
                if(c.OtherPhone!=null){
                    String phoneField3=c.OtherPhone;
                    c.OtherPhone=selectMethod(phoneField3,c.MailingCountry);
                    if(c.OtherPhone!=null && (((c.OtherPhone).substring(0,1))=='0' ||((c.OtherPhone).substring(0,1))=='1')){
                        c.OtherPhone='9999999999';
                    } 
                }
                
                
            }
             //process builder : Uncheck SMS Opt IN
            if(c.simplesms__DoNotSMS__c){
                c.SMS_Opt_In__c = false;
            }
            
            zipList.add(c.MailingPostalCode);
        }

        List<Territory_Zip_Code__c> codes = [SELECT Territory__r.id, Name FROM Territory_Zip_Code__c WHERE Name IN :zipList];
        for(Territory_Zip_Code__c z : codes) {
            zipMap.put(z.name,z.territory__r.id);
        }
        //assign territories to contacts based on zipcodes
        for(Contact c : newContacts) {
            c.Sync_with_Pardot__c = true;
            if(zipMap.containsKey(c.MailingPostalCode)) {
                c.territory__c = zipMap.get(c.MailingPostalCode);
            }
        }
    }

    public static void handleBeforeUpdate(Map<Id, Contact> oMap, Map<Id, Contact> newMap) {
        
        for(Contact objCon :newMap.values()){
            
            //process builder : Uncheck SMS Opt IN
            if(objCon.simplesms__DoNotSMS__c){
                objCon.SMS_Opt_In__c = false;
            }
            
            //process builder : Uncheck Dedupe Processed Checkbox when Contact Updated 
            if(objCon.Processed_By_Dedupe_Batch__c){
                if(oMap.get(objCon.id).FirstName!=newMap.get(objCon.id).FirstName){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
                if(oMap.get(objCon.id).LastName!=newMap.get(objCon.id).LastName){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
                if(oMap.get(objCon.id).MailingStreet!=newMap.get(objCon.id).MailingStreet){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
                if(oMap.get(objCon.id).OtherStreet!=newMap.get(objCon.id).OtherStreet){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
                if(oMap.get(objCon.id).MailingState!=newMap.get(objCon.id).MailingState){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
                if(oMap.get(objCon.id).OtherState!=newMap.get(objCon.id).OtherState){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
                if(oMap.get(objCon.id).MailingPostalCode!=newMap.get(objCon.id).MailingPostalCode){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
                if(oMap.get(objCon.id).OtherPostalCode !=newMap.get(objCon.id).OtherPostalCode ){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
                if(oMap.get(objCon.id).MobilePhone!=newMap.get(objCon.id).MobilePhone){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
                if(oMap.get(objCon.id).OtherPhone!=newMap.get(objCon.id).OtherPhone){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
                if(oMap.get(objCon.id).Email !=newMap.get(objCon.id).Email ){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
                if(oMap.get(objCon.id).Phone !=newMap.get(objCon.id).Phone ){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
                if(oMap.get(objCon.id).AccountId !=newMap.get(objCon.id).AccountId ){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
                 if(oMap.get(objCon.id).Email_1__c !=newMap.get(objCon.id).Email_1__c ){
                    objCon.Processed_By_Dedupe_Batch__c = false;
                }
            }
        }
        
        setOriginatingSource(newMap.values());
        
        //build map of zip codes to territories
        Map<String,ID> zipMap = new Map<String,ID>();
        Set<String> zipList = new Set<String>();
        for(Contact c : newMap.values()) {
            zipList.add(c.MailingPostalCode);
        }
 
        List<Territory_Zip_Code__c> codes = [SELECT Territory__r.id, Name FROM Territory_Zip_Code__c WHERE Name IN :zipList];
        for(Territory_Zip_Code__c z : codes) {
            zipMap.put(z.name,z.territory__r.id);
        }
        
        //changes start to remove account 
        
        for(Contact c : newMap.values()) {
        if(zipMap.containsKey(c.MailingPostalCode)) {
        c.territory__c = zipMap.get(c.MailingPostalCode);
        }
        }

        /*Map<Id, Account> contactIdToAccount = new Map<Id, Account>();
        for(Contact c : newMap.values()) {
            System.debug('con loop');
            System.debug(c);
            if(c.AccountId == null && c.of_Active_Reservations__c > 0) {
                Account newAccount = new Account();
                newAccount.Name = c.FirstName + ' ' + c.LastName + 'Household';
                newAccount.BillingStreet = c.MailingStreet;
                newAccount.BillingCity = c.MailingCity;
                newAccount.BillingState = c.MailingState;
                newAccount.BillingPostalCode = c.MailingPostalCode;
                newAccount.BillingCountry = c.MailingCountry;
                newAccount.Phone = c.Phone;
                newAccount.OwnerId = Constants.globalSettings.GenericOpptyOwnerID__c;
                contactIdToAccount.put(c.Id, newAccount);
            }
            if(zipMap.containsKey(c.MailingPostalCode)) {
                c.territory__c = zipMap.get(c.MailingPostalCode);
            }

        }*/

      /*  if(contactIdToAccount.size() > 0) {
            insert contactIdToAccount.values();
            for(Id contactId : contactIdToAccount.keySet()) {
                newMap.get(contactId).AccountId = contactIdToAccount.get(contactId).Id;
            }
        }*/
        //changes end to remove account 
    }

    public static void handleAfterInsert(Map<Id, Contact> newMap,List<Contact> webContact) {

        List<Opportunity> insertOpportunities = new List<Opportunity>();
        Id ttsales= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('TT Sales').getRecordTypeId();
        for(Contact newContact : newMap.values()) {
            //if(newContact.RecordTypeId == Constants.ContactCustomerContactRTId && newContact.Email == null && newContact.Portal_Add_Date__c != null) {
            if((newContact.RecordTypeId == Constants.ContactCustomerContactRTId || newContact.RecordTypeId == ttsales) && newContact.Portal_Add_Date__c != null) {
                Opportunity opp = new Opportunity();
                opp.RecordTypeId = Constants.OpportunityRVDealerSalesRTId;
                opp.Amount = 0;
                opp.CloseDate = Date.today().addDays(30);
                opp.StageName = 'Prospecting';
                opp.OwnerId = Constants.globalSettings.GenericOpptyOwnerID__c;
                opp.Contact_for_Opportunity__c = newContact.Id;
                opp.Name = newContact.FirstName + ' ' + newContact.LastName + ' - RV Dealer Opportunity';
                opp.Name = opp.Name.length() > 80 ? opp.Name.substring(0,80) : opp.Name;
                insertOpportunities.add(opp);
            }
        }

        if(insertOpportunities.size() > 0) {
            insert insertOpportunities;
        }
        // new code added    
    }
    //Chandan Tripathi
    //ELS :280 HytechPro 03/03/2021
   public static void handleAfterInsert2(List<Contact> webContact){
       List<Contact> contactBuffer= new List<Contact>();
        List<Contact> newContact= new List<Contact>();
		List<Contact> midContact=new List<Contact>();
		List<Contact> midContact2=new List<Contact>();
        Set<ID> contactToBeDeleted=new Set<Id>();
        for(Contact newlyCreatedLead: webContact){
            
            if(newlyCreatedLead.Email!=null&&!newlyCreatedLead.Email.equalsIgnoreCase('noemail@noemail.com')&&!newlyCreatedLead.Email.equalsIgnoreCase('n@a.com')&&!newlyCreatedLead.Email.equalsIgnoreCase('no@email.com')&&!newlyCreatedLead.Email.equalsIgnoreCase('koa@email.com')&&!newlyCreatedLead.Email.equalsIgnoreCase('none@none.com')){
            midContact.add(newlyCreatedLead);
        

		//Integer numberOfLead=[Select count() from Contact where Email=:newlyCreatedLead.Email And CreatedDate=Today];// will store the number of records for similar email created on similar date  
        ///    If(numberOfLead>3){
         //       contactToBeDeleted.add(newlyCreatedLead.Id);// id will be kept in a set to be deleted
          //  } 
            
        }
        }
		
		Set<String> emailFrommidContact=new Set<String>();
        for(Contact emailExtract:midContact){
            emailFrommidContact.add(emailExtract.Email);
        }
		
		midContact2= [Select Id,Email from Contact where Email IN :emailFrommidContact And createdDate=Today];
		
		Map<String,Integer> mapStrCon=new Map<String,Integer>();
        for( String objStr:emailFrommidContact){
            integer count=0;
            for(Contact objContact1:midContact2){
                if(objStr==objContact1.Email){
                    count++;
                }
            }
            if(count>3){
                mapStrCon.put(objStr,count-3);
            }
            
        }
        for(String objStr2:mapStrCon.keyset()){
            for(Contact objCon3:midContact2){
                if((objStr2==objCon3.Email)&&(mapStrCon.get(objStr2))>0){
                    contactToBeDeleted.add(objCon3.Id);
                    mapStrCon.put(objStr2,mapStrCon.get(objStr2)-1);
                }
            }
        }
		
       contactBuffer=[Select id,Firstname from Contact where Id In: contactToBeDeleted];
       for(Contact conToBeDeleted: contactBuffer){
           newContact.add(conToBeDeleted);
       }
        
        
        
        try{
            Delete newContact;
        }
        catch(Exception e){
            System.debug('I run till here');
        }       
       
       
       /* Set<id> contactIdList=new Set<id>();
        List<Contact> conDelFinal=new List<Contact>();
         List<Contact> conDel=new List<Contact>();
        
        for(Contact con:webContact){
            Integer contactNumber=0;
            if(con.FirstName!=Null){
           contactNumber=[Select count() from Contact where Originating_Source__c='Web' AND CreatedDate=Today AND Name=:con.FirstName+' '+con.LastName];
            }
            else{
                 contactNumber=[Select count() from Contact where Originating_Source__c='Web' AND CreatedDate=Today AND Name=:con.LastName];
            }
            if(contactNumber>3){
               contactIdList.add(con.id);
            }
            
                    conDel=[Select Id,Name from Contact where Id IN: contactIdList];
        for(Contact conToDeleteList:conDel){
            conDelFinal.add(conToDeleteList);
        }
        Try{
            Database.Delete(conDelFinal,false);
        }
            catch (DMLException ex){
        System.debug('I ran Till here');
}
            
        }*/
    }

    /** Method to synchronize contact updates with the primary client ID */
    public static void handleAfterUpdate(Map<Id, Contact> newContactsMap, Map<Id, Contact> oldContactMap) {
        System.debug('Enter After Update ------>');
        //Local vars
        List<Contact> contactList = new List<Contact> ();

        //Loop through the list of incoming contacts
        for (Contact myContact : newContactsMap.values()) {
            //Check if the update was something that is relevant to a Client Id record
            Contact oldContact = oldMap.containsKey(myContact.Id) == true ? oldMap.get(myContact.Id) : oldContactMap.get(myContact.Id);                         //Need to use persistant map to track changes in records across multiple triggers within a transaction
            if (myContact.FirstName != oldContact.FirstName || myContact.LastName != oldContact.LastName || myContact.MailingStreet != oldContact.MailingStreet ||
                myContact.MailingCity != oldContact.MailingCity || myContact.MailingState != oldContact.MailingState ||
                myContact.MailingPostalCode != oldContact.MailingPostalCode || myContact.MailingCountry != oldContact.MailingCountry ||
                myContact.Email != oldContact.Email || myContact.Phone != oldContact.Phone || myContact.MobilePhone != oldContact.MobilePhone ||
                myContact.Primary_Client_ID__c != oldContact.Primary_Client_ID__c)
                contactList.add(myContact);

            oldMap.put(myContact.Id, myContact);                         //Need update persistant map once all references to old values are complete
        }

        if (contactList.isEmpty()) return;

        //Pull Client ID records tied to these contacts
        List<ClientID__c> clientIdsToUpdate = new List<ClientID__c> ();
        User u = [SELECT Id FROM User WHERE FirstName='Sakonent' AND LastName='User' LIMIT 1];
        for (ClientID__c myClientId : [SELECT Id, FirstName__c, LastName__c, MailingStreet__c, MailingCity__c, MailingState__c, MailingPostalCode__c,
                                        MailingCountry__c, Email__c, Phone__c, Mobile_Phone__c, Contact__c, Primary_ClientID__c, ClientID_External_ID__c, Contact__r.Primary_Client_ID__c, Contact__r.LastModifiedById
                                       FROM ClientID__c
                                       WHERE Contact__c IN :contactList]) {
            if (myClientId.ClientID_External_ID__c == myClientID.Contact__r.Primary_Client_ID__c && myClientId.Contact__r.LastModifiedById != u.Id) {
                //Copy the Contact data to the Primary Client ID
                Contact myContact = newContactsMap.get(myClientId.Contact__c);
                myClientId.FirstName__c = myContact.FirstName;
                myClientId.LastName__c = myContact.LastName;
                //Do not update if address is Default address. Chintan Adhyapak, West Monroe Partners, February 17, 2017
                //if (!(String.isNotBlank(myContact.MailingStreet) && (myContact.MailingStreet.trim().startsWithIgnoreCase('123 Main St') || myContact.MailingStreet.trim().startsWithIgnoreCase('Default')))) {
                    //myContact.MailingStreet = myClientId.MailingStreet__c;
                    myClientId.MailingStreet__c = myContact.MailingStreet;
                    myClientId.MailingCity__c = myContact.MailingCity;
                    myClientId.MailingState__c = myContact.MailingState;
                    myClientId.MailingPostalCode__c = myContact.MailingPostalCode;
                    myClientId.MailingCountry__c = myContact.MailingCountry;
                //}
                myClientId.Email__c = myContact.Email;
                myClientId.Phone__c = myContact.Phone;
                myClientId.Mobile_Phone__c = myContact.MobilePhone;
                clientIdsToUpdate.add(myClientId);
            }
        }

        //Update Client IDs
        if (!clientIdsToUpdate.isEmpty())
            update clientIdsToUpdate;
    }  

    public static void handleBeforeDelete(Map<Id, Contact> oldMap){
        
        Id profileId = userinfo.getProfileId();
        if(profileId==label.ReservationProfileId){
            for(Contact con : oldMap.values()){
                con.adderror('Contact Cannot be deleted');
                return;
            }   
        }
        List<Contact> deleteContacts = [SELECT Id, FirstName, LastName, MasterRecordId, (SELECT Id, Name, Contact__c FROM ClientID__r) FROM Contact WHERE Id IN: oldMap.keySet()];
        List<ClientID__c> updateClientIDs = new List<ClientID__c>();
        for(Contact currContact : deleteContacts) {
            System.debug('Contact: ' + currContact.FirstName + ' ' + currContact.LastName + ' | ' + currContact.Id);
            for(ClientID__c currClientId : currContact.ClientID__r) {
                System.debug('ClientId: ' + currClientId.Name + ' | ' + currClientId.Id);
                updateClientIDs.add(currClientId);
            }
        }

        TriggerTracker.clientIds =  updateClientIDs;
    }

    public static Set<Id> masterIds = null;

    public static void handleAfterDelete(Map<Id, Contact> oldMap, List<ClientID__c> clientIds){
        Map<Id, Id> clientIdsToContact = new Map<Id, Id>();
        masterIds = new Set<Id>();
        for(ClientID__c currClientId : clientIds) {
            //if(oldMap.get(currClientId.Contact__c).MasterRecordId != null){
            Id currMasterId = oldMap.get(currClientId.Contact__c).MasterRecordId;
            currClientId.Contact__c = currMasterId;
            currClientId.Send_Update_Flag__c = true;
            masterIds.add(currMasterId);
            //}
        }

        if(clientIdsToContact.size() > 0) {
            update clientIds;
        }
    }
    
    public static void setOriginatingSource(List<Contact> newList){
        System.debug('do we even make it here?');
        Set<String> sourceIds = new Set<String>();
        for(Contact currContact : newList){
            if(currContact.Originating_Source__c == null){
                sourceIds.add(currContact.Source_ID__c);
            }
         
        }
        
        System.debug(sourceIds.size());
        if(sourceIds.size() <= 0){
            return;
        }
        
        List<Sources__c> sourceList = [SELECT Id, Source_ID__c, Source_Type__c FROM Sources__c WHERE Source_ID__c IN: sourceIds];
        Map<String, Sources__c> sourceMap = new Map<String, Sources__c>();
        System.debug('mapping');
        for(Sources__c currSource : sourceList){
            System.debug(currSource.Source_ID__c);
            sourceMap.put(currSource.Source_ID__c, currSource);
        }
        
        List<Contact> updateContacts = new List<Contact>();
        for(Contact currContact : newList){
            if(currContact.Originating_Source__c == null && sourceMap.containsKey(currContact.Source_ID__c)){
                currContact.Originating_Source__c = sourceMap.get(currContact.Source_ID__c).Source_Type__c;
            }
        }
    }
    
    /*public static void createOpportunity(Map<ID,Contact> newContacts){
        //existing opportunities for these contacts
        List<Opportunity> oList = [SELECT ID, contact_for_opportunity__c FROM Opportunity WHERE contact_for_opportunity__c IN :newContacts.keySet() AND StageName != 'Closed Won' AND StageName != 'Closed Lost'];

        //opportunities to exclude
        List<id> excludeIDs = new List<ID>();
        for(Opportunity o : oList) {
            excludeIDs.add(o.contact_for_opportunity__c);
        }

        //all cases of the contacts
        Map<ID,Case> caseMap = new Map<ID,Case>();
        for(Case c : [SELECT ID, Status, Property_Name__c, Check_in_Date__c, Check_out_Date__c, contact.id,Not_booked_Reason__c FROM Case WHERE contact.id IN :newContacts.keySet() ]) {
            caseMap.put(c.contact.id,c);
        }

        //all reservations of the contacts
        Map<ID,Reservation__c> reservationMap = new Map<ID,Reservation__c>();
        for(Reservation__c r : [SELECT ID, Arrival_Date__c, Departure_Date__c, Unique_Property_ID__c, Contact__r.id FROM Reservation__c WHERE Contact__r.id IN :newContacts.keySet() ]) {
            reservationMap.put(r.contact__r.id,r);
        }


        List<Opportunity> opList = new List<Opportunity>();
        List<String> properties = new List<String> {'Yosemite lakes','San Francisco RV','Mt. Hood','Portland Fairview','Tahoe Valley','Tropical Palms','Seaside'};

        //for all contacts that match the critiria create an opportunity
        for(Contact c : newContacts.values()) {

            if(caseMap.ContainsKey(c.id) &&
               caseMap.get(c.id).Status == 'New Reservation Not Booked' &&
               !properties.contains(caseMap.get(c.id).Property_Name__c) &&
               (reservationMap.get(c.id).Arrival_Date__c != caseMap.get(c.id).Check_in_Date__c ||
                reservationMap.get(c.id).Departure_Date__c != caseMap.get(c.id).Check_out_Date__c )                    //&& reservationMap.get(c.id).Unique_Property_ID__c != '5085'
               && !excludeIDs.contains(c.id)) {

                opList.add(new Opportunity(CloseDate = caseMap.get(c.id).Check_out_Date__c,
                                           name = 'Call Center Opportunity',
                                           StageName = 'Prospecting',
                                           Check_in_Date__c = caseMap.get(c.id).Check_in_Date__c,
                                           Check_out_Date__c = caseMap.get(c.id).Check_out_Date__c,
                                           contact_for_opportunity__c = caseMap.get(c.id).ContactID,
                                           ForecastCategoryName = 'Pipeline',
                                           Not_booked_Reason__c = caseMap.get(c.id).Not_booked_Reason__c,
                                           ownerid = '0050S000000zEvi',
                                           Property_Name__c = caseMap.get(c.id).Property_Name__c,
                                           RecordTypeId = '0120S0000005BEQ',
                                           Source__c = 'Phone'));
            }
        }

        insert opList;

    }*/

    /*public static void updateClientIdsFuture(Map<Id, Id> clientIdsToContact){
            List<ClientID__c> updateClientIds = new List<ClientID__c>();
            for(Id currClient : clientIdsToContact.keySet()) {
                    ClientID__c buildClient = new ClientID__c();
                    buildClient.Id = currClient;
                    buildClient.Contact__c = clientIdsToContact.get(currClient);
                    buildClient.Send_Update_Flag__c = true;
                    updateClientIds.add(buildClient);
            }
            update updateClientIds;
       }*/
}