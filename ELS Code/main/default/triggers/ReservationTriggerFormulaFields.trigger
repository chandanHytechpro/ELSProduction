trigger ReservationTriggerFormulaFields on Reservation__c (After Insert, After Update , before Delete) {
    System.debug('Enter Trigger-------->');
    //TestReservation objCall=new TestReservation();    
    List<Reservation__c> listOfReservations = new list<Reservation__c>();
    Map<Id,list<Reservation__c>> mapContactReservations = new Map<Id,list<Reservation__c>>();
    Set<String> setRateGroup = new Set<String>{'Seasonal','Annual','Transient'}; Set<Id> setOfContacts = new Set<Id>();
    Map<Id,Reservation__c> ContactOriginatingSource = new Map<Id,Reservation__c>();
    //Create set for all contacts that needs to be calculated

    if(Trigger.isDelete){
        for(Reservation__c objRez : Trigger.Old){
            if(objRez.contact__c!=null){
                setOfContacts.add(objRez.contact__c);
                ContactOriginatingSource.put(objRez.contact__c,objRez);
            }
        }
    }else{
        for(Reservation__c objRez : Trigger.New){
            if(objRez.contact__c!=null){
                setOfContacts.add(objRez.contact__c);
                ContactOriginatingSource.put(objRez.contact__c,objRez);
            }
        }
    }    
    //Query the contact Details
    if(setOfContacts.size()>0){
        list<Contact> ContactToUpdate = new list<Contact>();
        ContactToUpdate = [SELECT id ,Booked_Date_History__c,Rate_Class_History__c,Property_Stay_History__c,Property_Type_History__c,Original_Trails_Collection_Add_Date__c, X1st_Booking_Date__c , X1st_New_Rate_Class_Group__c , X1st_Property_Stay__c , X1st_Property_Type__c FROM Contact WHERE id IN :setOfContacts];        
        
        //find all the reservation related to the contact
        if(ContactToUpdate.size()>0){
            listOfReservations = [SELECT id,Name,contact__c,Booked_Date__c,New_Rate_Class_Group__c,Property_ID__c,Updated_Property_Name__c,Property_Type__c,CreatedDate  from Reservation__c where New_Rate_Class_Group__c IN :setRateGroup AND Contact__c IN :setOfContacts AND Reservation_Status__c<>'Cancelled' AND Booked_Date__c!=null order by Booked_Date__c];
        }
        
        //query reservation and create the map
        if(listOfReservations.size()>0){
            for(Reservation__c objRes : listOfReservations){
                if(!mapContactReservations.containsKey(objRes.contact__c)){
                    mapContactReservations.put(objRes.contact__c,new list<Reservation__c>());
                }
                mapContactReservations.get(objRes.contact__c).add(objRes);
            }
            
        }
        
        //iterate all the contacts to update the new values.
        for(Contact objCon : ContactToUpdate){
            
            //Put blank if no active reservation found
            boolean bookedflag=false,RateClassflag=false,PropertyStayflag=false,PropertyTypeflag=false;
            
            if(mapContactReservations.containsKey(objCon.id)){
                for(Reservation__c objRes : mapContactReservations.get(objCon.id)){
                    if(!bookedflag){
                        bookedflag = true;
                        if(objCon.X1st_Booking_Date__c != objRes.Booked_Date__c){
                            objCon.X1st_Booking_Date__c = objRes.Booked_Date__c;
                            /*if(objCon.Booked_Date_History__c!=null){
system.debug('test'+objCon.Booked_Date_History__c.countMatches('--'));
if(objCon.Booked_Date_History__c.countMatches('--')>1){
objCon.Booked_Date_History__c = objRes.Name + '::' + objRes.Booked_Date__c.format() + ' -- ' + objCon.Booked_Date_History__c ;
}else{
objCon.Booked_Date_History__c = objCon.Booked_Date_History__c.substringBeforeLast('--');
objCon.Booked_Date_History__c = objRes.Name + ' :: ' + objRes.Booked_Date__c.format() + ' -- ' +  objCon.Booked_Date_History__c ;
}
}else{
objCon.Booked_Date_History__c = objRes.Name + ' :: ' + objRes.Booked_Date__c.format();
}*/
                            objCon.Booked_Date_History__c = objRes.Name + ' :: ' + objRes.Booked_Date__c.format();
                        }
                    }
                    if(!RateClassflag){
                        RateClassflag = true;
                        if(objCon.X1st_New_Rate_Class_Group__c != objRes.New_Rate_Class_Group__c){
                            
                            objCon.Time_stamp_first_New_Rate_Class_Group__c = objRes.CreatedDate;
                            objCon.X1st_New_Rate_Class_Group__c = objRes.New_Rate_Class_Group__c;
                            /*
if(objCon.Rate_Class_History__c!=null){
system.debug('test'+objCon.Rate_Class_History__c.countMatches('--'));
if(objCon.Rate_Class_History__c.countMatches('--')<3){
objCon.Rate_Class_History__c = objRes.Name + '::' + objRes.New_Rate_Class_Group__c + ' -- ' + objCon.Rate_Class_History__c ;
}else{
objCon.Rate_Class_History__c = objCon.Rate_Class_History__c.substringBeforeLast('--');
objCon.Rate_Class_History__c = objRes.Name + ' :: ' + objRes.New_Rate_Class_Group__c + ' -- ' +  objCon.Rate_Class_History__c ;
}
}else{
objCon.Rate_Class_History__c = objRes.Name + ' :: ' + objRes.New_Rate_Class_Group__c;
}*/
                            objCon.Rate_Class_History__c = objRes.Name + ' :: ' + objRes.New_Rate_Class_Group__c;
                        }
                    }
                    if(!PropertyStayflag){
                        PropertyStayflag = true;
                        if(objCon.X1st_Property_Stay__c != objRes.Property_ID__c){
                            
                            objCon.Time_stamp_first_property_stay__c = objRes.CreatedDate;
                            objCon.X1st_Property_Stay__c = objRes.Property_ID__c;
                            /*
if(objCon.Property_Stay_History__c!=null){
system.debug('test'+objCon.Property_Stay_History__c.countMatches('--'));
if(objCon.Property_Stay_History__c.countMatches('--')<3){
objCon.Property_Stay_History__c = objRes.Name + '::' + objRes.Updated_Property_Name__c + ' -- ' + objCon.Property_Stay_History__c ;
}else{
objCon.Property_Stay_History__c = objCon.Property_Stay_History__c.substringBeforeLast('--');
objCon.Property_Stay_History__c = objRes.Name + ' :: ' + objRes.Updated_Property_Name__c + ' -- ' +  objCon.Property_Stay_History__c ;
}
}else{
objCon.Property_Stay_History__c = objRes.Name + ' :: ' + objRes.Updated_Property_Name__c;
}*/
                            objCon.Property_Stay_History__c = objRes.Name + ' :: ' + objRes.Updated_Property_Name__c;
                        }
                    }
                    if(!PropertyTypeflag){
                        PropertyTypeflag = true;
                        if(objCon.X1st_Property_Type__c != objRes.Property_Type__c){
                            
                            objCon.Time_stamp_first_property_type__c = objRes.CreatedDate;
                            objCon.X1st_Property_Type__c = objRes.Property_Type__c;
                            /*
if(objCon.Property_type_History__c!=null){
system.debug('test'+objCon.Property_type_History__c.countMatches('--'));
if(objCon.Property_type_History__c.countMatches('--')<3){
objCon.Property_type_History__c = objRes.Name + '::' + objRes.Property_Type__c + ' -- ' + objCon.Property_type_History__c ;
}else{
objCon.Property_type_History__c = objCon.Property_type_History__c.substringBeforeLast('--');
objCon.Property_type_History__c = objRes.Name + ' :: ' + objRes.Property_Type__c + ' -- ' +  objCon.Property_type_History__c ;
}
}else{
objCon.Property_type_History__c = objRes.Name + ' :: ' + objRes.Property_Type__c;
}*/
                            objCon.Property_type_History__c = objRes.Name + ' :: ' + objRes.Property_Type__c;
                        }
                    }
                }   
            }
        }
        if(ContactToUpdate.size()>0){
            update ContactToUpdate;
        }
    }
    
    if(Trigger.isInsert){        
        try{    
            
            System.debug('First If Condition Line No.----->142');
            if(ContactOriginatingSource.size()>0){
                list<Contact> ContactOrgSource = new list<Contact>();
                List<Contact> contactOrgSource1 = new List<Contact>(); //will use Contact Sub-Originating Source field equals Call Center 23 March 2021
                list<Contact> contactNullOrgSource=new list<Contact>();
                /*List<Reservation__c> reservationID=new List<Reservation__c>();
                Set<Id> contactID=new Set<Id>();
                
                List<Contact> lstContactHier = new List<Contact>();
                lstContactHier = [Select id,Originating_Source__c,CreatedDate,Sub_Originating_Source__c from Contact where id IN :ContactOriginatingSource.keyset() AND
                                  Originating_Source__c ='Reservation'];            
                
                for(Contact con3:lstContactHier){
                    contactID.add(con3.id);
                }
                
                reservationID=[Select Contact_ID_18__c,id,Booked_Date__c,Department_Category__c from Reservation__c where Contact_ID_18__c IN: contactID];
                System.debug('Waiting for this'+reservationID);
                
                ContactOrgSource = [Select id,Originating_Source__c,Sub_Originating_Source__c,Source_ID__c,CreatedDate from Contact where id IN :ContactOriginatingSource.keyset() AND
                                    Originating_Source__c ='Reservation' AND Sub_Originating_Source__c=Null ]; // it will consider Originating Source value Reservation OR Call Center

                
                contactOrgSource1 = [Select id,Originating_Source__c,Sub_Originating_Source__c,Source_ID__c,CreatedDate from Contact where id IN :ContactOriginatingSource.keyset() AND
                                     Originating_Source__c =null AND Sub_Originating_Source__c='Call Center' ]; // it will consider Originating Source value nall Sub Originating Source value Call Center

                
                contactNullOrgSource = [select Id, Originating_Source__c, CreatedDate from Contact where id in : ContactOriginatingSource.keyset() AND
                                        Originating_Source__c = null];
                
                if(lstContactHier.size()>0){
                    System.debug('lstContactHier.size' + ' ' + lstContactHier.size());                  
                    
                    for(Contact ObjCOn : lstContactHier){                    
                        System.debug('For Loop 166');
                        System.debug('-------->'+ContactOriginatingSource.containskey(ObjCOn.Id));
                        if(ContactOriginatingSource.containskey(ObjCOn.Id)){
                            System.debug('199------------->');
                            Date CompareDate = date.newinstance(ObjCOn.CreatedDate.year(), ObjCOn.CreatedDate.month(), ObjCOn.CreatedDate.day());
                            for(Reservation__c reservationCheck:reservationID){
                                if(reservationCheck.Contact_ID_18__c==ObjCOn.id){
                                    if((CompareDate == reservationCheck.Booked_Date__c || CompareDate > reservationCheck.Booked_Date__c)  && reservationCheck.Department_Category__c=='Call Center'){
                                        System.debug('Update Originating Source');
                                        ObjCOn.Originating_Source__c = 'Call Center';                            
                                    }
                                }
                            }
                        }
                    }
                    update lstContactHier;
                }*/
                
                /*else if(ContactOrgSource.size()>0){
System.debug('Third If Condition Line No.----->189');
for(Contact ObjCOn : ContactOrgSource){
if(ContactOriginatingSource.containskey(ObjCOn.Id) && ContactOriginatingSource.get(ObjCOn.Id).Reservation_Status__c=='Active'){
System.debug('Four If Condition Line No.----->192');
Date CompareDate = date.newinstance(ObjCOn.CreatedDate.year(), ObjCOn.CreatedDate.month(), ObjCOn.CreatedDate.day());
if(CompareDate == ContactOriginatingSource.get(ObjCOn.Id).Booked_Date__c  && ContactOriginatingSource.get(ObjCOn.Id).Department_Category__c!=null){
System.debug('Five If Condition Line No.----->195');
ObjCOn.Sub_Originating_Source__c = ContactOriginatingSource.get(ObjCOn.Id).Department_Category__c;   
ObjCOn.Sub_Originating_Source_Reason__c = ObjCOn.Originating_Source__c + '--' + ContactOriginatingSource.get(ObjCOn.Id).Id + '--' + ContactOriginatingSource.get(ObjCOn.Id).Booked_Date__c + '--' + ObjCOn.Source_ID__c;
}
}
}
update ContactOrgSource;
}*/
                /*else if(contactOrgSource1.size()>0){  //this condition will fire while Contact's Originating_Source__c should be null and  Sub_Originating_Source__c should be equal Call Center
System.debug('Third If Condition Line No.----->203');
for(Contact ObjCOn : contactOrgSource1){
if(ContactOriginatingSource.containskey(ObjCOn.Id) && ContactOriginatingSource.get(ObjCOn.Id).Reservation_Status__c=='Active'){
System.debug('Four If Condition Line No.----->206');
Date CompareDate = date.newinstance(ObjCOn.CreatedDate.year(), ObjCOn.CreatedDate.month(), ObjCOn.CreatedDate.day());
if(CompareDate == ContactOriginatingSource.get(ObjCOn.Id).Booked_Date__c  && ContactOriginatingSource.get(ObjCOn.Id).Department_Category__c == 'Call Center'){                            
//ObjCOn.Sub_Originating_Source__c = ContactOriginatingSource.get(ObjCOn.Id).Department_Category__c;   
ObjCOn.Originating_Source__c = 'Call Center';   
ObjCOn.Sub_Originating_Source_Reason__c = ObjCOn.Originating_Source__c + '--' + ContactOriginatingSource.get(ObjCOn.Id).Id + '--' + ContactOriginatingSource.get(ObjCOn.Id).Booked_Date__c + '--' + ObjCOn.Source_ID__c;
}
}
}
update contactOrgSource1;                                
}*/
                /*else if(contactNullOrgSource.size()>0){
System.debug('Enter else if Condition Line No.----->217');
for(Contact objC:contactNullOrgSource){
if(ContactOriginatingSource.containskey(objC.Id) && ContactOriginatingSource.get(objC.Id).Reservation_Status__c=='Active'){
Date CompareDate = date.newinstance(objC.CreatedDate.year(), objC.CreatedDate.month(), objC.CreatedDate.day());
if(CompareDate == ContactOriginatingSource.get(objC.Id).Booked_Date__c  && ContactOriginatingSource.get(objC.Id).Reservation_Source__c=='Call Center'){
objC.Originating_Source__c = 'Reservation';
objC.Sub_Originating_Source__c = ContactOriginatingSource.get(objC.Id).Reservation_Source__c;
}
}
}
update contactNullOrgSource;
}*/ 
            }
        }Catch(Exception e){
            System.debug('Error Message for After Insert '+e.getMessage());
            System.debug('Error line Number for After insert '+e.getLineNumber());
        }
    }
}