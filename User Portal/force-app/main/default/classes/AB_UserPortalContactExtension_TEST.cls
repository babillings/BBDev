@isTest//(SeeAllData = true)
public class AB_UserPortalContactExtension_TEST {

    public static User createUser(String type, String roleType, Boolean ProfileIdNull) {
        User u;
        if (!ProfileIdNull){
                u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name =: type].Id,
                LastName = 'last '+type,
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama'+roleType+'.com' + System.currentTimeMillis()+roleType,
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = roleType == 'IND' ? [select id from UserRole where name like 'IND Leadership' limit 1].id : [select id from UserRole where name like 'WOD%' limit 1].id,
                WSLRNbrRouteNbr__c = 'REG220922_TAM02',
                Wholesaler_Number__c ='51341'
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
                WSLRNbrRouteNbr__c = 'REG220922_TAM02',
                Wholesaler_Number__c ='51341'
            );             
        }
        
        return u;
    }

    @testSetup
    public static void params()
    {
        Wholesaler_Lola_Access__c ob= new Wholesaler_Lola_Access__c(Wholesaler_Number__c = '51341', Name = 'My custom');
        insert ob;
        Role_connector__c rc = new Role_connector__c(Role_Name__c = 'Sales Manager', Profile_Name__c = 'IND Management',
        Profile_ID__c = [SELECT Id FROM Profile WHERE Name='Standard User'].id);
        insert rc;
        Role_connector__c rc1 = new Role_connector__c(Role_Name__c = 'SEC', Profile_Name__c = 'WOD Management',
        Profile_ID__c = [SELECT Id FROM Profile WHERE Name='Standard User'].id);
        insert rc1;

    }    
    
    public static User[] createUser(Integer n, Boolean ProfileIdNull) {
        User[] users = new User[] {};
            for (Integer i = 0; i < n; i++) {
                if(i ==0)
                users.add(createUser('IND Management','IND', ProfileIdNull));
                else
                users.add(createUser('WOD Management','WOD', ProfileIdNull));
            }
        
        //RA 11/22/2018 - Consider Routes
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Route__c r = new Route__c();
            r.WSLRNbrRouteNbr__c = 'REG220922_TAM02';
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
        
        
               
            List<User> usrs = createUser(2, false);
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
                rc.Role_Name__c = 'SEC';
                Test.setCurrentPage(Page.AB_UserPortalContact);
                ApexPages.currentPage().getParameters().put('id', usr.id);
                
                AB_UserPortalContactExtension obj = new AB_UserPortalContactExtension();
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
        
               
            List<User> usrs = createUser(2, true);
            insert usrs;
             User u = [SELECT id, name, UserRoleId,Alias,Email,EmailEncodingKey, 
                       LastName,LanguageLocaleKey,LocaleSidKey,
                       ProfileId,TimeZoneSidKey,UserName from user WHERE LastName = 'ProfileNull' limit 1];
        System.runAs(u) {     
            for(User usr : usrs) {
                Role_connector__c rc = new Role_connector__c();
                rc.Profile_ID__c = usrs[0].profileid;
                rc.Profile_Name__c = 'WOD Management';
                rc.Role_Name__c = 'SEC';
                Test.setCurrentPage(Page.AB_UserPortalContact);
                ApexPages.currentPage().getParameters().put('id', usr.id);
                
                AB_UserPortalContactExtension obj = new AB_UserPortalContactExtension();
                obj.getRoleTypes();
                obj.getSubRouteNums();
                obj.getRouteOptions();
                obj.getUpdateLolaAccess();
                obj.selRolePickVal = 'SEC';
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
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND Id !=: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        User newDisUsr = createUser('ABI_Dispatcher_FSL','WOD',false);
        newDisUsr.Wholesaler_Number__c = '998877';
        newDisUsr.IsActive = true;
        Insert newDisUsr;
        
        User newUsr = createUser('ABI_Merchandiser_FSL','WOD',false);
        newUsr.Wholesaler_Number__c = '998877';
        newUsr.IsActive = true;
        Insert newUsr;
        
        System.runAs(newDisUsr){
            OperatingHours oh = new OperatingHours();
            oh.Name = 'TestOH';
            insert oh;
            
            ServiceTerritory st = new ServiceTerritory();
            st.Name = 'Ser Terr';
            st.OwnerId = newUsr.Id;
            st.OperatingHoursId = oh.Id;
            st.IsActive = true;
            Insert st;
        }
        System.runAs(u){
            Test.startTest();
            AB_UserPortalContactExtension cls = new AB_UserPortalContactExtension();
            cls.newUserId = newUsr.Id;
            cls.createServiceResource();
            ServiceResource sReq = new ServiceResource();
            sReq.Name = 'Test';
            sReq.IsActive = true;
            //sReq.ResourceType = 'Technician';
            //sReq.IsOptimizationCapable = true;
            cls.newUserId = newUsr.Id;
            sReq.RelatedRecordId = newUsr.Id;
            //Insert sReq;
            //cls.createServiceResource();
            Test.stopTest();
        }
        
    }
    
    public static testmethod void createServiceResourceExist()
    {
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND Id !=: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        User newDisUsr = createUser('ABI_Dispatcher_FSL','WOD',false);
        newDisUsr.Wholesaler_Number__c = '998877';
        newDisUsr.IsActive = true;
        Insert newDisUsr;
        
        User newUsr = createUser('ABI_Merchandiser_FSL','WOD',false);
        newUsr.Wholesaler_Number__c = '998877';
        newUsr.IsActive = true;
        Insert newUsr;
        
        System.runAs(newDisUsr){
            OperatingHours oh = new OperatingHours();
            oh.Name = 'TestOH';
            insert oh;
            
            ServiceTerritory st = new ServiceTerritory();
            st.Name = 'Ser Terr';
            st.OwnerId = newUsr.Id;
            st.OperatingHoursId = oh.Id;
            st.IsActive = true;
            Insert st;
            
            ServiceResource sReq = new ServiceResource();
            sReq.Name = 'Test';
            sReq.IsActive = true;
            //sReq.ResourceType = 'Technician';
            //sReq.IsOptimizationCapable = true;
            sReq.RelatedRecordId = newUsr.Id;
            sReq.IsActive = false;
            Insert sReq;
        }
        System.runAs(u){
            Test.startTest();
            AB_UserPortalContactExtension cls = new AB_UserPortalContactExtension();
            cls.newUserId = newUsr.Id;
            cls.createServiceResource();
            Test.stopTest();
        }
        
    }
    
    public static testmethod void createServiceResourceException()
    {
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND Id !=: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        User newDisUsr = createUser('ABI_Dispatcher_FSL','WOD',false);
        newDisUsr.Wholesaler_Number__c = '998877';
        newDisUsr.IsActive = true;
        Insert newDisUsr;
        
        User newUsr = createUser('ABI_Merchandiser_FSL','WOD',false);
        newUsr.Wholesaler_Number__c = '998877';
        newUsr.IsActive = true;
        Insert newUsr;
        
        System.runAs(newDisUsr){
            OperatingHours oh = new OperatingHours();
            oh.Name = 'TestOH';
            insert oh;
            
            ServiceTerritory st = new ServiceTerritory();
            st.Name = 'Ser Terr';
            st.OwnerId = newUsr.Id;
            st.OperatingHoursId = oh.Id;
            Insert st;
            
            ServiceResource sReq = new ServiceResource();
            sReq.Name = 'Test';
            sReq.IsActive = true;
            //sReq.ResourceType = 'Technician';
            //sReq.IsOptimizationCapable = true;
            sReq.RelatedRecordId = newUsr.Id;
            sReq.IsActive = false;
            Insert sReq;
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
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'WOD');
        insert r1;
        
               
        User newUsr = createUser('Telesales Team Lead','WOD',false);
        newUsr.Wholesaler_Number__c = '998877';
        newUsr.IsActive = true;
        newUsr.Title = 'Merchandiser';
        Insert newUsr;
        
        List<User> usrs = new List<User>{newUsr};
        System.runAs(newUsr) {     
            for(User usr : usrs) {
                Role_connector__c rc = new Role_connector__c();
                rc.Profile_ID__c = usrs[0].profileid;
                rc.Profile_Name__c = 'Telesales Team Lead';
                rc.Role_Name__c = 'Merchandiser';
                Test.setCurrentPage(Page.AB_UserPortalContact);
                ApexPages.currentPage().getParameters().put('id', usr.id);
                
                AB_UserPortalContactExtension obj = new AB_UserPortalContactExtension();
                obj.getRoleTypes();
                obj.getSubRouteNums();
                obj.getRouteOptions();
                obj.getUpdateLolaAccess();
                obj.selRolePickVal = 'Merchandiser';
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