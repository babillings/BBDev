/*
    Author Name : Femi
    Date        : July 5, 2018
    Description : controller for AB_UserPortalHome page
*/


public class AB_UserPortalHomeController_v1 
{

    public String UserInfoString{get;set;}
    public String UserIdString{get;set;}
    private integer counter=0;  //keeps track of the offset
    private integer list_size= Integer.valueOf(label.UserPortalPageSize); //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list
    public integer activeUsers_size {get;set;}
    public Set<String> wholesaler_numbers = new Set<String>();
    public Id nazUsrRecTypeId;
    public String sortFieldSave;
    public String queryUsers;
    public String userType {get;set;}
    public String nameVal {get;set;}
    public Boolean isSearch {get;set;}
    private Boolean updateLolaAccess;   
    
    //Femi: July19 - Added below lines by Femi
    //public String whslrNum;
    List<Wholesaler_App_Config__c> appConfigs;
    
    public List<userPortalWrapper> wrapper{get;set;}
    
    //Telesales variables Added in July 19 - Femi
    public Set<Id> set_RelatedRoleIds;
    public User currentUser;
    public boolean inContactAccess{get;set;}
    public boolean liveMsgAccess{get;set;}

    public AB_UserPortalHomeController_v1() 
    {
      //get user's role
      wrapper = new List<userPortalWrapper>(); 
      updateLolaAccess = getUpdateLolaAccess();
      UserIdString =UserInfo.getUserId();
      isSearch = false;
      String myRoleName;
      Id myRoleId = UserInfo.getUserRoleId();
        currentUser = [SELECT Id,Profile.Name,UserRoleId,Wholesaler_Number__c,RouteKey__c,WSLRNbrRouteNbr__c FROM User WHERE Id =: UserInfo.getUserId()];
        system.debug('ROLE ID: '+myRoleId);
        myRoleName = AB_UserPortalHelpers.getUserRoleName(myRoleId);
        //Femi: July19 - STARTS
        //if (myRoleName!=null){
        //if (currentUser.Profile.Name != null){
            //userType = myRoleName.left(3); 

            if(currentUser.Profile.Name.left(9).toLowerCase() == 'telesales')
            {
                userType = 'Telesales';
            }
            else if(currentUser.Profile.Name.left(3).toLowerCase() == 'wod')
            {
                userType = 'WOD';
            }
            else if(currentUser.Profile.Name.left(3).toLowerCase() == 'ind')
            {
                userType = 'IND';
            }
            else if(currentUser.Profile.Name.right(3).toLowerCase() == 'fsl')
            {
                userType = 'FSL';
            }

            /*List<String> strs =  myRoleName.split('-');  
            if(strs != null &&  strs.size() == 3) { 
                whslrNum = strs[2].trim();    
                if(String.isNotBlank(whslrNum)) {
                    appConfigs = new List<Wholesaler_App_Config__c>(
                        [select Name from Wholesaler_App_Config__c where Name =: whslrNum]
                    );                    
                } 
            }*/   
        //}
        //Femi: July19 - ENDS      
      
      if (!String.isBlank(myRoleName))
      {
        //UserInfoString = myRoleName.Right(myRoleName.Length()-6);
        UserInfostring = myRoleName;
        pattern myPattern = pattern.compile('\\b\\d{5}\\b');
        matcher myMatcher = myPattern.matcher(myRoleName); 
        while (myMatcher.find()) 
        { 
          wholesaler_numbers.add(myMatcher.group());
        }
      }
    
      //get the query tokens for page, sort field, sort direction
      String pn = ApexPages.currentPage().getParameters().get('pn');
      if(!String.isBlank(pn))
      {
        counter = Integer.valueOf(pn);
      }
      String sf = ApexPages.currentPage().getParameters().get('sf');
      if(!String.isblank(sf))
      {
        sortField=sf;
      }
      String sd = ApexPages.currentPage().getParameters().get('sd');
      if(!String.isBlank(sd))
      {
        sortDirection = sd;
      }
      //resetCount();
            
        set_RelatedRoleIds = new Set<Id>();
        if(currentUser.Profile.Name.left(9).toLowerCase() == 'telesales'&& currentUser.UserRoleId != Null)
        {
            //To get only direct childs
            /*for(UserRole role : [SELECT Id,Name,ParentRoleId FROM UserRole WHERE ParentRoleId =: currentUser.UserRoleId])
            {
                set_RelatedRoleIds.add(role.Id);
            }*/     
            set_RelatedRoleIds = getAllSubRoleIds(new Set<Id>{currentUser.UserRoleId}); // To get all related child heairarchy
        }
      buildQuery();
    } 
    
    //To get all subrole heirarchy - Added as part of Telesales : Femi
    static Set<ID> getAllSubRoleIds(Set<ID> roleIds) 
    {
        Set<ID> currentRoleIds = new Set<ID>();

        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id, Name from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null]) 
        {
            currentRoleIds.add(userRole.Id);
        }

        // go fetch some more roles!
        if(!currentRoleIds.isEmpty()) 
        {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        return currentRoleIds;
    }    
    /*public void resetCount() {
        //set the total size in the constructor
          List<AggregateResult> aggrResult;
          if(String.isNotBlank(nameVal)) {
              String lkStr = '\'%'+nameVal+'%\'';
              aggrResult = [select count(id), isActive from User 
              WHERE Profile.Name like: userType+'%' AND Wholesaler_Number__c IN: wholesaler_numbers AND Title != 'Owner' and 
              Name like: lkStr group by isActive]; 
          }
          else
              aggrResult = [select count(id), isActive from User 
          WHERE Profile.Name like: userType+'%' AND Wholesaler_Number__c IN: wholesaler_numbers AND Title != 'Owner' group by isActive];
          system.debug('aggrResult'+aggrResult);
          total_size = 0;
          for(AggregateResult ar : aggrResult) {
              Boolean isTrue = (Boolean)ar.get('isActive');
              Integer count = (Integer)ar.get('expr0');
              if(isTrue) {
                  activeUsers_size = count;
              }
              system.debug('count: '+count);
              total_size += count;              
          }
          system.debug('total_size: '+total_size);
    }*/
  
    //convert a Set<String> into a quoted, comma separated String literal for inclusion in a dynamic SOQL Query
    private String quoteKeySet(Set<String> mapKeySet)
    {
        String newSetStr = '' ;
        for(String str : mapKeySet)
            newSetStr += '\'' + str + '\',';

        newSetStr = newSetStr.lastIndexOf(',') > 0 ? '(' + newSetStr.substring(0,newSetStr.lastIndexOf(',')) + ')' : newSetStr ;
        return newSetStr;
    }
    
    public void buildQuery()
    {
      integer i = getUserQueryOffset(); 
      String wslrs = quoteKeySet(wholesaler_numbers);
      //Added  USERNAME__C to display login user name for user Femi Onakoya - Daugherty/1/4/2018
      //RA 10/4/2018 - Update for GSC Package
      //Femi: July19 - Modified below line
      queryUsers =   'SELECT Name, Username, Email, isActive, Title, gsc_mc__Sync_to_GoSpotCheck__c, LOLA_Access__c,BigTinCan_Access__c, SRI_Access__c,PCR_Access__c, ROUTEKEY__c, LastLoginDate, Employee_Number_US__c, WSLRNbrRouteNbr__c,InContact_Access__c,LiveMessage_Access__c FROM User ';      

      queryUsers += 'WHERE ';

        if(userType == 'Telesales')
        {
            String profileNam = '\'%'+currentUser.Profile.Name.left(9)+'%\'';
            //String profileNam = '\'%wod%\'';
            queryUsers += ' UserRoleId IN: set_RelatedRoleIds AND Profile.Name LIKE '+profileNam;
            if(String.isNotBlank(nameVal)) 
            {
                String lkStr = '\'%'+nameVal+'%\'';
                queryUsers +=  ' AND Name like '+lkStr;
            }
        }
        else if(userType == 'FSL')
        {
            if(userType == 'FSL') queryUsers += '('; // To also include/show ABI users that are associated to WOD
            queryUsers += 'Profile.Name like '+'\''+'ABI'+'%'+'\')';
            queryUsers +=  ' AND Title != \'Owner\'';      

            if(String.isNotBlank(wslrs))
            {
                queryUsers +=  ' AND Wholesaler_Number__c IN ' + wslrs;
            }
        }

        else
        {
            //Femi - Added below line to include ABI
            if(userType == 'WOD') queryUsers += '('; // To also include/show ABI users that are associated to WOD
            queryUsers += 'Profile.Name like '+'\''+userType+'%'+'\'';
            //Femi - Added below line to include ABI
            if(userType == 'WOD') queryUsers += ' OR Profile.Name like '+'\''+'ABI'+'%'+'\')'; // / To also include/show ABI users that are associated to WOD
            queryUsers +=  ' AND Title != \'Owner\'';      
            /*if(userType == 'Merchandiser') queryUsers += '('; // To also include/show ABI users that are associated to WOD
            queryUsers += 'Profile.Name like '+'\''+userType+'%'+'\'';
            if(userType == 'Merchandiser') queryUsers += ' OR Profile.Name like '+'\''+'ABI'+'%'+'\')'; // / To also include/show ABI users that are associated to WOD
            queryUsers +=  ' AND Title != \'Owner\'';      
            if(userType == 'Merchandiser') queryUsers += '(';
            queryUsers += 'Profile.Name like '+'\''+'FSL'+'%'+'\''; // / To also include/show ABI users that are associated to WOD
            queryUsers +=  ' AND Title != \'Owner\'';      
            system.debug('***wslrs: '+wslrs);*/
            if(String.isNotBlank(wslrs))
            {
                queryUsers +=  ' AND Wholesaler_Number__c IN ' + wslrs;
            }
        }
      if(String.isNotBlank(nameVal)) 
      {
          String lkStr = '\'%'+nameVal+'%\'';
          queryUsers +=  ' AND Name like '+lkStr;
      }
      //queryUsers +=  'RecordTypeId = \'' + nazUsrRecTypeId + '\' ';
      total_size = Database.query(queryUsers).size();
      activeUsers_size = Database.query(queryUsers  + ' AND isActive = true').size();
      
      if(userType != 'FSL')
      {
                queryUsers +=  'ORDER BY ' + sortField + ' ' + sortDirection + ' ';

      }
      queryUsers +=  'LIMIT ' + list_size + ' ';
      queryUsers +=  'OFFSET ' + i;
    }



     public List<userPortalWrapper> getMyUsersWrapper() 
    {
        //if(wrapper==null || String.isNotBlank(nameVal)){
          wrapper = new List<userPortalWrapper>();
          buildQuery();
          system.debug('query:*** '+queryUsers);
          List<User> myUsers = Database.query(queryUsers);
          List<FSL__User_Territory__c> myUserTerr = new List<FSL__User_Territory__c>([SELECT FSL__Territory_Name__c, FSL__User__c,Id FROM FSL__User_Territory__c]);

            Map<string, string> MapTerritory = new Map<string, string>();
            for (FSL__User_Territory__c terr : myUserTerr) {
                MapTerritory.put(terr.FSL__User__c, terr.FSL__Territory_Name__c);
            }

            for (User u : myUsers){
                String key =  u.Id;
                string territory = '';
                if(MapTerritory.containsKey(key)){
                    territory = MapTerritory.get(key);
                }
                wrapper.add(new userPortalWrapper(u, territory));
            }

            // Set<String> usernames = new Set<String>();
            // for(User u : myUsers)
            // {
            //     // if(userType == 'FSL')
            //     // {                                
            //         for(FSL__User_Territory__c ut: myUserTerr)
            //         {
            //             if(u.Id == ut.FSL__User__c)
            //             {
            //                 //usernames.add(u.username);
            //                 //wrapper.add(new userPortalWrapper(u, ut));
            //                 wrapper.add(new userPortalWrapper(u, ut.Id));
            //             }
            //         }
            //     // }
            //     else 
            //     {
            //         wrapper.add(new userPortalWrapper(u, ''));
            //     }
            //     //usernames.add(u.username);
            //     //match uid to utid
            //     //add below add to the
            // }
        return wrapper;
    }

    public pageReference doNewUser()
    {
      PageReference pageRef = new PageReference('/apex/AB_UserPortalContact?pn=' + pageOffset + '&sf=' + sortField + '&sd=' + sortDirection);       
      return pageRef;
    }
       

    public pageReference doLogout()
    {
      PageReference pageRef = new PageReference('/secur/logout.jsp');            
      return pageRef;
    }
    // in order to switch to ABIQ app - Femi
    public pageReference doSwitch()
    {
      PageReference pageRef = new PageReference('/home/home.jsp?tsid=' + Label.ABIQ_APP_ID);            
      return pageRef;
    }
    
    // in order to Reset Password to ABIQ app - Femi
    public pageReference doResetPassword()
    {
        //We will cycle through our list of cUsers and will check to see if the selected property is set to true, if it is we add the user to the selectedUsers list
        for(userPortalWrapper wUsr: wrapper) 
        {
            if(wUsr.selected == true) 
            {
                if(wUsr.usr.IsActive) 
                {
                    system.resetPassword(wUsr.usr.id, true);    
                }
            }
        }

        wrapper=null; // we need this line if we performed a write operation  because getContacts gets a fresh list now

        return null;
    }
    private integer getUserQueryOffset()
    {
      return counter;
    }
    
   public PageReference Beginning() 
   { //user clicked beginning
      counter = 0;
      wrapper = null;
      buildQuery();
      return null;
   }

   public PageReference Previous() 
   { //user clicked previous button
      counter -= list_size;
      wrapper = null;
      buildQuery();
      return null;
   }

   public PageReference Next() 
   { //user clicked next button
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
            return getUserQueryOffset();
        }
        set;
    }
    
    
    //SortDirection - return sort direction. Default ascending(asc)
    public String sortDirection {
        get { if (SortDirection == null) {  SortDirection = 'desc'; } return SortDirection;  }
        set;
    }
    
    
    //SortField - return sort by field. Default to Name
    public String sortField 
    {
        get 
        { 
            if (SortField == null) 
            {
                SortField = 'isActive'; 
            } 
        return SortField;  
        }
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
        //public Contact con {get; set;}
        public Boolean selected {get; set;}
        
        // Added usr attribute to hold user rec information - femi
        public User usr {get; set;}
        public String usrTerr {get; set;}
        //set territory, pass in Ut along with user
        
        // added extra parameter to hold user info - femi
        public userPortalWrapper(User u, String uTerrId)
        {
            selected = false;
            //con = c;
            usr = u;
            usrterr = uTerrId;
            /*List<FSL__User_Territory__c> userUT= new List<FSL__User_Territory__c> ([SELECT FSL__Territory_Name__c FROM FSL__User_Territory__c WHERE Id =: uTerrId]);
            if(userUT != null && userUT.size()>0)
            {
                usrTerr = userUT[0].FSL__Territory_Name__c;
            }*/
        }

    }
    public PageReference processSelected() {
        //We create a new list of Contacts that we be populated only with users if they are selected
        List<User> selectedUsers = new List<User>();
        //We will cycle through our list of users and will check to see if the selected property is set to true, if it is we add the User to the selectedUsers list
        for(userPortalWrapper wUsr: wrapper) {
            if(wUsr.selected == true) {
                selectedUsers.add(wUsr.usr);
            }
       }
        List<User> lstUsersToDelete = new List<User>();
        // Now we have our list of selected users and can perform any type of logic we want, sending emails, updating a field on the User, etc
        for(User usr: selectedUsers) {
            usr.isActive = false;
            if(currentUser.Profile.Name.left(9).toLowerCase() == 'telesales') {
                usr.RouteKey__c = null;
                usr.WSLRNbrRouteNbr__c = null;
                usr.InContact_Access__c = false;
                usr.LiveMessage_Access__c = false;
            }   
            
            lstUsersToDelete.add(usr);
        }

        update lstUsersToDelete;
        //Femi - July19 - To remove users from the Permission Set - STARTS
        //Note: Remove the users from all the permission sets.
        List<PermissionSetAssignment> pSetAssignmentsLst = [SELECT Id from PermissionSetAssignment 
        WHERE AssigneeId in : lstUsersToDelete AND 
        PermissionSetId IN (SELECT Id FROM PermissionSet WHERE IsOwnedByProfile =false)];
        
        if(pSetAssignmentsLst != null && pSetAssignmentsLst.size() > 0) {
            delete pSetAssignmentsLst;
        }
        List<PermissionSetLicenseAssign> pSetAssignmentsLicLst = [SELECT Id from PermissionSetLicenseAssign 
        WHERE AssigneeId in : lstUsersToDelete];
        
        if(pSetAssignmentsLicLst != null && pSetAssignmentsLicLst.size() > 0) {
            delete pSetAssignmentsLicLst;
        }
        //Femi - July19 - To remove users from the Permission Set - ENDS

        wrapper=null; // we need this line if we performed a write operation  because getContacts gets a fresh list now

        return null;

    }  
    
    public Boolean getUpdateLolaAccess(){
        List<Wholesaler_Lola_Access__c> ws = [SELECT Wholesaler_Number__c FROM Wholesaler_Lola_Access__c WHERE Wholesaler_Number__c = :getWholsalerNumber() limit 1];
        Boolean ret = false;
        if (!ws.isEmpty()){
            ret = true;
        }
        return ret;
    }   
   //Femi Onakoya: To display BTC access on the userportal page. July 2019
    public Boolean getHasBTCAccess() {
        Boolean isTrue = false;
        String whslrNum = getWholsalerNumber(); // the wholesaler number on the user record is been assigned.
        if(String.isNotBlank(whslrNum)) {
         //querying from the app object if the logged in users wslnumber is not blank.
            List<Wholesaler_App_Config__c> appConfigs = new List<Wholesaler_App_Config__c>(
                [select Name from Wholesaler_App_Config__c where Name =: whslrNum and Application_Name__c = 'BigTinCan']
            );
            if(appConfigs.size() > 0) {
                isTrue = true;
            }
        }
        return isTrue;
    }
    public String getWholsalerNumber(){
        User sn = [select Wholesaler_Number__c from user where id =  :UserInfo.getUserId()];
        return sn.Wholesaler_Number__c;
    }

    /*public List<FSL__User_Territory__c> getUserTerritories(){
        List<FSL__User_Territory__c> uTerr = new List<FSL__User_Territory__c>();
            if(userType == 'FSL')
            {
                for(User u : myUsers)
                    {
                        String userTerrit = '';
                        userTerrit = [SELECT FSL__Territory_Name__c FROM FSL__User_Territory__c where FSL__User__c =:u.Id LIMIT 1];
                    }
            }
        return userTerrit;
    }*/

    public void sortByUserTerritory()
    {
        List<FSL__User_Territory__c>sortUserTerritory=new List<FSL__User_Territory__c>([SELECT FSL__Territory_Name__c FROM FSL__User_Territory__c]);
        sortField = 'UserTerritory';
    }

}