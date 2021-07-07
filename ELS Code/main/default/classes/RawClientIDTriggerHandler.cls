public class RawClientIDTriggerHandler {
    /*Set<String> setNames=new Set<String>();
    Map<String, Raw_Client__c> mapNameRecord=new Map<String, Raw_Client__c>();
    List<ClientID__c> lstClientID=new List<ClientID__c>();
    public void beforeInsert(List<Raw_Client__c> lstRaw){
        if(lstRaw.size() != null && lstRaw.size()>0){
            for(Raw_Client__c objR:lstRaw){
                setNames.add(objR.Name);
                mapNameRecord.put(objR.Name, objR);
            }
        }
        
        Map<String, ClientID__c> mapNameClientID=new Map<String, ClientID__c>();
        List<ClientID__c> lstClient=new List<ClientID__c>([select Id, Name, FirstName__c, LastName__c, Address_1__c, Address_2__c, Email__c, Phone__c, MailingCity__c, MailingPostalCode__c from ClientID__c where Name in : setNames]);
        
        if(lstClient.size() != null && lstClient.size()>0){
            for(ClientID__c objC:lstClient){
                if(objC.FirstName__c==mapNameRecord.get(objC.Name).First_Name__c && objC.LastName__c==mapNameRecord.get(objC.Name).Last_Name__c && objC.Email__c==mapNameRecord.get(objC.Name).Email__c && objC.Phone__c==mapNameRecord.get(objC.Name).Phone__c){
                    for(Raw_Client__c obj:lstRaw){
                        obj.addError('You can not create RawClientID that already exists inthe ClientID');
                    }
                }
            }
        }else{
            for(Raw_Client__c objRaw:lstRaw){
                ClientID__c objClientID=new ClientID__c();
                System.debug('Create ClientId');
                objClientID.Name=objRaw.Name;
                objClientID.FirstName__c=objRaw.First_Name__c;
                objClientID.LastName__c=objRaw.Last_Name__c;
                objClientID.Address_1__c=objRaw.Address1__c;
                objClientID.Address_2__c=objRaw.Address2__c;
                objClientID.Email__c=objRaw.Email__c;
                objClientID.MailingCity__c=objRaw.City__c;
                objClientID.Phone__c=objRaw.Phone__c;
                objClientID.Client_Type__c=objRaw.CLIENTTYPELABEL__c;
                objClientID.MailingPostalCode__c=objRaw.Postal_Code__c;
                objClientID.CAMPUSAPROFILE__c=objRaw.CAMPUSAPROFILE__c;
                objClientID.RVOT__c=objRaw.RVOTGPROFILE__c;
                
                lstClientID.add(objClientID);
            }
            try{
                if(lstClientID.size() != null && lstClientID.size()>0){
                    insert lstClientID;
                    System.debug('Created ClientId' + ' ' + lstClientID);
                }
            }catch(Exception e){
                System.debug('Exception ----------->'+e.getMessage());
            }
        }
    }*/
}