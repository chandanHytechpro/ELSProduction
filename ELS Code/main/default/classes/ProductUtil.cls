/*
Name        : ProductUtil
Author      : Mahwish Iqbal
Date        : 26/June/2015
Version     : 1.0
Description : This class contains functions related to Product object and to co-applicant when product type is RCG after deduping  
*/
public class ProductUtil 
{
    //********* Constructor************
    public ProductUtil (){

    }
    
    /******************************************** getRCGContacts *****************************************/
    // This function is used to co-applicant when product type is RCG after deduping
    // This function is called from raw Contact batch after performing dedulication on product records
    public void getRCGContacts(List<WrapperDedup> iListWrapperDedup, DedupUtil obj){
    
    Map<string, ID> iMapEmailCon = new Map<string, ID>();
    Map<string, ID> iMapFLASCon = new Map<string, ID>();
    Map<string, ID> iMapLAZCon = new Map<string, ID>();
    Map<string, ID> iMapPFCon = new Map<string, ID>();
    Map<string, ID> iMapPLCon = new Map<string, ID>();
    
    Map<String, ID > iMapOfELSProduct = new Map<string,ID>(); 
    
        // Iteration over rawcontact wrapper list to populate map of rcg product id and contact
        for(WrapperDedup prod: iListWrapperDedup){
        
            if(prod.SfSourceType=='RCG' && prod.SfSourceId !=''){
                if(prod.Email == null && prod.Flas == null && prod.LAZ == null && prod.PF == null && prod.PL == null){
                
                    
                    iMapOfELSProduct.put(prod.SfSourceId, '003j000000cafFY');
                
                }else{       
                    if(obj.mapConAndEmail.ContainsKey(prod.Email)){
                        iMapOfELSProduct.put(prod.SfSourceId, obj.mapConAndEmail.get(prod.Email).Id);
                    }
                    
                    else if(obj.mapConAndFLAS.ContainsKey(prod.Flas)){
                        iMapOfELSProduct.put(prod.SfSourceId, obj.mapConAndFLAS.get(prod.Flas).Id);
                    }
                    
                    else if(obj.mapConAndLAZ.ContainsKey(prod.LAZ)){
                        iMapOfELSProduct.put(prod.SfSourceId, obj.mapConAndLAZ.get(prod.LAZ).Id);
                    }
                    
                    else if(obj.mapConAndPF.ContainsKey(prod.PF)){
                        iMapOfELSProduct.put(prod.SfSourceId, obj.mapConAndPF.get(prod.PF).Id);
                    }
                    
                    else if(obj.mapConAndPL.ContainsKey(prod.PL)){
                        iMapOfELSProduct.put(prod.SfSourceId, obj.mapConAndPL.get(prod.PL).Id);
                    }
                }
            } // End of if 
        } // End of for
    
        List<Contact> lstOfContacts = getNewContacts(obj); // list of new contacts created after deduplication
            
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
    
            for(WrapperDedup prod: iListWrapperDedup){
            
                if(prod.SfSourceType=='RCG' && prod.SfSourceId !=''){
                   if(prod.Email == null && prod.Flas == null && prod.LAZ == null && prod.PF == null && prod.PL == null){
                    
                        
                        iMapOfELSProduct.put(prod.SfSourceId, '003j000000cafFY');
                    
                    }else{                 
                        if(iMapEmailCon.ContainsKey(prod.email)){
                            iMapOfELSProduct.put(prod.SfSourceId, iMapEmailCon.get(prod.email));
                        }
                        
                        else if(iMapFLASCon.ContainsKey(prod.FLAS)){
                            iMapOfELSProduct.put(prod.SfSourceId, iMapFLASCon.get(prod.FLAS));
                        }
                        
                        else if(iMapLAZCon.ContainsKey(prod.LAZ)){
                            iMapOfELSProduct.put(prod.SfSourceId, iMapLAZCon.get(prod.LAZ));
                        }
                        
                        else if(iMapPFCon.ContainsKey(prod.PF)){     
                            iMapOfELSProduct.put(prod.SfSourceId, iMapPFCon.get(prod.PF));
                        }
                        
                        else if(iMapPLCon.ContainsKey(prod.PL)){
                            iMapOfELSProduct.put(prod.SfSourceId, iMapPLCon.get(prod.PL));
                        }
                    }
                } // End of if
            } // End of for
        
        } // End of if   
        
        
        List<Co_Applicant__c> ListOfCoApplicant = new List<Co_Applicant__c>();
         
        // Iteration over product ids on map keyset and create co-applicant
        for(ELS_Product__c m : [SELECT Contact__c, Id FROM ELS_Product__c where Id in : iMapOfELSProduct.keySet() ]){
            
            Co_Applicant__c coApp = new Co_Applicant__c();    
            if(iMapOfELSProduct.get(m.Id) != null){
                coApp.ELS_Products__c = m.Id;
                coApp.Contact_Id__c = iMapOfELSProduct.get(m.Id);
                ListOfCoApplicant.add(coApp);
            } 
        }
 
        if(ListOfCoApplicant.size() > 0 )
            insert ListOfCoApplicant; 
    
    } // End of function
    
    /******************************************** getNewContacts *****************************************/
    //This function is used to get new contact from obj.mapOfContToInsert.values() map in dedup class
    public List<Contact> getNewContacts(DedupUtil obj){
    
    List<Contact> ListOfDupCon = new list < contact > ();
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
    
    //update tradeshow count on contact
    public void UpdateContactTradeshowCount(AggregateResult[] groupedResults, set<Id> setContacts){
        map<Id, Contact> mapContact = new map<Id, Contact>();
        Contact contact = null;
        
        //zeriose
        for (Id id : setContacts){
            contact = new contact();
            contact.Id = id;
            contact.Tradeshow_Count__c = 0;
            
            if (contact.Id != null){
                mapContact.put(Id, contact);
            }
        }
        
        //setting new values
        for (AggregateResult ar : groupedResults)  {
            contact = new contact();
            contact.Tradeshow_Count__c = 0;
            
            if (mapContact.containsKey((Id) ar.get('Contact_Id__c'))){
                contact = mapContact.get((Id) ar.get('Contact_Id__c'));
            }
            
            if (ar.get('Tradeshow__c') != null && (boolean) ar.get('Tradeshow__c'))
            {
                contact.Tradeshow_Count__c = (double) ar.get('total');
            }
            
            contact.Id = (Id) ar.get('Contact_Id__c');
            
            if (contact.Id != null){
                mapContact.put(contact.Id, contact);
            }                
        }
        
        if (mapContact.size()>0){
            update mapContact.values();
        }
    }
    
    //update product count on contact
    public void UpdateContactProductCount(AggregateResult[] groupedResults, map<Id, String> pMapOfRecordTypes, set<Id> setContacts){
        map<Id, Contact> mapContact = new map<Id, Contact>();
        Id recordTypeId = null;
        Contact contact = null;
        
        //zeriose
        for (Id id : setContacts){
            contact = new contact();
            contact.Id = id;
            contact.Discount_Camping_Count__c = 0;
            contact.Free_Trial_Count__c = 0;
            contact.RCG_Count__c = 0;
            
            if (contact.Id != null){
                mapContact.put(Id, contact);
            }
        }
        
        for (AggregateResult ar : groupedResults)  {
            recordTypeId = (Id) ar.get('RecordTypeId');
            
            contact = new contact();
            contact.Discount_Camping_Count__c = 0;
            contact.Free_Trial_Count__c = 0;
            contact.RCG_Count__c = 0;
            
            if (mapContact.containsKey((Id) ar.get('Contact__c'))){
                contact = mapContact.get((Id) ar.get('Contact__c'));
                
                if (mapContact.get((Id) ar.get('Contact__c')).Discount_Camping_Count__c != null) { 
                    contact.Discount_Camping_Count__c = mapContact.get((Id) ar.get('Contact__c')).Discount_Camping_Count__c;
                }
                
                if (mapContact.get((Id) ar.get('Contact__c')).Free_Trial_Count__c != null) { 
                    contact.Free_Trial_Count__c = mapContact.get((Id) ar.get('Contact__c')).Free_Trial_Count__c;
                }
                
                if (mapContact.get((Id) ar.get('Contact__c')).RCG_Count__c != null) { 
                    contact.RCG_Count__c = mapContact.get((Id) ar.get('Contact__c')).RCG_Count__c;
                }
            }
            
            contact.Id = (Id) ar.get('Contact__c');                 
            if ('Discount_Camping' == pMapOfRecordTypes.get(recordTypeId))
            {
                contact.Discount_Camping_Count__c = (double) ar.get('total');       
            }
            
            if ('Free_Trials' == pMapOfRecordTypes.get(recordTypeId))
            {
                contact.Free_Trial_Count__c = (double) ar.get('total'); 
            }
            
            if ('Ready_Camp_Go' == pMapOfRecordTypes.get(recordTypeId))
            {
                contact.RCG_Count__c = (double) ar.get('total'); 
            }
            
            if (contact.Id != null){
                mapContact.put(contact.Id, contact);
            }                  
        }
        
        if (mapContact.size()>0){
            update mapContact.values();
        }
    }
    
    /******************************************** UpdateContactSources *****************************************/
    // This function is used to set Contact originating Source on product insert
    public void UpdateContactSources(list<ELS_Product__c> pListOfProduct, map<Id, String> pMapOfRecordTypes, Set<string> pSetofSourceID, Set<string> pSetofContactID){
    
        Sources__c iSrc; 
        Contact iCon;
        Date iAddDate;
           
        SourceUtil ObjSrc = new SourceUtil();
        List<Contact> iLstCon = new List<Contact>();
        Set<Contact> iSetCon = new Set<Contact>();
        String iRecordType;
        Map<ID, Contact> iMapCon = new Map<ID, Contact>();
        
        ObjSrc.getSourcesById(pSetofSourceID);
        ObjSrc.getContactSources(pSetofContactID);
        

        for(ELS_Product__c r : pListOfProduct){
            
            if(r.Source_ID__c != null){
                if(ObjSrc.mapOfSource.containsKey(r.Source_ID__c.toLowerCase()))
                    iSrc = ObjSrc.mapOfSource.get(r.Source_ID__c.toLowerCase());
            }
                
            if(ObjSrc.mapOfContact.containsKey(r.Contact__c))
                iCon = ObjSrc.mapOfContact.get(r.Contact__c);
                
           if(pMapOfRecordTypes.ContainsKey(r.RecordTypeId)){
               iRecordType = pMapOfRecordTypes.get(r.RecordTypeId);
           }
                
            if(/*iSrc != null && Comment by Hanif , Allow to set other source*/ iCon != null){
            
                iAddDate = r.Purchase_Date__c; 
                
                if(iAddDate !=null && ( iCon.Add_Date__c == null || iAddDate < iCon.Add_Date__c )){
                    
                     if(iSrc != null){
                    
                             iCon.Source_Description__c = iSrc.Description__c;
                    iCon.Source_ID__c = iSrc.Source_ID__c;
                    iCon.Source_ID_2__c = iSrc.ID; 
                    iCon.Originating_Source__c = iSrc.Source_Type__c;
                    
                    }else{
                    
                        iCon.Source_ID__c = r.Source_ID__c;
                        iCon.Originating_Source__c = 'Other';
                    }
          
                    iCon.Add_Date__c = iAddDate; 
                    
                    iCon.Subid__c = '';
                    iCon.Vendor_Name__c = '';
                    iCon.Vendor_Subgroup__c = '';
                    iCon.IP_Address__c = ''; 
                    
                    if(iMapCon.ContainsKey(iCon.Id)){
                        Contact con = iMapCon.get(iCon.Id);
                        if(iCon.Add_Date__c < con.Add_Date__c){
                             iMapCon.put(iCon.Id, iCon);
                        }
                    }else{
                        iMapCon.put(iCon.Id, iCon);
                    } // End of else
               } // End of       
            }      
        } 
        
        if(iMapCon.size() > 0) update iMapCon.values();  
    }
    
    public void updateRawContactELSProd(List<ELS_Product__c> lstofELSProduct){
        list<Raw_Contact__c> lstofRawcontacttoinsert = new list<Raw_Contact__c>();
        Raw_Contact__c RCC = null;
        
        for(ELS_Product__c  ELSProd: lstofELSProduct){
            RCC = new Raw_Contact__c();
            
            RCC.Name = ELSProd.Co_Applicant_First_Name__c+'-' + ELSProd.Co_Applicant_Last_Name__c;
            RCC.First_Name__c = ELSProd.Co_Applicant_First_Name__c;
            RCC.Last_Name__c = ELSProd.Co_Applicant_Last_Name__c;
            RCC.Street_1__c = ELSProd.Co_Applicant_Address_1__c ;
            RCC.Street_2__c = ELSProd.Co_Applicant_Address_2__c ;
            RCC.City_1__c = ELSProd.Co_Applicant_City__c ;
            RCC.State_1__c = ELSProd.Co_Applicant_State__c ;
            RCC.Mobile__c = ELSProd.Co_Applicant_Cell_Phone__c ;
            RCC.Phone__c = ELSProd.Co_Applicant_Phone__c;
            RCC.Zip_1__c = ELSProd.Co_Applicant_Zip_Code__c;
            RCC.Email__c = ELSProd.Co_Applicant_Email__c;
            RCC.Source__c = ELSProd.Source_ID__c;
            RCC.Record_Type__c = 'RCG';
            RCC.Add_Date__c = ELSProd.Purchase_Date__c;    
            RCC.SF_Record_ID__c = ELSProd.Id;
            
            lstofRawcontacttoinsert.add(RCC);

        }
        if(lstofRawcontacttoinsert.size()>0){
            insert lstofRawcontacttoinsert;

        }        
    }
}