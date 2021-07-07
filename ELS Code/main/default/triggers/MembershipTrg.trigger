/*
Name        : MembershipTrg
Author      : Umer Aziz
Date        : 22/06/2015
Version     : 1.0
Description : 1) Update Contact Lookup on the basis of Client ID
*/
trigger MembershipTrg on Membership__c (Before Insert, after Insert, before update, After update) {
    
    /*ClientIDUtil ObjClientId = new ClientIDUtil();
    MembershipUtil  ObjMem = new MembershipUtil();
    
    List<Membership__c> lstofMembership = new list<Membership__c>();
    List<Contact> lstofContacttoUpdate = new List<Contact>();

    //Fill List of Member and Set for Client ID 
    for(Membership__c  Mem : trigger.new){
        if (Mem.Client_ID__c != null){
            ObjClientId.SetofClientId.add(Mem.Client_ID__c);
        }
        lstofMembership.add(Mem);
    }
    
    /****************************** Before ********************************/
    /*if(trigger.isbefore && (Trigger.Isinsert || Trigger.Isupdate)){
        
        //Update Contact lookup on the basic of Client ID and update Contact DG field to Customer
        ObjClientId.GetContactID();
        for(Membership__c  Mem : trigger.new){
            if(ObjClientId.MapofMemberandClient.size() > 0 && ObjClientId.MapofMemberandClient.containskey(Mem.Client_ID__c)){
                Mem.Contact__c = ObjClientId.MapofMemberandClient.get(Mem.Client_ID__c);
            }
        }
    }
    /**************************** Update Sources ***************************/
    /*************************** After Insert Event ************************/ 
    /*if(trigger.isafter && Trigger.isInsert){
        if(lstofMembership.size() >0){
            ObjMem.updateRawContactMember(lstofMembership);
        }
        Set<string> SetofContactID = new set<string>();
        Set<string> SetofSourceID = new set<string>();
        
        for(Membership__c mem: trigger.new){    
            if(mem.Contact__c != null && mem.Source_ID__c != null){
                SetofContactID.add(mem.Contact__c);
                SetofSourceID .add(mem.Source_ID__c.toLowerCase());
            }
        }      
        ObjMem.UpdateContactSources(trigger.new, SetofSourceID, SetofContactID);
        //End of is insert and is update logic   
    }*/  
}