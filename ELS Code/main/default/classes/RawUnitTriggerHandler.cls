public class RawUnitTriggerHandler {
    
    Set<String> setNames=new Set<String>();
    Map<String, RawUnit__c> mapNameRecord = new Map<String, RawUnit__c>();
    List<Unit__c> lstUnit=new List<Unit__c>();
    
    public void recordBeforeInsert(List<RawUnit__c> lstRaw){
        try{
            if(lstRaw.size() != null && lstRaw.size()>0){
                for(RawUnit__c objUnit:lstRaw){
                    setNames.add(objUnit.Name);
                    mapNameRecord.put(objUnit.Name, objUnit);
                }
            }
            
            Map<String, RawUnit__c> mapName=new Map<String, RawUnit__c>();
            List<Unit__c> lstUnit=new List<Unit__c>([select Id, Name, Is_Rental__c, Max_Length__c, Robot_ID__c, Site_Number__c, Site_Type__c, Unit_ID__c from Unit__c where Name IN : setNames]);
            
            if(lstUnit.size() != null && lstUnit.size()>0){
                for(Unit__c objC:lstUnit){
                    if(objC.Name==mapNameRecord.get(objC.Name).Name && objC.Is_Rental__c==mapNameRecord.get(objC.Is_Rental__c).Is_Rental__c && objC.Robot_ID__c==mapNameRecord.get(objC.Robot_ID__c).Robot_ID__c && objC.Site_Number__c==mapNameRecord.get(objC.Site_Number__c).Site_Number__c && objC.Site_Type__c==mapNameRecord.get(objC.Site_Type__c).Site_Type__c){
                        for(RawUnit__c obj:lstRaw){
                            obj.addError('You can not create RawUnit who is already exist to Unit');
                        }
                    }
                }
            }else{
                List<RawUnit__c>  lstRawU = new LIst<RawUnit__c>();            
                for(RawUnit__c objR:lstRaw){
                    Unit__c objUnit=new Unit__c();
                    objUnit.Name=objR.Name;
                    objUnit.Is_Rental__c=objR.Is_Rental__c;
                    objUnit.Max_Length__c=objR.Max_Length__c;
                    objUnit.Robot_ID__c=objR.Robot_ID__c;
                    objUnit.Site_Number__c=objR.Site_Number__c;
                    objUnit.Site_Type__c=objR.Site_Type__c;
                    //objUnit.Unit_ID__c=objR.Unit_ID__c;
                    lstUnit.add(objUnit);
                    lstRawU.add(objR);
                }            
                if(lstUnit.size() != null && lstUnit.size()>0){
                    insert lstUnit;
                    delete lstRawU;
                    System.debug('Created Unit__c' + ' ' + lstUnit);
                }
            }
        }
        catch(Exception e){
            System.debug('Exception ------'+e.getMessage());
        }
    }
}