/*
Class       : LogsUtil 
Author      : Mahwish Iqbal
Date        : 18-Dec-2013
Version     : 1.0
Description : 
*/
public without sharing class LogsUtil {  
    
    
    public string logDesc;
    public integer Inserted;
    public integer Updated;
    public integer errors;
    public integer success;
    public string source;
    
    /*******************************CONSTRUCTOR******************/
    public LogsUtil (){
          
        
     //   obj = new DedupUtil2(iObject );
      //  iListWrapperDedup = new List<WrapperDedup>(); 
      
    
    }//End of Constructor
    
   
    public void CreateLogs(){
        
        Log__c l = new Log__c();
        l.Error_Description__c = logDesc;
        l.No_Of_Error_Records__c = errors;
        l.No_Of_Inserted_Records__c = Inserted;
        l.No_Of_Processed_Records__c = success;
        l.No_Of_Updated_Records__c = updated;
        l.source__c = source;
        insert l;
    }
    
}