public with sharing class ReservationTriggerHandler {
    
    public static Boolean isFirstTime = true;
    public static void handleBeforeInsert(list<Reservation__c> Reslist) {
        try{
        Set<Id> propertyIdset = new Set<Id>();
        
        for(Reservation__c reservation : Reslist){
            //RV-Check the 3 Day box
            if(reservation.Arrival_Date_in_3_Days__c){
                reservation.X3_Days__c = true;
            }//stop
            
            //Reservation - Sync with Pardot Field Update (Acoustic fields)
            if(reservation.Property_ID__c!=null){
                propertyIdset.add(reservation.Property_ID__c);  
            }//stop 
            
            
        }
        
        //Reservation - Sync with Pardot Field Update (Acoustic fields)
        if(propertyIdset.size()>0){
            map<id,Property__c> listOfProperties = new map<id,Property__c>([Select Id,Win_Back_Body_Copy__c,Win_Back_Button__c,Win_Back_Hero_Image__c from Property__c where Id IN :propertyIdset]);
            if(listOfProperties.size()>0){
                for(Reservation__c reservation : Reslist) {
                    if(reservation.Property_ID__c!=null){
                        if(listOfProperties.containskey(reservation.Property_ID__c)){
                            Property__c tempProp = listOfProperties.get(reservation.Property_ID__c);
                            if(tempProp.Win_Back_Body_Copy__c!=null){
                                reservation.Win_Back_Body_Copy__c = tempProp.Win_Back_Body_Copy__c;
                            }
                            if(tempProp.Win_Back_Button__c!=null){
                                reservation.Win_Back_Button__c = tempProp.Win_Back_Button__c;
                            }
                            if(tempProp.Win_Back_Hero_Image__c!=null){
                                reservation.Win_Back_Hero_Image__c = tempProp.Win_Back_Hero_Image__c;
                            }
                        }   
                    }
                }   
            }
        }//stop 
        
                   for(Reservation__c objRez : Reslist){
            
            if(objRez.Amount_due_before_taxes__c==null){
                objRez.Org_Amount_Due_Before_Taxes_Discounts__c = 0;
            }else{
                objRez.Org_Amount_Due_Before_Taxes_Discounts__c = objRez.Amount_due_before_taxes__c;    
            }
            
            if(objRez.Discounts__c==null){
                objRez.Org_Discounts__c = 0;
            }else{
                objRez.Org_Discounts__c = objRez.Discounts__c;
            }
            
            if(objRez.Reservation_Status__c=='Cancelled'){
                
                objRez.Discounts__c=0;
                objRez.Amount_due_before_taxes__c=0;                
                
                //Reservation - Sync with Pardot Field Update
                if(objRez.Booked_Date__c!=null && (objRez.Booked_Date__c == objRez.Date_Cancelled__c)){
                    objRez.Org_Amount_Due_Before_Taxes_Discounts__c =0;
                    objRez.Org_Discounts__c = 0;
                }//stop
            }
        }
        if(system.label.Campaign_Functionality=='True'){
            
            //Campaign functionality
            set<Id> promoContactIdSet = new set<Id>();
            Map<Id,Campaign> updateCampaign = new Map<Id,Campaign>();
            Map<Id,Date> ContactWithReservationBookedDate = new Map<Id,Date>();
            list<Reservation__c> listwithpromo = new list<Reservation__c>();
            list<Reservation__c> listwithoutpromo = new list<Reservation__c>();
            Set<String> promocode = new Set<String>();
            set<Id> ReservationcontactWithoutPromo = new set<Id>();
            for(Reservation__c reservation : Reslist) {
                if(reservation.Contact__c!=null && reservation.Booked_Date__c!=null&& (reservation.Promotional_Discount_Used__c=='No Discount/Surcharge'||reservation.Promotional_Discount_Used__c==null)){
                    ReservationcontactWithoutPromo.add(reservation.Contact__c);
                    listwithoutpromo.add(reservation);
                    ContactWithReservationBookedDate.put(reservation.Contact__c,reservation.Booked_Date__c);
                }else if(reservation.Contact__c!=null && reservation.Promotional_Discount_Used__c!=null){//No Discount/Surcharge
                    promocode.add(reservation.Promotional_Discount_Used__c);
                    listwithpromo.add(reservation);
                    ContactWithReservationBookedDate.put(reservation.Contact__c,reservation.Booked_Date__c);
                }
                
                
                
                
                
            }
            System.debug('Reservation Contact withoud promo code Set Id'+ReservationcontactWithoutPromo);
            
            //Indirect revenue
            if(ReservationcontactWithoutPromo.size()>0){
                list<CampaignMember> latestCampaignOnContact = [Select id,ContactId,CampaignId,createdDate from CampaignMember where ContactId IN : ReservationcontactWithoutPromo order by createdDate desc];
                System.debug('Sqol query for campaign member :'+latestCampaignOnContact);
                if(latestCampaignOnContact.size()>0){
                    Map<Id,List<id>> campMap = new Map<Id,List<id>>();
                    for(CampaignMember objCampMem :latestCampaignOnContact){
                        system.debug(ContactWithReservationBookedDate.get(objCampMem.contactId));
                        Date BookedDate = ContactWithReservationBookedDate.get(objCampMem.contactId);
                        System.debug('Bokked Date'+BookedDate);
                        Date memCreatedDate = objCampMem.createdDate.Date();
                        system.debug('objCampMem' + objCampMem.createdDate);
                        system.debug('memCreatedDate' + memCreatedDate);
                        System.debug('2nd'+(BookedDate >= memCreatedDate));
                        System.debug('3rd'+(BookedDate <= memCreatedDate.addDays(365)));
                        
                        
                        
                        if(BookedDate >= memCreatedDate && BookedDate <= memCreatedDate.addDays(365)){
                            if(!campMap.containskey(objCampMem.contactId)){
                                List<Id> firstTime=new List<id>();
                                firstTime.add(objCampMem.CampaignId);
                            campMap.put(objCampMem.contactId,firstTime);
                               // firstTime.clear();
                            }else{
                                 List<Id> secondTime=new List<id>();
                                 secondTime.addAll(campMap.get(objCampMem.contactId));
                                secondTime.add(objCampMem.CampaignId);
                                 campMap.put(objCampMem.contactId,secondTime);
                              //  secondTime.clear();
                            }
                            
                        }
                    }
                    System.debug('Contact id to campaign id'+campMap);
                    if(campMap.size()>0){
                        List<Id> queryIds=new List<Id>();
                        for(id collectId: campMap.keyset()){
                            queryIds.addAll(campMap.get(collectId));
                        }
                        
                        Map<Id,Campaign> campaignList = new Map<Id,Campaign>([Select id,Indirect_Revenue__c from Campaign where id IN :queryIds]);                     
                        System.debug('Campaign List Soql Query :'+campaignList);
                        for(Reservation__c objRes : listwithoutpromo){
                            Boolean updateCampaign2=True;
                            if(campMap.containskey(objRes.Contact__c)){
                                for(Id loopCampaignId:campMap.get(objRes.Contact__c)){
                            //     Campaign forExpeptions=campaignList.get(loopCampaignId);// this is added to remove exception
                            //        if(forExpeptions!=null){// this is added to remove exception
                                if(campaignList.containskey(loopCampaignId)){
                                    if(updateCampaign2){
                                    objRes.Campaign__c = loopCampaignId;
                                     updateCampaign2=false;   
                                    }
                                    if(campaignList.get(loopCampaignId).Indirect_Revenue__c!=null){
                                        if(objRes.Org_Amount_Due_Before_Taxes_Discounts__c!=null){
                                        campaignList.get(loopCampaignId).Indirect_Revenue__c += objRes.Org_Amount_Due_Before_Taxes_Discounts__c;
                                        }
                                        System.debug('::Value::' +campaignList.get(loopCampaignId).Indirect_Revenue__c);
                                    }else{
                                        if(objRes.Org_Amount_Due_Before_Taxes_Discounts__c!=null){
                                        campaignList.get(loopCampaignId).Indirect_Revenue__c = objRes.Org_Amount_Due_Before_Taxes_Discounts__c;
                                        }
                                        System.debug('::Value::' +campaignList.get(loopCampaignId).Indirect_Revenue__c);
                                        
                                    }
                                    
                                }
                               //     }// this is added to remove exception
                            }  
                            }
                        }
                        update campaignList.values(); 
                    }
                }
            }
                           Map<Id,CampaignMember> campMapMem=new Map<Id,CampaignMember>();
            //direct revenue
            if(promocode.size()>0){
                
                for(Reservation__c ObjRes : listwithpromo){
                    promoContactIdSet.add(ObjRes.Contact__c);
                }
                
                
                list<CampaignMember> latestCampaignOnContactpromo = [Select id,ContactId,CampaignId,createdDate from CampaignMember where ContactId IN : promoContactIdSet order by createdDate desc];
                 Map<Id, List<ID>> directWithIndirect=new Map<ID,List<ID>>();
                Map<Id,set<Id>> campMapPromo = new Map<Id,set<Id>>();
                if(latestCampaignOnContactpromo.size()>0){
                    
                    for(CampaignMember objCampMem :latestCampaignOnContactpromo){
                        campMapMem.put(objCampMem.CampaignId,objCampMem);
                        system.debug(ContactWithReservationBookedDate.get(objCampMem.contactId));
                        Date BookedDate = ContactWithReservationBookedDate.get(objCampMem.contactId);
                        system.debug('BookedDate' + BookedDate);
                        Date memCreatedDate = objCampMem.createdDate.Date();
                        system.debug('objCampMem.createdDate'+objCampMem.createdDate);
                        system.debug((objCampMem.createdDate >= BookedDate) + ' objCampMem.createdDate >= BookedDate');
                        //system.debug('objCampMem.createdDate <= BookedDate.addDays(7)'+( objCampMem.createdDate <= BookedDate.addDays(7)));
                        if(!campMapPromo.containskey(objCampMem.contactId) ){//&& objCampMem.createdDate >= BookedDate && objCampMem.createdDate <= BookedDate.addDays(7)){
                            campMapPromo.put(objCampMem.contactId, new set<Id>());   
                        }
                        campMapPromo.get(objCampMem.contactId).add(objCampMem.CampaignId);
                        if(BookedDate >= memCreatedDate && BookedDate <= memCreatedDate.addDays(365)){
                          
                            
                                 if(!directWithIndirect.containskey(objCampMem.contactId)){
                                List<Id> firstTime=new List<id>();
                                firstTime.add(objCampMem.CampaignId);
                            directWithIndirect.put(objCampMem.contactId,firstTime);
                               // firstTime.clear();
                            }else{
                                 List<Id> secondTime=new List<id>();
                                 secondTime.addAll(directWithIndirect.get(objCampMem.contactId));
                                secondTime.add(objCampMem.CampaignId);
                                 directWithIndirect.put(objCampMem.contactId,secondTime);
                              //  secondTime.clear();
                            }
                            
                            
                            
                            
                            
                        }
                        
                    }
                }
                
                 List<Id> queryIds=new List<Id>();
                        for(id collectId: directWithIndirect.keyset()){
                            queryIds.addAll(directWithIndirect.get(collectId));
                        }
                
                 Map<Id,Campaign> updatePromocodeForIndirect = new Map<Id,Campaign>([Select id,Indirect_Revenue__c from Campaign where id IN :queryIds]);  
                
                Map<String,Campaign> promoCampaignMap = new Map<String,Campaign>();
                list<Campaign> campaignList = [Select id,Promo_Code__c,Promo_Code_1__c,Promo_Code_2__c,Promo_Code_3__c,Promo_Code_4__c,Promo_Code_5__c,Promo_Code_6__c,Promo_Code_7__c,Promo_Code_8__c,Direct_Revenue__c from Campaign 
                                               where Promo_Code__c IN: promocode OR
                                               Promo_Code_1__c IN: promocode OR
                                               Promo_Code_2__c IN: promocode OR
                                               Promo_Code_3__c IN: promocode OR
                                               Promo_Code_4__c IN: promocode OR
                                               Promo_Code_5__c IN: promocode OR
                                               Promo_Code_6__c IN: promocode OR
                                               Promo_Code_7__c IN: promocode OR
                                               Promo_Code_8__c IN: promocode];
                Set<Id> CampaignIDTest=new Set<Id>();
                Map<Id,Campaign> assignCamToReservation= new Map<Id,Campaign>();
                if(campaignList.size()>0){
                    for(Campaign objCamp :campaignList){
                        CampaignIDTest.add(objCamp.Id);
                        assignCamToReservation.put(objCamp.Id,objCamp);
                    }
                }
                List<CampaignMember> finalCampaignTest=[Select CampaignId from CampaignMember where CampaignId IN :CampaignIDTest Order by CreatedDate DESC];
                List<Id> directToIndirect=new List<Id>();
                Id finalCampaignTestId;
                if(finalCampaignTest.size()>0){
                    finalCampaignTestId=finalCampaignTest[0].CampaignId; 
                }
                if(campaignList.size()>0){
                    for(Campaign objCamp :campaignList){
                        promoCampaignMap.put(objCamp.Promo_Code__c,objCamp);
                        promoCampaignMap.put(objCamp.Promo_Code_1__c,objCamp);
                        promoCampaignMap.put(objCamp.Promo_Code_2__c,objCamp);
                        promoCampaignMap.put(objCamp.Promo_Code_3__c,objCamp);
                        promoCampaignMap.put(objCamp.Promo_Code_4__c,objCamp);
                        promoCampaignMap.put(objCamp.Promo_Code_5__c,objCamp);
                        promoCampaignMap.put(objCamp.Promo_Code_6__c,objCamp);
                        promoCampaignMap.put(objCamp.Promo_Code_7__c,objCamp);
                        promoCampaignMap.put(objCamp.Promo_Code_8__c,objCamp);
                        promoCampaignMap.remove(null);
                    }
                    
                    for(Reservation__c ObjRes : listwithpromo){
                    Id campId;
                    if(promoCampaignMap.containskey(ObjRes.Promotional_Discount_Used__c) && campMapPromo.containsKey(ObjRes.Contact__c)){
                        if(campaignList.size()>1){
                          campId= finalCampaignTestId; 
                        }
                        else{
                        campId = promoCampaignMap.get(ObjRes.Promotional_Discount_Used__c).Id;
                        }
                        if(campMapPromo.get(ObjRes.Contact__c).contains(campId)){
                            if(campaignList.size()>1){
                                ObjRes.campaign__c =campId;
                        //  campId= finalCampaignTestId; 
                        }
                        else{
                            ObjRes.campaign__c = promoCampaignMap.get(ObjRes.Promotional_Discount_Used__c).Id;
                       // campId = promoCampaignMap.get(ObjRes.Promotional_Discount_Used__c).Id;
                        }
                            ObjRes.campaign__c = promoCampaignMap.get(ObjRes.Promotional_Discount_Used__c).Id;
                            updateCampaign.put(ObjRes.campaign__c,promoCampaignMap.get(ObjRes.Promotional_Discount_Used__c));
                            if(updateCampaign.get(ObjRes.campaign__c).Direct_Revenue__c!=null && ObjRes.Org_Amount_Due_Before_Taxes_Discounts__c!=null){
                                updateCampaign.get(ObjRes.campaign__c).Direct_Revenue__c += ObjRes.Org_Amount_Due_Before_Taxes_Discounts__c;   
                            }else{
                                if(ObjRes.Org_Amount_Due_Before_Taxes_Discounts__c!=null){
                                updateCampaign.get(ObjRes.campaign__c).Direct_Revenue__c = ObjRes.Org_Amount_Due_Before_Taxes_Discounts__c;
                                }
                            }
                            List<Id> forExpeptions=directWithIndirect.get(ObjRes.Contact__c);
                           // if((directWithIndirect.get(ObjRes.Contact__c)).size()>0){
                            if(forExpeptions!=null){
                            for(ID campaigndirectWithIndirect:directWithIndirect.get(ObjRes.Contact__c)){
                                if(campaigndirectWithIndirect!=ObjRes.campaign__c){
                                    if(updatePromocodeForIndirect.get(campaigndirectWithIndirect).Indirect_Revenue__c!=null && objRes.Org_Amount_Due_Before_Taxes_Discounts__c!=null){
                                        updatePromocodeForIndirect.get(campaigndirectWithIndirect).Indirect_Revenue__c += objRes.Org_Amount_Due_Before_Taxes_Discounts__c;
                                        System.debug('::Value::' +updatePromocodeForIndirect.get(campaigndirectWithIndirect).Indirect_Revenue__c);
                                    }else{
                                        if(objRes.Org_Amount_Due_Before_Taxes_Discounts__c!=null){
                                        updatePromocodeForIndirect.get(campaigndirectWithIndirect).Indirect_Revenue__c = objRes.Org_Amount_Due_Before_Taxes_Discounts__c;
                                        }
                                        System.debug('::Value::' +updatePromocodeForIndirect.get(campaigndirectWithIndirect).Indirect_Revenue__c);
                                    
                                }
                            }
                            
                        }
                        }
                    }
                }
                    }
                    update updateCampaign.values();
                    update updatePromocodeForIndirect.values();
                
                }            
            }//stop campaign functionality
            
        }
        
 
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    

    
    public static void handleAfterInsert(Map<Id, Reservation__c> newMap) {        
        
        // Start from here ELS-288 Logic 1 & 2..... Line 243 - 403
        
        Set<Id> setIds=new Set<Id>();
        Map<Id, Reservation__c> mapCOnRez=new Map<Id, Reservation__c>();
        
        for(Reservation__c objRs : newMap.values()){
            if(objRs.Contact__c != null){
                setIds.add(objRs.Contact__c);
            }
        }
        
        for(Reservation__c objRez : newMap.values()){
            if(objRez.Contact__c != null){
                mapCOnRez.put(objRez.contact__c,objRez);
            }
        }
        
        List<Reservation__c> reservationID=new List<Reservation__c>();
        Set<Id> contactID=new Set<Id>();
        List<Contact> lstContactHier = new List<Contact>();
        
        lstContactHier = [Select id,Originating_Source__c,CreatedDate,Sub_Originating_Source__c,Source_ID__c,Sub_Originating_Source_Reason__c from Contact where id IN :mapCOnRez.keyset() AND
                          Originating_Source__c ='Reservation'];            
        
        for(Contact con3:lstContactHier){
            contactID.add(con3.id);
        }
        
        reservationID=[Select Contact_ID_18__c,id,Booked_Date__c,Department_Category__c from Reservation__c where Contact_ID_18__c IN: contactID];
        
        if(lstContactHier.size()>0){
            System.debug('lstContactHier.size' + ' ' + lstContactHier.size());                  
            
            for(Contact ObjCOn : lstContactHier){                    
                System.debug('For Loop 166');
                //System.debug('-------->'+ContactOriginatingSource.containskey(ObjCOn.Id));
                if(mapCOnRez.containskey(ObjCOn.Id)){
                    System.debug('199------------->');
                    Date CompareDate = date.newinstance(ObjCOn.CreatedDate.year(), ObjCOn.CreatedDate.month(), ObjCOn.CreatedDate.day());
                    for(Reservation__c reservationCheck:reservationID){
                        if(reservationCheck.Contact_ID_18__c==ObjCOn.id){
                            if((CompareDate == reservationCheck.Booked_Date__c || CompareDate > reservationCheck.Booked_Date__c)  && reservationCheck.Department_Category__c=='Call Center'){
                                System.debug('Update Originating Source');
                                ObjCOn.Originating_Source__c = 'Call Center'; 
                                ObjCOn.Sub_Originating_Source_Reason__c = ObjCOn.Originating_Source__c + '--' + mapCOnRez.get(ObjCOn.Id).Id + '--' + mapCOnRez.get(ObjCOn.Id).Booked_Date__c + '--' + ObjCOn.Source_ID__c;
                            }
                        }
                    }
                }
            }
            update lstContactHier;
        }
        
        
        //
        List<Reservation__c> lstReser=[select Id, Contact__c, Reservation_Status__c, Department_Category__c, Booked_Date__c from Reservation__c where Contact__c IN : setIds];   // here setIds is all the contact from the reservation
        
        Set<Id> conId=new Set<Id>();
        List<Contact> lstCn=new List<Contact>();
        for(Reservation__c objR : lstReser){                
            if(objR.Contact__c != null){
                conId.add(objR.Contact__c);// conId is same as setId take as variable in above query
            }
        }  
        
        List<Contact> lstCon=new List<Contact>();
        lstCon=[select Id, Originating_Source__c, Sub_Originating_Source__c,createdDate,Source_ID__c,Sub_Originating_Source_Reason__c from Contact where Id IN : conId AND Originating_Source__c = 'Reservation'];
        
        List<Reservation__c> lstConRez=new List<Reservation__c>();
        
        Map<String,Integer> mapStrInt=new Map<String,Integer>();
        mapStrInt.put('OTA',1);
        mapStrInt.put('Web',2);
        mapStrInt.put('campUSA',3);
        mapStrInt.put('Property',4);
        mapStrInt.put('Default',5);
        
        List<String> lstStr=new List<String>();
        lstStr.add('OTA');
        lstStr.add('Web');
        lstStr.add('campUSA');
        lstStr.add('Property');
        
        Integer count;
        
        for(Contact objC : lstCon){   // 413 to 489
            count=5;
            lstConRez.clear();
            Date contactDate2=date.newinstance(objC.CreatedDate.year(), objC.CreatedDate.month(), objC.CreatedDate.day());
            for(Reservation__c objRez : lstReser){
                if(objC.Id == objRez.Contact__c && objRez.Department_Category__c != 'Call Center'){
                    lstConRez.add(objRez);                        
                }                    
            } 
            
            System.debug('List of reservation that we got'+lstConRez);
            
            Id rezId;
            Date rezBookedDate; 
              List<Reservation__c> lstRez2=new List<Reservation__c>();// this is for new requirement where reservation booked date and contact created date is taken into consideration
            for(Reservation__c objRs : lstConRez){// this is to take the id and booked date for oldest reservation booked
                
                if(rezId == null){
                    rezId = objRs.Id;
                    rezBookedDate = objRs.Booked_Date__c;
                }
                else if(rezBookedDate > objRs.Booked_Date__c){
                    System.debug('Reservation '+objRs+' booked date '+ rezBookedDate+' objectcopareds reservation '+ objRs.Booked_Date__c);
                    rezId = objRs.Id;
                    rezBookedDate = objRs.Booked_Date__c;
                }
            }
            System.debug('RezId--------->'+ rezId);
            System.debug('rezBookedDate--------->'+ rezBookedDate);
            List<Reservation__c> lstRez1=new List<Reservation__c>();
            
            for(Reservation__c objRs : lstConRez){    // this is to take reservation and add it to the list if its having more than one at the same date
                if(objRs.Booked_Date__c == rezBookedDate){
                    lstRez1.add(objRs);
                }
                System.debug('ObjRs ContactId ---->'+objRs.Contact__c);
                System.debug('objC ContactId ---->'+objC.Id);
                
                if( contactDate2>objRs.Booked_Date__c || contactDate2==objRs.Booked_Date__c){
                    System.debug('Compare Date --------->');
                    lstRez2.add(objRs);
                }                
                System.debug('lstRez2 Size '+lstRez2);                
            }
            System.debug('lstRez2 Size ------> '+lstRez2.size());
            System.debug('lstRez1 Size ------> '+lstRez1.size());
            /*if(lstRez1 != null && lstRez1.size()<2){
                Reservation__c objRsv=new Reservation__c();
                System.debug('One Reservation Got------>'+ lstRez1);
                for(Reservation__c objReservation : lstRez1){
                    objRsv=objReservation;
                }     
                objC.Sub_Originating_Source__c=objRsv.Department_Category__c;
                objC.Sub_Originating_Source_Reason__c = objC.Originating_Source__c + '--' + mapCOnRez.get(objC.Id).Id + '--' + mapCOnRez.get(objC.Id).Booked_Date__c + '--' + objC.Source_ID__c;
            }else*/ if(lstRez2.size() != null && lstRez2.size()>0){
                System.debug('Enter Compare Date Logic -------->');
                Reservation__c objRsv=new Reservation__c();
                System.debug('Date Comparison Many Reservation Got------>'+ lstRez2);
                for(Reservation__c objReservation : lstRez2){
                    System.debug('Counter :'+count+' reservation: '+objReservation.Id);
                    if(mapStrInt.get(objReservation.Department_Category__c)<count){
                        count=mapStrInt.get(objReservation.Department_Category__c);
                    }                                                                                                
                    //objC.Sub_Originating_Source__c=objRsv.Department_Category__c;
                }
                System.debug('Date Comparison Final :'+count );
                if(count<5){
                    objC.Sub_Originating_Source__c=lstStr[count-1];   
                }                    
                System.debug('Sub_Originating_Source__c'+objC.Sub_Originating_Source__c);
                objC.Sub_Originating_Source_Reason__c = objC.Originating_Source__c + '--' + mapCOnRez.get(objC.Id).Id + '--' + mapCOnRez.get(objC.Id).Booked_Date__c + '--' + objC.Source_ID__c;
            } /*else if(lstRez1 != null && lstRez1.size()>1){
                Reservation__c objRsv=new Reservation__c();
                System.debug('Same Date Many Reservation Got------>'+ lstRez1.size());
                for(Reservation__c objReservation : lstRez1){
                    System.debug('Counter :'+count+' reservation: '+objReservation.Id);
                    if(mapStrInt.get(objReservation.Department_Category__c)<count){
                        count=mapStrInt.get(objReservation.Department_Category__c);
                    }                                                                                                
                    //objC.Sub_Originating_Source__c=objRsv.Department_Category__c;
                }
                System.debug('Same Date Final :'+count );
                if(count<5){
                    objC.Sub_Originating_Source__c=lstStr[count-1];    
                }
            }*/
            lstCn.add(objC);
        }
        update lstCn;
        System.debug('------->'+lstCn);
        
        Set<Id> clientIDIds = new Set<Id>();
        for(Reservation__c reservation : newMap.values()) {
            //If the reservation is active and has a clientid, we will roll the num of reservations to the clientid record
            if(reservation.ClientID__c != null && reservation.Reservation_Status__c == Constants.ReservationStatusActive) {
                clientIDIds.add(reservation.ClientID__c);
            } 
        }              
        //Find all active reservations for each clientID and update the number of reservations
        List<ClientID__c> clientIDs = new List<ClientID__c>();
        if(clientIDIds.size() > 0) {
            for(AggregateResult ar : [Select ClientID__c, count(Id) from Reservation__c Where Reservation_Status__c =: Constants.ReservationStatusActive And ClientID__c in: clientIDIds Group By ClientID__c]) {
                clientIDs.add(new ClientID__c(Id = (ID)ar.get('ClientID__c'), Number_of_Reservations__c = (Decimal)ar.get('expr0')));
            }
        }
        if(clientIDs.size() > 0) {
            update clientIds;
        } 
    }
    
    public static void handleBeforeUpdate(Map<Id, Reservation__c> oldMap, Map<Id, Reservation__c> newMap) {
        
        Set<Id> propertyIdset = new Set<Id>();
        
        for(Reservation__c reservation : newMap.values()){
            
            //RV-Check the 3 Day box
            if(reservation.Arrival_Date_in_3_Days__c){
                reservation.X3_Days__c = true;
            }//stop
            
            if(reservation.Reservation_Status__c=='Cancelled'){
                
                reservation.Discounts__c=0;
                reservation.Amount_due_before_taxes__c=0;                
                
                //Reservation - Sync with Pardot Field Update
                if(reservation.Booked_Date__c!=null && (reservation.Booked_Date__c == reservation.Date_Cancelled__c)){
                    reservation.Org_Amount_Due_Before_Taxes_Discounts__c =0;
                    reservation.Org_Discounts__c = 0;
                }//stop
            }
            
            //Reservation - Sync with Pardot Field Update (Acoustic fields)
            if(reservation.Property_ID__c!=null){
                propertyIdset.add(reservation.Property_ID__c);  
            }//stop            
        }
        
        //Reservation - Sync with Pardot Field Update (Acoustic fields)
        if(propertyIdset.size()>0){
            map<id,Property__c> listOfProperties = new map<id,Property__c>([Select Id,Win_Back_Body_Copy__c,Win_Back_Button__c,Win_Back_Hero_Image__c from Property__c where Id IN :propertyIdset]);
            if(listOfProperties.size()>0){
                for(Reservation__c reservation : newMap.values()) {
                    if(reservation.Property_ID__c!=null){
                        if(listOfProperties.containskey(reservation.Property_ID__c)){
                            Property__c tempProp = listOfProperties.get(reservation.Property_ID__c);
                            if(tempProp.Win_Back_Body_Copy__c!=null){
                                reservation.Win_Back_Body_Copy__c = tempProp.Win_Back_Body_Copy__c;
                            }
                            if(tempProp.Win_Back_Button__c!=null){
                                reservation.Win_Back_Button__c = tempProp.Win_Back_Button__c;
                            }
                            if(tempProp.Win_Back_Hero_Image__c!=null){
                                reservation.Win_Back_Hero_Image__c = tempProp.Win_Back_Hero_Image__c;
                            }
                        }   
                    }
                }   
            }
        }//stop
        
    }
    
    public static void handleAfterUpdate(Map<Id, Reservation__c> oldMap, Map<Id, Reservation__c> newMap) {
        
        
        Set<Id> clientIDIds = new Set<Id>();
        for(Reservation__c newReservation : newMap.values()) {
            Reservation__c oldReservation = oldMap.get(newReservation.Id);
            
            //If the reservation status has chanced, we will roll the new num of reservations to the clientid record\
            System.debug('Take it'+ newReservation.ClientID__c);
              System.debug('Take it2'+ newReservation.Reservation_Status__c);
            System.debug('Take it2'+ oldReservation.Reservation_Status__c);
            if(newReservation.ClientID__c != null && newReservation.Reservation_Status__c != oldReservation.Reservation_Status__c) {
                clientIDIds.add(newReservation.ClientID__c);
            }
        }
        
        //Find all active reservations for each clientID and update the number of reservations
        List<ClientID__c> clientIDs = new List<ClientID__c>();
        if(clientIDIds.size() > 0) {
            Map<Id, Decimal> numActiveReservations = new Map<Id, Decimal>();
            for(AggregateResult ar : [Select ClientID__c, count(Id) from Reservation__c Where Reservation_Status__c =: Constants.ReservationStatusActive And ClientID__c in: clientIDIds Group By ClientID__c]) {
                numActiveReservations.put((ID)ar.get('ClientID__c'), (Decimal)ar.get('expr0'));
            }
            
            //This has to be done for each clientID and not each aggregate result because AR does not pull 0 count records
            for(Id clientIDId : clientIDIds) {
                clientIDs.add(new ClientID__c(Id = clientIDId, Number_of_Reservations__c = numActiveReservations.containsKey(clientIDId) ? numActiveReservations.get(clientIDId) : 0)); //Manually handle 0 count records
            }
        }
        
        if(clientIDs.size() > 0) {
            update clientIds;
        }
    }
    
    
    /**
* Created By: Shane Blazier
* Created Date: 9/18/2018
* Description: Method used to check if a Junction object needs to be created or deleted
*/
    public static void checkJunction(Map<Id,Reservation__c> oldMap, Map<Id,Reservation__c> newMap){
        Map<Id,Reservation__c> createMap = new Map<Id,Reservation__c>();
        List<Id> deleteIds = new List<Id>();
        Map<String,Integer> cmMap = new Map<String,Integer>();
        List<CampaignMember> cmList = new List<CampaignMember>();
        
        
        if(oldMap != null) {
            for (Id rId : oldMap.keySet()) {
                if ((oldMap.get(rId).Reservation_Status__c == 'Cancelled' || oldMap.get(rId).Reservation_Status__c == null) && newMap.get(rId).Reservation_Status__c == 'Active') {
                    createMap.put(rId, newMap.get(rId));
                }
                if (oldMap.get(rId).Reservation_Status__c == 'Active' && (newMap.get(rId).Reservation_Status__c == 'Cancelled' || newMap.get(rId).Reservation_Status__c == null)) {
                    deleteIds.add(rId);
                }
            }
            
            List<Campaign_Reservation_Junction__c> juncsToDelete = [SELECT Id, Campaign_Member_Id__c FROM Campaign_Reservation_Junction__c WHERE Reservation__c IN :deleteIds];
            
            createJunction(createMap, null);
            
            delete juncsToDelete;
        }
        
        else{
            for(Reservation__c reservation : newMap.values()){
                if(reservation.Reservation_Status__c == 'Active'){
                    
                    createMap.put(reservation.Id,reservation);
                }
            }
            createJunction(createMap, null);
        }
        
    }
    
    
    /**
* Created By: Shane Blazier
* Created Date: 9/18/2018
* Description: Creates Campaign Reservation Junction records depending on criteria that decides how and what values are
*         going to be rolled up to the Campaign that the Contact on the Reservation is a member of.
*/
    
    public static void createJunction(Map<Id,Reservation__c> reservationMap, List<CampaignMember> campaignMembers){
        Try{
        System.debug('Entering Create Junction');
        List<Id> contactIds = new List<Id>();
        List<String> promoCodes = new List<String>();
        for(Reservation__c reservation : reservationMap.values()){
            contactIds.add(reservation.Contact__c);
            promoCodes.add('%'+reservation.Promotional_Discount_Used__c+'%');
        }
        
        Set<Id> campaignIds = new Set<Id>();
        Map<Id,Set<Id>> conToCampMap = new Map<Id,Set<Id>>();
        Map<Id,List<CampaignMember>> campaignMemberMap = new Map<Id,List<CampaignMember>>();
        List<CampaignMember> cmList = new List<CampaignMember>();
        if(campaignMembers == null){
            cmList = [SELECT Id, CampaignId, ContactId, CreatedDate FROM CampaignMember WHERE ContactId IN :contactIds];
        }
        else{
            cmList = campaignMembers;
            promoCodes.clear();
        }
        
        for(CampaignMember cm : cmList){
            campaignIds.add(cm.CampaignId);
            if(conToCampMap.containsKey(cm.ContactId)){
                conToCampMap.get(cm.ContactId).add(cm.CampaignId);
            }
            else{
                conToCampMap.put(cm.ContactId,new Set<Id>{cm.CampaignId});
            }
            
            if(campaignMemberMap.containsKey(cm.ContactId)){
                List<CampaignMember> tmpList = campaignMemberMap.get(cm.ContactId);
                tmpList.add(cm);
                campaignMemberMap.put(cm.ContactId,tmpList);
            }
            else{
                campaignMemberMap.put(cm.ContactId,new List<CampaignMember>{cm});
            }
            
        }
        
        
        
        Map<String,Set<Id>> spIdMap = new Map<String,Set<Id>>();
        for(silverpop__Silverpop_Email_Activity__c spea : [SELECT Id, Silverpop_Id_8_Digit__c,silverpop__Contact__c
                                                           FROM silverpop__Silverpop_Email_Activity__c
                                                           WHERE silverpop__Contact__c IN :contactIds]){
                                                               
                                                               if(spIdMap.containsKey(spea.Silverpop_Id_8_Digit__c)){
                                                                   spIdMap.get(spea.Silverpop_Id_8_Digit__c).add(spea.silverpop__Contact__c);
                                                               }
                                                               else{
                                                                   spIdMap.put(spea.Silverpop_Id_8_Digit__c,new Set<Id>{spea.silverpop__Contact__c});
                                                               }
                                                           }
        
        
        List<String> promoFields = promoCodeFields();
        Map<Id,Set<Id>> conToCampEmailMap = new Map<Id,Set<Id>>();
        Map<String,List<Campaign>> promoToCampaignMap = new Map<String,List<Campaign>>();
        String query = 'SELECT Id, Book_From_Start_Date__c, Book_From_End_Date__c, Promo_Codes__c, ';
        for(String field : promoFields){
            query +=  field + ', ' ;
        }
        query += ' (SELECT Id, silverpop__Silverpop_id__c, silverpop__Sent_Date_Time__c, silverpop__Salesforce_Campaign__c'+
            ' FROM silverpop__Silverpop_Email_Campaign_Activities__r)'+
            ' FROM Campaign WHERE Id IN :campaignIds OR Promo_Codes__c LIKE :promoCodes';
        
        System.debug(query);
        System.debug(promoCodes);
        List<Campaign> camps = Database.query(query);
        
        
        Map<Id,Campaign> campaignMap = new Map<Id,Campaign>(camps);
        System.debug(campaignMap);
        for(Campaign c : campaignMap.values()){
            for(String field : promoFields){
                if(promoToCampaignMap.containsKey((String)c.get(field))){
                    promoToCampaignMap.get((String)c.get(field)).add(c);
                }else{
                    promoToCampaignMap.put((String)c.get(field),new List<Campaign>{c});
                }
            }
            
            
            
            for(silverpop__Silverpop_Email_Campaign_Activity__c speca : c.silverpop__Silverpop_Email_Campaign_Activities__r){
                if(spIdMap.containsKey(speca.silverpop__Silverpop_id__c)){
                    for(Id conId : spIdMap.get(speca.silverpop__Silverpop_id__c)){
                        if(conToCampEmailMap.containsKey(conId)){
                            conToCampEmailMap.get(conId).add(c.Id);
                        }
                        else{
                            conToCampEmailMap.put(conId,new Set<Id>{c.Id});
                        }
                    }
                }
            }
        }
        System.debug(promoToCampaignMap);
        
        CampaignMember tmpcm = new CampaignMember();
        List<Campaign_Reservation_Junction__c> juncToInsert = new List<Campaign_Reservation_Junction__c>();
        Date sentDate = System.today();
        for(Reservation__c reservation : reservationMap.values()){
            Boolean inPromoCampaign = false;
            if(reservation.Promotional_Discount_Used__c==null){
                inPromoCampaign = true;
            }
            
            if(conToCampMap.containsKey(reservation.Contact__c)){
                for(Id campId : conToCampMap.get(reservation.Contact__c)){
                    Campaign c = campaignMap.get(campId);
                    Map<String,Integer> promos = new Map<String,Integer>();
                    Integer count = 1;
                    for(String promo : c.Promo_Codes__c.split(',')){
                        promos.put(promo,count);
                        count++;
                    }
                    System.debug(promos);
                    
                    /*if(c.Promo_Code__c == reservation.Promotional_Discount_Used__c && c.Promo_Code__c != null) {
inPromoCampaign = true;
}*/
                    
                    sentDate = null;
                    if(conToCampEmailMap.containsKey(reservation.Contact__c)){
                        System.debug('>');
                        if(conToCampEmailMap.get(reservation.Contact__c).contains(c.Id) && c.silverpop__Silverpop_Email_Campaign_Activities__r.size() > 0){
                            System.debug('>>');
                            if(c.silverpop__Silverpop_Email_Campaign_Activities__r[0].silverpop__Sent_Date_Time__c!=null){
                                sentDate = c.silverpop__Silverpop_Email_Campaign_Activities__r[0].silverpop__Sent_Date_Time__c.date();
                            }
                            else{
                                sentDate = System.today();
                            }
                        }
                    }
                    if(campaignMemberMap.containsKey(reservation.Contact__c)){
                        for(CampaignMember cm : campaignMemberMap.get(reservation.Contact__c)){
                            if(c.Id == cm.CampaignId){
                                if(sentDate==null){
                                    sentDate = cm.CreatedDate.date();
                                }
                            }
                        }
                    }
                    
                    System.debug(sentDate);
                    System.debug(reservation.Contact__c);
                    System.debug((promos.containsKey(reservation.Promotional_Discount_Used__c)) + ' ' + (reservation.Promotional_Discount_Used__c != null) + ' ' + (reservation.Booked_Date__c >= c.Book_From_Start_Date__c) + ' ' +
                                 (reservation.Booked_Date__c <= c.Book_From_End_Date__c) + ' ' + (sentDate!=null) + ' ' + (sentDate<=reservation.Booked_Date__c));
                    
                    if(promos.containsKey(reservation.Promotional_Discount_Used__c) && reservation.Promotional_Discount_Used__c != null && reservation.Booked_Date__c >= c.Book_From_Start_Date__c &&
                       reservation.Booked_Date__c <= c.Book_From_End_Date__c && sentDate!=null && sentDate<=reservation.Booked_Date__c) {
                           
                           inPromoCampaign = true;
                           juncToInsert.add(new Campaign_Reservation_Junction__c(Campaign__c = c.Id, Reservation__c = reservation.Id, Promo_Code_Number__c = promos.get(reservation.Promotional_Discount_Used__c),
                                                                                 Revenue__c = reservation.Trans_Gross__c, Revenue_Type__c = 'Direct', Contact__c = reservation.Contact__c));
                           
                       }
                    
                    else if(sentDate!=null && reservation.Booked_Date__c >= sentDate && reservation.Booked_Date__c <= sentDate.addDays(2)){
                        juncToInsert.add(new Campaign_Reservation_Junction__c(Campaign__c = c.Id, Reservation__c = reservation.Id,
                                                                              Revenue__c = reservation.Trans_Gross__c, Revenue_Type__c = 'Indirect', Contact__c = reservation.Contact__c));
                    }
                }
            }
            System.debug((!inPromoCampaign) + ' ' + (promoToCampaignMap.containsKey(reservation.Promotional_Discount_Used__c)));
            if(!inPromoCampaign && promoToCampaignMap.containsKey(reservation.Promotional_Discount_Used__c)){
                for(Campaign c : promoToCampaignMap.get(reservation.Promotional_Discount_Used__c)){
                    Map<String,Integer> promos = new Map<String,Integer>();
                    Integer count = 1;
                    for(String promo : c.Promo_Codes__c.split(',')){
                        promos.put(promo,count);
                        count++;
                    }
                    System.debug(c);
                    if(reservation.Promotional_Discount_Used__c != null && reservation.Booked_Date__c >= c.Book_From_Start_Date__c && reservation.Booked_Date__c <= c.Book_From_End_Date__c) {
                        juncToInsert.add(new Campaign_Reservation_Junction__c(Campaign__c = c.Id, Reservation__c = reservation.Id, Promo_Code_Number__c = promos.get(reservation.Promotional_Discount_Used__c),
                                                                              Revenue__c = reservation.Trans_Gross__c, Revenue_Type__c = 'Promo', Contact__c = reservation.Contact__c));
                    }
                }
                
            }
        }
        if(!juncToInsert.isEmpty()){
            System.debug(juncToInsert);
            insert juncToInsert;
        }
        }catch(Exception e){
            System.debug('Current message');
        }
        
    }
    
    public static List<String> promoCodeFields(){
        Integer count = 1;
        Set<String> campFields = Schema.SObjectType.Campaign.fields.getMap().keySet();
        List<String> promoFields = new List<String>();
        System.debug('Promo_Code_'+count+'__c');
        System.debug(campFields);
        while(campFields.contains('promo_code_'+count+'__c')){
            
            promoFields.add('Promo_Code_'+count+'__c');
            count++;
        }
        return promoFields;
    }
}