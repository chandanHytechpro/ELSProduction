public with sharing class CampResJuncTriggerHandler {
    public static void afterInsert(Map<Id,Campaign_Reservation_Junction__c> newMap){
        List<Id> campaignIds = new List<Id>();
        for(Campaign_Reservation_Junction__c junc : newMap.values()){
            campaignIds.add(junc.Campaign__c);
        }

        Map<Id,Campaign> campaignMap = new Map<Id,Campaign>([SELECT Total_Conversions__c, Id FROM Campaign WHERE Id IN :campaignIds]);
        updateCampaign(campaignMap);
    }
    public static void afterDelete(Map<Id,Campaign_Reservation_Junction__c> oldMap){
        List<Id> campaignIds = new List<Id>();
        for(Campaign_Reservation_Junction__c junc : oldMap.values()){
            campaignIds.add(junc.Campaign__c);
        }

        Map<Id,Campaign> campaignMap = new Map<Id,Campaign>([SELECT Total_Conversions__c, Id FROM Campaign WHERE Id IN :campaignIds]);
        updateCampaign(campaignMap);
    }

    public static void updateCampaign(Map<Id,Campaign> campaignMap){
        AggregateResult[] arList = [SELECT COUNT_DISTINCT(Contact__c)amount, Campaign__c FROM Campaign_Reservation_Junction__c WHERE Campaign__c IN :campaignMap.keySet() AND Revenue_Type__c != 'Promo' GROUP BY Campaign__c];
        List<Campaign> campToUpdate = new List<Campaign>();
        Set<Id> campaignIds = new Set<Id>();

        for(AggregateResult ar : arList){
            System.debug(ar.get('amount'));
            campaignMap.get((Id)ar.get('Campaign__c')).Total_Conversions__c = (Decimal)ar.get('amount');
            campToUpdate.add(campaignMap.get((Id)ar.get('Campaign__c')));
            campaignIds.add((Id)ar.get('Campaign__c'));
        }

        for(Id cId : campaignMap.keySet()){
            if(!campaignIds.contains(cId)){
                campaignMap.get(cId).Total_Conversions__c = 0;
                campToUpdate.add(campaignMap.get(cId));
            }
        }
        System.debug(campToUpdate);

        update campToUpdate;
    }
}