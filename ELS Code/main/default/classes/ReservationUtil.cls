/*
Name        : ReservationUtil
Author      : Umer Aziz, Mahwish Iqbal
Date        : 26/June/2015
Version     : 1.0
Description : This class contains functions Reservation object and to set contact refrence in voyger reservation after deduping
*/
public without sharing class ReservationUtil
{
    /************ LIST****************/
    public list<Reservation__c> ListOfReservation;

    Public ID RT_Reservation ;
    Public ID RT_Voyager_Reservation ;

    Map<string,ID> iMapEmailCon;
    Map<string,ID> iMapFLASCon;
    Map<string,ID> iMapLAZCon;
    Map<string,ID> iMapPFCon;
    Map<string,ID> iMapPLCon;

    public list<Contact> lstofContacttoUpdate;
    Map<String,ID> iMapOfReservation;

    /*************CONSTRUCTOR*********/
    public ReservationUtil(){

        iMapEmailCon = new Map<string, ID>();
        iMapFLASCon = new Map<string, ID>();
        iMapLAZCon = new Map<string, ID>();
        iMapPFCon = new Map<string, ID>();
        iMapPLCon = new Map<string, ID>();

        lstofContacttoUpdate = new list<Contact>();
        ListOfReservation = new list<Reservation__c>();
        iMapOfReservation = new Map<string,ID>();
    }

    /******************************************** UpdateContact *****************************************/
    // This function is used to update contact type on reservation contacts from reservation trigger
    public void UpdateContact(List<ID> pSetContactId){
        //putting contactIds in set
        Set<Id> setContactId = new Set<Id>(pSetContactId);
        lstofContacttoUpdate = new list<Contact>();

        if (setContactId.size() > 0 ){
            for(Contact Con : [SELECT Id, DG_Contact_Type__c FROM Contact where ID IN : setContactId]){
                Con.DG_Contact_Type__c = 'Customer';
                lstofContacttoUpdate.add(Con);
            }

            if(lstofContacttoUpdate.size() > 0){
                upsert lstofContacttoUpdate;
            }
        }
    } // End of function

    /******************************************** getrecordtype *****************************************/
    // This function is used to get record type of reservation object
    public void getrecordtype(){
        System.debug('Function getRecordType -------->');
        RT_Voyager_Reservation = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Voyager_Reservation' limit 1].id;
        RT_Reservation = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Reservation' limit 1].id;
    }

    /******************************************** updateRawContact *****************************************/
    // This function is used to create voyger reservation in rawContact
    public void updateRawContact(List<Reservation__c> lstofreservation){
        list<Raw_Contact__c> lstofRawcontacttoinsert = new list<Raw_Contact__c>();
        Raw_Contact__c RCC = null;

        for(Reservation__c res : lstofreservation){
            RCC = new Raw_Contact__c();

            RCC.Name = res.First_Name__c +'-' + res.Last_Name__c;
            RCC.First_Name__c = res.First_Name__c;
            RCC.Last_Name__c = res.Last_Name__c;
            RCC.Street_1__c = res.Address__c;
            RCC.City_1__c = res.City__c;
            RCC.State_1__c = res.State__c;
            RCC.Zip_1__c = res.Zip_Code__c;
            RCC.Phone__c = res.Phone__c;
            RCC.Email__c = res.Email__c;
            RCC.Add_Date__c = res.Booked_Date__c;
            RCC.IsError__c = false;
            RCC.Record_Type__c = 'Voy';
            RCC.SF_Record_ID__c = res.Id;
            RCC.Source__c = res.Source_ID__c ;

            lstofRawcontacttoinsert.add(RCC);
        } // Enf of function

        if(lstofRawcontacttoinsert.size()>0){
            insert lstofRawcontacttoinsert;
        }
    } // End of function

    /******************************************** UpdateContactSources *****************************************/
    // This function is used to Contact originating Source on reservation insert
    public void UpdateContactSources(list<Reservation__c> pListOfReservation, Set<string> pSetofSourceID, Set<string> pSetofContactID){

        Sources__c iSrc;
        Contact iCon;

        SourceUtil ObjSrc = new SourceUtil();
        List<Contact> iLstCon = new List<Contact>();
        Set<Contact> iSetCon = new Set<Contact>();
        Map<ID, Contact> iMapCon = new Map<ID, Contact>();

        ObjSrc.getSourcesById(pSetofSourceID); // get Originating source from source object
        ObjSrc.getContactSources(pSetofContactID); // get contact sources

        for(Reservation__c r : pListOfReservation){

            System.debug('getSource');
            System.debug('ObjSrc.mapOfSource '+ ' '+ObjSrc.mapOfSource);            
            System.debug(ObjSrc.mapOfSource);
            if(r.Source_ID__c!= null){
                System.debug('Enter For Loop ');
                if(ObjSrc.mapOfSource.containsKey(r.Source_ID__c.toLowerCase()))
                    iSrc = ObjSrc.mapOfSource.get(r.Source_ID__c.toLowerCase());
            }
            System.debug('iSrc'+iSrc);

            if (r.RecordTypeId == RT_Reservation){
                System.debug('Enter if 126');
                iCon = ObjSrc.mapOfContact.get(r.Contact__c);
                iCon.Sync_with_Pardot__c = true;
                iMapCon.put(iCon.Id, iCon);
                continue;
                System.debug('iMapCon'+' '+iMapCon.keySet()+' '+iMapCon.values());
            }
            
            if(ObjSrc.mapOfContact.containsKey(r.Contact__c)){
                System.debug('Enter if 134');
                iCon = ObjSrc.mapOfContact.get(r.Contact__c);
            }
                System.debug('iCon data'+iCon);
            
            if(iCon != null){
                System.debug('Get iCon Size');
                
                if(iCon.Add_Date__c == null || r.Booked_Date__c < iCon.Add_Date__c){
                    System.debug('Add Date == null');
                    
                    if(iSrc != null){
                        System.debug('Get iSrc Size');
                        iCon.Source_Description__c = iSrc.Description__c;
                        iCon.Source_ID__c = iSrc.Source_ID__c;
                        iCon.Source_ID_2__c = iSrc.ID;
                        iCon.Originating_Source__c = iSrc.Source_Type__c;

                    }else{
                        System.debug('else iCon'+iCon);
						//System.debug('iCon Originating Source');
                        iCon.Source_ID__c = r.Source_ID__c;
                        iCon.Originating_Source__c = 'Other';
                    }

                    iCon.Add_Date__c  = r.Booked_Date__c;
                    /* Empty coreg details */
                    iCon.Subid__c = '';
                    iCon.Vendor_Name__c = '';
                    iCon.Vendor_Subgroup__c = '';
                    iCon.IP_Address__c = '';
                    iCon.Sync_with_Pardot__c = true;

                    if(iMapCon.ContainsKey(iCon.Id)){
                        Contact con = iMapCon.get(iCon.Id);
                        if(iCon.Add_Date__c < con.Add_Date__c){
                             iMapCon.put(iCon.Id, iCon);
                        }
                    }else{
                        System.debug('Ready for Update');
                        iMapCon.put(iCon.Id, iCon);
                        System.debug('Values vise updated'+ ' '+iCon.Id+ ' '+iCon.Originating_Source__c+ ' '+iCon.Source_ID__c);
                    } // End of else
                } // End of if
            }
        } // End of for

        if(iMapCon.size() > 0){
          update iMapCon.values();  
        } 
        System.debug('Updated iCon'+ iMapCon.values());

    } // End of function

    /******************************************** getResContacts *****************************************/
    // This function is used to set contact refrence on reservation record
    // This function is called from raw Contact batch after performing dedulication on voyger reservation
    public void getResContacts(List<WrapperDedup> iListWrapperDedup, DedupUtil obj){
        // Iteration over rawcontact wrapper list to populate map of voyger reservation id and contact
        for(WrapperDedup Res: iListWrapperDedup){

            if(Res.SfSourceType=='Voy' && Res.SfSourceId !=''){
              if(Res.Email == null && Res.Flas == null && Res.LAZ == null && Res.PF == null && Res.PL == null){

                    iMapOfReservation.put(Res.SfSourceId, '003j000000cafFY');

                }else{
                    if(obj.mapConAndEmail.ContainsKey(Res.Email)){
                        iMapOfReservation.put(Res.SfSourceId, obj.mapConAndEmail.get(Res.Email).Id);
                    }

                    else if(obj.mapConAndFLAS.ContainsKey(Res.Flas)){
                        iMapOfReservation.put(Res.SfSourceId, obj.mapConAndFLAS.get(Res.Flas).Id);
                    }

                    else if(obj.mapConAndLAZ.ContainsKey(Res.LAZ)){
                        iMapOfReservation.put(Res.SfSourceId, obj.mapConAndLAZ.get(Res.LAZ).Id);
                    }

                    else if(obj.mapConAndPF.ContainsKey(Res.PF)){
                        iMapOfReservation.put(Res.SfSourceId, obj.mapConAndPF.get(Res.PF).Id);
                    }

                    else if(obj.mapConAndPL.ContainsKey(Res.PL)){
                        iMapOfReservation.put(Res.SfSourceId, obj.mapConAndPL.get(Res.PL).Id);
                    }
                }
            } // End of if
        } // End of for

        List<Contact> lstOfContacts = getNewContacts(obj); // New contact refrence

        if(lstOfContacts.size() > 0){
            // Itration over new contacts to create maps of Email, FLAS, LAZ, PL and PF
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

                if(con.PL__c != null && !string.Isblank(con.PL__c ))
                    iMapPLCon.put(con.PL__c, con.id);

            } // End of loop

            // Iteration over rawcontact wrapper list to populate map of voyger reservation id and contact
            for(WrapperDedup Res: iListWrapperDedup){

                if(Res.SfSourceType=='Voy' && Res.SfSourceId !=''){
                   if(Res.Email == null && Res.Flas == null && Res.LAZ == null && Res.PF == null && Res.PL == null){


                       iMapOfReservation.put(Res.SfSourceId, '003j000000cafFY');

                    }else{
                        if(iMapEmailCon.ContainsKey(Res.email)){
                            iMapOfReservation.put(Res.SfSourceId, iMapEmailCon.get(Res.email));
                        }

                        else if(iMapFLASCon.ContainsKey(Res.FLAS)){
                            iMapOfReservation.put(Res.SfSourceId, iMapFLASCon.get(Res.FLAS));
                        }

                        else if(iMapLAZCon.ContainsKey(Res.LAZ)){
                            iMapOfReservation.put(Res.SfSourceId, iMapLAZCon.get(Res.LAZ));
                        }

                        else if(iMapPFCon.ContainsKey(Res.PF)){
                            iMapOfReservation.put(Res.SfSourceId, iMapPFCon.get(Res.PF));
                        }

                        else if(iMapPLCon.ContainsKey(Res.PL)){
                            iMapOfReservation.put(Res.SfSourceId, iMapPLCon.get(Res.PL));
                        }
                    }
                } // End of if
            } // End of for
        } // End of if

        // Iteration over reservation ids on map keyset and set contact refrence on record
        for(Reservation__c r : [Select Id, Contact__c from Reservation__c where Id in : iMapOfReservation.keySet() ]){
            if(iMapOfReservation.get(r.Id) != null){
                r.Contact__c = iMapOfReservation.get(r.Id);
                ListOfReservation.add(r);
            }
        }

        if(ListOfReservation.size() > 0 )
            update ListOfReservation;

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

    } // End of function

    //update active reservation count on membership
    public void UpdateActiveMembershipCount(AggregateResult[] groupedResults, set<Id> setMemberships){
        map<Id, Membership__c> mapMembership = new map<Id, Membership__c>();
        Membership__c membership = null;

        //zeriose
        for (Id id : setMemberships){
            membership = new Membership__c();
            membership.Id = id;
            membership.Active_Reservation_Nights_Count__c = 0;

            mapMembership.put(Id, membership);
        }

        //setting new values
        for (AggregateResult ar : groupedResults)  {
            membership = new Membership__c();
            membership.Active_Reservation_Nights_Count__c = 0;

            if (mapMembership.containsKey((Id) ar.get('Membership_ID__c'))){
                membership = mapMembership.get((Id) ar.get('Membership_ID__c'));
            }

            membership.Active_Reservation_Nights_Count__c = (double) ar.get('total');
            membership.Id = (Id) ar.get('Membership_ID__c');
            mapMembership.put(membership.Id, membership);
        }

        if (mapMembership.size()>0){
            update mapMembership.values();
        }
    }
}