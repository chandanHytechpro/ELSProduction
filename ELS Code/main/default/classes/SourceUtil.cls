/*
Name        : SourceUtil 
Author      : Mahwish Iqbal
Date        : 6-June-2015
Version     : 1.0
Description : This class contain functions related to source object
        
*/
public without sharing class SourceUtil {  
  
    list<Sources__c> lstOfSources;
    
    public map<string, Sources__c> mapOfSource;
    public map<string, Contact> mapOfContact;

        
    public SourceUtil(){
       
        lstOfSources = new List<Sources__c>();    // Initializing List
        mapOfSource = new map<string, Sources__c>();
        mapOfContact = new map<string, Contact>();  
    }
    
    
    public void getSourceList(List<Sources__c> pLstSrc){
    
        this.lstOfSources = pLstSrc;            // Set list of source records
        decimal iCounter = getSourceCounter();  // Get current max count
        setSourceCounter(iCounter);            // set count value to update Source Id        
    }
    
    
    decimal getSourceCounter(){
    
     decimal iCounter;
        
        /*Select max count*/ 
        for(AggregateResult ar : [select Max(Counter__c) counter from Sources__c]){     
           iCounter = (decimal) ar.get('counter');
        }  
    return iCounter;
    }

    public void setSourceCounter(decimal pCounter){
    
        if(pCounter == null) pCounter = 0;
        /*iterate over list of Source to set auto generated value to Source Id*/ 
        if(lstOfSources.size() > 0){
            for(Sources__c src :  lstOfSources){
                
                if(src.Source_ID__c == null) {          
                    pCounter ++;           
                   // src.Source_ID__c = 'SRC-'+FormatNumber(pCounter);          
                    src.Counter__c = pCounter ;   
                }
            }
        }  
    }
    
    
     public void getSourcesById(Set<string> pSetOfSourceID ){
		System.debug('Enter SourceUtil getContactSources');
       for(Sources__c src : [Select ID, Source_ID__c, Source_Type__c, Description__c from Sources__c where Source_ID__c in : pSetOfSourceID]){      
            mapOfSource.put(src.Source_ID__c.toLowerCase(), src);
           System.debug('mapOfSource'+mapOfSource.values());
        }
    }
    
    
    public void getContactSources(Set<string> pSetOfContactID){
		System.debug('Enter SourceUtil getContactSources');
      for(Contact con : [Select ID, Source_Description__c, Source_Add_Date__c,Add_Date__c,  Source_ID__c, Source_ID_2__c, Originating_Source__c from Contact where ID in : pSetOfContactID]){   
            mapOfContact.put(con.ID, con); 
          System.debug('mapOfContact'+mapOfContact.values());
        }
    }
    
    public map<string, Sources__c> getSources(){
    
       map<string, Sources__c>  mapOfAllSources = new map<string, Sources__c>();
         
       for(Sources__c src : [Select ID, Source_ID__c, Source_Type__c,Sub_Type__c, Description__c from Sources__c]){     
            if(!String.IsBlank(src.Source_ID__c))
                mapOfAllSources.put(src.Source_ID__c.toLowerCase(), src); 
        }
        
        return mapOfAllSources;
    }
    
     public map<string, Sources__c> getLowerCaseSources(){ 
    
       map<string, Sources__c>  mapOfAllSources = new map<string, Sources__c>();
         
       for(Sources__c src : [Select ID, Source_ID__c, Source_Type__c,Sub_Type__c, Description__c from Sources__c]){     
            if(!String.IsBlank(src.Source_ID__c))
                mapOfAllSources.put(src.Source_ID__c.toLowerCase(), src); 
        }
        
        return mapOfAllSources;
    }
   
}