/** The handler class for all Client ID trigger events
* Chintan Adhyapak, West Monroe Partners. August 09, 2016
*/
public with sharing class ClientIDTriggerHandler {
    
    
    
    //Need to use persistant map to track changes in records across multiple triggers within a transaction
    public static Map<Id, ClientID__c> updatedOldMap {get {if(updatedOldMap == null) updatedOldMap = new Map<Id, ClientID__c>(); return updatedOldMap;}set;}
    
    public static void beforeUpdateClientID(List<ClientID__c> lstClient, Map<Id, ClientID__c> oldMap){
        System.debug('Enter Update Method 491');
        List<ClientID__c> lstC=new List<ClientID__c>();
        for(ClientID__c objClient : lstClient){
            System.debug('Enter For Loop 494');
            if(objClient.MailingStreet__c != oldMap.get(objClient.Id).MailingStreet__c){
                System.debug('Enter IF 496');
                objClient.Send_Update_Flag__c=true;
            }
            lstC.add(objClient);				
        }
        //update lstC;
    }
    
    
    
    
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
    public static void handlebeforeInsert(List<ClientID__c> ListClient){
        String afterplace;
        String afterMailingContry;
        try{
            for(ClientID__c objClient : ListClient ){
                
         /*       if(objClient.Phone__c!=null){
                    String phoneField=objClient.Phone__c;
                    objClient.Phone__c=selectMethod(phoneField,objClient.MailingCountry__c);
                }
                if(objClient.Mobile_Phone__c!=null){
                    String phoneField=objClient.Mobile_Phone__c;
                    objClient.Mobile_Phone__c=selectMethod(phoneField,objClient.MailingCountry__c);
                }*/
    
                        
                      /*  if(objClient.Phone__c!=null){
                String phoneFunctionality=objClient.Phone__c;
                phoneFunctionality=phoneFunctionality.replaceAll('[^0-9]', '');
                phoneFunctionality=phoneFunctionality.replaceAll('(\\s+)','');
                if((phoneFunctionality.length())<10||(phoneFunctionality.length())>10){
                    phoneFunctionality='9999999999';
                }
                objClient.Phone__c=phoneFunctionality;
            }*/
                
                
                
                //objClient.Send_Update_Flag__c = True;
                afterMailingContry = objClient.MailingCountry__c;
                if((objClient.MailingCountry__c == null || objClient.MailingCountry__c == 'US') && (integer.valueof(objClient.MailingPostalCode__c) > 4)&&(objClient.MailingState__c.contains('AL')||objClient.MailingState__c.contains('AK')
                                                                                                                                                           || objClient.MailingState__c.contains('AZ')||objClient.MailingState__c.contains('AR') || objClient.MailingState__c.contains('CA') ||objClient.MailingState__c.contains('CO')
                                                                                                                                                           ||objClient.MailingState__c.contains('CT') ||objClient.MailingState__c.contains('DE') || objClient.MailingState__c.contains('FL') ||objClient.MailingState__c.contains('GA') 
                                                                                                                                                           ||objClient.MailingState__c.contains('HI') ||objClient.MailingState__c.contains('ID') || objClient.MailingState__c.contains('IL') ||objClient.MailingState__c.contains('IN')  
                                                                                                                                                           ||objClient.MailingState__c.contains('IA') ||objClient.MailingState__c.contains('KS') || objClient.MailingState__c.contains('KY') ||objClient.MailingState__c.contains('LA') 
                                                                                                                                                           ||objClient.MailingState__c.contains('ME') ||objClient.MailingState__c.contains('MD') || objClient.MailingState__c.contains('MA') ||objClient.MailingState__c.contains('MI') 
                                                                                                                                                           || objClient.MailingState__c.contains('MN')||objClient.MailingState__c.contains('MS') || objClient.MailingState__c.contains('MO') ||objClient.MailingState__c.contains('MT')  
                                                                                                                                                           || objClient.MailingState__c.contains('NE')||objClient.MailingState__c.contains('NV') || objClient.MailingState__c.contains('NH') ||objClient.MailingState__c.contains('NJ')    
                                                                                                                                                           || objClient.MailingState__c.contains('NM')||objClient.MailingState__c.contains('NY') || objClient.MailingState__c.contains('NC') ||objClient.MailingState__c.contains('ND')    
                                                                                                                                                           || objClient.MailingState__c.contains('OH')||objClient.MailingState__c.contains('OK') ||  objClient.MailingState__c.contains('OR')||objClient.MailingState__c.contains('PA')
                                                                                                                                                           || objClient.MailingState__c.contains('RI')||objClient.MailingState__c.contains('SC') ||  objClient.MailingState__c.contains('SD')||objClient.MailingState__c.contains('TN')
                                                                                                                                                           || objClient.MailingState__c.contains('TX')||objClient.MailingState__c.contains('UT') ||  objClient.MailingState__c.contains('VT')||objClient.MailingState__c.contains('VA') 
                                                                                                                                                           || objClient.MailingState__c.contains('WA')||objClient.MailingState__c.contains('WV') ||  objClient.MailingState__c.contains('WI')||objClient.MailingState__c.contains('WY')                                                                                                                    
                                                                                                                                                           || objClient.MailingState__c.contains('XX')                                                                                                                   
                                                                                                                                                          )){
                                                                                                                                                              objClient.MailingCountry__c = 'USA';
                                                                                                                                                              //objClient.Send_Update_Flag__c=true;
                                                                                                                                                          }
                afterplace = objClient.MailingStreet__c;
                System.debug('Starting string---------->'+afterplace);
                Map<String, String> map1 = new Map<String, String>();
                
                
                map1.put('STREET','St');map1.put('DRIVE','Dr');map1.put('AVENUE','Ave');map1.put('LANE','Ln');map1.put('COURT','Ct');
                map1.put('ROAD','Rd');map1.put('CIRCLE','Cir');map1.put('TERRACE','Terr');map1.put('BOULEVARD','Blvd');map1.put('PLACE','Pl');
                map1.put('PARKWAY','Pkwy');map1.put('PLAZA','Plz');map1.put('APARTMENT','Apt');map1.put('SUITE','Ste');map1.put('UNIT','Ut');
                map1.put('SPACE','Spc');map1.put('BOX','Box');map1.put('TRAIL','Trl');map1.put('POB','PO Box');map1.put('FLOOR','Flr');
                map1.put('BUILDING','Bldg');map1.put('NORTH','N');map1.put('SOUTH','S');map1.put('EAST','E');map1.put('WEST','W');
                map1.put('NORTHEAST','NE');map1.put('NORTHWEST','NW');map1.put('SOUTHEAST','SE');map1.put('SOUTHWEST','SW');
                map1.put('POSTOFFICE','PO');map1.put('EXPRESSWAY','Expwy');map1.put('APT STE BLDG (OPTIONAL)','');map1.put('APARTMENT SUITE BUILDING (OPTIONAL)','');
                map1.put('APARTMENT SUITE UNIT SPACE','');map1.put('APARTMENT SUITE UNIT BUILDING FLOOR','');map1.put('APARTMENT SUITE UNIT BUILDING','');
                map1.put('APARTMENT OR SUITE NUMBER','');map1.put('APARTMENT SUITE UNIT SPACE','');map1.put('ADDRESS Line 2','');map1.put('BILLING ADDRESS LINE 2','');
                map1.put('STREET ADDRESS 2','');
                
                afterplace=afterplace.trim();
                System.debug(' after trim'+afterplace);
                //afterplace=afterplace.replaceAll('(\\s+)',' ');
                System.debug(' after (\\s+)'+afterplace);
                //afterplace=afterplace.replaceAll('-', '');                
                
                if(map1.containsKey(afterplace.toUpperCase()))   {
                    afterplace=' ';
                    //s=getValue;
                }                           
                
                
                
                
                
                afterplace=afterplace.replaceAll('(?i)post office', 'postoffice');
                System.debug(' after post office'+afterplace);
                afterplace=afterplace.replaceAll('[^a-zA-Z0-9\\s+-]', '');
                afterplace=afterplace.replaceAll('(\\s+)',' ');
                System.debug(' after ....'+afterplace);
                afterplace=afterplace.replaceAll('#', '');
                System.debug(' after ####'+afterplace);
                afterplace=afterplace.replaceAll(',', '');
                System.debug(' after ,,,,,'+afterplace);
                
                System.debug('BEfore for loop Starting string---------->'+afterplace);
                List<String> lstAlpha = afterplace.split(' ');// Splitting the String based on sapce;
                System.debug('list to showcase---------->'+ lstAlpha);
                List<String> finalList=new List<String>();
                //System.debug('lstAlpha List----->'+lstAlpha)
                for(String s: lstAlpha){
                    if(map1.containsKey(s.toUpperCase()))   {
                        String getValue=map1.get(s.toUpperCase());
                        s=getValue;
                    }
                    finalList.add(s);
                }
                String listToString=' ';
                for(String ConvertToSentence: finalList){
                    listToString+=ConvertToSentence+' ';
                }
                System.debug('after for loop  before Final--------->'+listToString);              
                listToString=listToString.trim();
                listToString=listToString.replaceAll('(?i)Apt Ste Flr Etc', '');
                listToString=listToString.replaceAll('(?i)Apt Ste Ut Bldg Flr', '');
                listToString=listToString.replaceAll('(?i)Apt Ste Ut Bldg', '');
                listToString=listToString.replaceAll('(?i)Apt Ste Bldg (Optional)', '');
                listToString=listToString.replaceAll('(?i)Apt Ste Ut Bldg', '');                
                
                System.debug('Final--------->'+listToString);
                
                
                //String listToString='twenty-firsT sixtry #### twenty fourth tHirtyThird eleventh tenth first';
                //listToString=listToString.replaceAll('[^a-zA-Z0-9\\s+-]', '');
                System.debug('Removing of extra character'+listToString);
                Map<String,String> numberMap1=new Map<String,String>();
                numberMap1.put('TWENTY','2');numberMap1.put('THIRTY','3');numberMap1.put('FORTY','4');numberMap1.put('FIFTY','5');
                numberMap1.put('SIXTY','6');numberMap1.put('SEVENTY','7');numberMap1.put('EIGHTY','8');numberMap1.put('NINETY','9');
                System.debug('Map1---->'+ numberMap1.keySet());
                
                Map<String,String> numberMap2=new Map<String,String>();
                numberMap2.put('FIRST','1st');numberMap2.put('SECOND','2nd');numberMap2.put('THIRD','3rd');numberMap2.put('FOURTH','4th');
                numberMap2.put('FIFTH','5th');numberMap2.put('SIXTH','6th');numberMap2.put('SEVENTH','7th');numberMap2.put('EIGHTH','8th');
                numberMap2.put('NINTH','9th');
                System.debug('Map2---->'+ numberMap2.keySet());
                
                Map<String,String> numberMap3=new Map<String,String>();
                numberMap3.put('TENTH','10th');numberMap3.put('ELEVENTH','11th');numberMap3.put('TWELFTH','12th');
                numberMap3.put('THIRTEENTH','13th');numberMap3.put('FOURTEENTH','14th');numberMap3.put('FIFTEENTH','15th');
                numberMap3.put('SIXTEENTH','16th');numberMap3.put('SEVENTEENTH','17th');numberMap3.put('EIGHTEENTH','18th');
                numberMap3.put('NINETEENTH','19th');
                System.debug('Map3---->'+ numberMap3.keySet());
                
                
                Map<String,String> numberMap4=new Map<String,String>();
                numberMap1.put('TWENTIETH','2');numberMap1.put('THIRTIETH','3');numberMap1.put('FORTIETH','4');numberMap1.put('FIFTIETH','5');
                numberMap1.put('SIXTIETH','6');numberMap1.put('SEVENTIETH','7');numberMap1.put('EIGHTIETH','8');numberMap1.put('NINETIETH','9');
                System.debug('Map1---->'+ numberMap1.keySet());                
                
                
                for(Integer z=1;z<10;z++){             
                    for(String s: numberMap1.KeySet()){
                        for(String t:numberMap2.KeySet()){
                            
                            if((listToString.containsIgnoreCase(s))&&(listToString.containsIgnoreCase(t))){
                                String notfinding=s+'-'+t;
                                System.debug('These are the findings'+notfinding);
                                if(listToString.containsIgnoreCase(s+' '+t)){
                                    listToString = listToString.replaceAll('(?i)'+s+' '+t, ' '+numberMap1.get(s)+numberMap2.get(t)+' ');
                                }
                                if(listToString.containsIgnoreCase(s+'-'+t)){
                                    System.debug('Iam here');
                                    listToString = listToString.replaceAll('(?i)'+s+'-'+t, ' '+numberMap1.get(s)+numberMap2.get(t)+' ');
                                }
                                if(listToString.containsIgnoreCase(s+t)){
                                    System.debug('we are inside of s+t'+s+t);
                                    listToString = listToString.replaceAll('(?i)'+s+t, ' '+numberMap1.get(s)+numberMap2.get(t)+' ');
                                }
                            }
                        }
                    }
                }
                
                
                
                
                
                
                
                
                
                for(Integer z=1;z<10;z++){             
                    for(String s: numberMap4.KeySet()){
                        for(String t:numberMap2.KeySet()){
                            
                            if((listToString.containsIgnoreCase(s))&&(listToString.containsIgnoreCase(t))){
                                String notfinding=s+'-'+t;
                                System.debug('These are the findings'+notfinding);
                                if(listToString.containsIgnoreCase(s+' '+t)){
                                    listToString = listToString.replaceAll('(?i)'+s+' '+t, ' '+numberMap4.get(s)+numberMap2.get(t)+' ');
                                }
                                if(listToString.containsIgnoreCase(s+'-'+t)){
                                    System.debug('Iam here');
                                    listToString = listToString.replaceAll('(?i)'+s+'-'+t, ' '+numberMap4.get(s)+numberMap2.get(t)+' ');
                                }
                                if(listToString.containsIgnoreCase(s+t)){
                                    System.debug('we are inside of s+t'+s+t);
                                    listToString = listToString.replaceAll('(?i)'+s+t, ' '+numberMap4.get(s)+numberMap2.get(t)+' ');
                                }
                            }
                        }
                    }
                } 
                
                
                
                
                
                
                
                
                
                
                System.debug('After the three if statments'+listToString);
                for(Integer z=1;z<5;z++){ 
                    for(String t2:numberMap3.KeySet()){
                        
                        if(listToString.containsIgnoreCase(t2)){
                            listToString = listToString.replaceAll('(?i)'+t2+'', ' '+numberMap3.get(t2)+' ');
                        }
                    }
                }
                
                System.debug('After the t2 Stringg statments'+listToString);
                for(Integer z=1;z<5;z++){ 
                    for(String t3:numberMap2.KeySet()){
                        
                        if(listToString.containsIgnoreCase(t3)){
                            listToString = listToString.replaceAll('(?i)'+t3, ' '+numberMap2.get(t3)+' ');
                        }
                    }
                }
                
                for(String t5:numberMap1.KeySet()){             
                    if(listToString.containsIgnoreCase(t5)){
                        Integer toEndTheLoop=1;
                        while(listToString.containsIgnoreCase(t5)&&(toEndTheLoop<5)){
                            toEndTheLoop+=1;
                            System.debug('I got it here to the last line');
                            
                            Integer one= listToString.indexOfIgnoreCase(t5);
                            //  Integer two=numberMap1.get(t5).length();
                            Integer two=t5.length();
                            if(one==0){
                                if(listToString.mid(two,1).isNumeric()){
                                    System.debug('we got the first part');
                                    listToString=numberMap1.get(t5)+listToString.mid(two,3)+' '+listToString.mid(two+3,listToString.length());
                                }
                            }
                            if(one>0){
                                
                                if(listToString.mid(two+one,1).isNumeric()){
                                    System.debug('we got the second part');
                                    listToString=listToString.mid(0,one)+' '+numberMap1.get(t5)+listToString.mid(two+one,3)+' '+listToString.mid(two+one+3,listToString.length());
                                }
                                
                            }
                            
                            //listToString = listToString.replaceAll('\\s(?i)'+t5+'[0-9]', ' '+numberMap1.get(t5));
                        }
                    } 
                }
                
                
                
                
                
                for(String t5:numberMap4.KeySet()){             
                    if(listToString.containsIgnoreCase(t5)){
                        Integer toEndTheLoop=1;
                        while(listToString.containsIgnoreCase(t5)&&(toEndTheLoop<5)){
                            toEndTheLoop+=1;
                            System.debug('I got it here to the last line');
                            
                            Integer one= listToString.indexOfIgnoreCase(t5);
                            //  Integer two=numberMap1.get(t5).length();
                            Integer two=t5.length();
                            if(one==0){
                                if(listToString.mid(two,1).isNumeric()){
                                    System.debug('we got the first part');
                                    listToString=numberMap4.get(t5)+listToString.mid(two,3)+' '+listToString.mid(two+3,listToString.length());
                                }
                            }
                            if(one>0){
                                
                                if(listToString.mid(two+one,1).isNumeric()){
                                    System.debug('we got the second part');
                                    listToString=listToString.mid(0,one)+' '+numberMap4.get(t5)+listToString.mid(two+one,3)+' '+listToString.mid(two+one+3,listToString.length());
                                }
                                
                            }
                            
                            //listToString = listToString.replaceAll('\\s(?i)'+t5+'[0-9]', ' '+numberMap1.get(t5));
                        }
                    } 
                }
                
                
                
                
                
                /*
                System.debug('After the t3 Stringg statments'+listToString);
                for(Integer z=1;z<5;z++){      
                    for(String t4:numberMap1.KeySet()){
                        
                        if(listToString.containsIgnoreCase(t4)){
                            listToString = listToString.replaceAll('(?i)'+t4, ' '+numberMap1.get(t4)+'0th ');
                        }
                        
                    }
                }
                
*/                
                for(Integer z=1;z<5;z++){      
                    for(String t4:numberMap4.KeySet()){
                        
                        if(listToString.containsIgnoreCase(t4)){
                            listToString = listToString.replaceAll('(?i)'+t4, ' '+numberMap4.get(t4)+'0th ');
                        }
                        
                    }
                }
                
                
                
             
                listToString=listToString.trim();
                listToString=listToString.replaceAll('[^a-zA-Z0-9\\s+]', '');
                 listToString=listToString.replaceAll('\\s+',' ');
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                objClient.MailingStreet__c=listToString;
                
                
            } 
            System.debug('-------> Else If End');
        }catch(Exception e){
            System.debug('------->'+e.getLineNumber());
            System.debug('------->'+e.getMessage());            
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    /** The handler method for after insert event. Set the Primary Client ID on the Contact */
    // Calculate primary client id for related contacts
    public static void handleAfterInsert(Map<Id, ClientID__c> newMap) {
        //local vars
        Map<Id, ClientID__c> contactClientMap = new Map<Id, ClientID__c> ();
        List<Contact> contactsToUpdate = new List<Contact> ();
        Set<Id> contactIdsForPrimaryClientIdCalculation = new Set<Id>();
        
        //loop through incoming client IDs
        for(ClientID__c newClientID : newMap.values()) {
            if (newClientID.Primary_ClientID__c)
                contactClientMap.put(newClientID.Contact__c, newClientID);
            if(newClientID.Contact__c != null) {
                contactIdsForPrimaryClientIdCalculation.add(newClientID.Contact__c);
            }
        }
        
        if (!contactClientMap.isEmpty()) {
            
            //Pull Contact records tied to these primary client IDs
            for (Contact myContact : [SELECT Id, Primary_Client_ID__c FROM Contact Where Id in :contactClientMap.keySet()]) {
                ClientID__c myClientId = contactClientMap.get(myContact.Id);
                myContact.Primary_Client_ID__c = myClientId.ClientID_External_ID__c;
                myContact.Sync_with_Pardot__c = true;
                contactsToUpdate.add(myContact);
            }
            
            //Update Contacts
            if (!contactsToUpdate.isEmpty())
                update contactsToUpdate;
        }
        
        if(contactIdsForPrimaryClientIdCalculation.size() > 0) {
            PrimaryClientIDUtil.assignPrimaryClientID(contactIdsForPrimaryClientIdCalculation);
        }
    } //handleAfterInsert
    
    
    //Method for updating the values of the custom rollup fields on the contact object
    public static void updateCustomContactRollups(List<ClientID__c> clientList){
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        
        //make initial map of all related contacts with 0 counts.
        for(ClientID__c currClientID : clientList){
            Id currContactId = currClientID.Contact__c;
            
            if(currContactId != null &&
               !contactMap.containsKey(currContactId)){
                   Contact currContact = new Contact();
                   currContact.Id = currContactId;
                   currContact.ClientID_Rollup__c = 0;
                   currContact.ClientID_DBD_Rollup__c = 0;
                   contactMap.put(currContactId, currContact);
               }
        }
        
        Set<Id> contactIds = contactMap.keySet();
        Set<Id> masterIds = ContactTriggerHandler.masterIds;
        String query = 'SELECT Id, Contact__c, Deleted_by_Digi__c, Send_Update_Flag__c ' +
            'FROM ClientID__c ' +
            'WHERE Contact__r.Id IN: contactIds ';
        
        System.debug('masterIds: ' + ContactTriggerHandler.masterIds);
        if(ContactTriggerHandler.masterIds != null){
            query += 'AND (NOT Contact__c IN: masterIds)';
        }
        
        List<ClientID__c> allClientIDs = Database.query(query);
        
        if(allClientIDs.size() == 0){
            update contactMap.values();
            return;
        }
        
        //loop through all the the retrieved ClientIds and populate custom rollup summaries
        for(ClientID__c currClient : allClientIDs){
            
            Id currContactId = currClient.Contact__c;
            if(currContactId == null){
                continue;
            }
            
            Contact currContact = contactMap.get(currContactId);
            Decimal idRollup = currContact.ClientID_Rollup__c;
            if(currClient.Deleted_by_Digi__c){
                currContact.ClientID_DBD_Rollup__c++;
            }
            idRollup++;
            currContact.ClientID_Rollup__c = idRollup;
            
            contactMap.put(currContactId, currContact);
        }
        
        update contactMap.values();
    }
    
    
    /** The handler method for after update event. Update Contact data if client ID is the Primary */
    public static void handleAfterUpdate(Map<Id, ClientID__c> oldMap, Map<Id, ClientID__c> newMap) {
        //local vars
        Map<Id, ClientID__c> contactClientMap = new Map<Id, ClientID__c> ();
        List<Contact> contactsToUpdate = new List<Contact> ();
        Set<Id> contactIdsForPrimaryClientIdCalculation = new Set<Id>();
        
        //loop through incoming client IDs
        for(ClientID__c newClientID : newMap.values()) {
            ClientID__c oldClientID =  updatedOldMap.containsKey(newClientID.Id) == true ? updatedOldMap.get(newClientID.Id) : oldMap.get(newClientID.Id); //Need to use persistant map to track changes in records across multiple triggers within a transaction
            
            System.debug(updatedOldMap.get(newClientID.Id));
            System.debug(oldMap.get(newClientID.Id));
            System.debug(newClientID.Primary_ClientID__c);
            System.debug(newClientID.FirstName__c + ' | ' + oldClientID.FirstName__c);
            System.debug(newClientID.LastName__c + ' | ' + oldClientID.LastName__c);
            System.debug(newClientID.Email__c + ' | ' + oldClientID.Email__c);
            System.debug(newClientID.Contact__c + ' | ' + oldClientID.Contact__c);
            if (newClientID.Primary_ClientID__c &&
                (newClientID.Contact__c != oldClientID.Contact__c
                 || newClientID.Primary_ClientID__c != oldClientID.Primary_ClientID__c
                 || newClientID.FirstName__c != oldClientID.FirstName__c
                 || newClientID.LastName__c != oldClientID.LastName__c
                 || newClientID.MailingStreet__c != oldClientID.MailingStreet__c
                 || newClientID.MailingCity__c != oldClientID.MailingCity__c
                 || newClientID.MailingState__c != oldClientID.MailingState__c
                 || newClientID.MailingPostalCode__c != oldClientID.MailingPostalCode__c
                 || newClientID.MailingCountry__c != oldClientID.MailingCountry__c
                 || newClientID.Email__c != oldClientID.Email__c
                 || newClientID.Phone__c != oldClientID.Phone__c
                 || newClientID.Mobile_Phone__c != oldClientID.Mobile_Phone__c
                 || newClientID.ClientID_External_ID__c != oldClientID.ClientID_External_ID__c
                 || PrimaryClientIDUtil.postMergePrimaryClientIDCalculation == true
                )
               )
            {
                contactClientMap.put(newClientID.Contact__c, newClientID);
            }
            
            // 03/29 - Nate Helterbrand, West Monroe Partners,
            // adding condition to check for changes for the Contact__c field
            if(newClientID.Number_of_Reservations__c != oldClientID.Number_of_Reservations__c
               || newClientID.Deleted_by_Digi__c != oldClientID.Deleted_by_Digi__c
               || newClientId.Contact__c != oldClientID.Contact__c
              )
            {
                contactIdsForPrimaryClientIdCalculation.add(newClientID.Contact__c);
                
                // 03/29 - Nate Helterbrand, West Monroe Partners,
                // Primary ID Client Calculation should be triggered on both contacts
                if (oldClientID.Contact__c != null) {
                    contactIdsForPrimaryClientIdCalculation.add(oldClientID.Contact__c);
                }
            }
            
            updatedOldMap.put(newClientID.Id, newClientID); //Update persistant map once all necessary references to the old values have been made
        }
        
        if (!contactClientMap.isEmpty()) {
            
            //Pull Contact records tied to these primary client IDs
            for (Contact myContact : [SELECT Id, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode,
                                      MailingCountry, Email, Phone, MobilePhone, Primary_Client_ID__c FROM Contact Where Id in :contactClientMap.keySet()]) {
                                          ClientID__c myClientId = contactClientMap.get(myContact.Id);
                                          myContact.FirstName = myClientId.FirstName__c;
                                          myContact.LastName = myClientId.LastName__c;
                                          //Do not update if address is Default address. Chintan Adhyapak, West Monroe Partners, February 17, 2017
                                          if (!(String.isNotBlank(myClientId.MailingStreet__c) && (myClientId.MailingStreet__c.trim().startsWithIgnoreCase('123 Main St') || myClientId.MailingStreet__c.trim().startsWithIgnoreCase('Default')))) {
                                              myContact.MailingStreet = myClientId.MailingStreet__c;
                                              myContact.MailingCity = myClientId.MailingCity__c;
                                              myContact.MailingState = myClientId.MailingState__c;
                                              myContact.MailingPostalCode = myClientId.MailingPostalCode__c;
                                              myContact.MailingCountry = myClientId.MailingCountry__c;
                                          }
                                          myContact.Email = myClientId.Email__c;
                                          myContact.Phone = myClientId.Phone__c;
                                          myContact.MobilePhone = myClientId.Mobile_Phone__c;
                                          myContact.Primary_Client_ID__c = myClientId.ClientID_External_ID__c;
                                          contactsToUpdate.add(myContact);
                                      }
            
            //Update Contacts
            if (!contactsToUpdate.isEmpty())
                update contactsToUpdate;
        }
        
        if(contactIdsForPrimaryClientIdCalculation.size() > 0) {
            PrimaryClientIDUtil.assignPrimaryClientID(contactIdsForPrimaryClientIdCalculation);
        }
    } //handleAfterUpdate
}