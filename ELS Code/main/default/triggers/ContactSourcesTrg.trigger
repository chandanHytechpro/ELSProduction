/*
Name        : ContactSourcesTrg
Author      : Muhammad Asif
Date        : 06/08/2015
Version     : 1.0
Description : 1) Rollup count of tradeshow at contact level
*/
trigger ContactSourcesTrg on Contact_Sources__c (before insert, before update, after delete, after insert, after update) {
    
    set<Id> setContacts = new set<Id>();
    set<Id> setSources = new set<Id>();
      
    if (trigger.isBefore){
        Map<Id, Sources__c> mapSources = new Map<Id, Sources__c> ([Select s.Source_Type__c, s.Id From Sources__c s WHERE s.Source_Type__c ='Tradeshow']);
        
        for(Contact_Sources__c contactSource : trigger.new){
            if (contactSource.Sources_ID__c != null && 
            		mapSources.containsKey(contactSource.Sources_ID__c)){
                contactSource.Tradeshow__c = true;
            } else {
                contactSource.Tradeshow__c = false;
            }       
        }
        
    } else {
        ProductUtil ObjProd = new ProductUtil();
        
        if (!Trigger.isDelete) {
            for(Contact_Sources__c contactSource : trigger.new){
                if (contactSource.Contact_Id__c != null){
                	setContacts.add(contactSource.Contact_Id__c);
                }
            }   
        } else {
            for(Contact_Sources__c  contactSource : trigger.old){
            	if (contactSource.Contact_Id__c != null){
                	setContacts.add(contactSource.Contact_Id__c);
            	}
            }        
        }
        
        //updating tradeshow count on contact
        if (setContacts.size() > 0){
            AggregateResult[] groupedResults = [Select Count(c.Id) total, c.Contact_Id__c , c.Tradeshow__c From Contact_Sources__c c
                                                        Where 
                                                            c.Add_Date__c = LAST_N_DAYS:365 AND c.Contact_Id__c =:setContacts 
                                                        Group By
                                                        c.Tradeshow__c, c.Contact_Id__c];
            ObjProd.UpdateContactTradeshowCount(groupedResults, setContacts);
        }       
    }
}