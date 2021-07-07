/*
Name        : SourcesTrg
Author      : Mahwish Iqbal
Date        : 6-June-2015
Version     : 1.0
Trigger     : Before insert
Description : Check if SourceId is blank then auto generate SourceId. 
    
*/
trigger SourcesTrg on Sources__c (before insert) {
    
    if(trigger.isBefore){
    
        List<Sources__c> lstOfSources = new List<Sources__c>();
        SourceUtil  iObjSrc= new SourceUtil();   
        iObjSrc.getSourceList(trigger.New);
    }     
}