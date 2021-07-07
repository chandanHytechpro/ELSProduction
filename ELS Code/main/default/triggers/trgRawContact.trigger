trigger trgRawContact on Raw_Contact__c (before insert, after update) {

  // Delete lead when it is processed and arrived from silverpop
    if(Trigger.IsUpdate){
    
    List<Lead> lstOfDelLead = new List<Lead>();
    Lead ilead;
    
        for (Raw_Contact__c rc: trigger.new){
        
            if(rc.Is_Processed__c == true && rc.Is_From_Silverpop__c == true && !String.IsBlank(rc.SF_Record_ID__c)){
                
                ilead = new Lead();
                ilead.Id = (Id)rc.SF_Record_ID__c;
                
                lstOfDelLead.add(ilead);
            }
        }

        if(lstOfDelLead.size() > 0){  
            try {
            	delete lstOfDelLead;
            } catch (Exception e) {}
        }
    }
  
  if(Trigger.IsInsert){

    //SourceUtil objSource = new SourceUtil(); 
    map<string, Sources__c> imapOfSources = new map<string, Sources__c>();
    map<string, String> imapOfActivities = new map<string, String>();
    set<string> setOfSourceIds = new set<string>();
    
    //imapOfSources = objSource.getSources();
    
    for (Raw_Contact__c rc: trigger.new){
        if (rc.Source__c !=null && rc.Source__c != ''){
            setOfSourceIds.add(rc.Source__c);
        }
    }
    List<Sources__c> newListSource=[Select ID, Source_ID__c, Source_Type__c,Sub_Type__c, Description__c, Create_Activities_and_Interests__c from Sources__c where Source_ID__c =: setOfSourceIds];
    for(Sources__c src : newListSource){     
            if(!String.IsBlank(src.Source_ID__c))
                imapOfSources.put(src.Source_ID__c.toLowerCase(), src); 
    }
    List<Create_Activities__c> newcreateActivity=[select Name from Create_Activities__c];
    for(Create_Activities__c act : newcreateActivity){
        imapOfActivities.put(act.Name.toLowerCase() , act.Name);
    }
    
    Sources__c objSrc;
    String RecordType;
    
    for(Raw_Contact__c r : trigger.new){
        
        objSrc = null; 
        
        if(r.Source__c != null && !String.IsBlank(r.Source__c )) objSrc = imapOfSources.get(r.Source__c.toLowerCase());
        
        system.debug('source::: '+r.Source__c);
        
        if(objSrc != null && String.IsBlank(r.Record_Type__c)){
            r.Record_Type__c = objSrc.Source_Type__c;
            RecordType = objSrc.Source_Type__c;      
        }else{
             RecordType = r.Record_Type__c; 
        }
        
      
        if(RecordType != null && !String.IsBlank(RecordType) ){
        
            if(imapOfActivities.ContainsKey(RecordType.toLowerCase())){

                // added by Nate Helterbrand, West Monroe Partners
                // adding logic to look at Source's Create_Activities_and_Interests field too
                if (objSrc.Create_Activities_and_Interests__c == true) {
                    r.Create_Activities_and_Interests__c = true; 
                } 
            }
        }
    }
    
  }
}