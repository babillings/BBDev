@isTest//(SeeAllData = true)
public class AB_UserPortalContactExtension_TEST {

    public static User createUser(String type, String roleType, Boolean ProfileIdNull) {
        User u;
        if (!ProfileIdNull){
                u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name =: type].Id,
                LastName = 'last '+type,
                Email = 'puser000'+System.currentTimeMillis()+'@amamama.com',
                Username = 'puser000@amamama'+roleType+'.com' + System.currentTimeMillis()+roleType,
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = roleType == 'IND' ? [select id from UserRole where name like 'IND Leadership' limit 1].id : [select id from UserRole where name like 'WOD%' limit 1].id,
                WSLRNbrRouteNbr__c = '12345R001',
                Wholesaler_Number__c ='12345'
            );  
        }
        else
        {
                u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name =: type].Id,
                LastName = 'ProfileNull',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama'+roleType+'.com' + System.currentTimeMillis()+roleType,
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                WSLRNbrRouteNbr__c = '12345R001',
                Wholesaler_Number__c ='12345'
            );             
        }
        
        return u;
    }

    @testSetup
    public static void params()
    {
        Wholesaler_Lola_Access__c ob= new Wholesaler_Lola_Access__c(Wholesaler_Number__c = '51341', Name = 'My custom');
        insert ob;
        Role_connector__c rc = new Role_connector__c(Role_Name__c = 'Sales Manager', Profile_Name__c = 'IND Management', Profile_ID__c = [SELECT Id FROM Profile WHERE Name='Standard User'].id);
        insert rc;
        Role_connector__c rc1 = new Role_connector__c(Role_Name__c = 'SEC', Profile_Name__c = 'WOD Management', Profile_ID__c = [SELECT Id FROM Profile WHERE Name='Standard User'].id);
        insert rc1;
        //BB START
        Role_connector__c rc2 = new Role_connector__c(Role_Name__c = 'Dispatcher', Profile_Name__c = 'WOD ABI Dispatcher FSL', Profile_ID__c = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id);
        insert rc2;
        //BB END

    }    
    
    public static User[] createUser(Integer n, Boolean ProfileIdNull) {
        User[] users = new User[] {};
            for (Integer i = 0; i < n; i++) {
                if(i ==0)
                users.add(createUser('IND Management','IND', ProfileIdNull));
                else if(i ==1)
                users.add(createUser('WOD Management','WOD', ProfileIdNull));
                //BB START
                else 
                users.add(createUser('WOD ABI Dispatcher FSL','FSL', ProfileIdNull));
                //BB END
            }
        
        //RA 11/22/2018 - Consider Routes
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Route__c r = new Route__c();
            r.WSLRNbrRouteNbr__c = '12345R001';
            insert r;
        }
        //End
        
        return users;
    }

@isTest
    public static void userportalinfoIND()
    {
        Test.startTest();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'IND');
        insert r;
        UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'WOD');
        insert r1;
        UserRole r2 = new UserRole(DeveloperName = 'MyCustomRole3', Name = 'IND Leadership');
        insert r2;

        List<User> usrs = createUser(1, false);
        insert usrs;
        User u = [SELECT id, name, UserRoleId,Alias,Email,EmailEncodingKey, 
                    LastName,LanguageLocaleKey,LocaleSidKey,
                    ProfileId,TimeZoneSidKey,UserName from user WHERE LastName = 'Last IND Management' limit 1];
        System.runAs(u) {     
            for(User usr : usrs) {
                Role_connector__c rc = new Role_connector__c();
                rc.Profile_ID__c = usrs[0].profileid;
                rc.Profile_Name__c = 'IND Management';
                rc.Role_Name__c = 'Sales Manager';
                rc.Permission_Sets__c = [SELECT ID FROM PermissionSet WHERE Name like 'ABIQ%' LIMIT 1].ID;
                Test.setCurrentPage(Page.AB_UserPortalContact);
                ApexPages.currentPage().getParameters().put('id', usr.id);
                
                AB_UserPortalContactExtension obj = new AB_UserPortalContactExtension();
                obj.getRoleTypes();
                obj.getSubRouteNums();
                obj.getRouteOptions();
                obj.getUpdateLolaAccess();
                obj.selRolePickVal = 'IND Management';
                obj.save();
                try {
                    obj.doRemoveUser();
                }catch(Exception e){}
                obj.doCancel();
            }
        }
        Test.stopTest();
    }
@isTest
    public static void userportalinfoWOD()
    {
        Test.startTest();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'WOD');
        insert r1;
        
               
            List<User> usrs = createUser(2, false);
            insert usrs;
             User u = [SELECT id, name, UserRoleId,Alias,Email,EmailEncodingKey, 
                       LastName,LanguageLocaleKey,LocaleSidKey,
                       ProfileId,TimeZoneSidKey,UserName from user WHERE LastName = 'Last WOD Management' limit 1];
        System.runAs(u) {     
            for(User usr : usrs) {
                Role_connector__c rc = new Role_connector__c();
                rc.Profile_ID__c = usrs[0].profileid;
                rc.Profile_Name__c = 'WOD Management';
                rc.Role_Name__c = 'Dispatcher';
                rc.Permission_Sets__c = [SELECT ID FROM PermissionSet WHERE Name like 'ABIQ%' LIMIT 1].ID;
                insert rc;
                Test.setCurrentPage(Page.AB_UserPortalContact);
                ApexPages.currentPage().getParameters().put('id', usr.id);
                
                AB_UserPortalContactExtension obj = new AB_UserPortalContactExtension();
                obj.UserType = 'FSL';
                obj.getRoleTypes();
                obj.getSubRouteNums();
                obj.getRouteOptions();
                obj.getUpdateLolaAccess();
                obj.selRolePickVal = 'WOD Management';
                obj.save();
                try {
                    obj.doRemoveUser();
                }catch(Exception e){}
                obj.doCancel();
            }
        }
        Test.stopTest();
    }   
 @isTest
    public static void userportalinfoProfileIdNull()
    {
        Test.startTest();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'WOD');
        insert r1;
        
               
            List<User> usrs = createUser(1, true);
            insert usrs;
             User u = [SELECT id, name, UserRoleId,Alias,Email,EmailEncodingKey, 
                       LastName,LanguageLocaleKey,LocaleSidKey,
                       ProfileId,TimeZoneSidKey,UserName from user WHERE LastName =: 'ProfileNull' limit 1];
        System.runAs(u) 
        {     
            for(User usr : usrs) 
            {
                Role_connector__c rc = new Role_connector__c();
                rc.Profile_ID__c = usrs[0].profileid;
                rc.Profile_Name__c = 'WOD Management';
                rc.Role_Name__c = 'SEC';
                rc.Permission_Sets__c = [SELECT ID FROM PermissionSet WHERE Name like 'ABIQ%' LIMIT 1].ID;
                Test.setCurrentPage(Page.AB_UserPortalContact);
                ApexPages.currentPage().getParameters().put('id', usr.id);
                
                AB_UserPortalContactExtension obj = new AB_UserPortalContactExtension();
                obj.getRoleTypes();
                obj.getSubRouteNums();
                obj.getRouteOptions();
                obj.getUpdateLolaAccess();
                obj.selRolePickVal = 'SEC';
                
                obj.userUserTerritory = 'Denver';
                obj.save();
                try {
                    obj.doRemoveUser();
                }catch(Exception e){}
                obj.doCancel();
            }
        }
        Test.stopTest();
    }    
    public static testmethod void createServiceResourceNew()
    {
        Test.startTest();
		User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND Id !=: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        User newDisUsr = createUser('ABI_Dispatcher_FSL','WOD',false);
        newDisUsr.Wholesaler_Number__c = '12345';
        newDisUsr.IsActive = true;
        Insert newDisUsr;
        
        User newUsr = createUser('ABI_Merchandiser_FSL','WOD',false);
        newUsr.Wholesaler_Number__c = '12345';
        newUsr.IsActive = true;
        Insert newUsr;

        
        System.runAs(newDisUsr){
            OperatingHours oh = new OperatingHours();
            oh.Name = 'TestOH';
            insert oh;
            
            ServiceTerritory st = new ServiceTerritory();
            st.Name = 'Loveland';
            //st.OwnerId = newUsr.Id; //BB Comment Out
            st.OwnerId = newDisUsr.Id;//BB
            st.OperatingHoursId = oh.Id;
            st.IsActive = true;
            Insert st;

            //BB START
            FSL__User_Territory__c ut = new FSL__User_Territory__c();
            ut.FSL__ServiceTerritory__c = st.Id;
            ut.FSL__User__c = newUsr.Id;
            Insert ut;
            //BB END

            //BB START
            Account accnt = new Account();
            accnt.Name = 'Test Account';
            accnt.RecordTypeId = '012U0000000E9k6IAC';
            accnt.Service_Territory__c = st.Id;
            accnt.WSLR_NBR_US__c = '12345';
            Insert accnt;
            //BB END
            
                Test.setCurrentPage(Page.AB_UserPortalContact);
                ApexPages.currentPage().getParameters().put('id', newDisUsr.id);
                AB_UserPortalContactExtension obj = new AB_UserPortalContactExtension();
                
                obj.getRoleTypes();
                obj.getSubRouteNums();
                obj.getRouteOptions();
                obj.getUpdateLolaAccess();
                obj.selRolePickVal = 'Dispatcher';
                obj.UserType = 'Telesales';
                obj.save();
            
        }
            Test.stopTest();
    
        }
    
    public static testmethod void createServiceResourceExist()
    {
         Test.startTest();
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND Id !=: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        User newDisUsr = createUser('ABI_Dispatcher_FSL','WOD',false);
        newDisUsr.Wholesaler_Number__c = '12345';
        newDisUsr.IsActive = true;
        Insert newDisUsr;
        
        User newUsr = createUser('ABI_Merchandiser_FSL','WOD',false);
        newUsr.Wholesaler_Number__c = '12345';
        newUsr.IsActive = true;
        Insert newUsr;
        
        System.runAs(newDisUsr)
        {
           
            OperatingHours oh = new OperatingHours();
            oh.Name = 'TestOH';
            insert oh;
            
            ServiceTerritory st = new ServiceTerritory();
            st.Name = 'Denver';
            //st.OwnerId = newUsr.Id;//BB Comment Out
            st.OwnerId = newDisUsr.Id; //BB
            st.OperatingHoursId = oh.Id;
            st.IsActive = true;
            Insert st;
            
            ServiceResource sReq = new ServiceResource();
            sReq.Name = 'Test';
            sReq.IsActive = true;
            sReq.ResourceType = 'T';
            //sReq.IsOptimizationCapable = true;
            sReq.RelatedRecordId = newUsr.Id;
            sReq.IsActive = false;
            Insert sReq;

            FSL__User_Territory__c ut = new FSL__User_Territory__c();
            ut.FSL__ServiceTerritory__c = st.Id;
            ut.FSL__User__c = newUsr.Id;
            Insert ut;

            //BB START
            Account accnt = new Account();
            accnt.Name = 'Test Account';
            accnt.RecordTypeId = '012U0000000E9k6IAC';
            accnt.Service_Territory__c = st.Id;
            accnt.WSLR_NBR_US__c = '12345';
            Insert accnt;
            //BB END
   
        }
        
        system.runAs(newDisUsr)
        {
            
            
            Test.setCurrentPage(Page.AB_UserPortalContact);
                ApexPages.currentPage().getParameters().put('id', newDisUsr.id);
                AB_UserPortalContactExtension obj = new AB_UserPortalContactExtension();
                
                obj.getRoleTypes();
                obj.getSubRouteNums();
                obj.getRouteOptions();
                obj.getUpdateLolaAccess();
                obj.selRolePickVal = 'Dispatcher';
                obj.UserType = 'Telesales';
                obj.save();
            
            AB_UserPortalContactExtension cls = new AB_UserPortalContactExtension();
            cls.newUserId = newUsr.Id;
            cls.createServiceResource();
           
            
        }
        
        Test.stopTest();    
        
        
    }
    public static testmethod void createServiceResourceNotExist()
    {
         Test.startTest();
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND Id !=: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        User newDisUsr = createUser('ABI_Dispatcher_FSL','WOD',false);
        newDisUsr.Wholesaler_Number__c = '12345';
        newDisUsr.IsActive = true;
        Insert newDisUsr;
        
        User newUsr = createUser('ABI_Merchandiser_FSL','WOD',false);
        newUsr.Wholesaler_Number__c = '12345';
        newUsr.IsActive = true;
        Insert newUsr;
        
        System.runAs(newDisUsr)
        {
           
            OperatingHours oh = new OperatingHours();
            oh.Name = 'TestOH';
            insert oh;
            
            ServiceTerritory st = new ServiceTerritory();
            st.Name = 'Denver';
            //st.OwnerId = newUsr.Id;//BB Comment Out
            st.OwnerId = newDisUsr.Id; //BB
            st.OperatingHoursId = oh.Id;
            st.IsActive = true;
            Insert st;
            
            ServiceResource sReq = new ServiceResource();
            sReq.Name = 'Test';
            sReq.IsActive = true;
            sReq.ResourceType = 'T';
            //sReq.IsOptimizationCapable = true;
            sReq.RelatedRecordId = newUsr.Id;
            sReq.IsActive = false;
            //Insert sReq;

            FSL__User_Territory__c ut = new FSL__User_Territory__c();
            ut.FSL__ServiceTerritory__c = st.Id;
            ut.FSL__User__c = newUsr.Id;
            Insert ut;

            //BB START
            Account accnt = new Account();
            accnt.Name = 'Test Account';
            accnt.RecordTypeId = '012U0000000E9k6IAC';
            accnt.Service_Territory__c = st.Id;
            accnt.WSLR_NBR_US__c = '12345';
            Insert accnt;
            //BB END
   
        }
        
        system.runAs(newDisUsr)
        {
            
            
            Test.setCurrentPage(Page.AB_UserPortalContact);
                ApexPages.currentPage().getParameters().put('id', newDisUsr.id);
                AB_UserPortalContactExtension obj = new AB_UserPortalContactExtension();
                
                obj.getRoleTypes();
                obj.getSubRouteNums();
                obj.getRouteOptions();
                obj.getUpdateLolaAccess();
                obj.selRolePickVal = 'Dispatcher';
                obj.UserType = 'Telesales';
                obj.save();
            
            AB_UserPortalContactExtension cls = new AB_UserPortalContactExtension();
            cls.newUserId = newUsr.Id;
            cls.createServiceResource();
           
            
        }
        
        Test.stopTest();    
        
        
    }
    
    public static testmethod void createServiceResourceException()
    {
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND Id !=: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        User newDisUsr = createUser('ABI_Dispatcher_FSL','WOD',false);
        newDisUsr.Wholesaler_Number__c = '12345';
        newDisUsr.IsActive = true;
        Insert newDisUsr;
        
        User newUsr = createUser('ABI_Merchandiser_FSL','WOD',false);
        newUsr.Wholesaler_Number__c = '12345';
        newUsr.IsActive = true;
        Insert newUsr;

        System.runAs(newDisUsr){
            OperatingHours oh = new OperatingHours();
            oh.Name = 'TestOH';
            insert oh;
            
            ServiceTerritory st = new ServiceTerritory();
            st.Name = 'Ser Terr';
            st.OwnerId = newDisUsr.Id;
            st.OperatingHoursId = oh.Id;
            Insert st;
            
            ServiceResource sReq = new ServiceResource();
            sReq.Name = 'Test';
            sReq.IsActive = true;
            sReq.ResourceType = 'T';
            //sReq.IsOptimizationCapable = true;
            sReq.RelatedRecordId = newUsr.Id;
            sReq.IsActive = false;
            Insert sReq;

            //BB START
            Account accnt = new Account();
            accnt.Name = 'Test Account';
            accnt.RecordTypeId = '012U0000000E9k6IAC';
            accnt.Service_Territory__c = st.Id;
            accnt.WSLR_NBR_US__c = '12345';
            Insert accnt;
            //BB END
            
        }
        System.runAs(u){
            Test.startTest();

            
            AB_UserPortalContactExtension cls = new AB_UserPortalContactExtension();
            cls.newUserId = newUsr.Id;
            cls.createServiceResource();
            Test.stopTest();
        }
        
    }
    public static testmethod void testHasBTAccess()
    {
        User newUsr = createUser('Telesales Team Lead','WOD',false);
        newUsr.Wholesaler_Number__c = '998877';
        newUsr.IsActive = true;
        newUsr.Title = 'Merchandiser';
        Insert newUsr;
        
        
        System.runAs(newUsr) {  
            Wholesaler_App_Config__c wApp = new Wholesaler_App_Config__c();
            wApp.Name = '998877';
            wApp.Application_Name__c = 'BigTinCan';
            Insert wApp;
            AB_UserPortalContactExtension cls = new AB_UserPortalContactExtension();
            cls.getHasBTCAccess();
        }
    }
    public static testmethod void saveTeleSales()
    {
        Test.startTest();
        Test.setCurrentPage(Page.AB_UserPortalContact);
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND Id !=: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name like 'Telesales Team Lead'];
        UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'WOD');
        insert r1;
        
        
		
               
        User newUsr = createUser('Telesales Team Lead','WOD',false);
        newUsr.Wholesaler_Number__c = '12345';
        newUsr.WSLRNbrRouteNbr__c = '123456'; //BB
        newUsr.IsActive = true;
        newUsr.Title = 'Telesales Team Lead';
        newUsr.InContact_Access__c = true; //BB
        newUsr.profileId = p.id;
        newUsr.LiveMessage_Access__c = True;
        Insert newUsr;
        
        User newUsr2 = createUser('Telesales Team Lead','WOD',false);
        newUsr2.IsActive = true;
        newUsr.LiveMessage_Access__c = True;
        Insert newUsr2;
        
        List<User> usrs = new List<User>{newUsr};
 
        System.runAs(newUsr2) {     
            for(User usr : usrs) {
                Role_connector__c rc = new Role_connector__c();
                rc.Profile_ID__c = usr.profileid;
                rc.Profile_Name__c = 'Telesales Team Lead';
                rc.Role_Name__c = 'Telesales Team Lead';
                rc.Permission_Sets__c = [SELECT ID FROM PermissionSet WHERE Name like 'Telesales%' LIMIT 1].ID;
				insert rc;
                ApexPages.currentPage().getParameters().put('id', newUsr.id);
                
                
                AB_UserPortalContactExtension obj = new AB_UserPortalContactExtension();
                obj.getRoleTypes();
                obj.getSubRouteNums();
                obj.getRouteOptions();
                obj.getUpdateLolaAccess();
                obj.selRolePickVal = 'Telesales Team Lead';
                obj.save();
               
            }
        }
        Test.stopTest();
    }   

    public static testmethod void saveMerchandiser()
    {
        Test.startTest();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'WOD');
        insert r1;
        
               
        User newUsr = createUser('ABI_Dispatcher_FSL','WOD',false);
        newUsr.Wholesaler_Number__c = '12345';
        newUsr.WSLRNbrRouteNbr__c = ''; //BB
        newUsr.IsActive = true;
        newUsr.Title = 'Dispatcher';
        Insert newUsr;
        
        List<User> usrs = new List<User>{newUsr};
        System.runAs(newUsr) {     
            for(User usr : usrs) {
                Role_connector__c rc = new Role_connector__c();
                rc.Profile_ID__c = usrs[0].profileid;
                rc.Profile_Name__c = 'WOD ABI Dispatcher FSL';
                rc.Role_Name__c = 'Dispatcher';
                rc.Permission_Sets__c = [SELECT ID FROM PermissionSet WHERE Name like 'FSL%' LIMIT 1].ID;
                Test.setCurrentPage(Page.AB_UserPortalContact);
                ApexPages.currentPage().getParameters().put('id', usr.id);
                
                AB_UserPortalContactExtension obj = new AB_UserPortalContactExtension();
                obj.getRoleTypes();
                obj.getSubRouteNums();
                obj.getRouteOptions();
                obj.getUpdateLolaAccess();
                obj.selRolePickVal = 'Dispatcher';
                obj.save();
                try {
                    obj.doRemoveUser();
                }catch(Exception e){}
                obj.doCancel();
            }
        }
        Test.stopTest();
    }   
}