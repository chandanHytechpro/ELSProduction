/*
Name        : ELSProductTrg
Author      : Umer Aziz
Date        : 22/06/2015
Version     : 1.0
Description : 1) Update Contact Lookup on the basis of Client ID
*/
trigger ELSProductTrg on ELS_Product__c (Before insert, Before update, After Insert, After Update, After Delete) {
    
    List<ELS_Product__c> LstofElsProduct = new List<ELS_Product__c >();
    ClientIDUtil ObjClientId = new ClientIDUtil();
    map<Id, String>  mapOfRecordTypes = new map<Id, String>();
    
    set<Id> setContactsProduct = new set<Id>();
    
    
    ProductUtil ObjProd = new ProductUtil();
  
    for(RecordType recType : [SELECT Id, Name, SobjectType, DeveloperName FROM RecordType where SobjectType = 'ELS_Product__c']){       
        mapOfRecordTypes.put(recType.Id, recType.DeveloperName); 
    }
    
    if (!Trigger.isDelete) {
        for(ELS_Product__c  ElsProd : trigger.new){
            ObjClientId.SetofClientId.add(ElsProd.Client_ID__c);
            
            if(ElsProd.Source_ID__c == 'RCG' && trigger.isInsert){
                LstofElsProduct.add(ElsProd);
            }
            
            //creating set of discount camping products & free trial products count on contact
            if (Trigger.isAfter)
            {
                setContactsProduct.add(ElsProd.Contact__c);
            }        
        }   
    } else {
        for(ELS_Product__c  ElsProd : trigger.old){
            setContactsProduct.add(ElsProd.Contact__c);
        }        
    }
    
    /***********************Before Insert*********************/
    if( (Trigger.isBefore || trigger.isafter) && !Trigger.isDelete && (Trigger.isInsert || Trigger.isUpdate)){
        
        /*****Update Contact lookup on the basis of Client ID.*****/
        
        if( Trigger.isBefore ){
            ObjClientId.GetContactID();
            for(ELS_Product__c  ElsProd : trigger.new){
                if(ObjClientId.MapofMemberandClient.containskey(ElsProd.Client_ID__c)){
                    ElsProd.Contact__c = ObjClientId.MapofMemberandClient.get(ElsProd.Client_ID__c);
                } 
            }
        }
    
        /*************************** Update Sources ************************/ 
        // Update originating source on contact      
        if( Trigger.IsInsert && !Trigger.isDelete && Trigger.IsAfter ){
        
            Set<string> SetofContactID = new set<string>();
            Set<string> SetofSourceID = new set<string>();
            
            for(ELS_Product__c prod: trigger.new){
            
                if(prod.Contact__c != null && prod.Source_ID__c != null){
                    SetofContactID.add(prod.Contact__c);
                    SetofSourceID.add(prod.Source_ID__c.toLowerCase());
                    system.debug('$$$$$'+SetofContactID+'$$$$$$'+SetofSourceID);
                }
            }       
            ObjProd.UpdateContactSources(trigger.new, mapOfRecordTypes, SetofSourceID, SetofContactID);
        }
    }
    
    /***********************After Insert*********************/
    if(trigger.isafter && !Trigger.isDelete){
        if(LstofElsProduct.size() >0){
            ObjProd.updateRawContactELSProd(LstofElsProduct); 
        }
    }
    
    //updating discount camping products & free trial products count on contact
    if (setContactsProduct.size() > 0){
        AggregateResult[] groupedResults = [Select e.RecordTypeId, e.Contact__c, Count(e.Id) total From ELS_Product__c e
                                                Where e.Contact__c =: setContactsProduct 
                                                Group By e.RecordTypeId, e.Contact__c ];
        ObjProd.UpdateContactProductCount(groupedResults, mapOfRecordTypes, setContactsProduct);
    }
}