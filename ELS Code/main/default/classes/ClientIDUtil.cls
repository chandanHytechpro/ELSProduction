/*
Class       : ClientIDUtil
Author      : Mahwish Iqbal, Umer Aziz
Date        : 18-June-2015
Version     : 1.0
Description : This class contains functions related to ClientID object.
*/
public without sharing class ClientIDUtil{  
    
    string iObject;   
    DeDupUtil obj;
    /*******************************MAPS***********************/
    map<string,ID> iMapEmailCon;
    map<string,ID> iMapFLASCon;
    map<string,ID> iMapLAZCon;
    map<string,ID> iMapPFCon;
    map<string,ID> iMapPLCon;
    
    Public map<String, ID> MapofMemberandClient;
    
    Public List<Contact> lstofContacttoUpdate;
    
    /*******************************LISTS***********************/
    list<WrapperDedup> iListWrapperDedup;
    list<ClientID__c> ListOfClientID;
    
    /*******************************SETS***********************/
    Public set<String> SetofClientId;
    
    /******************************************** CONSTRUCTORS ***********************************/
    // This constructor accepts string as paramter to pass value in dedupUtil class constructor.
    
    public ClientIDUtil(string pObject){
          
        iObject = pObject; // set paramter value
        obj = new DedupUtil(iObject); // Initialize dedupe class and pass object to its constructor
        
        /*Initializing wrapper lists*/
        iListWrapperDedup = new List<WrapperDedup>(); 
        
        /*Initializing maps*/
        iMapEmailCon = new map<string, ID>();
        iMapFLASCon = new map<string, ID>();
        iMapLAZCon = new map<string, ID>();
        iMapPFCon = new map<string, ID>();
        iMapPLCon = new map<string, ID>();
        
         /*Initializing lists*/
         ListOfClientID = new List<ClientID__c>();
    
    }//End of Constructor
    
    // This constructor accepts no paramter and has been called in membership trigger
    public ClientIDUtil(){
    
        MapofMemberandClient = new Map<String, ID>();
        SetofClientId = new set<String>();
        lstofContacttoUpdate = new List<Contact>();
    }
    

   /******************************************** GetContactID *****************************************/
   // This function is used to return map of Contact Id from Client Id records.
    Public void GetContactID(){
    
       List<ClientID__c> ListofClientID = [SELECT Contact__c, ClientID_External_ID__c, Id FROM ClientID__c where ClientID_External_ID__c IN:SetofClientId AND Contact__c!=null];
        
        if(ListofClientID.size()>0){
            for(ClientID__c cli : ListofClientID ){
                MapofMemberandClient.put(cli.ClientID_External_ID__c, cli.Contact__c);  
            
            } // End of for loop
            
            //Update Contact reference in membership
            for(Contact ConUpdate : [SELECT Id, DG_Contact_Type__c FROM Contact where ID IN : MapofMemberandClient.Values()]){
                ConUpdate.DG_Contact_Type__c = 'Customer';
                lstofContacttoUpdate.add(ConUpdate);
            }
            
            if(lstofContacttoUpdate.size()>0){
                upsert lstofContacttoUpdate;
            }//End of Update
        } // End of if 
    } // End of function
   
    /******************************************** GetClientID *****************************************/
    //This method is used to set values of wrapper type and add it in wrapper list from ClientID record
    public void GetClientID(List<ClientID__c> pListClientID){
        For(ClientID__c iClient : pListClientID){
            iListWrapperDedup.add(new WrapperDedup(iClient.Id, iClient.Email__c, iClient.FLAS__c, iClient.LAZ__c, iClient.PL__c, iClient.PF__c, iClient.FirstName__c, iClient.LastName__c, iClient.MailingCity__c, iClient.MailingPostalCode__c, iClient.MailingState__c, iClient.Address_1__c, iClient.Address_2__c, iClient.Phone__c, iClient.Contact__c, iClient.CAMPUSAPROFILE__c, iClient.Client_Type__c, iClient.RVOT__c, iClient.Create_Time__c, 'CLIENTID' ));
        } 
    }// End of function

    /******************************************** DedupClientID *****************************************/
    // This function is used to apply deduping on ClientID records and create/update contacts. 
    //After deduping process, it sets contact refrence to the ClientID record. 
    public void DedupClientID(){
    
        // Call dedupUtil class method to fill sets with all de duping criteria in wrapper list
        obj.MatchDeDupCriteria(iListWrapperDedup);
        
        // Call dedupUtil class method to apply deduping on records from wrapper list 
        obj.CheckDuplicates(iListWrapperDedup); 
        
        // Set contact lookup in ClientID  
        setContactLookup();
        
    }// End of function
   
    
    /******************************************** setContactLookup *********************************************/
    //This function is used to set Contact on ClientID record.
    public void setContactLookup(){
        
        // Itrate over wrapper list and set contact ids from existing contact maps from dedupe class
        for(WrapperDedup clid: iListWrapperDedup){
        
            if(clid.Email == null && clid.Flas == null && clid.LAZ == null && clid.PF == null && clid.PL == null){
            
                clid.ContactID = '003j000000alMxfAAE';
            
            }else{
        
	            //Check if contact exists with Email
	            if(obj.mapConAndEmail.ContainsKey(clid.Email)){
	                clid.ContactID = obj.mapConAndEmail.get(clid.Email).Id;
	            }
	            //Check if contact exists with FLAS
	            else if(obj.mapConAndFLAS.ContainsKey(clid.Flas)){
	                clid.ContactID = obj.mapConAndFLAS.get(clid.Flas).Id;
	            }
	            //Check if contact exists with LAZ
	            else if(obj.mapConAndLAZ.ContainsKey(clid.LAZ)){
	                clid.ContactID = obj.mapConAndLAZ.get(clid.LAZ).Id;
	            }
	            //Check if contact exists with PF
	            else if(obj.mapConAndPF.ContainsKey(clid.PF)){
	                clid.ContactID = obj.mapConAndPF.get(clid.PF).Id;
	            }
	            //Check if contact exists with PL
	            else if(obj.mapConAndPL.ContainsKey(clid.PL)){
	                clid.ContactID = obj.mapConAndPL.get(clid.PL).Id;
	            }
            }
        }

        List<Contact> lstOfContacts = getNewContacts();
            
        if(lstOfContacts.size() > 0){
            // Itration on map of insert contacts to create maps of Email, FLAS, LAZ, PL and PF
            for(Contact con : lstOfContacts){
            
                if(con.Email != null && !string.Isblank(con.Email))
                    iMapEmailCon.put(con.Email, con.id);
                    
                if(con.Email_2__c != null && !string.Isblank(con.Email_2__c))
                    iMapEmailCon.put(con.Email_2__c, con.id);
                    
                if(con.FLAS__c != null && !string.Isblank(con.FLAS__c))
                    iMapFLASCon.put(con.FLAS__c, con.id);
                
                if(con.FLAS_2__c != null && !string.Isblank(con.FLAS_2__c))
                    iMapFLASCon.put(con.FLAS_2__c, con.id);
                    
                if(con.LAZ__c != null && !string.Isblank(con.LAZ__c))
                    iMapLAZCon.put(con.LAZ__c, con.id);
                    
                if(con.LAZ_2__c != null && !string.Isblank(con.LAZ_2__c))
                    iMapLAZCon.put(con.LAZ_2__c, con.id);
                    
                if(con.PF__c != null && !string.Isblank(con.PF__c))
                    iMapPFCon.put(con.PF__c, con.id);
                
                if(con.PL__c != null && !string.Isblank(con.PL__c))
                    iMapPLCon.put(con.PL__c, con.id);
                        
            } // End of loop
    
            // Itrate over wrapper list and set contact ids from new inserted contact maps from dedupe class
            for(WrapperDedup clid: iListWrapperDedup){
            	
	            if(clid.Email == null && clid.Flas == null && clid.LAZ == null && clid.PF == null && clid.PL == null){
	            
	                 clid.ContactID = '003j000000alMxfAAE';
	            
	            }else{
                
	                if(iMapEmailCon.ContainsKey(clid.email)){
	                    clid.ContactID =  iMapEmailCon.get(clid.email);
	                }
	                else if(iMapFLASCon.ContainsKey(clid.FLAS )){
	                    clid.ContactID =  iMapFLASCon.get(clid.FLAS );
	                }
	                else if(iMapLAZCon.ContainsKey(clid.LAZ)){
	                    clid.ContactID =  iMapLAZCon.get(clid.LAZ);
	                }
	                else if(iMapPFCon.ContainsKey(clid.PF)){
	                    clid.ContactID =  iMapPFCon.get(clid.PF);
	                }
	                else if(iMapPLCon.ContainsKey(clid.PL))
	                    clid.ContactID =  iMapPLCon.get(clid.PL);
	            }
            } // End of loop
       }

        // Itrate over wrapper list and type cast wrapper values to ClientID 
        for(WrapperDedup iWrap : iListWrapperDedup){
            ClientID__c iClient = new ClientID__c();
            iClient.Contact__c = iWrap.contactID;         
            iClient.Id = iWrap.ID;
            
            ListOfClientID.add(iClient);
        }
        update ListOfClientID; //Update ClientID list
    } // End of function   
    
   
    /******************************************** getNewContacts *********************************************/
    //This function is used to get new contact from obj.mapOfContToInsert.values() map in dedup class
    public List<Contact> getNewContacts(){
    
        List<Contact> ListOfDupCon = new list <contact> ();
        Set<ID> setOfConIds = new Set<ID>();
        
        if(obj.mapOfContToInsert.size() > 0){
        
            for(Contact c : obj.mapOfContToInsert.values()){
                setOfConIds.add(c.ID);
            }
            
            ListOfDupCon = [select id, FLAS__c, FLAS_2__c, LAZ__c, LAZ_2__c, PL__c, PL_2__c, PF__c, PF_2__c,
                   Email, Email_2__c from contact where Id IN: setOfConIds  ];       
        }      
        return ListOfDupCon;
    }
}