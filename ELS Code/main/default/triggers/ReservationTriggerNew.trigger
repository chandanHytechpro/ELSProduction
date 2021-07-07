trigger ReservationTriggerNew on Reservation__c (After insert,After Update) {
    /* 
    Map<Id,Date> ContactIdsBookingDate = new Map<Id,Date>();
    Map<Id,Reservation__c> ContactIdsPropertyId = new Map<Id,Reservation__c>();
    Map<Id,Reservation__c> RateClassContactIds = new Map<Id,Reservation__c>();
    Map<Id,Reservation__c> PropertyTypeContactIds = new Map<Id,Reservation__c>();

    list<Reservation__c> ReservationCancelled = new list<Reservation__c>();
    list<Reservation__c> ReservationActive = new list<Reservation__c>();
    
    for(Reservation__c objRez : Trigger.New){
        if(objRez.Reservation_Status__c=='Cancelled'){
            ReservationCancelled.add(objRez);
        }else{
            ReservationActive.add(objRez);
        }
    }
    
    for(Reservation__c objRez : ReservationActive){       
        if(objRez.Contact__c !=null && objRez.Booked_Date__c!=null && (objRez.New_Rate_Class_Group__c=='Annual' || objRez.New_Rate_Class_Group__c=='Seasonal' || objRez.New_Rate_Class_Group__c=='Transient')){
            //bookedContactIds.add(objRez.Contact__c);
            ContactIdsBookingDate.put(objRez.Contact__c,objRez.Booked_Date__c);
        }
        
        if(objRez.Contact__c !=null && objRez.Property_ID__c!=null && (objRez.New_Rate_Class_Group__c=='Annual' || objRez.New_Rate_Class_Group__c=='Seasonal' || objRez.New_Rate_Class_Group__c=='Transient')){
            ContactIdsPropertyId.put(objRez.Contact__c,objRez);
        }
        
        if(objRez.Contact__c !=null && (objRez.New_Rate_Class_Group__c=='Annual' || objRez.New_Rate_Class_Group__c=='Seasonal' || objRez.New_Rate_Class_Group__c=='Transient')){
            RateClassContactIds.put(objRez.Contact__c,objRez);
        }
        
        if(objRez.Contact__c !=null && objRez.Property_Type__c!=null && (objRez.New_Rate_Class_Group__c=='Annual' || objRez.New_Rate_Class_Group__c=='Seasonal' || objRez.New_Rate_Class_Group__c=='Transient')){
            PropertyTypeContactIds.put(objRez.Contact__c,objRez);
        }
        
    }
    
    if(ContactIdsBookingDate.size()>0){
        list<Contact> listContacts = [Select id,X1st_Booking_Date__c from Contact Where id IN :ContactIdsBookingDate.keySet()];
        system.debug('listContacts'+listContacts);
        if(listContacts.size()>0){
            for(Contact ObjCOn :listContacts){
                if(ObjCOn.X1st_Booking_Date__c==null){
                    if(ContactIdsBookingDate.containsKey(ObjCOn.Id)){
                        ObjCOn.X1st_Booking_Date__c = ContactIdsBookingDate.get(ObjCOn.Id);   
                    }
                }
            }
            update listContacts;
        }
    }
    
    if(RateClassContactIds.size()>0){
        Set<Id> rateContactId = RateClassContactIds.keyset();
        list<Contact> listContacts = [Select id,X1st_New_Rate_Class_Group__c from Contact Where id IN :rateContactId];
        system.debug('listContacts'+listContacts);
        if(listContacts.size()>0){
            for(Contact ObjCOn :listContacts){
                if(ObjCOn.X1st_New_Rate_Class_Group__c==null){
                    if(RateClassContactIds.containsKey(ObjCOn.Id)){
                        ObjCOn.X1st_New_Rate_Class_Group__c = RateClassContactIds.get(ObjCOn.Id).New_Rate_Class_Group__c;   
                        ObjCOn.Time_stamp_first_New_Rate_Class_Group__c =   RateClassContactIds.get(ObjCOn.Id).createddate;
                    }
                }
            }
            update listContacts;
        }
    }
    
    if(PropertyTypeContactIds.size()>0){
        Set<Id> prppertypeContactId = PropertyTypeContactIds.keyset();
        list<Contact> listContacts = [Select id,X1st_Property_Type__c from Contact Where id IN :prppertypeContactId];
        system.debug('listContacts'+listContacts);
        if(listContacts.size()>0){
            for(Contact ObjCOn :listContacts){
                if(ObjCOn.X1st_Property_Type__c==null || ObjCOn.X1st_Property_Type__c==''){
                    if(PropertyTypeContactIds.containsKey(ObjCOn.Id)){
                        ObjCOn.X1st_Property_Type__c = PropertyTypeContactIds.get(ObjCOn.Id).Property_Type__c; 
                        ObjCOn.Time_stamp_first_property_type__c = PropertyTypeContactIds.get(ObjCOn.Id).createddate;  
                    }
                }
            }
            update listContacts;
        }
    }
    
    if(ContactIdsPropertyId.size()>0){
        Set<Id> propertyStayedId = ContactIdsPropertyId.keyset();
        list<Contact> listContacts = [Select id,X1st_Property_Stay__c from Contact Where id IN :propertyStayedId];
        system.debug('listContacts'+listContacts);
        if(listContacts.size()>0){
            for(Contact ObjCOn :listContacts){
                if(ObjCOn.X1st_Property_Stay__c==null){
                    if(ContactIdsPropertyId.containsKey(ObjCOn.Id)){
                        ObjCOn.X1st_Property_Stay__c = ContactIdsPropertyId.get(ObjCOn.Id).Property_ID__c; 
                        ObjCOn.Time_stamp_first_property_stay__c = ContactIdsPropertyId.get(ObjCOn.Id).createddate;  
                    }
                }
            }
            update listContacts;
        }
    }
    */
}