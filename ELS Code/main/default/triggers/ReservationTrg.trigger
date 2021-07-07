/*
/*
Name        : ReservationTrg
Author      : Umer Aziz
Date        : 22/06/2015
Version     : 1.0
Description : 1) Update Contact Lookup on the basis of Client ID
                       2) Fill Dummy contact from custom setting if Client ID is null or blank
*/
trigger ReservationTrg on Reservation__c ( After Insert , Before Insert,  After Update, Before Update, after delete)
{
/*
    The trigger is for case of insert only if we include update please verify the code at line # 90 code(ObjResUtil.updateRawContact(listofreservation);)
*/
    public set<ID> SetofReservationId = new set<ID> ();
    public List<Reservation__c> listofreservation = new List<Reservation__c>();
    public list<String> LstofRobotId = new list<String>();

    public Map<String, List<ID>> MapofRobotandAmanitiesList = new map<String, List<ID>>();
    public Map<String, List<ID>> MapofRobotndRobotAmenitiesList = new map<String, List<ID>>();

    public list<ID> lstofAmanitytoInsert = new list<ID>();
    public list<ID> lstofRobotAmenitiesToInsert = new list<ID>();
    public list<ID> lstofContacttoUpdate = new list<ID>();

    ReservationUtil ObjResUtil = new ReservationUtil();

    Public ID RT_Reservation {get; set;}
    Public ID RT_Voyager_Reservation {get; set;}

    //Anonymous Contact user setting from custom settings
    string Contact_Name ='';
    string Contact_ID;

    Contact__c ContactSettings = Contact__c.getValues('Dummy Contact');
    system.debug(ContactSettings);
    if (ContactSettings != null){
        Contact_Name = ContactSettings.name;
        Contact_ID = ContactSettings.Contact__c;
    }
    //Anonymous Contact user setting from custom settings ends

    //Fill Contact lookup on the basis of clientID if matched
    if(trigger.Isbefore && !Trigger.isDelete && (Trigger.IsInsert || Trigger.isUpdate)){
        set<ID> setofReservation = new set<ID>();
        ClientIDUtil ObjClientId = new ClientIDUtil();

        //Get Record Type from Reservation
        ObjResUtil.getrecordtype();

        if(Trigger.isBefore && Trigger.isInsert){

            //Update Contact Lookup on the basis of Client ID
            for(Reservation__c  Res : trigger.new){
                //Return if this is not a Voyager Reservation. West Monroe Partners, Nov 7, 2016
                if (Res.RecordTypeId == ObjResUtil.RT_Reservation)
                    continue;
                if(Res.Client_ID_Flat__c != null && Res.Client_ID_Flat__c != '' ){
                    Res.RecordTypeId = ObjResUtil.RT_Reservation;
                    ObjClientId.SetofClientId.add(Res.Client_ID_Flat__c);
                }else if(Res.Client_ID_Flat__c == null || Res.Client_ID_Flat__c == '' ){
                    Res.Contact__c = Contact_ID;
                    Res.RecordTypeId = ObjResUtil.RT_Voyager_Reservation;
                }
            }
        }
        //Method to get client ID and Contact
        ObjClientId.GetContactID();

        //Update Contact Loookup from Map of Contact Id and Client ID
        for(Reservation__c  Res : trigger.new){
            //Return if this is not a Voyager Reservation. West Monroe Partners, Nov 7, 2016
            if (Res.RecordTypeId == ObjResUtil.RT_Reservation)
                continue;
            if(ObjClientId.MapofMemberandClient.containskey(Res.Client_ID_Flat__c)){
                Res.Contact__c = ObjClientId.MapofMemberandClient.get(Res.Client_ID_Flat__c);
            }
        }
    }

    //Update Contact when Voyager reservation Contact Field is Update
    if(trigger.isBefore && trigger.Isupdate && !Trigger.isDelete){
        for(Reservation__c  Res : trigger.new){
            //Return if this is not a Voyager Reservation. West Monroe Partners, Nov 7, 2016
            if (Res.RecordTypeId == ObjResUtil.RT_Reservation)
                continue;
            if(Trigger.oldMap.get(Res.ID).Contact__c != Trigger.newMap.get(Res.ID).Contact__c){
                lstofContacttoUpdate.add(Res.Contact__c);
            }

            if(lstofContacttoUpdate.size()>0){
                ObjResUtil.UpdateContact(lstofContacttoUpdate);
            }
        }
    }

    //Trigger on after event creates RawContact if record type is Voyager Reservation
    //if(Trigger.isAfter && Trigger.IsInsert && !Trigger.isDelete){
    if(Trigger.isAfter && !Trigger.isDelete){

        //Get record type ID
        ObjResUtil.getrecordtype();
        System.debug('GetRecord Type ------------>');
        for (Reservation__c res : trigger.new){
            //Return if this is not a Voyager Reservation. West Monroe Partners, Nov 7, 2016
            if (Res.RecordTypeId == ObjResUtil.RT_Reservation)
                continue;
            if(res.RecordTypeId == ObjResUtil.RT_Reservation ){
                SetofReservationId.add(res.ID);
            }else if(res.RecordTypeId == ObjResUtil.RT_Voyager_Reservation ){
                listofreservation.add(res);
            }
        }

        //Create Raw Contact if Reservation Record type is Voyager Reservation
        if(listofreservation.size()>0 && Trigger.isInsert && !Trigger.isDelete){
            ObjResUtil.updateRawContact(listofreservation);
        }

        // **********************Update Source****************
        if(trigger.IsInsert && !Trigger.isDelete){
            Set<string> SetofContactID = new set<string>();
            Set<string> SetofSourceID = new set<string>();

            for(Reservation__c Res: trigger.new){
                //Return if this is not a Voyager Reservation. West Monroe Partners, Nov 7, 2016
                /*if (Res.RecordTypeId == ObjResUtil.RT_Reservation)
                    continue;*/
                if(Res.Contact__c != null && Res.Source_ID__c != null){
					System.debug('line 130');
                    SetofContactID.add(Res.Contact__c);
                    SetofSourceID.add(Res.Source_ID__c.toLowerCase());
                    system.debug('$$$$$'+SetofContactID+'$$$$$$'+SetofSourceID);
                }
					System.debug('Rez Contact'+SetofContactID);
                	System.debug('Rez Source ID'+SetofSourceID);
            }
            ObjResUtil.UpdateContactSources(trigger.new, SetofSourceID, SetofContactID);
        }
        //--------------------------------------------------
    }

    /*************************** Active reservation count on memberships ************************/
    set<Id> setMemberships = new set<Id>();
    if (!Trigger.isDelete && Trigger.isAfter) {
        for(Reservation__c  rec : trigger.new){
            //Return if this is not a Voyager Reservation. West Monroe Partners, Nov 7, 2016
            if (rec.RecordTypeId == ObjResUtil.RT_Reservation)
                continue;
            if (rec.Membership_ID__c != null){
                setMemberships.add(rec.Membership_ID__c);
            }
        }
    } else if (Trigger.isDelete) {
        for(Reservation__c  rec : trigger.old){
            //Return if this is not a Voyager Reservation. West Monroe Partners, Nov 7, 2016
            if (rec.RecordTypeId == ObjResUtil.RT_Reservation)
                continue;
            if (rec.Membership_ID__c != null){
                setMemberships.add(rec.Membership_ID__c);
            }
        }
    }

    //updating reservation count on memberships
    if (setMemberships.size() > 0){
        AggregateResult[] groupedResults = [Select r.Membership_ID__c, SUM(r.Number_Of_Nights__c) total From Reservation__c r
                                                WHERE r.Membership_ID__c =:setMemberships AND r.Reservation_Status__c ='Active' AND Core_Yes_No__c = 'N'
                                                Group By
                                                 r.Membership_ID__c];

        ObjResUtil.UpdateActiveMembershipCount(groupedResults, setMemberships);
    }
    /*************************** Active reservation count on memberships end ************************/
}