/** Class to store Constants that are used throughout code base
* West Monroe Partners. September 2016
*/public with sharing class Constants {
	
	public static GlobalSettings__c globalSettings {get {
		if(globalSettings == null) {
			globalSettings = GlobalSettings__c.getInstance();
		}

		return globalSettings;
	}set;}

	public static Id ELSProductDiscountCampingRTId {get {

		if(ELSProductDiscountCampingRTId == null) {
			ELSProductDiscountCampingRTId = Schema.SObjectType.ELS_Product__c.getRecordTypeInfosByName().get('Discount Camping').getRecordTypeId();
		}

		return ELSProductDiscountCampingRTId;
	}set;}

	public static Id ELSProductReadyCampGoRTId {get {
		if(ELSProductReadyCampGoRTId == null) {
			ELSProductReadyCampGoRTId = Schema.SObjectType.ELS_Product__c.getRecordTypeInfosByName().get('Ready Camp Go').getRecordTypeId();
		}
		return ELSProductReadyCampGoRTId;
	}set;}

	public static Id ContactCustomerContactRTId {get {
		if(ContactCustomerContactRTId == null) {
			ContactCustomerContactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
		}
		return ContactCustomerContactRTId;
	}set;}

	public static Id ContactPropertyContactRTId {get {
		if(ContactPropertyContactRTId == null) {
			ContactPropertyContactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Property Contact').getRecordTypeId();
		}
		return ContactPropertyContactRTId;
	}set;}

	public static Id OpportunityRVDealerSalesRTId {get {
		if(OpportunityRVDealerSalesRTId == null) {
			OpportunityRVDealerSalesRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('RV Dealer Sales').getRecordTypeId();
		}
		return OpportunityRVDealerSalesRTId;
	}set;}

	public static final Integer LazyDaysNightsInactiveThreshold = 14;
	public static final String ELSProductStatusInactive = 'Inactive';

	public static final String ReservationStatusActive = 'Active';
	public static final String ReservationStatusCancelled = 'Cancelled';
}