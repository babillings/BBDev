/*
Author Name : Scott Meidroth/Slalom
Date        : April 11, 2017
Description : controller for AB_UserPortalHome page
*/

/*Test class: AB_UserPortalTest*/

public with sharing class AB_UserPortalHomeController {

    public String UserInfoString{get;set;}
    private integer counter=0;  //keeps track of the offset
    private integer list_size=20; //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list
    public Set<String> wholesaler_numbers = new Set<String>();
    public Id nazUsrRecTypeId;
    public String sortFieldSave;
    public String queryContacts;
    
    public List<userPortalWrapper> wrapper{get;set;}

    public AB_UserPortalHomeController() {
      //get user's role
      String myRoleName;
      Id myRoleId = UserInfo.getUserRoleId();
      myRoleName = AB_UserPortalHelpers.getUserRoleName(myRoleId);
      if (!String.isBlank(myRoleName)){
        UserInfoString = myRoleName.Right(myRoleName.Length()-6);
        pattern myPattern = pattern.compile('\\b\\d{5}\\b');
        matcher myMatcher = myPattern.matcher(myRoleName);  
        while (myMatcher.find()) { 
          wholesaler_numbers.add(myMatcher.group());
        }
      }
    
      //get the NAZ User record type
      nazUsrRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('NAZ User').getRecordTypeId();
      //get the query tokens for page, sort field, sort direction
      String pn = ApexPages.currentPage().getParameters().get('pn');
      if(!String.isBlank(pn)){
        counter = Integer.valueOf(pn);
      }
      String sf = ApexPages.currentPage().getParameters().get('sf');
      if(!String.isblank(sf)){
        sortField=sf;
      }
      String sd = ApexPages.currentPage().getParameters().get('sd');
      if(!String.isBlank(sd)){
        sortDirection = sd;
      }

      //set the total size in the constructor
      total_size = [select count() from Contact WHERE RecordTypeId =: nazUsrRecTypeId AND Account.WSLR_NBR_US__c IN: wholesaler_numbers  ]; 
      buildQuery();
    }  
  
    //convert a Set<String> into a quoted, comma separated String literal for inclusion in a dynamic SOQL Query
    private String quoteKeySet(Set<String> mapKeySet)
    {
        String newSetStr = '' ;
        for(String str : mapKeySet)
            newSetStr += '\'' + str + '\',';

        newSetStr = newSetStr.lastIndexOf(',') > 0 ? '(' + newSetStr.substring(0,newSetStr.lastIndexOf(',')) + ')' : newSetStr ;
        return newSetStr;
    }
    
    public void buildQuery(){
      integer i = getContactQueryOffset(); 
      String wslrs = quoteKeySet(wholesaler_numbers);
      //Added  USERNAME__C to display login user name for user Femi Onakoya - Daugherty/1/4/2018
      queryContacts =   'SELECT Name, Account.Name,Account.WSLR_NBR_US__c , USERNAME__C, Email, ISACTIVE__c, GoSpotCheck_Access__c, ABIQ_Access__c, SRI_Access__c, ROUTEKEY__c, Role_Picklist__c, Rep_Type__c FROM Contact ';
      queryContacts += 'WHERE ';
      if(!String.isBlank(wslrs)){
        queryContacts +=  'Account.WSLR_NBR_US__c IN ' + wslrs + ' AND ';
      }
      queryContacts +=  'RecordTypeId = \'' + nazUsrRecTypeId + '\' ';
      queryContacts +=  'ORDER BY ' + sortField + ' ' + sortDirection + ' ';
      queryContacts +=  'LIMIT ' + list_size + ' ';
      queryContacts +=  'OFFSET ' + i;
    }
    
     public List<userPortalWrapper> getMyContactsWrapper() {
        
        if(wrapper==null){
          wrapper = new List<userPortalWrapper>();
          buildQuery();
          List<Contact> myContacts = Database.query(queryContacts);
            Set<String> usernames = new Set<String>();
            for(Contact con : myContacts){
                usernames.add(con.USERNAME__c);
            }          
          // SOQL to get the lastlogindate from User - Femi
          List<User> userlist = [Select Id,UserName, LastLoginDate from User where UserName IN: usernames];
          Map<String, User> conUserRecMap = new Map<String, User>();
            for(User u : userlist){
                conUserRecMap.put(u.UserName, u);
            }
            
          for (Contact c: myContacts){
            wrapper.add(new userPortalWrapper(c, conUserRecMap.get(c.USERNAME__c))); // passing the relevant user rec from conUserRecMap
          }
        }
        return wrapper;
      
    }

    public pageReference doNewContact(){
      PageReference pageRef = new PageReference('/apex/AB_UserPortalContact?pn=' + pageOffset + '&sf=' + sortField + '&sd=' + sortDirection);       
      return pageRef;
    }
       

    public pageReference doLogout(){
      PageReference pageRef = new PageReference('/secur/logout.jsp');            
      return pageRef;
    }
    // in order to switch to ABIQ app - Femi
    public pageReference doSwitch(){
      PageReference pageRef = new PageReference('/home/home.jsp?tsid=' + Label.ABIQ_APP_ID);            
      return pageRef;
    }
    
    // in order to Reset Password to ABIQ app - Femi
    public pageReference doResetPassword(){
        //to hold the selected contact usernames
        Set<String> selectedContacts = new Set<String>();
        //We will cycle through our list of cContacts and will check to see if the selected property is set to true, if it is we add the Contact to the selectedContacts list
        for(userPortalWrapper wCon: wrapper) {
            if(wCon.selected == true) {
                selectedContacts.add(wCon.con.USERNAME__c);
            }
        }
        
        // Fetch all the User records for the selected contacts
        List<User> userlist = [Select Id, IsActive from User where Username IN: selectedContacts];
        
        // Reseting the password for users
        for(User u: userlist) {
            if(u.IsActive){
                system.resetPassword(u.id, true);    
            }
        }

        wrapper=null; // we need this line if we performed a write operation  because getContacts gets a fresh list now

        return null;
    }
    private integer getContactQueryOffset(){
      return counter;
    }
    
   public PageReference Beginning() { //user clicked beginning
      counter = 0;
      wrapper = null;
      buildQuery();
      return null;
   }

   public PageReference Previous() { //user clicked previous button
      counter -= list_size;
      wrapper = null;
      buildQuery();
      return null;
   }

   public PageReference Next() { //user clicked next button
      counter += list_size;
      wrapper = null;
      buildQuery();
      return null;
   }

   public PageReference End() { //user clicked end
      counter = total_size - math.mod(total_size, list_size);
      wrapper = null;
      buildQuery();
      return null;
   }

   public Boolean getDisablePrevious() { //this will disable the previous and beginning buttons
      if (counter>0) return false; else return true;
   }

   public Boolean getDisableNext() { //this will disable the next and end buttons
      if (counter + list_size < total_size) return false; else return true;
   }

   public Integer getTotal_size() {
      return total_size;
   }

   public Integer getPageNumber() {
      return counter/list_size + 1;
   }

   public Integer getTotalPages() {
      if (math.mod(total_size, list_size) > 0) {
         return total_size/list_size + 1;
      } else {
         return (total_size/list_size);
      }
   }
    
    public Integer pageOffset{
        get{
            return getContactQueryOffset();
        }
        set;
    }
    
    
    //SortDirection - return sort direction. Default ascending(asc)
    public String sortDirection {
        get { if (SortDirection == null) {  SortDirection = 'asc'; } return SortDirection;  }
        set;
    }
    
    
    //SortField - return sort by field. Default to Name
    public String sortField {
        get { if (SortField == null) {SortField = 'Name'; } return SortField;  }
        set; 
    }
    
    
    //SortToggle - toggles the sorting of query from asc<-->desc
    public void sortToggle() {
        SortDirection = SortDirection.equals('asc') ? 'desc NULLS LAST' : 'asc';
        // reset sort sequence when sorted field is changed
        if (SortFieldSave != SortField) {
            SortDirection = 'asc';
            SortFieldSave = SortField;
        }
        // run the query again
        wrapper = null;
        buildQuery();
    }

    public class userPortalWrapper{
        public Contact con {get; set;}
        public Boolean selected {get; set;}
        
        // Added usr attribute to hold user rec information - femi
        public User usr {get; set;}
        
        // added extra parameter to hold user info - femi
        public userPortalWrapper(Contact c, User u) {
          selected = false;
          con = c;
          usr = u;
        }

    }

    public PageReference processSelected() {
     //We create a new list of Contacts that we be populated only with Contacts if they are selected
    List<Contact> selectedContacts = new List<Contact>();
    //We will cycle through our list of cContacts and will check to see if the selected property is set to true, if it is we add the Contact to the selectedContacts list
        for(userPortalWrapper wCon: wrapper) {
            if(wCon.selected == true) {
                selectedContacts.add(wCon.con);
            }
        }
        List<Contact> lstContactsToDelete = new List<Contact>();
        // Now we have our list of selected contacts and can perform any type of logic we want, sending emails, updating a field on the Contact, etc
        for(Contact con: selectedContacts) {
            lstContactsToDelete.add(con);
        }

        delete lstContactsToDelete;

        wrapper=null; // we need this line if we performed a write operation  because getContacts gets a fresh list now

        return null;

    }


    
    
        
        
}