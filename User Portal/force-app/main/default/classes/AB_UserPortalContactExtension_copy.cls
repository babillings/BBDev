public without sharing class AB_UserPortalContactExtension_copy {
    public User usr {get;set;}
    public String selRoleId {get;set;}
    public String leadRoleId {get;set;}
    public String selRolePickVal {get;set;}
    public String wholesalerKey {get;set;}
    public Set<String> routeNums {get;set;}
    public String selRouteNum {get;set;}
    public Boolean isSaveDisabled {get;set;}
    Map<Id,UserRole> rolesMap;
    Map<String,String> roleNameTitleMap = new Map<String,String>();
    List<SelectOption> options;
    List<SelectOption> roleTypeOptions;
    Set<String> wholesalerSearchKeys = new Set<String>();
    Id currentUserRoleId;
    String currentUserRoleName;
    public String userType {get;set;}
    private Boolean updateLolaAccess;
    public List<Role_connector__c> roleConnectorLst;
    Map<String,Role_connector__c> roleNameRcMap = new Map<String,Role_connector__c>(); //Femi:variable declaration, To collect roleName and corresponding role connect records
    List<Role_connector__c> defaultRoleConnectorRecs = new List<Role_connector__c>(); //Femi:variable declaration, To collected role related to current logged in profile
    public User currentUser;
    public String newUserId; //Femi: Created/Selected user id to create Service Resource
    public String userErrorMessage; //Femi: To Capture if any error message in Save method and display the same on oncomplete action
    public AB_UserPortalContactExtension_copy() 
    {
        currentUser = [SELECT Id,Profile.Name,UserRoleId,Wholesaler_Number__c FROM User WHERE Id =: UserInfo.getUserId()];
        usr = new User();
        newUserId = '';
        userErrorMessage = '';
        String userId = ApexPages.currentPage().getParameters().get('id');   
        if(String.isNotBlank(userId)) 
        {
            //RA 10/4/2018 - Update for GSC Package
            //Femi - July19 -  Modified below line
            usr = [select id, FirstName, LastName, Email, isActive, gsc_mc__Sync_to_GoSpotCheck__c, PCR_Access__c,
                   SRI_Access__c, EmployeeNumber, Title, Wholesaler_Number__c, WSLRNbrRouteNbr__c, UserRoleId, Employee_Number_US__c, ProfileId, LOLA_Access__c, BigTinCan_Access__c,InContact_Access__c,LiveMessage_Access__c from User where id =: userId];
        }   
        if(usr.id == UserInfo.getUserId()) 
        {
            isSaveDisabled = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,'Current logged in user record cannot be saved. Please contact your Administrator.'));
        }       
        //BB START If the user is editing themselves, don't let them save
        else 
        {
            isSaveDisabled = false;
        }
        //BB END
        rolesMap = new Map<Id,UserRole>([Select name from UserRole Limit: Limits.getLimitQueryRows()]);
        
        //BB START
        //isSaveDisabled = false;
        //BB END

        if(String.isNotBlank(usr.Wholesaler_Number__c))
            wholesalerKey = usr.Wholesaler_Number__c;
        system.debug('***usr.WSLRNbrRouteNbr__c: '+usr.WSLRNbrRouteNbr__c);
        if(String.isNotBlank(usr.WSLRNbrRouteNbr__c)) 
        {
            List<Route__c> routeLst = [select id, WSLRNbrRouteNbr__c from Route__c where WSLRNbrRouteNbr__c =: usr.WSLRNbrRouteNbr__c];
            system.debug('***routeLst: '+routeLst);
            if(routeLst != null && routeLst.size() > 0)
                selRouteNum = routeLst[0].WSLRNbrRouteNbr__c;
        }
        system.debug('USER:'+UserInfo.getUserId());
        system.debug('***selRouteNum: '+selRouteNum);
        currentUserRoleId = UserInfo.getUserRoleId();
        system.debug('****currentUserRoleId: '+currentUserRoleId);
        system.debug('****LIMITS: '+Limits.getLimitQueryRows());
        
        //currentUserRoleName = AB_UserPortalHelpers.getUserRoleName(currentUserRoleId);
        if (currentUserRoleId!=null)
        {
            currentUserRoleName = rolesMap.get(currentUserRoleId).Name;   
        }
        //BB START
        /*
        system.debug('currentUserRoleName : '+currentUserRoleName);
        if(String.isNotBlank(currentUserRoleName))
            userType = currentUserRoleName.left(3);
        system.debug('USERTYPE : '+userType);
        */
        String typeLike = '';
        if(currentUser.Profile.Name.left(9).toLowerCase() == 'telesales')
        {
            userType = 'Telesales';
            typeLike = '%Telesales%';
        }
        else if(currentUser.Profile.Name.left(3).toLowerCase() == 'wod')
        {
            userType = 'WOD';
            typeLike = '%WOD%';
        }
        else if(currentUser.Profile.Name.left(3).toLowerCase() == 'ind')
        {
            userType = 'IND';
            typeLike = '%IND%';
        }
        else if(currentUser.Profile.Name.right(3).toLowerCase() == 'fsl')
        {
            userType = 'FSL';
            typeLike = '%FSL%';
        }
        system.debug('USERTYPE : '+userType);

        //BB END

        //System.debug('@@@==>>: '+roleConnectorLst); 
        //System.debug('@@@==>>Prof Type: '+currentUser.Profile.Name.left(9).toLowerCase()); 
        
        //BB START
        /*
        if(currentUser.Profile.Name.left(9).toLowerCase() == 'telesales') //For TeleSales Profile : Femi july 19
        {
            typeLike = '%'+currentUser.Profile.Name.left(9)+'%';
        }
        else
        {
            typeLike = '%'+userType+'%';
        }
        */
        //BB END

        //System.debug('@@@==>>typeLike: '+typeLike); 
        roleConnectorLst = new List<Role_connector__c>(
            [select Role_Name__c, Profile_ID__c, Profile_Name__c, Title__c, Permission_Sets__c from Role_connector__c where Profile_Name__c like: typeLike
             order by Role_Name__c Limit: Limits.getLimitQueryRows()]
        ); //Femi:Based on the logged in user Collecting all role connected records of type WOD or IND
        //System.debug('@@@==>>: '+roleConnectorLst); 
        for(Role_connector__c rc : roleConnectorLst) 
        {
            roleNameRcMap.put(rc.Role_Name__c,rc); // collecting role name and correcponding role connector record
            if(usr.ProfileId == rc.Profile_ID__c) // checking if the profile id of logged in user is == role connector profile id. because there can be multiple role connect record for same profile id
            { 
                defaultRoleConnectorRecs.add(rc); // // if there is a match i am adding in this list
            }
        } 
        List<SelectOption> roleOptions = getRoles();
        if(roleOptions.size() > 0) 
        {
            if(usr.UserRoleId != null)
                selRoleId = usr.UserRoleId;
            else
                selRoleId = roleOptions[0].getValue();
            //leadRoleId = selRoleId; //Avoid missing wholesaler issue by Femi
            for(SelectOption option : roleOptions) 
            {
                System.debug('GETLABEL: '+option.getLabel());
                if(option.getLabel().endsWith('Leadership'))
                    leadRoleId = option.getValue();
            }
        }
        init();
        for(SelectOption opt : getRoleTypes()) //Femi: in the user portal, the role names that we want to show is prepared here. getRoleTypes is the method
        {
            if(String.isBlank(usr.ProfileId) && roleNameTitleMap.size() == 0) //  for new record, we need to set default values
                selRolePickVal = opt.getValue();
            roleNameTitleMap.put(opt.getValue(),opt.getLabel()); //map which will hold the role names
        }
        if(String.isNotBlank(usr.ProfileId) && defaultRoleConnectorRecs != null && defaultRoleConnectorRecs.size() > 0)  //for existing user
        {
            selRolePickVal = defaultRoleConnectorRecs[0].Role_Name__c;  
            //system.debug(selRolePickVal+'***');
        }   
        //habilitacion actualizacion LOLA
        
        updateLolaAccess = getUpdateLolaAccess();            
        //
        //system.debug(selRolePickVal+'***roleNameTitleMap: '+roleNameTitleMap);
        //selectedname = 'TPM_PCR_Permission_NEW_v2';
    }
    public void init() 
    {
        options = new List<SelectOption>();
        roleTypeOptions = new List<SelectOption>();
        //system.debug('***selRoleId: '+selRoleId);
        String myRoleName = AB_UserPortalHelpers.getUserRoleName(selRoleId);//Avoid missing wholesaler issue by Femi (uncommented)
        //Commented below logic - //Avoid missing wholesaler issue by Femi 
        /*String myRoleName;
        if (leadRoleId!=null){
            system.debug('@@@leadRoleId: '+leadRoleId);
            myRoleName = rolesMap.get(leadRoleId).Name;
        }*/
        system.debug('myRoleName: '+myRoleName);
        if(String.isNotBlank(myRoleName)) 
        {
            pattern myPattern = pattern.compile('\\b\\d{5}\\b');
            matcher myMatcher = myPattern.matcher(myRoleName);   
            //options.add(new SelectOption('','--None--'));        
            while (myMatcher.find()) 
            { 
                //if(routeNums == null) {
                wholesalerSearchKeys.add(myMatcher.group()+'%');
                //}                
                options.add(new SelectOption(myMatcher.group(),myMatcher.group()));
            }
            system.debug('options in init: '+options);
            if(routeNums == null && wholesalerSearchKeys.size() > 0) 
            {
                routeNums = new Set<String>();
                for(Route__c route : [select id,WSLRNbrRouteNbr__c from Route__c 
                                      where WSLRNbrRouteNbr__c like: wholesalerSearchKeys]) 
                                      {
                                          routeNums.add(route.WSLRNbrRouteNbr__c);
                                      }
            }
        }
        
        //system.debug('routeNums: '+routeNums);
    }
    public List<SelectOption> getRoleTypes() 
    {
        List<SelectOption> options = new List<SelectOption>();
        for(Schema.Role_connector__c rc : roleConnectorLst) 
        {
            //BB START
            //if(currentUser.Profile.Name.left(9).toLowerCase() == 'telesales') //For TeleSales Profile : Femi july 19
            if(userType == 'Telesales')
            //BB END
            {
                if(rc.Profile_Name__c.containsIgnoreCase('telesales')) //BB
                //if(rc.Profile_Name__c.startsWithIgnoreCase('TeleSales')) //BB
                {
                    options.add(new SelectOption(rc.Role_Name__c,rc.Role_Name__c));
                }  
            }
            else if(userType == 'IND') 
            {   
                if(rc.Profile_Name__c.containsIgnoreCase('IND')) //BB
                //if(rc.Profile_Name__c.startsWithIgnoreCase('IND')) //BB
                {
                    options.add(new SelectOption(rc.Role_Name__c,rc.Role_Name__c));
                }              
            }
            else if(userType == 'WOD') 
            {
                if(rc.Profile_Name__c.containsIgnoreCase('WOD')) //BB
                //if(rc.Profile_Name__c.startsWithIgnoreCase('WOD')) //BB
                {
                    options.add(new SelectOption(rc.Role_Name__c,rc.Role_Name__c));
                }
            }
            //BB START
            else if(userType == 'FSL')
            {
                if(rc.Profile_Name__c.containsIgnoreCase('FSL'))
                {
                    options.add(new SelectOption(rc.Role_Name__c,rc.Role_Name__c));
                }
            }
            //BB END
        }
        return options;
    }
    public List<SelectOption> getSubRouteNums() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        if(routeNums != null) 
        {
            for(String str : routeNums) 
            {
                options.add(new SelectOption(str,str));
            }
        }
        return options;
    }
    public List<SelectOption> getRouteOptions() 
    { 
        init();      
        return options;
    }
    public PageReference save() 
    {
        PageReference pr;
        //RA 11/20/2018 - Update due to code overwrite issues
        //if(usr.Remote_Survey_Vendor_Enabled__c && !usr.isActive) {
        if(usr.gsc_mc__Sync_to_GoSpotCheck__c && !usr.isActive) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,label.GoSpotCheck_Access_Validation_Error));
            userErrorMessage = label.GoSpotCheck_Access_Validation_Error;
        }
        else 
        {
            pr = Page.AB_UserPortalContact;
            if(usr.id == null && usr.isActive) 
            {
                Database.DMLOptions dmlo = new Database.DMLOptions();
                dmlo.EmailHeader.triggerUserEmail = true;
                usr.setOptions(dmlo);
            }           
            
            usr.UserRoleId = selRoleId;
            if(roleNameRcMap.containsKey(selRolePickVal))
                usr.ProfileId = roleNameRcMap.get(selRolePickVal).Profile_ID__c;
            //system.debug('***PROFILE ID: '+selRolePickVal);
            //system.debug('***title: '+roleNameTitleMap.get(selRolePickVal));
            usr.Title = selRolePickVal;
            Role_connector__c roleConnect = new Role_connector__c();
            if(userType == 'IND') 
            {   
                usr.User_Type__c = 'External User';
            }
            else
            //else if(userType == 'WOD') //BB
            {
                usr.User_Type__c = 'A-B Employees';
                //Femi - AB Permission Set/title - STARTS  
                //Femi: Below logic is to assing title for merchantiser or dispatcher by getting from the role connector records              
                if(roleNameRcMap.containsKey(selRolePickVal)) roleConnect = roleNameRcMap.get(selRolePickVal);
                if(roleConnect.Role_Name__c == 'Merchandiser' || roleConnect.Role_Name__c == 'Dispatcher') 
                {
                    usr.Title = roleConnect.Title__c;
                }
                //Femi: May19 - STARTS
                // Femi:- If Count of profile = ABI_Dispatcher_FSL > 1 provide error "You can only have 1 dispatcher per wholesaler number"
                List<User> usersLst;
                if(roleConnect.Role_Name__c == 'Dispatcher')  // checking only for dispatcher
                {
                    String keyLike = '%'+wholesalerKey;
                    usersLst = [select id, UserRole.Name from User where ProfileId =: roleNameRcMap.get(selRolePickVal).Profile_ID__c and isActive = true and UserRole.Name like: keyLike];
                }
                //Femi: below logic is to show the error for if there is more then one active dispatcher per whole saler.
                if(usersLst != null && usersLst.size() > 0) 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'You can only have 1 '+roleConnect.Role_Name__c+' per wholesaler number'));
                    userErrorMessage = 'You can only have 1 '+roleConnect.Role_Name__c+' per wholesaler number';
                    return null;
                }                
                //Femi - AB Permission Set - ENDS
            }
            if(currentUser.Profile.Name.left(9).toLowerCase() == 'telesales') 
            {
                List<CallCenter> callCenterLst = [select id, name from Callcenter where Name = 'inContact Call Center'];
                if(callCenterLst != null && callCenterLst.size() > 0) 
                {
                    usr.CallCenterId = callCenterLst[0].id;
                }
            }
            usr.Wholesaler_Number__c = wholesalerKey;
            //selRouteNum = [select id,WSLRNbrRouteNbr__c from Route__c where id =: route.Route__c].WSLRNbrRouteNbr__c;
            usr.WSLRNbrRouteNbr__c = selRouteNum;
            if(String.isNotBlank(selRouteNum))
                usr.RouteKey__c = selRouteNum.substring(wholesalerKey.length(),selRouteNum.length());
            List<User> users = new List<User>();
            users = AB_UserPortalUserContrl_Handler.prefillUserFields(new List<User>{usr},userType);
            List<User> lstUsersToDelete = new List<User>();            
            try 
            {
                if(usr.id != UserInfo.getUserId()) 
                {
                    system.debug('User is not editing themselves');
                    //Femi - AB Permission Set - STARTS
                    //Femi - the below logic is to assing the active users to the permission sets configured in Role Connect object
                    Database.upsertResult[] upRslt = Database.upsert(users); 
                    List<PermissionSetAssignment> psaLst = new List<PermissionSetAssignment>();
                    for(Integer i=0;i<upRslt.size();i++) 
                    {
                        if(upRslt[i].isSuccess()) // if the user is inserted successfully, i am assigning to permissionset
                        { 
                            system.debug('User was upserted successfully'); //BB
                            if(usr.isActive) newUserId = upRslt[i].getId(); //Femi: Collect Created/Selected user id to create Service Resource
                            if(!usr.isActive) 
                            {
                                System.debug('User is not active'); //BB
                                system.debug('@@== New User Id: '+upRslt[i].getId());
                                system.debug('@@== newUserId: '+newUserId);
                                if(userType == 'telesales') //BB
                                //if(currentUser.Profile.Name.left(9).toLowerCase() == 'telesales') //BB
                                {
                                    usr.RouteKey__c = null;
                                    usr.WSLRNbrRouteNbr__c = null;
                                    usr.InContact_Access__c = false;
                                    usr.LiveMessage_Access__c = false;
                                }                                
                                lstUsersToDelete.add(usr);
                            }
                            if(roleConnect != null && (roleConnect.Role_Name__c == 'Merchandiser' || roleConnect.Role_Name__c == 'Dispatcher' || currentUser.Profile.Name.left(9).toLowerCase() == 'telesales'))
                            {
                                system.debug('User is Merch or Telesales'); //BB
                                   List<String> permissionsetIds = new List<String>();
                                   if(String.isNotBlank(roleConnect.Permission_Sets__c)) 
                                   {
                                       system.debug('User has permission sets to apply');
                                       if(userType != 'telesales') //BB
                                       //if(currentUser.Profile.Name.left(9).toLowerCase() != 'telesales') //BB
                                       {
                                           system.debug('User is not a Telesales user');
                                           permissionsetIds.addAll(roleConnect.Permission_Sets__c.split(';'));     
                                       }           
                                       else 
                                       {
                                           system.debug('User is a Telesales user');
                                           if(usr.InContact_Access__c && String.isNotBlank(Label.InContact_Access_Permission_Sets)) 
                                           {
                                               permissionsetIds.addAll(Label.InContact_Access_Permission_Sets.split(';'));
                                           }
                                           if(usr.LiveMessage_Access__c && String.isNotBlank(Label.LiveMessage_Access_Permission_Sets)) 
                                           {
                                               permissionsetIds.addAll(Label.LiveMessage_Access_Permission_Sets.split(';'));
                                           }
                                       }                                             
                                       for(String perId : permissionsetIds) 
                                       {
                                           if(users[i].isActive) 
                                           {
                                               psaLst.add(new PermissionSetAssignment(PermissionSetId = perId, AssigneeId = upRslt[i].getId()));
                                               system.debug('Permission sets have been added to the list for this active user');
                                           }
                                       }
                                   }
                               }
                        }
                    }
                    if(psaLst != null && psaLst.size() > 0) 
                    {
                        insert psaLst;
                        system.debug('Permission Sets have been applied');                        
                    }
                    //Femi - July19 - To remove users from the Permission Set - STARTS
                    //Note: Remove the users from all the permission sets.
                    if(!usr.isActive) //BB
                    {
                        system.debug('user is not active, start the process of removing permission sets'); //BB
                        List<PermissionSetAssignment> pSetAssignmentsLst = [SELECT Id from PermissionSetAssignment 
                                                                            WHERE AssigneeId in : lstUsersToDelete AND 
                                                                            PermissionSetId IN (SELECT Id FROM PermissionSet WHERE IsOwnedByProfile =false)];
                        
                        if(pSetAssignmentsLst != null && pSetAssignmentsLst.size() > 0) 
                        {
                            delete pSetAssignmentsLst;
                            system.debug('Permission Sets have been removed'); //BB
                        }
                        List<PermissionSetLicenseAssign> pSetAssignmentsLicLst = [SELECT Id from PermissionSetLicenseAssign 
                                                                                WHERE AssigneeId in : lstUsersToDelete];
                        
                        if(pSetAssignmentsLicLst != null && pSetAssignmentsLicLst.size() > 0) 
                        {
                            delete pSetAssignmentsLicLst;
                            system.debug('Permission Set Licenses have been removed');// BB
                        }
                    //Femi - July19 - To remove users from the Permission Set - ENDS
                    //Femi - AB Permission Set - ENDS
                    pr = Page.AB_UserPortalHome;
                    }
                    else 
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Current logged in user record cannot be modified. Please contact your Administrator.'));
                        userErrorMessage = 'Current logged in user record cannot be modified. Please contact your Administrator.';
                    }
                }
            }
            catch(Exception e) 
            {
                String errMsg = e.getMessage();
                if(errMsg.contains('The specified Federation ID already exists for this organization'))
                    errMsg = label.UsernameAlreadyExist;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,errMsg));
                userErrorMessage = errMsg;
            }
        }
        //BB START
        return pr; //uncomment
        //return null; //comment out
        //BB END
    }
    
    //08/06/2019 Femi Onakoya: As a user with an ABI_Dispatcher_FSL profile, when I create or update a user with a role of Merchandiser in the User Portal
    public PageReference createServiceResource()
    {
        try
        {
            system.debug('Entering Create Service Resource(CSR)'); //BB
            if(!String.isBlank(newUserId)) //Check whether user id blank or not, if not blank go for the logic
            {
                system.debug('CSR: The user has an ID'); //BB
                //Query the current created/selected user
                User newUser = [SELECT Id,Name,Wholesaler_Number__c,ProfileId,IsActive FROM USer WHERE Id =: newUserId];
                system.debug('CSR: newUser name ='+newUser.Name); //BB
                String profileId = String.valueOf(newUser.ProfileId);
                
                //Check if the Profile is Merchandiser and Active
                if(userType == 'FSL' && newUser.IsActive) //BB
                //if(profileId.subString(0,15) == Label.ABI_Merchandiser_FSL_ProfileId && newUser.IsActive) //BB
                {
                    system.debug('CSR: user is active and is a merchandiser'); //BB
                    //If Yes, query for existing ServiceResource if any
                    List<ServiceResource> listSReq = new List<ServiceResource>([SELECT Id,IsActive FROM ServiceResource 
                                                                                WHERE RelatedRecordId =: newUser.Id]);
                    //system.debug('CSR: Service Resource ID & Status '+listSReq[0].Id + listSReq[0].IsActive);
                    if(listSReq.isEmpty()) //If no existing Service Resource create new set of records
                    {
                        system.debug('CSRNew: No Existing Service Resource'); //BB
                        //Creating new Service Resource
                        ServiceResource sReq = new ServiceResource();
                        sReq.Name = newUser.Name;
                        sReq.IsActive = true;
                        //sReq.ResourceType = 'Technician';
                        if(!Test.isRunningTest()) sReq.IsOptimizationCapable = true;
                        sReq.RelatedRecordId = newUser.Id;
                        Insert sReq;
                        system.debug('CSRNew: Service Resource Created' + sReq.Id);
                        
                        //Creating Service Skill
                        system.debug('CSRNew: Creating Service Resource Skill');
                        ServiceResourceSkill srSkill = new ServiceResourceSkill();
                        srSkill.ServiceResourceId = sReq.Id;
                        srSkill.SkillId = Label.Standard_Skill_Id; //Populate Standard Skill from Label
                        srSkill.EffectiveStartDate = System.today();
                        //srSkill.EffectiveEndDate = null;
                        //srSkill.SkillLevel = 0;
                        Insert srSkill;
                        system.debug('CSRNew: Service Resource Skill ID' + srSkill.Id); //BB
                        
                        if(!String.IsBlank(newUser.Wholesaler_Number__c))//Check for Wholesaler number of the user created/selected
                        {
                            system.debug('CSRNew: User has a wholesaler number'); //BB
                            //Check if Service Territory exist for the created/selected User wholesaler number
                            //BB START
                            //Check if Service Territory exist for the created/selected User wholesaler number
                            /*List<Account> list_SerTerritories = new List<Account>([SELECT Service_Territory__r.Id
                                                                                                     FROM Account 
                                                                                                     WHERE WSLR_NBR_US__c = : newUser.Wholesaler_Number__c
                                                                                                     ORDER BY LastModifiedDate DESC]);
                            String servTerrId;
                            if(list_SerTerritories.size()>0)
                            {
                                system.debug('Service territory for wholesaler found');
                                servTerrId = list_SerTerritories[0].Service_Territory__r.Id;
                            }                           
                            */
                            List<ServiceTerritory> list_SerTerritories = new List<ServiceTerritory>([SELECT Id,Owner_s_Wholesaler_Number__c 
                                                                                                     FROM ServiceTerritory 
                                                                                                     WHERE Owner_s_Wholesaler_Number__c = : newUser.Wholesaler_Number__c 
                                                                                                     ORDER BY LastModifiedDate DESC]);
                            
                            //BB END


                            //If Service Terrtory exist, create Service Territory Member
                            if(!list_SerTerritories.isEmpty())
                            {
                                system.debug('CSRNew: Service Territory list is not empty' + list_SerTerritories[0].Id); //BB
                                //Create Service Territory Member
                                system.debug('CSRNew: Start Creating Service Territory Member'); //BB
                                ServiceTerritoryMember stm = new ServiceTerritoryMember();
                                stm.ServiceTerritoryId = list_SerTerritories[0].Id;
                                stm.ServiceResourceId = sReq.Id;
                                stm.EffectiveStartDate = System.today();
                                //stm.EffectiveEndDate = null;
                                Insert stm;
                                system.debug('CSRNew: Created Service Territory Member'+stm.Id); //BB

                                //BB START
                                //Creating User Territory
                                system.debug('CSRNew: Start creating User Territory');
                                FSL__User_Territory__c usrTerr = new FSL__User_Territory__c();
                                usrTerr.FSL__User__c = newUser.Name;
                                usrTerr.FSL__ServiceTerritory__c = list_SerTerritories[0].Id;
                                Insert usrTerr;
                                system.debug('User Territory Created');
                                //BB END
                            }
                            else //If no matching Service Territory, show the message saying the same
                            {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,'User, Service Resource and Skill has been Created/Updated Successfully..!!'));
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'No Machting Serivice Territory found to Create Service Territory Member..!!'));
                                return null;
                            }
                        }
                    }
                    else //If Service Resource Exist
                    {
                        //Check if Service Territory exist for the created/selected User wholesaler number
                        List<ServiceTerritory> list_SerTerritories1 = new List<ServiceTerritory>([SELECT Id,Owner_s_Wholesaler_Number__c 
                                                                                                    FROM ServiceTerritory 
                                                                                                    WHERE Owner_s_Wholesaler_Number__c = : newUser.Wholesaler_Number__c
                                                                                                    ORDER BY LastModifiedDate DESC]);
                        system.debug('CSROld: Query Service Territory '+list_SerTerritories1[0].Id);
                        
                        system.debug('CSROld: Service Resource already exists');
                        if(!listSReq[0].IsActive) //Check if it's Inactive and make it active
                        {
                            system.debug('CSROld: Service Resource is not active');
                            listSReq[0].IsActive = true;
                            Update listSReq[0];
                            system.debug('CSROld: Service Resource should now be active'+listSReq[0].Id);
                        } 
                        
                        //Query and check if Service Resource Skill already exist
                        List<ServiceResourceSkill> list_Skills = new List<ServiceResourceSkill>([SELECT Id FROM ServiceResourceSkill WHERE ServiceResourceId =: listSReq[0].Id]);
                        system.debug('CSROld: Checking for service resource skill');

                        //If there is no existing Service Resource Skill, create new 
                        if(list_Skills == null || list_Skills.isEmpty())
                        {
                            system.debug('CSROld: No Existing Service Resource Skill');
                            //Createing new Service Resource Skill
                            ServiceResourceSkill srSkill1 = new ServiceResourceSkill();
                            srSkill1.ServiceResourceId = listSReq[0].Id;
                            srSkill1.SkillId = Label.Standard_Skill_Id; //Populate Standard Skill from Label
                            srSkill1.EffectiveStartDate = System.today();
                            //srSkill1.EffectiveEndDate = null;
                            //srSkill1.SkillLevel = 0;
                            Insert srSkill1;
                            system.debug('CSROld: New Service Resource Skill Created'+srSkill1.Id);
                        }
                        else 
                        {
                            system.debug('CSROld: Service Resource Skill Exists' + list_Skills[0].Id);
                        }
                        
                        //Query and check if already ServiceTerritoryMember exist
                        List<ServiceTerritoryMember> list_ServTerr = new List<ServiceTerritoryMember>([SELECT Id FROM ServiceTerritoryMember WHERE ServiceResourceId =: listSReq[0].Id]);
                        
                        //If there is no existing Service Territory Member, create new 
                        if(list_ServTerr == null || list_ServTerr.isEmpty())
                        {
                            system.debug('CSROld: Service Territory Member does not exist');
                            //If Service Terrtory exist, create Service Territory Member
                            if(!list_SerTerritories1.isEmpty())
                            {
                                system.debug('Service Territory Member commented out for the time being');
                                system.debug('CSROld: Service Territory Exists, create service territory member');
                                //Creating ServiceTerritoryMember
                                ServiceTerritoryMember stm1 = new ServiceTerritoryMember();
                                stm1.ServiceTerritoryId = list_SerTerritories1[0].Id;
                                stm1.ServiceResourceId = listSReq[0].Id;
                                stm1.EffectiveStartDate = System.today();
                                //stm.EffectiveEndDate = null;
                                Insert stm1;
                                system.debug('CSROld: Service Territory Member Created' + stm1.Id);
                            }
                            else //If no matching Service Territory, show the message saying the same
                            {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,'User, Service Resource and Skill has been Created/Updated Successfully..!!'));
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'No Matching Service Territory found to Create Service Territory Member..!!'));
                                return null;
                            }
                        }

	                    //BB START
                        //Query and check if User Territory exists
                        List<FSL__User_Territory__c> list_UserTerr = new List<FSL__User_Territory__c>([SELECT Id,FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c =: newUser.Id]);
                        //If there is an existing User Territory and if the territory is different than the existing, start logic to delete it
                        if(list_UserTerr != null && list_UserTerr.size() > 0 && List_UserTerr[0].FSL__ServiceTerritory__c != list_SerTerritories1[0].Id)
                            {
                                system.debug('Existing Service Resource: User Territory Exits');
                                delete list_UserTerr;
                                system.debug('Existing Service Resource: Old user territory deleted');
                            }
                        //If there is no existing User Territory, start logic to create new
                        List<FSL__User_Territory__c> list_UserTerr1 = new List<FSL__User_Territory__c>([SELECT Id 
                                                                                                        FROM FSL__User_Territory__c 
                                                                                                        WHERE FSL__User__c =: newUser.Id]);
                        //BRIANNA Added a bit to say if the user is active create a new user territory
                        if(list_UserTerr1 == null || list_UserTerr1.isEmpty())
                            {
                                FSL__User_Territory__c userTerr1 = new FSL__User_Territory__c();
                                userTerr1.FSL__User__c = newUser.Id;
                                userTerr1.FSL__ServiceTerritory__c = list_SerTerritories1[0].Id;
                                Insert userTerr1;
                                system.debug('Existing Service Resource: Created user territory');
                            }
                        //BRIANNA END
                        
                    }
                }
                return Page.AB_UserPortalHome;
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,userErrorMessage));
                return null;
            }
        }
        catch(exception e)
        {
            System.debug('@@@@ Exp: '+String.valueOf(e));
            String mainMessage = 'User has been created, below errors came while assigning service resource..!!';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,mainMessage));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,String.valueOf(e)+'. At: '+e.getStackTraceString()));
            return null;
        }
    }
    //End of Service Resource Creation
    public List<SelectOption> getRoles() {
        List<SelectOption> options = new List<SelectOption>();
        if(String.isNotBlank(currentUserRoleId)) {            
            options.add(
                new SelectOption(currentUserRoleId, currentUserRoleName.Right(currentUserRoleName.Length()-6))
            );
            for(Id rlId : getAllSubRoleIds(new Set<Id>{currentUserRoleId})){
                //String rlName = AB_UserPortalHelpers.getUserRoleName(rlId);
                String rlName = rolesMap.get(rlId).Name;
                options.add(new SelectOption(rlId,rlName.Right(rlName.Length()-6)));
            }
        }
        return options;
    }
    static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        
        Set<ID> currentRoleIds = new Set<ID>();
        
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id, Name from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null]) {
            String roleName = String.valueOf(userRole.Name);
            
            if(roleName.indexOf(Label.Owner)>0){
                //do not display the "Owner" dummy role
            } else {
                currentRoleIds.add(userRole.Id);
            }
        }
        
        // go fetch some more roles!
        if(!currentRoleIds.isEmpty()) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        return currentRoleIds;
    }
    public pageReference doRemoveUser(){
        PageReference pageRef;
        usr.isActive = false;
        List<User> users = [select id, ManagerId from User where ManagerId =: usr.id];
        if(users != null && users.size() > 0)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,label.UserManagerReferenceError));
        else {
            update usr;
            pageRef = new PageReference('/apex/AB_UserPortalHome');
        }
        return pageRef;
    }
    public pageReference doCancel(){
        PageReference pageRef = new PageReference('/apex/AB_UserPortalHome');
        return pageRef;
    }
    
    public Boolean getUpdateLolaAccess(){
        List<Wholesaler_Lola_Access__c> ws = [SELECT Wholesaler_Number__c FROM Wholesaler_Lola_Access__c WHERE Wholesaler_Number__c = :getWholsalerNumber() limit 1];
        Boolean ret = false;
        if (!ws.isEmpty()){
            ret = true;
        }
        return ret;
    }   
    //Femi - July19 - STARTS
    public Boolean getHasBTCAccess() {
        //Wholesaler_App_Config__c
        Boolean isTrue = false;
        String whslrNum = getWholsalerNumber();
        if(String.isNotBlank(whslrNum)) {
            List<Wholesaler_App_Config__c> appConfigs = new List<Wholesaler_App_Config__c>(
                [select Name from Wholesaler_App_Config__c where Name =: whslrNum and Application_Name__c = 'BigTinCan']
            );
            if(appConfigs.size() > 0) {
                isTrue = true;
            }
        }
        return isTrue;
    }
    //Femi - July19 - ENDS
    public String getWholsalerNumber(){
        User sn = [select Wholesaler_Number__c from user where id =  :UserInfo.getUserId()];
        return sn.Wholesaler_Number__c;
    }    
}