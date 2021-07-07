public class ZapierLogTriggerHandler {
    
    public static void handleAfterInsert(Map<Id,Zapier_logs__c> newMap) {
        createContact(newMap);    
    }
    
    public static void createContact(Map<Id,Zapier_logs__c> newMap){
        Map<string, Sources__c> imapOfSources = new map<string, Sources__c>();
        SourceUtil objSource = new SourceUtil();
        List<Contact_Sources__c> ListOfActInterest = new List<Contact_Sources__c>();
        Map<Id,Zapier_logs__c> mapContactZapierLog = new Map<Id,Zapier_logs__c>();
        Map<Id,contact> newContactCreatedmap = new Map<Id,Contact>();
        system.debug('newMap.values()'+newMap); 
        for(Zapier_logs__c objZapLog : newMap.values()){
            
            Contact objCon = new Contact();
            if(objZapLog.first_Name__c!=null){
                objCon.FirstName = objZapLog.first_Name__c;
            }else{
                objCon.FirstName = 'Camper';
            }
            
            if(objZapLog.Last_name__c!=null){
                objCon.LastName = objZapLog.Last_name__c;
            }else{
                objCon.LastName = 'Lname';
            }
            
            if(objZapLog.Email__c!=null){
                objCon.Email = objZapLog.Email__c;
            }else{
                objCon.Email = 'noemail@noemail.com';
            }
            
            if(objZapLog.State_of_Residence__c!=null && objZapLog.Country__c!=null){
                objCon.MailingState = objZapLog.State_of_Residence__c;
                objCon.MailingCountry = objZapLog.Country__c;
                objCon.MailingCity = 'Anytown';
                objCon.MailingPostalCode = '99999';
                objCon.MailingStreet = '123 Main St';
            }
            imapOfSources = objSource.getLowerCaseSources();
            if (objZapLog!=null && !String.IsBlank(objZapLog.Source_ID__c) && imapOfSources.containsKey(objZapLog.Source_ID__c.toLowerCase())) {
                objCon.Originating_Source__c = imapOfSources.get(objZapLog.Source_ID__c.toLowerCase()).Source_Type__c;
                objCon.Source_ID__c = imapOfSources.get(objZapLog.Source_ID__c.toLowerCase()).Source_ID__c;
                objCon.Source_ID_2__c = imapOfSources.get(objZapLog.Source_ID__c.toLowerCase()).id;
                objCon.Source_Description__c = imapOfSources.get(objZapLog.Source_ID__c.toLowerCase()).Description__c;
            }else{
                objCon.Originating_Source__c = 'Zapier';
            }
            newContactCreatedmap.put(objZapLog.Id,objCon);
        }
        if(newContactCreatedmap.size()>0){
            try{
                insert newContactCreatedmap.values();
                list<Zapier_logs__c> zapLoglist = new list<Zapier_logs__c>();
                for(Zapier_logs__c objZapLog : newMap.values()){
                    zapLoglist.add(new Zapier_logs__c(id=objZapLog.id,ContactId_Error__c = newContactCreatedmap.get(objZapLog.id).Id) ); 
                    mapContactZapierLog.put(newContactCreatedmap.get(objZapLog.id).Id,objZapLog);
                }
                if(zapLoglist.size()>0){
                    update zapLoglist;
                }
                imapOfSources = objSource.getLowerCaseSources();
                for(Contact objCon : newContactCreatedmap.values()){
                    Zapier_logs__c objZapLog = (mapContactZapierLog.containsKey(objCon.id)) ? mapContactZapierLog.get(objCon.id) : null;
                    Contact_Sources__c ActInterest = new Contact_Sources__c();
                    ActInterest.Contact_Id__c = objCon.Id;
                    if(objZapLog.What_experience_would_you_like_to_win__c!=null){
                        ActInterest.What_experience_would_you_like_to_win__c=objZapLog.What_experience_would_you_like_to_win__c;    
                    }
                    if(objZapLog.What_s_your_Ideal_Getaway__c!=null){
                        ActInterest.What_s_your_Ideal_Getaway__c = objZapLog.What_s_your_Ideal_Getaway__c;   
                    }
                    if(objZapLog.Where_are_you_Interested_in_Camping__c!=null){
                        ActInterest.Where_are_you_Interested_in_Camping__c = objZapLog.Where_are_you_Interested_in_Camping__c;   
                    }
                    if (objZapLog!=null && !String.IsBlank(objZapLog.Source_ID__c) && imapOfSources.containsKey(objZapLog.Source_ID__c.toLowerCase())) {
                        ActInterest.Sources_ID__c = imapOfSources.get(objZapLog.Source_ID__c.toLowerCase()).Id;
                        ActInterest.Source_Description__c  = imapOfSources.get(objZapLog.Source_ID__c.toLowerCase()).Description__c;
                    }
                    ActInterest.Add_Date__c = system.today();
                    ListOfActInterest.add(ActInterest);
                }
                if (ListOfActInterest.size()  > 0 ){
                    insert ListOfActInterest;
                }
            }Catch(exception ex){
                for(Zapier_logs__c objZapLog : newMap.values()){
                    objZapLog.ContactId_Error__c = ex.getStackTraceString()+ex.getMessage();
                }
            }          
        }
        system.debug(newContactCreatedmap.values());        
    }
}