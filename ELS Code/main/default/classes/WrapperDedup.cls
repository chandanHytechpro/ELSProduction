/*
Class       : WrapperDedup
Author      : Mahwish Iqbal
Date        : 18-June-2015
Version     : 1.0
Description : This class is used to covert object values in wrapper type.
*/
public class WrapperDedup{

    public id ID { get; set; }
    public string Email { get; set; }
    public string Flas { get; set; }
    public string Laz { get; set; }
    public string Pl { get; set; }
    public string Pf { get; set; }
    
    public string Email2 { get; set; }
    public string Flas2 { get; set; }
    public string Laz2 { get; set; }
    public string Pl2 { get; set; }
    public string Pf2 { get; set; }
    
    public string FirstName { get; set;}
    public string LastName {get; set;}
    public id ContactID {get; set;}
    public string MailingCity {get; set;}
    public string MailingCountry {get; set;}
    public string MailingPostalCode {get; set;}
    public string MailingState {get; set;}
    public string MailingStreet {get; set;}
    
    public string OtherCity {get; set;}
    public string OtherCountry {get; set;}
    public string OtherPostalCode {get; set;}
    public string OtherState {get; set;}
    public string OtherStreet {get; set;}
    
    public string Phone {get; set;}
    public string ClientType {get; set;}
    public Date AddDate {get; set;}
    public string CampusProfile {get; set;}
    public string RVOT {get; set;}
    public string SfSourceType {get; set;}
    public string SfSourceId {get; set;}
     
    public string RawContactID {get ;set;}
    
    public string Subid {get; set;}
    public string VendorName {get; set;}
    public string VendorSubGroup {get; set;}
    public string IPAddress {get; set;}
    public string Source {get; set;}
    public string AccountName {get; set;}
    public string Age {get; set;}
    public string Gender {get; set;}
    public boolean FromSilverpop {get; set;}
    public string country3 {get; set;}
    public boolean generalOptIn {get; set;}
    public boolean canadaOptIn {get; set;}
    public string state3 {get; set;}
    public boolean frenchOptIn {get; set;}
    public boolean smsOptIn {get; set;}
    public boolean spanishOptIn {get; set;}
    public String mobile {get; set;}
    public String langPref {get;set;}
	public boolean frenchSMSOptIn {get;set;}
    public boolean spanishSMSOptIn {get;set;}
    public WrapperDedup() {
    	
    }

    // Constructor to set ClientId values
    public WrapperDedup(id pID, string pEmail, string pFlas, string pLaz, string pPl, string pPf, string pFirstName, string pLastName, string pCity, string pPostalCode, string pState, string pStreet1, string pStreet2, string pPhone, id pContactID, string pCampusProfile, string pClientType, string pRvot, Date pAddDate, string pSfSourceType ){
        
        this.ID = pID;
        this.Email = pEmail;
        this.Flas = pFlas;
        this.Laz = pLaz;
        this.Pl = pPl;
        this.Pf = pPf;
        this.FirstName = pFirstName;
        this.LastName = pLastName;
        this.MailingCity = pCity;
        this.MailingPostalCode = pPostalCode;
        this.MailingState = pState;
        
        if(pStreet1 ==null) pStreet1 ='';
        if(pStreet2 ==null)  pStreet2 ='';
        
        if(pStreet2 != '' && pStreet1 != ''){
          this.MailingStreet = pStreet1 +' '+pStreet2;
        }
        else if (pStreet1 != '' && pStreet2 =='' ){
            this.MailingStreet = pStreet1;
        }
        else if(pStreet2 != '' && pStreet1 == ''){        
             this.MailingStreet = pStreet2;
        }
       
        this.Phone = pPhone;
        this.ClientType = pClientType;
        this.AddDate = pAddDate;
        this.CampusProfile = pCampusProfile;
        this.RVOT = pRvot;
        this.SfSourceType = pSfSourceType;
        this.ContactID = pContactID;
    }
    
    // Constructor to set RawContact values
    public WrapperDedup( ID pRawContactid,string pEmail, string pFlas, string pLaz, string pPl, string pPf, string pFirstName, string pLastName, string pCity, string pPostalCode, string pState, string pStreet1, string pStreet2, string pCountry ,string pPhone, string pCampusProfile, string pOrgSrc, Date pAddDate, string pSfSourceType, string pSfSourceId, String pSubid, String pVendorName, String pVendorSubGroup, String pIPAddress, String pSource, String pAccountName, String pAge, String pGender, Boolean pFromSilverpop, String pcountry3, Boolean pgeneralOptIn, Boolean pcanadaOptIn){
          
        this.id = pRawContactid;             
        this.Email = pEmail;
        this.Flas = pFlas;
        this.Laz = pLaz;
        this.Pl = pPl;
        this.Pf = pPf;
        this.FirstName = pFirstName;
        this.LastName = pLastName;
        this.MailingCity = pCity;
        this.MailingPostalCode = pPostalCode;
        this.MailingState = pState;
      
        if(pStreet1 ==null) pStreet1 ='';
        if(pStreet2 ==null)  pStreet2 ='';
        
        if(pStreet2 != '' && pStreet1 != ''){
          this.MailingStreet = pStreet1 +' '+pStreet2;
        }
        else if (pStreet1 != '' && pStreet2 =='' ){
            this.MailingStreet = pStreet1;
        }
        else if(pStreet2 != '' && pStreet1 == ''){        
             this.MailingStreet = pStreet2;
        }
        
        this.Phone = pPhone;
        this.AddDate = pAddDate;
        this.CampusProfile = pCampusProfile;
        this.SfSourceType = pSfSourceType;
        this.SfSourceId = pSfSourceId;
        
        this.Subid = pSubid;
        this.VendorName = pVendorName;
        this.VendorSubGroup = pVendorSubGroup;
        this.IPAddress = pIPAddress;
        if(pSource != null )  this.Source = pSource.toLowerCase();
        this.AccountName = pAccountName; 
        this.Age = pAge;
        this.Gender = pGender;
        this.FromSilverpop = pFromSilverpop;
        this.country3 = pcountry3;
        this.generalOptIn = pgeneralOptIn;
        this.canadaOptIn = pcanadaOptIn;

    }
}