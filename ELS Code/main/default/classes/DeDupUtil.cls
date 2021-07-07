/*
Author: Mahwish Iqbal
Created Date: 13/7/2015
Description: 
            1)This class is used to run De Duplication methodology.
            2)This class check duplication of contacts when inserting from different sources.
            3)This class perform deduplication from wrapperDedup values. 
            
Description: Used for deduplication 
*/

public without sharing class DeDupUtil {
    
    String iObject; //This string is used to identify source from constructor
    LogsUtil iLog; //Initiate Log obj
    SourceUtil objSource;
    
    final string CLIENT_ID = 'ClientID';
    
    /*******************************MAPS***********************/
    
    // Maps of exisiting and duplicate contacts //
    public Map<String, Contact> mapConAndEmail;
    public Map<string, Contact> mapConAndEmail2;
    
    public Map<String, Contact> mapConAndFLAS;
    public Map<string, Contact> mapConAndFLAS2;
    
    public Map<String, Contact> mapConAndLAZ;
    public map<string, Contact> mapConAndLAZ2;
    
    public Map<String, Contact> mapConAndPL;
    public Map<String, Contact> mapConAndPF;
    
    // Maps of new and duplicate contacts //
    public Map<String, Contact> mapConAndEmailN;
    public Map<String, Contact> mapConAndEmail2N;
    
    public Map<String, Contact> mapConAndFLASN;
    public map<string, Contact> mapConAndFLAS2N;
    
    public Map<String, Contact> mapConAndLAZN;
    public map<string, Contact> mapConAndLAZ2N;
    
    public Map<String, Contact> mapConAndPLN;
    public Map<String, Contact> mapConAndPFN;
    
    // Maps to contain unique key of new and duplicate contacts //
    public Map<String, Integer> mapConAndEmails;
    public Map<String, Integer> mapConAndEmail2s;
    
    public Map<String, Integer> mapConAndFLASs;
    public Map<String, Integer> mapConAndFLAS2s;
    
    public Map<String, Integer> mapConAndLAZs;
    public Map<String, Integer> mapConAndLAZ2s;
    
    public Map<String, Integer> mapConAndPLs;
    public Map<String, Integer> mapConAndPFs;
    
    // Maps of insert and update contacts //
    public Map<Integer, Contact> mapOfContToInsert;
    public Map<String, Contact> mapOfConToUpdate;
    
    // Maps of show eror description
    Map<Integer, String> mapToShowDescUpdate, mapToShowDescInsert; 
    
    Map<string, Sources__c> imapOfSources;

    /*******************************SETS************************/
    public Set<String> setEmail {get; set;}
    public Set<String> setFLAS {get; set;}
    public Set<String> setLAZ {get; set;}
    public Set<String> setPL {get; set;}
    public Set<String> setPF {get; set;}
    
    /*******************************CONSTRUCTOR***********************/  
    public DeDupUtil (){}
    public DeDupUtil(String pObject){
        
        iObject = pObject;
        iLog  = new LogsUtil ();  
        objSource = new SourceUtil();

        /*Initializing maps*/ 
        mapConAndEmail  = new Map<String, Contact>();
        mapConAndEmail2 = new Map<String, Contact>();
        
        mapConAndFLAS  = new Map<String, Contact>();
        mapConAndFLAS2 = new Map<String, Contact>();
        
        mapConAndLAZ  = new Map<String, Contact>();
        mapConAndLAZ2 = new Map<String, Contact>();
        
        mapConAndPL = new Map<String, Contact>();
        mapConAndPF = new Map<String, Contact>();

        mapConAndEmailN  = new Map<String, Contact>();
        mapConAndEmail2N = new Map<String, Contact>();
        
        mapConAndFLASN  = new Map<String, Contact>();
        mapConAndFLAS2N = new Map<String, Contact>();
        
        mapConAndLAZN  = new Map<String, Contact>();
        mapConAndLAZ2N = new Map<String, Contact>();
        
        mapConAndPLN = new Map<String, Contact>();
        mapConAndPFN = new Map<String, Contact>();
        
        mapConAndEmails  = new Map<String, Integer>();
        mapConAndEmail2s = new Map<String, Integer>();
        
        mapConAndFLASs  = new Map<String, Integer>();
        mapConAndFLAS2s = new Map<String, Integer>();
        
        mapConAndLAZs  = new Map<String, Integer>();
        mapConAndLAZ2s = new Map<String, Integer>();
        
        mapConAndPLs = new Map<String, Integer>();
        mapConAndPFs = new Map<String, Integer>();
               
        mapOfContToInsert = new Map<Integer, Contact>();
        mapOfConToUpdate = new Map<String, Contact>();
        
        mapToShowDescUpdate = new Map<Integer, String>();
        mapToShowDescInsert = new Map<Integer, String>();
        
        imapOfSources = new map<string, Sources__c>();
        
        /*Initializing sets*/ 
        setEmail = new Set<String>();
        setFLAS = new Set<String>();
        setLAZ = new Set<String>();
        setPL = new Set<String>();
        setPF = new Set<String>();
        
        // Get all sources in map to set in originating source by source id
        //imapOfSources = objSource.getSources();
         imapOfSources = objSource.getLowerCaseSources();
    }
    
    /*******************************GetRawContacts**********************************/ 
    // This function is used to convert raw contact data into wrapper type
    public List<WrapperDedup> GetRawContacts(List<Raw_Contact__c> pLstOfRawContacts){
    
        List<WrapperDedup> iListWrapperDedup = new List<WrapperDedup>(); 
        
        if(pLstOfRawContacts.size() > 0){
            For(Raw_Contact__c iRawCon: pLstOfRawContacts){
                WrapperDeDup dup = new WrapperDedup(iRawCon.id, iRawCon.Email__c, iRawCon.FLAS__c, iRawCon.LAZ__c, iRawCon.PL__c, iRawCon.PF__c, iRawCon.First_Name__c, iRawCon.Last_Name__c, iRawCon.City_1__c, iRawCon.zip_1__c, iRawCon.State_1__c, iRawCon.Street_1__c, iRawCon.Street_2__c, iRawCon.Country_1__c, iRawCon.Phone__c, iRawCon.Campus_A_Profile__c, null, iRawCon.Add_Date__c, iRawCon.Record_Type__c, iRawCon.SF_Record_ID__c, iRawCon.Subid__c, iRawCon.Vendor_Name__c, iRawCon.Vendor_Subgroup__c, iRawCon.IP_Address__c, iRawCon.Source__c, iRawCon.Account_Name__c, iRawCon.Age__c, iRawCon.Gender__c, iRawCon.Is_From_Silverpop__c,iRawCon.Country_3__c,iRawCon.General_Opt_In__c,iRawCon.Canada_Opt_In__c); 
                if(iRawCon.State_3__c != null )
                    dup.state3 = iRawCon.State_3__c;
                if(iRawCon.French_Canadian_Opt_In__c)
                    dup.frenchOptIn = iRawCon.French_Canadian_Opt_In__c;
                if(iRawCon.SMS_Opt_In__c)
                    dup.smsOptIn = iRawCon.SMS_Opt_In__c;
                if(iRawCon.Language_Preference__c != null )
                    dup.langPref = iRawCon.Language_Preference__c;
                if(iRawCon.Spanish_Opt_In__c)
                    dup.spanishOptIn = iRawCon.Spanish_Opt_In__c;
                if(iRawCon.Mobile__c != null)
                    dup.mobile = iRawCon.Mobile__c;    
                if(iRawCon.French_SMS_Opt_In__c)
                    dup.frenchSMSOptIn = iRawCon.French_SMS_Opt_In__c;  
                if(iRawCon.Spanish_SMS_Opt_In__c)
                    dup.spanishSMSOptIn = iRawCon.Spanish_SMS_Opt_In__c;  
                    
                //iListWrapperDedup.add(new WrapperDedup(iRawCon.id, iRawCon.Email__c, iRawCon.FLAS__c, iRawCon.LAZ__c, iRawCon.PL__c, iRawCon.PF__c, iRawCon.First_Name__c, iRawCon.Last_Name__c, iRawCon.City_1__c, iRawCon.zip_1__c, iRawCon.State_1__c, iRawCon.Street_1__c, iRawCon.Street_2__c, iRawCon.Country_1__c, iRawCon.Phone__c, iRawCon.Campus_A_Profile__c, null, iRawCon.Add_Date__c, iRawCon.Record_Type__c, iRawCon.SF_Record_ID__c, iRawCon.Subid__c, iRawCon.Vendor_Name__c, iRawCon.Vendor_Subgroup__c, iRawCon.IP_Address__c, iRawCon.Source__c, iRawCon.Account_Name__c, iRawCon.Age__c, iRawCon.Gender__c, iRawCon.Is_From_Silverpop__c,iRawCon.Country_3__c,iRawCon.General_Opt_In__c,iRawCon.Canada_Opt_In__c)); 
                iListWrapperDedup.add(dup);
                
            } // End of for
        } // End of if
        
        return iListWrapperDedup;
        
    } // End of function

    /*******************************MatchDeDupCriteria**********************************/  
    // This function is used to fill sets which will be used to search duplicate contacts
    public void MatchDeDupCriteria(List<WrapperDedup> pListDedup){   
        
        if(pListDedup.size() > 0){
            // Iterate over wrapper list and populate sets of Email, FLAS, LAZ, PF, PL to search in existing contacts
            for(WrapperDedup w: pListDedup){
                
                if(w.Email != null && !String.IsBlank(w.Email))
                    setEmail.add(w.Email);
                if(w.FLAS != null && !String.IsBlank(w.FLAS))    
                    setFLAS.add(w.FLAS);
                if(w.Laz != null && !String.IsBlank(w.Laz))        
                    setLAZ.add(w.Laz);
                if(w.PF != null && !String.IsBlank(w.PF))     
                    setPF.add(w.PF);
                if(w.PL != null && !String.IsBlank(w.PL)) 
                    setPL.add(w.PL);
                    
            } // End of for
        } // End of if
    } // End of function
    
    /*******************************CheckDuplicates*************************************/ 
    // This function is used to find duplicates of existing and new contacts
    public void CheckDuplicates(List<WrapperDedup> pListDedup){
        
        integer i = 0;  // Unique key of map to create new contacts whcih are duplicate
        integer j = 0;
        
        Contact c;             // Refrence to fill new contact
        Contact oldContact;    // Refrence to fill old contact
        
        IdentifyDupContact();  // Populate maps of existing and duplicate contacts
        
        /*iterate over list of WrapperDedup to find contact in exsting maps or create maps for new contacts*/
        for(WrapperDedup dupCon: pListDedup){
            
            //Check if contact exists with email in existing contact map
             if(mapConAndEmail.ContainsKey(dupCon.Email)){
                
                oldContact = mapConAndEmail.get(dupCon.Email); 
                system.debug('oldContact >>'+oldContact);
                // Update contact if add date is greater than old contact address add date
                c =  AddListToUpdateContact(dupCon, oldContact); 
                
                /* 1- Check if updated contact is return from function AddListToUpdateContact 
                   2- Add contact in update map
                   3- Set Updated contact according to map keys*/    
                if(c != null){
                    mapOfConToUpdate.put(oldContact.id, c);
                    setExistingNewContactMapKeys(c); 
                    checkExistingOldContactMapKeys(c, oldContact); 
                    mapToShowDescUpdate.put(j, 'Found by Email');
                }
                system.debug('@@@Found by Email: '+dupCon);
            }
            
            //Check if contact exists with FLAS in existing contact map
            else if(mapConAndFLAS.ContainsKey(dupCon.Flas)){
                
                oldContact = mapConAndFLAS.get(dupCon.Flas); 
                // Update contact if add date is greater than old contact address add date
                c =  AddListToUpdateContact(dupCon, oldContact); 
                
               /* 1- Check if updated contact is return from function AddListToUpdateContact 
                  2- Add contact in update map
                  3- Set Updated contact according to map keys*/         
                if(c != null){
                    mapOfConToUpdate.put(oldContact.id, c); 
                    setExistingNewContactMapKeys(c); 
                    checkExistingOldContactMapKeys(c, oldContact); 
                    mapToShowDescUpdate.put(j, 'Found by Flas');
                } 
                system.debug('@@@Found by Flas: '+dupCon);
            }
            
            //Check if contact exists with LAZ in existing contact map
            else if(mapConAndLAZ.ContainsKey(dupCon.LAZ)){
            
                oldContact = mapConAndLAZ.get(dupCon.LAZ); 
                // Update contact if add date is greater than old contact address add date
                c =  AddListToUpdateContact(dupCon, oldContact); 
                
                /* 1- Check if updated contact is return from function AddListToUpdateContact 
                   2- Add contact in update map
                   3- Set Updated contact according to map keys*/   
                if(c != null){
                    mapOfConToUpdate.put(oldContact.id, c); 
                    setExistingNewContactMapKeys(c); 
                    checkExistingOldContactMapKeys(c, oldContact); 
                    mapToShowDescUpdate.put(j, 'Found by LAZ');
                }
                system.debug('@@@Found by Laz: '+dupCon);
            }
            
            //Check if contact exists with PF in existing contact map
            else if(mapConAndPF.ContainsKey(dupCon.PF)){
            
                oldContact = mapConAndPF.get(dupCon.PF);
                // Update contact if add date is greater than old contact address add date
                c =  AddListToUpdateContact(dupCon, oldContact); 
                
                /* 1- Check if updated contact is return from function AddListToUpdateContact 
                   2- Add contact in update map
                   3- Set Updated contact according to map keys*/   
                if(c != null){
                    mapOfConToUpdate.put(oldContact.id, c); 
                    setExistingNewContactMapKeys(c); 
                    checkExistingOldContactMapKeys(c, oldContact); 
                    mapToShowDescUpdate.put(j, 'Found by PF');
                }
                system.debug('@@@Found by PF: '+dupCon);
            }
            
            //Check if contact exists with PL in existing contact map
            else if(mapConAndPL.ContainsKey(dupCon.PL)){
            
                oldContact = mapConAndPL.get(dupCon.PL);
                // Update contact if add date is greater than old contact address add date
                c =  AddListToUpdateContact(dupCon, oldContact); 
                
                /* 1- Check if updated contact is return from function AddListToUpdateContact 
                   2- Add contact in update map
                   3- Set Updated contact according to map keys*/   
                if(c != null){
                    mapOfConToUpdate.put(oldContact.id, c); 
                    setExistingNewContactMapKeys(c); 
                    checkExistingOldContactMapKeys(c, oldContact  );   
                    mapToShowDescUpdate.put(j, 'Found by PL');
                }
                system.debug('@@@Found by PL: '+dupCon);    
            }
            else{
               /* 1- Check if contact is not found in maps of new contact then create new contact
                  2- Add New contact in maps of new contact 
                  3- Generate unique key of map for new contact */
               if(!mapConAndEmailN.ContainsKey(dupCon.email) && !mapConAndFLASN.ContainsKey(dupCon.FLAS) && !mapConAndLAZN.ContainsKey(dupCon.LAZ) && !mapConAndPFN.ContainsKey(dupCon.PF) && !mapConAndPLN.ContainsKey(dupCon.PL) && dupCon.SfSourceType !='Survey'){
                    if(dupCon.Email != null || dupCon.Flas != null || dupCon.LAZ != null || dupCon.PF != null || dupCon.PL != null){  
                        c = AddListToInsertContact(dupCon); // Create new contact 
                        
                        if(dupCon.Email != null && !String.IsBlank(dupCon.Email) ){
                            mapConAndEmailN.put(dupCon.Email, c);
                            mapConAndEmails.put(dupCon.Email, i);
                         }
                        
                        if(dupCon.Flas != null && !String.IsBlank(dupCon.Flas)){
                            mapConAndFLASN.put(dupCon.Flas, c);
                            mapConAndFLASs.put(dupCon.Flas, i);
                        }
                            
                        if(dupCon.LAZ != null && !String.IsBlank(dupCon.LAZ) ){
                            mapConAndLAZN.put(dupCon.LAZ, c);
                            mapConAndLAZs.put(dupCon.LAZ, i);
                        }
                        
                        /* If contact will not be matched by PF if it comes from CoReg */    
                        if(dupCon.PF != null && !String.IsBlank(dupCon.PF) && dupCon.SfSourceType != 'CoReg'){
                            mapConAndPFN.put(dupCon.PF, c);
                            mapConAndPFs.put(dupCon.PF, i);
                        }
                        /* If contact will not be matched by PL if it comes from CoReg */   
                        if(dupCon.PL != null && !String.IsBlank(dupCon.PL) && dupCon.SfSourceType != 'CoReg'){
                            mapConAndPLN.put(dupCon.PL, c);
                            mapConAndPLs.put(dupCon.PL, i);
                        }
                        
                        mapOfContToInsert.put(i, c);
                        mapToShowDescInsert.put(j, 'New Record Inserted');
                       
                        i++; // Unique key of new contact in maps
                        
                        system.debug('@@@New record inserted: '+dupCon);
                    }
                
                }else{
                    /* Check if contact is found in maps of new contact then update new contact */
                     if(dupCon.SfSourceType !='Survey'){ 
                     
                         Contact oldCon; // Refrece to keep new and duplicate contact
                         integer newI; // Unique key of new contact map 
                         
                         // Check if new contact is duplicate by email
                         if(mapConAndEmailN.ContainsKey(dupCon.Email)){ 
                             
                             oldCon = mapConAndEmailN.get(dupCon.Email);
                             newI = mapConAndEmails.get(dupCon.Email);
                             
                             mapToShowDescInsert.put(j, 'New Record and duplicate. Found by Email.');     
                         }
                         
                         // Check if new contact is duplicate by FLAS
                         else if(mapConAndFLASN.ContainsKey(dupCon.FLAS)){ 
                             
                             oldCon = mapConAndFLASN.get(dupCon.FLAS);
                             newI = mapConAndFLASs.get(dupCon.FLAS); 
                              
                             mapToShowDescInsert.put(j,'New Record and duplicate. Found by FLAS.');   
                         } 
                         
                         // Check if new contact is duplicate by LAZ
                         else if(mapConAndLAZN.ContainsKey(dupCon.LAZ)){ 
                             
                             oldCon = mapConAndLAZN.get(dupCon.LAZ);
                             newI = mapConAndLAZs.get(dupCon.LAZ);
                             
                             mapToShowDescInsert.put(j,'New Record and duplicate. Found by LAZ.');  
                         } 
                         
                         // Check if new contact is duplicate by PF
                         else if(mapConAndPFN.ContainsKey(dupCon.PF)){ 
                             
                             oldCon = mapConAndPFN.get(dupCon.PF);
                             newI = mapConAndPFs.get(dupCon.PF);
                             
                             mapToShowDescInsert.put(j,'New Record and duplicate. Found by PF.');    
                         }
                         
                         // Check if new contact is duplicate by PL
                         else if(mapConAndPLN.ContainsKey(dupCon.PL)){ 
                             
                             oldCon = mapConAndPLN.get(dupCon.PL);
                             newI = mapConAndPLs.get(dupCon.PL);
                             
                            mapToShowDescInsert.put(j,'New Record and duplicate. Found by PL.');   
                         }  
                         // Contact will update if its add date is greater than duplicate contact
                         c =  AddListToUpdateNewContact(dupCon, oldCon); 
                         
                         System.debug('@@@dupCon : '+dupCon);
                         System.debug('@@@OldCon : '+oldCon);
                         System.debug('@@@Contact : '+c);
                         
                      /* 1- Check if updated contact is return from function AddListToUpdateNewContact
                         2- Add contact in insert map
                         3- Set Updated contact according to map keys*/  
                          
                         if(c != null){
                        
                             mapOfContToInsert.put(newI , c);
                             setNewContactMapKeys(c, newI);
                             checkOldContactMapKeys(c, oldCon, newI); 
                         }
                     
                   } // End of survey if
               
                }  // End of nested else     
            } // End of else
            j++; 
        } // End of for loop
        
        // If map of insert contact have values then insert contact and update RawContact/ClientID list of records if any error occur
        if(mapOfContToInsert.size() > 0){         
            if(iObject != CLIENT_ID)
                 AddErrorRawContact( mapOfContToInsert.values(),true);
             else
                 AddErrorClientID(mapOfContToInsert.values(),true);     
        }
        
        system.debug('@@@Map of contact to update : '+mapOfConToUpdate);
         // If map of update contact have values then insert contact and update RawContact/ClientID list of records if any error occur
        if(mapOfConToUpdate.size() > 0){
        
            if(iObject != CLIENT_ID)
                AddErrorRawContact (mapOfConToUpdate.values(),false);
            else
                AddErrorClientID(mapOfConToUpdate.values(),false);    
        }
        
       // iLog.CreateLogs();     
    }
   
   
   /************************************FillMapSetWithDupContact*****************************************/  
    // This function is used to create map of duplicate and existing contacts
    public void IdentifyDupContact(){
              
        List<Contact> iListOfDupCon = new List<Contact>();
        
        system.debug('@@setEmail :'+setEmail);
        system.debug('@@setFLAS :'+setFLAS);
        system.debug('@@setLAZ :'+setLAZ);
        system.debug('@@setPF :'+setPF);
        system.debug('@@setPL :'+setPL);
                
        iListOfDupCon = [select id, Add_Date__c, FirstName, LastName, New_Add_Date__c, createddate, FLAS__c, FLAS_2__c, LAZ__c, LAZ_2__c,
               PL__c, PF__c, email, email_2__c, MailingStreet, MailingCity, MailingCountry, Coreg_Source_Id__c, 
               MailingState, MailingPostalCode, otherStreet, otherCity, otherCountry, Oldest_Add_Date__c,
               otherState, otherPostalCode, phone, otherphone, Vendor_Name__c, Vendor_Subgroup__c,
               Req_Date__c, RV_Coreg_ID__c, IP_Address__c, Coreg_Add_Date__c, Subid__c, RVOTGPROFILE__c, Originating_Source__c,
               CAMPUSAPROFILE__c, Source_ID__c, Source_Description__c,Country_3__c,State_3__c,Canadian_Opt_In__c,General_Opt_In__c,French_Canadian_Opt_In__c,SMS_Opt_In__c from contact where email IN: setEmail OR FLAS__c IN: setFLAS OR LAZ__c in: setLAZ 
               OR PL__c IN: setPL OR PF__c IN: setPF OR Email_2__c IN: setEmail OR FLAS_2__c IN: setFLAS OR LAZ_2__c in: setLAZ]; 

       if(iListOfDupCon.size()>0){
            
            //Iterating over existing records which have duplications
            for(contact dupCon : iListOfDupCon){
              
              //filling a map with that record whose duplicate record is arrived in order to update
            
                if(dupCon.Email != null && !String.isBlank(dupCon.Email)){ 
                    mapConAndEmail.put(dupCon.Email, dupCon);
                } 
                
                if(dupCon.Email_2__c != null && !String.isBlank(dupCon.Email_2__c)){
                    mapConAndEmail.put(dupCon.Email_2__c, dupCon);
                }
                
                if(dupCon.FLAS__c != null && !String.isBlank(dupCon.FLAS__c)){
                    mapConAndFLAS.put(dupCon.FLAS__c, dupCon);
                }
                
                if(dupCon.FLAS_2__c != null && !String.isBlank(dupCon.FLAS_2__c)){ 
                    mapConAndFLAS.put(dupCon.FLAS_2__c, dupCon);
                }
                
                if(dupCon.LAZ__c != null && !String.isBlank(dupCon.LAZ__c) ){
                    mapConAndLAZ.put(dupCon.LAZ__c, dupCon);
                }
                
                if(dupCon.LAZ_2__c != null && !String.isBlank(dupCon.LAZ_2__c)){
                    mapConAndLAZ.put(dupCon.LAZ_2__c, dupCon);
                }
                
                if(dupCon.PL__c != null&& !String.isBlank(dupCon.PL__c) ){
                    mapConAndPL.put(dupCon.PL__c, dupCon);
                }

                if(dupCon.PF__c != null && !String.isBlank(dupCon.PF__c)){
                    mapConAndPF.put(dupCon.PF__c, dupCon);
                }
                
              } //End of for
         } //End of if
     } // End of function
    
    
    /*******************************checkOldContactMapKeys*******************************/
    // Set existing and new reference with updated contact in map of flas, laz, email, pf and pl according to its old keys
    public void checkOldContactMapKeys(Contact pContact, Contact pOldContact, integer iVal){
    
        String FLAS = '';
        String FLAS2 = '';
        String LAZ = '';
        String LAZ2 = '';
        String PF = '';
        String PL = '';
        
        // Create contact map keys
        FLAS = CreateNewContactFLAS(pOldContact);
        FLAS2 = CreateNewContactFLAS2(pOldContact);
        LAZ = CreateNewContactLAZ(pOldContact);
        LAZ2 = CreateNewContactLAZ2(pOldContact);
        PF = CreateNewContactPF(pOldContact);
        PL = CreateNewContactPL(pOldContact);
             
        if(mapConAndEmailN.ContainsKey(pOldContact.Email)){    
            mapConAndEmailN.put(pOldContact.Email, pContact);
            mapConAndEmails.put(pOldContact.Email, iVal);
        }
        
        if(!String.IsBlank(pOldContact.Email_2__c) && mapConAndEmailN.ContainsKey(pOldContact.Email_2__c)){
            mapConAndEmailN.put(pContact.Email_2__c, pContact);
            mapConAndEmails.put(pContact.Email_2__c, iVal);
        }
        
        if(!String.IsBlank(FLAS) && mapConAndFLASN.ContainsKey(FLAS)){
            mapConAndFLASN.put(FLAS, pContact);
            mapConAndFLASs.put(FLAS, iVal); 
        }
        
        if(!String.IsBlank(FLAS2) && mapConAndFLASN.ContainsKey(FLAS2)){
            mapConAndFLASN.put(FLAS2, pContact);
            mapConAndFLASs.put(FLAS2, iVal);  
        }
        
        if(!String.IsBlank(LAZ) && mapConAndLAZN.ContainsKey(LAZ)){
            mapConAndLAZN.put(LAZ, pContact);
            mapConAndLAZs.put(LAZ, iVal); 
        }
        
        if(!String.IsBlank(LAZ2) && mapConAndLAZN.ContainsKey(LAZ2)){  
            mapConAndLAZN.put(LAZ2, pContact);
            mapConAndLAZs.put(LAZ2, iVal); 
        }
        
        if(!String.IsBlank(PF) && mapConAndPFN.ContainsKey(PF)){
        
            mapConAndPFN.put(PF, pContact);
            mapConAndPFs.put(PF, iVal);  
        }
        
        if(!String.IsBlank(PL) && mapConAndPLN.ContainsKey(PL)){
            mapConAndPLN.put(PL, pContact);
            mapConAndPLs.put(PL, iVal);
        }
    } // End of function

    /*******************************checkExistingOldContactMapKeys*******************************/
    // Set existing and old contact reference with updated contact in map of flas, laz, email, pf and pl according to its old keys
    public void checkExistingOldContactMapKeys(Contact pContact, Contact pOldContact){
 
        String FLAS = '';
        String FLAS2 = '';
        String LAZ = '';
        String LAZ2 = '';
        String PF = '';
        String PL = '';
        
        // Create contact map keys
        FLAS = CreateNewContactFLAS(pOldContact);
        FLAS2 = CreateNewContactFLAS2(pOldContact);
        LAZ = CreateNewContactLAZ(pOldContact);
        LAZ2 = CreateNewContactLAZ2(pOldContact);
        PF = CreateNewContactPF(pOldContact);
        PL = CreateNewContactPL(pOldContact);
             
        if(mapConAndEmail.ContainsKey(pOldContact.Email)){    
            mapConAndEmail.put(pOldContact.Email, pContact);    
        }
        
        if(!String.IsBlank(pOldContact.Email_2__c) && mapConAndEmail.ContainsKey(pOldContact.Email_2__c)){
            mapConAndEmail.put(pContact.Email_2__c, pContact);  
        }
        
        if(!String.IsBlank(FLAS) && mapConAndFLAS.ContainsKey(FLAS)){
            mapConAndFLAS.put(FLAS, pContact); 
        }
        
        if(!String.IsBlank(FLAS2) && mapConAndFLAS.ContainsKey(FLAS2)){
            mapConAndFLAS.put(FLAS2, pContact); 
        }
        
        if(!String.IsBlank(LAZ) && mapConAndLAZ.ContainsKey(LAZ)){
            mapConAndLAZ.put(LAZ, pContact); 
        }
        
        if(!String.IsBlank(LAZ2) && mapConAndLAZ.ContainsKey(LAZ2)){  
            mapConAndLAZ.put(LAZ2, pContact);    
        }
        
        if(!String.IsBlank(PF) && mapConAndPF.ContainsKey(PF)){
            mapConAndPF.put(PF, pContact);   
        }
        
        if(!String.IsBlank(PL) && mapConAndPL.ContainsKey(PL)){
            mapConAndPL.put(PL, pContact);
        }
        
    } // End of function
    
    /*******************************setExistingNewContactMapKeys*******************************/
    // Set new and old contact refrence with updated contact in map of flas, laz, email, pf and pl according to its old keys
    public void setExistingNewContactMapKeys(Contact pContact){
    
        String FLAS = '';
        String FLAS2 = '';
        String LAZ = '';
        String LAZ2 = '';
        String PF = '';
        String PL = '';
        
        // Create contact map keys
        FLAS =  CreateNewContactFLAS(pContact);
        FLAS2 = CreateNewContactFLAS2(pContact);
        LAZ = CreateNewContactLAZ(pContact);
        LAZ2 = CreateNewContactLAZ2(pContact);
        PF = CreateNewContactPF(pContact);
        PL = CreateNewContactPL(pContact);
        
        if(!String.IsBlank(pContact.Email) && mapConAndEmail.ContainsKey(pContact.Email)){
            mapConAndEmail.put(pContact.Email, pContact);
        }
        
        if(!String.IsBlank(pContact.Email_2__c) && mapConAndEmail.ContainsKey(pContact.Email_2__c)){
            mapConAndEmail.put(pContact.Email_2__c, pContact);
        }
        
        if(!String.IsBlank(FLAS) && mapConAndFLAS.ContainsKey(FLAS)){
            mapConAndFLAS.put(FLAS, pContact);
        }
        
        if(!String.IsBlank(FLAS2) && mapConAndFLAS.ContainsKey(FLAS2)){
            mapConAndFLAS.put(FLAS2, pContact);
        }
        
        if(!String.IsBlank(LAZ) && mapConAndLAZ.ContainsKey(LAZ)){
            mapConAndLAZ.put(LAZ, pContact);
        }
        
        if(!String.IsBlank(LAZ2) && mapConAndLAZ.ContainsKey(LAZ2)){
            mapConAndLAZ.put(LAZ2, pContact);
        }
        
        if(!String.IsBlank(PF) && mapConAndPF.ContainsKey(PF)){
            mapConAndPF.put(PF, pContact);
        }
        
        if(!String.IsBlank(PL) && mapConAndPL.ContainsKey(PL)){
            mapConAndPL.put(PL, pContact);
        }
        
        System.debug('@@@mapConAndEmail***: '+mapConAndEmail);
        System.debug('@@@mapConAndFLAS***: '+mapConAndFLAS);
        System.debug('@@@mapConAndLAZ***: '+mapConAndLAZ);
                    
    } // End of function
    
    /*******************************setNewContactMapKeys*******************************/
    // Set new and updated contact refrence in map of flas, laz, email, pf and pl according to its keys
    public void setNewContactMapKeys(Contact pContact, integer iVal){
    
        String FLAS = '';
        String FLAS2 = '';
        String LAZ = '';
        String LAZ2 = '';
        String PF = '';
        String PL = '';
        
        // Create contact map keys
        FLAS = CreateNewContactFLAS(pContact);
        FLAS2 = CreateNewContactFLAS2(pContact);
        LAZ = CreateNewContactLAZ(pContact);
        LAZ2 = CreateNewContactLAZ2(pContact);
        PF = CreateNewContactPF(pContact);
        PL = CreateNewContactPL(pContact);
       
        if(!String.IsBlank(pContact.Email)){
            mapConAndEmailN.put(pContact.Email, pContact);
            mapConAndEmails.put(pContact.Email, iVal);
        }
        
        if(!String.IsBlank(pContact.Email_2__c)){
            mapConAndEmailN.put(pContact.Email_2__c, pContact);
            mapConAndEmails.put(pContact.Email_2__c, iVal);
        }
        
        if(!String.IsBlank(FLAS)){
            mapConAndFLASN.put(FLAS, pContact);
            mapConAndFLASs.put(FLAS, iVal); 
        }
        
        if(!String.IsBlank(FLAS2)){
            mapConAndFLASN.put(FLAS2, pContact);
            mapConAndFLASs.put(FLAS2, iVal);  
        }
        
        if(!String.IsBlank(LAZ)){
            mapConAndLAZN.put(LAZ, pContact);
            mapConAndLAZs.put(LAZ, iVal); 
        }
        
        if(!String.IsBlank(LAZ2)){
            mapConAndLAZN.put(LAZ2, pContact);
            mapConAndLAZs.put(LAZ2, iVal); 
        }
        
        if(!String.IsBlank(PF)){
            mapConAndPFN.put(PF, pContact);
            mapConAndPFs.put(PF, iVal);  
        }
        
        if(!String.IsBlank(PL)){
            mapConAndPLN.put(PL, pContact);
            mapConAndPLs.put(PL, iVal);
        }
        
    } // End of function
    
    /*******************************CreateNewContactFLAS*******************************/
    // This function is used to create FLAS of updated contact
    private static string CreateNewContactFLAS(Contact c)
    {
        string FLAS = '';
        
        if(!string.IsBlank(c.FirstName))
            FLAS += c.FirstName.substring(0, 1);
        if(!string.IsBlank(c.LastName))
            FLAS += c.LastName;
        if(!string.IsBlank(c.MailingStreet)){
              if(c.MailingStreet.length() < 9)
                  FLAS += c.MailingStreet; 
              else 
                 FLAS += c.MailingStreet.substring(0, 9);
         }
         if(!string.IsBlank(c.MailingState))
            FLAS += c.MailingState;
            
        return FLAS;
    }
    
    /*******************************CreateNewContactFLAS2*******************************/
    // This function is used to create FLAS2 of updated contact
    private static string CreateNewContactFLAS2(Contact c)
    {
        string FLAS = '';
        
        if(!string.IsBlank(c.FirstName))
            FLAS += c.FirstName.substring(0, 1);
        if(!string.IsBlank(c.LastName) )
            FLAS += c.LastName;
         if(!string.IsBlank(c.OtherStreet)  ){
              if(c.OtherStreet.length() < 9)
                  FLAS += c.OtherStreet; 
              else 
                 FLAS += c.OtherStreet.substring(0, 9);
         }
         if(!string.IsBlank(c.otherState))
            FLAS += c.OtherState;
            
        return FLAS;
    }
    
    /*******************************CreateNewContactLAZ*******************************/
    // This function is used to create LAZ of updated contact
    private static string CreateNewContactLAZ(Contact c)
    {
        string LAZ = '';
        
        if(!string.IsBlank(c.LastName))
            LAZ += c.LastName;
        if(!string.IsBlank(c.MailingStreet) ){
            if(c.MailingStreet.length() < 9)
                LAZ += c.MailingStreet;
            else
                LAZ += c.MailingStreet.substring(0, 9);
         }
        if(!string.IsBlank(c.MailingPostalCode)){
            if(c.MailingPostalCode.length() < 5)
                LAZ += c.MailingPostalCode;
            else
                LAZ += c.MailingPostalCode.substring(0,5);
        }
            
        return LAZ;
    }
    
    /*******************************CreateNewContactLAZ2*******************************/
    // This function is used to create LAZ2 of updated contact
    private static string CreateNewContactLAZ2(Contact c)
    {
        string LAZ = '';
        if(!string.IsBlank(c.LastName))
            LAZ += c.LastName;
        if(!string.IsBlank(c.OtherStreet) ){
            if(c.OtherStreet.length() < 9)
                LAZ += c.OtherStreet;
            else
                LAZ += c.OtherStreet.substring(0, 9);
         }
        if(!string.IsBlank(c.OtherPostalCode)){
            if(c.OtherPostalCode.length() < 5)
                LAZ += c.OtherPostalCode;
            else
                LAZ += c.OtherPostalCode.substring(0,5);
        } 
        return LAZ;
    }
    
    /*******************************CreateNewContactPF*******************************/
    // This function is used to create PF of updated contact
    private static string CreateNewContactPF(Contact c)
    {
        string PF = '';
        
       if(!string.IsBlank(c.Phone))
            PF += c.Phone;
        if(!string.IsBlank(c.FirstName))  
            PF += c.FirstName;
            
        return PF;
    }
    
    /*******************************CreateNewContactPL*******************************/
    // This function is used to create PL of updated contact
    private static string CreateNewContactPL(Contact c)
    {
        string PL = '';
        if(!string.IsBlank(c.Phone))
            PL += c.Phone;
        if(!string.IsBlank(c.LastName))    
            PL += c.LastName;
            
        return PL;
    }
    
    /************************************IsAddressEmpty*****************************************/  
    // Return false if wrapper address is not empty
    public static boolean IsAddressEmpty(WrapperDedup objWrp){
    
        if(!string.IsBlank(objWrp.MailingCity) || !string.IsBlank(objWrp.MailingCountry) || !string.IsBlank(objWrp.MailingPostalCode)
            || !string.IsBlank(objWrp.MailingState) || !string.IsBlank(objWrp.MailingStreet)){
            
            return false;
        }
        return true;
     }
     
    /************************************IsAddress2Empty*****************************************/  
    // Return false if contact address2 is not empty
    public static boolean IsAddress2Empty(Contact objCon){
    
        if(!string.IsBlank(objCon.OtherCity) || !string.IsBlank(objCon.OtherCountry) || !string.IsBlank(objCon.OtherPostalCode)
            || !string.IsBlank(objCon.OtherState) || !string.IsBlank(objCon.OtherStreet)){
            
            return false;
        }
        return true;
    }
    
    /************************************CopyAddress1ToAddress2*****************************************/  
    // Copy address1 to address2 in old contact refrence 'c'
    private static void CopyAddress1ToAddress2(Contact oldContact, Contact c){

          c.OtherCity = oldContact.MailingCity;
          c.OtherCountry = oldContact.MailingCountry;
          c.OtherPostalCode = oldContact.MailingPostalCode;
          c.OtherState = oldContact.MailingState;
          c.OtherStreet = oldContact.MailingStreet;     
    }
    
    /************************************UpdateEmail*****************************************/  
    // Check email in old contact email1 and email2 if it is different then update email address in old contact refrence 'c'
    public void UpdateEmail(Contact oldContact, WrapperDedup pWrapper, Contact c){
       /* Copy old email address in new refrence of old contact 'c' if it is missed in below conditions */       
        c.Email = oldContact.Email;
        c.Email_2__c = oldContact.Email_2__c;
       
        if(!String.IsBlank(pWrapper.Email)){
            if(String.IsBlank(oldContact.Email)){
                c.Email = pWrapper.Email;
            }   
            else if(oldContact.Email != pWrapper.Email && oldContact.Email_2__c != pWrapper.Email){
                c.Email_2__c = oldContact.Email;
                c.Email = pWrapper.Email;
                
            } // End of else if
        } // End of if
    }  // End of function
    
    /************************************UpdatePhone*****************************************/  
    // Update phone if it is different in old contact
    public void UpdatePhone(Contact oldContact, WrapperDedup pWrapper, Contact c){
        c.Phone = oldContact.Phone;
        if(!String.IsBlank(pWrapper.Phone) && pWrapper.Phone != oldContact.Phone){
            c.Phone = pWrapper.Phone;  
             
        } // End of if
    } // End of function
    
    /************************************UpdateAddress*****************************************/  
    // Update phone if it is different in old contact
    
        public static string IsStringNull(string s){
        if (s == null) { 
            return '';
        }
        return s;
    }
    
    public static void UpdateAddress(Contact oldContact, WrapperDedup newContact, Contact c){
        String newContactMailing = IsStringNull(newContact.MailingStreet) +'-'+ IsStringNull(newContact.MailingCity) +'-'+ IsStringNull(newContact.MailingState) +'-'+ IsStringNull(newContact.MailingCountry) +'-'+ IsStringNull(newContact.MailingPostalCode);
        String newContactOther = IsStringNull(newContact.OtherStreet) +'-'+ IsStringNull(newContact.OtherCity) +'-'+ IsStringNull(newContact.OtherState) +'-'+ IsStringNull(newContact.OtherCountry) +'-'+ IsStringNull(newContact.OtherPostalCode);
       
        String oldContactMailing = IsStringNull(oldContact.MailingStreet) +'-'+ IsStringNull(oldContact.MailingCity) +'-'+ IsStringNull(oldContact.MailingState) +'-'+ IsStringNull(oldContact.MailingCountry) +'-'+ IsStringNull(oldContact.MailingPostalCode);
        String oldContactOther = IsStringNull(oldContact.OtherStreet) +'-'+ IsStringNull(oldContact.OtherCity) +'-'+ IsStringNull(oldContact.OtherState) +'-'+ IsStringNull(oldContact.OtherCountry) +'-'+ IsStringNull(oldContact.OtherPostalCode);
        
        /*Modified the Condition so that the incoming address overwrites a Default address instead of pushing the default
          add to Address 2 field. A Default Address is identified by address 1 = '123 Main St' per Alvin Cano, 02/14/2017 
          Chintan Adhyapak, West Monroe Partners, February 14, 2017 */
        Boolean isDefaultAddress = String.isNotBlank(newContact.MailingStreet) && (newContact.MailingStreet.trim().startsWithIgnoreCase('123 Main St') || newContact.MailingStreet.trim().startsWithIgnoreCase('Default'));
        
        //if(!String.IsBlank(newContactOther.replace('-','').trim()) && newContactOther != oldContactMailing){
        if(!String.IsBlank(newContactOther.replace('-','').trim()) && newContactOther != oldContactMailing
                && !isDefaultAddress) {
           c.OtherCity = oldContact.MailingCity;
           c.OtherCountry = oldContact.MailingCountry;
           c.OtherPostalCode = oldContact.MailingPostalCode;
           c.OtherState = oldContact.MailingState;
           c.OtherStreet = oldContact.MailingStreet;  
           
           
           c.MailingCity = newContact.OtherCity;
           c.MailingCountry = newContact.OtherCountry;
           c.MailingPostalCode = newContact.OtherPostalCode;
           c.MailingState = newContact.OtherState;
           c.MailingStreet = newContact.OtherStreet;
           
           newContactMailing = IsStringNull(newContact.MailingStreet) +'-'+ IsStringNull(newContact.MailingCity) +'-'+ IsStringNull(newContact.MailingState) +'-'+ IsStringNull(newContact.MailingCountry) +'-'+ IsStringNull(newContact.MailingPostalCode);
           newContactOther = IsStringNull(newContact.OtherStreet) +'-'+ IsStringNull(newContact.OtherCity) +'-'+ IsStringNull(newContact.OtherState) +'-'+ IsStringNull(newContact.OtherCountry) +'-'+ IsStringNull(newContact.OtherPostalCode);
       
           oldContactMailing = IsStringNull(oldContact.MailingStreet) +'-'+ IsStringNull(oldContact.MailingCity) +'-'+ IsStringNull(oldContact.MailingState) +'-'+ IsStringNull(oldContact.MailingCountry) +'-'+ IsStringNull(oldContact.MailingPostalCode);
           oldContactOther = IsStringNull(oldContact.OtherStreet) +'-'+ IsStringNull(oldContact.OtherCity) +'-'+ IsStringNull(oldContact.OtherState) +'-'+ IsStringNull(oldContact.OtherCountry) +'-'+ IsStringNull(oldContact.OtherPostalCode);
       }
       
       /*Modified the Condition so that the incoming address overwrites a Default address instead of pushing the default
          add to Address 2 field. A Default Address is identified by address 1 = '123 Main St' per Alvin Cano, 02/14/2017 
          Chintan Adhyapak, West Monroe Partners, February 14, 2017 */
       //if(!String.IsBlank(newContactMailing.replace('-','').trim()) && newContactMailing != oldContactMailing){
        if(!String.IsBlank(newContactMailing.replace('-','').trim()) && newContactMailing != oldContactMailing
                && !isDefaultAddress) {
           c.OtherCity = oldContact.MailingCity;
           c.OtherCountry = oldContact.MailingCountry;
           c.OtherPostalCode = oldContact.MailingPostalCode;
           c.OtherState = oldContact.MailingState;
           c.OtherStreet = oldContact.MailingStreet;  
           
           c.MailingCity = newContact.MailingCity;
           c.MailingCountry = newContact.MailingCountry;
           c.MailingPostalCode = newContact.MailingPostalCode;
           c.MailingState = newContact.MailingState;
           c.MailingStreet = newContact.MailingStreet;               
       }        
    }
    
    
  /*  public static void UpdateAddress(Contact oldContact, WrapperDedup pWrapper, Contact c){

        Boolean isAddress2Update = false;
 
         if(!IsAddressEmpty(pWrapper)){

            if(string.IsBlank(oldContact.MailingCity) && string.IsBlank(oldContact.MailingCountry) && string.IsBlank(oldContact.MailingPostalCode)
                && string.IsBlank(oldContact.MailingState) && string.IsBlank(oldContact.MailingStreet)){
                
                    c.MailingCity = pWrapper.MailingCity;
                    c.MailingCountry = pWrapper.MailingCountry;
                    c.MailingPostalCode = pWrapper.MailingPostalCode;
                    c.MailingState = pWrapper.MailingState;
                    c.MailingStreet = pWrapper.MailingStreet;
                    
            }else{
                // Check if street is different from old contact street1 and street2 then update new values in old contact refrence 'c'
                if(oldContact.MailingStreet != pWrapper.MailingStreet && oldContact.OtherStreet != pWrapper.MailingStreet){
                    // Copy address1 to address2 and set isAddress2Update = true
                    if(!isAddress2Update){ 
                        CopyAddress1ToAddress2(oldContact, c);
                        isAddress2Update = true;
                    }
                    c.MailingStreet = pWrapper.MailingStreet;
                    
                }else{
                    c.MailingStreet = oldContact.MailingStreet;   
                }
                
                // Check if street is different from old contact country1 and country2 then update new values in old contact refrence 'c'
                if(oldContact.MailingCountry != pWrapper.MailingCountry && oldContact.OtherCountry != pWrapper.MailingCountry ){
                    // Check if address jumping is not performed in previous conditions then copy country1 to country2
                    if(!isAddress2Update){
                        CopyAddress1ToAddress2(oldContact, c);
                        isAddress2Update = true;
                    }
                    c.MailingCountry = pWrapper.MailingCountry; 
                
                }else{
                    c.MailingCountry = oldContact.MailingCountry; 
                }
                
                // Check if street is different from old contact city1 and city2 then update new values in old contact refrence 'c'
                if(oldContact.MailingCity != pWrapper.MailingCity && oldContact.OtherCity != pWrapper.MailingCity){
                    // Check if address jumping is not performed in previous conditions then copy city1 to city2
                    if(!isAddress2Update){ 
                        CopyAddress1ToAddress2(oldContact, c);
                        isAddress2Update = true; 
                    }
                    c.MailingCity = pWrapper.MailingCity;
                    
                }else{
                    c.MailingCity = oldContact.MailingCity;
                }
                
                // Check if street is different from old contact state1 and state2 then update new values in old contact refrence 'c'
                if(oldContact.MailingState != pWrapper.MailingState && oldContact.OtherState != pWrapper.MailingState){
                    // Check if address jumping is not performed in previous conditions then copy state1 to state2
                    if(!isAddress2Update){
                        CopyAddress1ToAddress2(oldContact, c);
                        isAddress2Update = true; 
                    }
                    c.MailingState = pWrapper.MailingState;
                }else{
                    c.MailingState = oldContact.MailingState;  
                }
                
                // Check if street is different from old contact zip1 and zip2 then update new values in old contact refrence 'c'
                if(oldContact.MailingPostalCode != pWrapper.MailingPostalCode && oldContact.OtherPostalCode != pWrapper.MailingPostalCode){
                    // Check if address jumping is not performed in previous conditions then copy zip1 to zip2
                    if(!isAddress2Update){
                        CopyAddress1ToAddress2(oldContact, c);
                        isAddress2Update = true;
                    }
                    c.MailingPostalCode = pWrapper.MailingPostalCode;
                }
                else{
                    c.MailingPostalCode = oldContact.MailingPostalCode; 
                }
            }
            
        }else{
           // If no above condition bypass then copy old contact address1 in old contact refrence 'c'
            c.MailingCity = oldContact.MailingCity;
            c.MailingCountry = oldContact.MailingCountry;
            c.MailingPostalCode = oldContact.MailingPostalCode;
            c.MailingState = oldContact.MailingState;
            c.MailingStreet = oldContact.MailingStreet;
        } 
        
        // If no above condition bypass then copy old contact addres2s in old contact refrence 'c'
        if(isAddress2Update==false){
            c.OtherCity = oldContact.OtherCity;
            c.OtherCountry = oldContact.OtherCountry;
            c.OtherPostalCode = oldContact.OtherPostalCode;
            c.OtherState = oldContact.OtherState;
            c.OtherStreet = oldContact.OtherStreet;  
        } 
    
        System.debug('****OldContact::::'+oldContact);
        System.debug('****NewContact::::'+pWrapper);
        System.debug('****con::::'+c);
        
    }  */// End of function
    
    /************************************UpdateOriginatingSource*****************************************/  
    // Update originating source in new reference of old contact 'c'
    public void UpdateOriginatingSource(Contact oldContact, Contact c){
        
        if(oldContact.Add_Date__c !=null )
            c.Add_Date__c = oldContact.Add_Date__c;
        if(!String.IsBlank(oldContact.Source_ID__c))    
            c.Source_ID__c = oldContact.Source_ID__c;
        if(!String.IsBlank(oldContact.Originating_Source__c))    
            c.Originating_Source__c = oldContact.Originating_Source__c;
        if(!String.IsBlank(oldContact.Source_Description__c)) 
            c.Source_Description__c = oldContact.Source_Description__c;
    }
    
    /************************************UpdateCoregDetails*****************************************/  
    // Update coreg details in new reference of old contact 'c'
    public void UpdateCoregDetails(Contact oldContact, Contact c){
        
        if(!String.IsBlank(oldContact.Subid__c))    
            c.Subid__c = oldContact.Subid__c;
        if(!String.IsBlank(oldContact.Vendor_Name__c))  
          c.Vendor_Name__c = oldContact.Vendor_Name__c;
        if(!String.IsBlank(oldContact.Vendor_Subgroup__c))     
          c.Vendor_Subgroup__c = oldContact.Vendor_Subgroup__c;
        if(!String.IsBlank(oldContact.IP_Address__c))
          c.IP_Address__c = oldContact.IP_Address__c; 
    }
    
    /************************************setCoregDetails*****************************************/  
    // Check if source type is Co-Registration then update coreg details in new reference of old contact 'c'
    // Check if source type is not Co-Registration then empty coreg details in new reference of old contact 'c'
    public void setCoregDetails(Contact c, WrapperDedup pWrapper,  String pSourceType){
    
    String stype;
    stype = 'Co-Registration';
         if(!String.IsBlank(pSourceType) && pSourceType.toLowerCase() == stype.toLowerCase()) {
         
              if(!String.IsBlank(pWrapper.Subid))    
                  c.Subid__c = pWrapper.Subid;
              if(!String.IsBlank(pWrapper.VendorName))  
                  c.Vendor_Name__c = pWrapper.VendorName;
              if(!String.IsBlank(pWrapper.VendorSubGroup))     
                  c.Vendor_Subgroup__c = pWrapper.VendorSubGroup;
              if(!String.IsBlank(pWrapper.IPAddress))
                  c.IP_Address__c = pWrapper.IPAddress; 
              
          }else{
          
              c.Subid__c ='';
              c.Vendor_Name__c ='';
              c.Vendor_Subgroup__c ='';
              c.IP_Address__c ='';
          }
    } // End of function
    
    /************************************setOriginatingSource*****************************************/  
    // Check if source is not empty then set originating source from source object otherwise set originitating source as 'other'
    public void setOriginatingSource(Contact pCon, WrapperDedup pWrapper, String pType){
    
        system.debug('pCon>>>>>>'+pCon);
    
        Date iAddDate;
        Sources__c iSource;
        Boolean isDetail;
        String OriginatingSource;
        
        if(pWrapper.AddDate != null){ 
            iAddDate = pWrapper.AddDate;      
        }else{
            iAddDate = Date.Today();   
        }
        
        system.debug('###Add Date::::'+iAddDate);
        system.debug('###Source::::'+pWrapper.Source);
       
        if(!String.IsBlank(pWrapper.Source) && imapOfSources.containsKey(pWrapper.Source.toLowerCase())){
        
            system.debug('###In Cond::::');
        
              iSource = imapOfSources.get(pWrapper.Source.toLowerCase());
           // iSource = imapOfSources.get(pWrapper.Source);
            if(pType == 'Insert'){
                pCon.Source_ID__c = iSource.Source_ID__c;
                pCon.Originating_Source__c = iSource.Source_Type__c;
                pCon.Source_Description__c = iSource.Description__c;
            }
            
            OriginatingSource = 'Co-Registration';
            
            if(pCon.Originating_Source__c.toLowerCase() == OriginatingSource.toLowerCase() && pType == 'Update'){
                isDetail = false;
            }else{
                isDetail = true;
            }
            
            if(isDetail) setCoregDetails(pCon, pWrapper, pCon.Originating_Source__c);
            
            pCon.Add_Date__c = iAddDate; 
            
        }else{
        
            pCon.Source_ID__c = pWrapper.Source;
            pCon.Originating_Source__c = 'Other';
            pCon.Add_Date__c = iAddDate; 
            setCoregDetails(pCon, pWrapper, ''); 
        }
    }
    
    /************************************AddListToInsertContact*****************************************/  
    // Create new contact refrence which needs to be inserted from wrapper values
    Contact AddListToInsertContact(WrapperDedup pWrapper){

         Date iAddDate;
                
         Contact c = new Contact();

         if(pWrapper.AddDate != null){
            iAddDate = pWrapper.AddDate;    
        }else{
            iAddDate = Date.Today();   
        }
        
         c.New_Add_Date__c = iAddDate; 
         c.FirstName = pWrapper.FirstName;
         c.LastName = pWrapper.LastName;
         c.Email = pWrapper.Email;
         c.Phone = pWrapper.Phone;
         c.MailingCity = pWrapper.MailingCity;
         c.MailingCountry = pWrapper.MailingCountry;
         c.MailingPostalCode = pWrapper.MailingPostalCode;
         c.MailingState = pWrapper.MailingState;
         c.MailingStreet = pWrapper.MailingStreet;
         c.OtherCity = '';
         c.OtherCountry = '';
         c.OtherPostalCode = '';
         c.OtherState = '';
         c.OtherStreet = '';  
         c.Email_2__c = '';
         c.RVOTGPROFILE__c = pWrapper.RVOT;
         c.CAMPUSAPROFILE__c = pWrapper.CampusProfile;
         c.Account_Name__c = pWrapper.AccountName;
         c.Age__c = pWrapper.Age;
         c.Gender__c = pWrapper.Gender;
         if(pWrapper.country3 != null) c.Country_3__c  = pWrapper.country3;
         if(pWrapper.state3 != null) c.State_3__c = pWrapper.state3;
         if(pWrapper.frenchOptIn != null) c.French_Canadian_Opt_In__c = pWrapper.frenchOptIn;
         if(pWrapper.generalOptIn != null) c.General_Opt_In__c  = pWrapper.generalOptIn;
         if(pWrapper.canadaOptIn != null) c.Canadian_Opt_In__c  = pWrapper.canadaOptIn;
         if(pWrapper.smsOptIn != null) c.SMS_Opt_In__c  = pWrapper.smsOptIn;
         
         if(pWrapper.spanishOptIn != null) c.Spanish_Opt_In__c  = pWrapper.spanishOptIn;
         if(pWrapper.langPref != null) c.Language_Preference__c  = pWrapper.langPref;
         if(pWrapper.mobile != null) c.MobilePhone  = pWrapper.mobile;
         
         if(pWrapper.frenchSMSOptIn != null) c.French_SMS_Opt_In__c  = pWrapper.frenchSMSOptIn;
         if(pWrapper.spanishSMSOptIn != null) c.Spanish_SMS_Opt_In__c  = pWrapper.spanishSMSOptIn;
         
         if(iObject == CLIENT_ID){
             c.Client_ID__c = pWrapper.id;
         }else{
              c.Raw_Contact_ID__c = pWrapper.id;
              
              
             setOriginatingSource(c, pWrapper, 'Insert'); // Set originating source from rawContact batch
         }
         
         system.debug('@@@New Contact '+c);
         
         return c;   
    }
    
    /************************************AddListToUpdateNewContact*****************************************/  
    // Update new and duplicate contact which needs to be inserted from wrapper values
    Contact AddListToUpdateNewContact(WrapperDedup pWrapper, Contact oldContact){
		system.debug('AddListToUpdateNewContact>>>>');
        boolean isUpdate = true;
        Date iCompareDate;
        Date iAddDate;
         
        if(oldContact.New_Add_Date__c!= null){
            // Add one year in address add date to compare with new add date 
            iCompareDate = oldContact.New_Add_Date__c.AddYears(1);   
        }
        // If wrapper add date is null then select current date as add date
        if(pWrapper.AddDate != null){
            iAddDate = pWrapper.AddDate;       
        }else{
            iAddDate = Date.Today();   
        }
        // Set contact update false if old contact profile values are equal to 'Y' and one year is not elapsed from add date 
        if((oldContact.RVOTGPROFILE__c == 'Y' || oldContact.CAMPUSAPROFILE__c == 'Y')  && iCompareDate > iAddDate ){
            isUpdate = false;
        }
        
        
        
        if(isUpdate){
            // Check if add date is greater than address date date f old record
            if(iAddDate > oldContact.New_Add_Date__c){
            
                Contact c = new Contact();

                c.FirstName = oldContact.FirstName;
                c.LastName = oldContact.LastName;
                c.New_Add_Date__c = iAddDate;
               
                UpdateOriginatingSource(oldContact, c);
                UpdateCoregDetails(oldContact, c);
                
                UpdateEmail(oldContact, pWrapper, c);
                UpdateAddress(oldContact, pWrapper, c);
                UpdatePhone(oldContact, pWrapper, c);
                
                c.Is_Modified__c = true;
                
                if(pWrapper.country3 != null) c.Country_3__c  = pWrapper.country3;
                if(pWrapper.state3 != null) c.State_3__c = pWrapper.state3;
                if(pWrapper.frenchOptIn != null) c.French_Canadian_Opt_In__c = pWrapper.frenchOptIn;
                if(pWrapper.generalOptIn != null) c.General_Opt_In__c  = pWrapper.generalOptIn;
                if(pWrapper.canadaOptIn != null) c.Canadian_Opt_In__c  = pWrapper.canadaOptIn;
                if(pWrapper.smsOptIn != null) c.SMS_Opt_In__c  = pWrapper.smsOptIn;
                
                if(pWrapper.spanishOptIn != null) c.Spanish_Opt_In__c  = pWrapper.spanishOptIn;
                if(pWrapper.langPref != null) c.Language_Preference__c  = pWrapper.langPref;
                if(pWrapper.mobile != null) c.MobilePhone  = pWrapper.mobile;
                
                if(pWrapper.frenchSMSOptIn != null) c.French_SMS_Opt_In__c  = pWrapper.frenchSMSOptIn;
                if(pWrapper.spanishSMSOptIn != null) c.Spanish_SMS_Opt_In__c  = pWrapper.spanishSMSOptIn;
                 
                if(iObject == CLIENT_ID){
                    c.Client_ID__c = pWrapper.id;
                    c.RVOTGPROFILE__c = pWrapper.RVOT;
                    c.CAMPUSAPROFILE__c = pWrapper.CampusProfile;
                }
                else{
                
                    c.Raw_Contact_ID__c = pWrapper.id;
                    
                    /*c.Account_Name__c = pWrapper.AccountName;
                    c.Age__c = pWrapper.Age;
                    c.Gender__c = pWrapper.Gender; */
                }
              
               return c;
               
            } // End of if
        } // End of if

        // Check if add date is empty and new add date is less than old contact add date when batch is not client ID then set originating source
        if((oldContact.Add_Date__c ==null || iAddDate < oldContact.Add_Date__c ) && iObject != CLIENT_ID){
            
            Contact c = new Contact();
            c = oldContact;
            setOriginatingSource(c, pWrapper, 'Update');
            if(pWrapper.country3 != null) c.Country_3__c  = pWrapper.country3;
            if(pWrapper.state3 != null) c.State_3__c = pWrapper.state3;
            if(pWrapper.frenchOptIn != null) c.French_Canadian_Opt_In__c = pWrapper.frenchOptIn;
            if(pWrapper.generalOptIn != null) c.General_Opt_In__c  = pWrapper.generalOptIn;
            if(pWrapper.canadaOptIn != null) c.Canadian_Opt_In__c  = pWrapper.canadaOptIn;
            if(pWrapper.smsOptIn != null) c.SMS_Opt_In__c  = pWrapper.smsOptIn;
            
            if(pWrapper.spanishOptIn != null) c.Spanish_Opt_In__c  = pWrapper.spanishOptIn;
            if(pWrapper.langPref != null) c.Language_Preference__c  = pWrapper.langPref;
            if(pWrapper.mobile != null) c.MobilePhone  = pWrapper.mobile;
            
            if(pWrapper.frenchSMSOptIn != null) c.French_SMS_Opt_In__c  = pWrapper.frenchSMSOptIn;
            if(pWrapper.spanishSMSOptIn != null) c.Spanish_SMS_Opt_In__c  = pWrapper.spanishSMSOptIn;
            
            return c;
            
        } // End of if

        return null;
    
    } // End of function

    /************************************AddListToUpdateContact*****************************************/  
    // Update existing and duplicate contact which needs to be updated from wrapper values else return null
    Contact AddListToUpdateContact(WrapperDedup pWrapper, Contact oldContact){
       
        Date iAddDate;
        Date iCompareDate;
        boolean isUpdate = true;
        
        if(oldContact.New_Add_Date__c != null){
            // Add one year in address add date to compare with new add date 
            iCompareDate = oldContact.New_Add_Date__c.AddYears(1);   
        }
        // If wrapper add date is null then select current date as add date
        if(pWrapper.AddDate != null){ 
            iAddDate = pWrapper.AddDate;       
        }else{
            iAddDate = Date.Today();     
        }
        // Set contact update false if old contact profile values are equal to 'Y' and one year is not elapsed from add date 
        if((oldContact.RVOTGPROFILE__c == 'Y' || oldContact.CAMPUSAPROFILE__c == 'Y')  && iCompareDate > iAddDate){
            isUpdate = false;
        }
        
        if(isUpdate){
            // Check if add date is greater than address date date f old record
            if(iAddDate > oldContact.New_Add_Date__c){
            
                Contact c = new Contact();
             
                c.id = oldContact.id;
                c.New_Add_Date__c = iAddDate; 
                c.FirstName = oldContact.FirstName;
                c.LastName = oldContact.LastName;
                
                UpdateOriginatingSource(oldContact, c);
                UpdateCoregDetails(oldContact, c);
                    
                UpdateEmail(oldContact, pWrapper,c);
                UpdatePhone(oldContact, pWrapper,c);
                UpdateAddress(oldContact, pWrapper, c);
                
                if(pWrapper.country3 != null) c.Country_3__c  = pWrapper.country3;
                if(pWrapper.state3 != null) c.State_3__c = pWrapper.state3;
                if(pWrapper.frenchOptIn != null) c.French_Canadian_Opt_In__c = pWrapper.frenchOptIn;
                if(pWrapper.generalOptIn != null) c.General_Opt_In__c  = pWrapper.generalOptIn;
                if(pWrapper.canadaOptIn != null) c.Canadian_Opt_In__c  = pWrapper.canadaOptIn;
                if(pWrapper.smsOptIn != null) c.SMS_Opt_In__c  = pWrapper.smsOptIn;
                
                if(pWrapper.spanishOptIn != null) c.Spanish_Opt_In__c  = pWrapper.spanishOptIn;
                if(pWrapper.langPref != null) c.Language_Preference__c  = pWrapper.langPref;
                if(pWrapper.mobile != null) c.MobilePhone  = pWrapper.mobile;
                
                if(pWrapper.frenchSMSOptIn != null) c.French_SMS_Opt_In__c  = pWrapper.frenchSMSOptIn;
                if(pWrapper.spanishSMSOptIn != null) c.Spanish_SMS_Opt_In__c  = pWrapper.spanishSMSOptIn;
                
                /* c.Account_Name__c = pWrapper.AccountName;
                 c.Age__c = pWrapper.Age;
                 c.Gender__c = pWrapper.Gender; */
                    
                c.Is_Modified__c = true;
                
                if(iObject == CLIENT_ID){
                    c.Client_ID__c = pWrapper.id;
                    c.RVOTGPROFILE__c = pWrapper.RVOT;
                    c.CAMPUSAPROFILE__c = pWrapper.CampusProfile; 
                }else{
                    c.Raw_Contact_ID__c = pWrapper.id;
                   
                }
            return c;
            }
        }
        System.debug('###UiAddDate::'+iAddDate);
        // Check if add date is empty and new add date is less than old contact add date when batch is not client ID then set originating source
        if((oldContact.Add_Date__c ==null || iAddDate < oldContact.Add_Date__c) && iObject != CLIENT_ID){
            system.debug('oldContact>>>1450'+oldContact);
            Contact c = new Contact();
            c = oldContact;
            system.debug('c'+c);
            System.debug('###pWrapper::'+pWrapper);
            setOriginatingSource(c, pWrapper, 'Update');
            if(pWrapper.country3 != null) c.Country_3__c  = pWrapper.country3;
            if(pWrapper.state3 != null) c.State_3__c = pWrapper.state3;
            if(pWrapper.frenchOptIn != null) c.French_Canadian_Opt_In__c = pWrapper.frenchOptIn;
            if(pWrapper.generalOptIn != null) c.General_Opt_In__c  = pWrapper.generalOptIn;
            if(pWrapper.canadaOptIn != null) c.Canadian_Opt_In__c  = pWrapper.canadaOptIn; 
            if(pWrapper.smsOptIn != null) c.SMS_Opt_In__c  = pWrapper.smsOptIn;
            
            if(pWrapper.spanishOptIn != null) c.Spanish_Opt_In__c  = pWrapper.spanishOptIn;
            if(pWrapper.langPref != null) c.Language_Preference__c  = pWrapper.langPref;
            if(pWrapper.mobile != null) c.MobilePhone  = pWrapper.mobile;
                
            if(pWrapper.frenchSMSOptIn != null) c.French_SMS_Opt_In__c  = pWrapper.frenchSMSOptIn;
            if(pWrapper.spanishSMSOptIn != null) c.Spanish_SMS_Opt_In__c  = pWrapper.spanishSMSOptIn;
            
            return c;
        }

        return null;
    }
    
    /************************************AddErrorRawContact*****************************************/  
    // This function is used to insert / update contact from rawContact object
    // If error occur on record it will update that record on rawContact  
    void AddErrorRawContact(List<Contact> iListCon, boolean isInsert){
        
        integer isError = 0;
        integer isSucess = 0;
        integer inserted = 0; 
        integer updated = 0;
        string iDesc = '';
        
        List<Raw_Contact__c> iListRawCont = new List<Raw_Contact__c>();
        List<Database.SaveResult> Results;
        
        if(isInsert) Results = Database.insert(iListCon, false);
        else  Results = Database.update(iListCon, false);
        
        // Iteration over insert / update results to find error records and mark isError true on rawcontact    
        for(integer index = 0 ; index < Results .size() ; index ++){
            
            if (!Results .get(index ).isSuccess()){  
                isError ++;          
                Raw_Contact__c iRaw = new Raw_Contact__c();
                iRaw.Error_Description__c = Results .get(index).getErrors().get(0).getMessage();
                iRaw.IsError__c = true;
                iRaw.Is_Processed__c = false;
                iRaw.id = iListCon.get(index).Raw_Contact_ID__c;
                iListRawCont.add(iRaw); 
            }
            else{
                isSucess ++;

                if(isInsert)
                {
                   Raw_Contact__c iRaw = new Raw_Contact__c();
                   iRaw.id = iListCon.get(index).Raw_Contact_ID__c;
                   iRaw.Is_New_Lead__c = true;

                   iListRawCont.add(iRaw); 
                    
                    system.debug('$$i' + iListCon.get(index));
                    iDesc += iListCon.get(index) + '::' + mapToShowDescInsert.get(index) +'\n';
                    inserted ++;
                }
                else
                {   

                    system.debug('$$u' + iListCon.get(index));
                    iDesc += iListCon.get(index) + '::' + mapToShowDescUpdate.get(index) +'\n';
                    updated++;
                }           
            }       
        }
        
       
        if(isInsert)
            iLog.Inserted = inserted ;
        else
            iLog.Updated = updated;
        iLog.errors = isError ;
        iLog.success = isSucess;
        iLog.logDesc = iDesc;
        iLog.source = 'ContactRaw';
        
        if( iListRawCont.size() > 0) upsert  iListRawCont;      
    }
    
    /************************************AddErrorClientID*****************************************/  
    // This function is used to insert / update contact from ClientID object
    // If error occur on record it will update that record on ClientID  
    void AddErrorClientID(List<Contact> iListCon, boolean isInsert){
    
        List<ClientID__c > iListClient = new List<ClientID__c >();
        List<Database.SaveResult> Results;
        
        if(isInsert) Results = Database.insert(iListCon, false);
        else  Results = Database.update(iListCon, false);
        
        // Iteration over insert / update results to find error records and mark isError true on ClientId    
        for(integer index = 0 ; index < Results .size() ; index ++){
            
            if (!Results .get(index ).isSuccess()){            
                ClientID__c iClient = new ClientID__c ();
                iClient .Error_Description__c = Results .get(index).getErrors().get(0).getMessage();
                iClient .IsError__c = true;
                iClient .Is_Processed__c = false;
                iClient .id = iListCon.get(index).Client_ID__c;
                iListClient .add(iClient ); 
            }
        }
        
        if( iListClient.size() > 0) update  iListClient ;      
    }  

}