@isTest
public class AB_UserPortalHomeController_v1_TEST {
    @testSetup
    public static void params()
    {
        Wholesaler_Lola_Access__c ob= new Wholesaler_Lola_Access__c(Wholesaler_Number__c = '51341', Name = 'My custom');
        insert ob;
    }
    
    @isTest
    public static void userportalinfo()
    {
        Test.startTest(); 
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='ABI_Dispatcher_FSL'];
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'ABI-ContractsDB');
        insert r;
        UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'WOD');
        insert r1;

        User u = new User(UserRoleId = r.Id,Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',Wholesaler_Number__c ='51341',
                          UserName=uniqueUserName);
        
        System.runAs(u) {        
        AB_UserPortalHomeController_v1 obj = new AB_UserPortalHomeController_v1();
            
        //AB_UserPortalHomeController_v1.userPortalWrapper obj1 = new AB_UserPortalHomeController_v1.userPortalWrapper(u);
          
        obj.buildQuery();
        obj.getMyUsersWrapper();
        obj.processSelected();  
        obj.doNewUser();
        obj.doLogout();
        obj.doSwitch();
       
        obj.Beginning();
        obj.Previous();
        obj.Next();
        obj.getDisablePrevious();
        obj.getDisableNext();
        obj.sortToggle();
        obj.getTotalPages();
        obj.getPageNumber();
        obj.getTotal_size();
        obj.getUpdateLolaAccess();

        obj.End();
        }
        Test.stopTest();
    }
    
    @isTest
    public static void userportalinfo2()
    {
        Test.startTest(); 
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='IND Management'];
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
		insert r;


        User u = new User(UserRoleId = r.Id,Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',Wholesaler_Number__c ='51341',
                          UserName=uniqueUserName);
        
        System.runAs(u) {        
        Test.setCurrentPage(Page.AB_UserPortalHome);
    ApexPages.currentPage().getParameters().put('pn', '0');
	ApexPages.currentPage().getParameters().put('sf', 'isActive');
	ApexPages.currentPage().getParameters().put('sd', 'desc');
            AB_UserPortalHomeController_V1 obj = new AB_UserPortalHomeController_V1();
        //AB_UserPortalHomeController_v1.userPortalWrapper obj1 = new AB_UserPortalHomeController_v1.userPortalWrapper(u);
            
        //obj.buildQuery();
        //obj.getMyUsersWrapper();
        obj.doResetPassword();
        //obj.End();
        }
        Test.stopTest();
    }   
     @isTest
    public static void userportalinfo3()
    {
        
        Test.startTest(); 
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='ABI_Dispatcher_FSL'];
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'ABI-ContractsDB');
		insert r;        
        User u = new User(UserRoleId = r.Id,Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',Wholesaler_Number__c ='51341',
                          UserName=uniqueUserName);
        
        AB_UserPortalHomeController_v1 obj = new AB_UserPortalHomeController_v1();
        //AB_UserPortalHomeController_v1.userPortalWrapper obj1 = new AB_UserPortalHomeController_v1.userPortalWrapper(u);
        obj.buildQuery();
        //obj.sortByUserTerritory();
        //obj.getMyUsersWrapper();        
           //obj1.selected = true;
        obj.processSelected();
        obj.getWholsalerNumber();
        Test.stopTest();
    }
    
    @IsTest
    Public static void userportalinfo4()
    {
        User newUsr = AB_UserPortalContactExtension_TEST.createUser('Telesales Team Lead','WOD',false);
        newUsr.Wholesaler_Number__c = '12345';
        newUsr.IsActive = true;
        Insert newUsr;

        System.runAs(newUsr){
            OperatingHours oh = new OperatingHours();
            oh.Name = 'TestOH';
            insert oh;
            
            ServiceTerritory st = new ServiceTerritory();
            st.Name = 'Denver';
            //st.OwnerId = newUsr.Id; //BB Comment Out
            st.OwnerId = newUsr.Id;//BB
            st.OperatingHoursId = oh.Id;
            st.IsActive = true;
            Insert st;

            //BB START
            FSL__User_Territory__c ut = new FSL__User_Territory__c();
            ut.FSL__ServiceTerritory__c = st.Id;
            ut.FSL__User__c = newUsr.Id;
            Insert ut;
            //BB END
           // }
        
        
        //system.runas(u)
        //{
        Test.setCurrentPage(Page.AB_UserPortalHome);
    ApexPages.currentPage().getParameters().put('pn', '0');
	ApexPages.currentPage().getParameters().put('sf', 'isActive');
	ApexPages.currentPage().getParameters().put('sd', 'desc');
            AB_UserPortalHomeController_v1 obj = new AB_UserPortalHomeController_v1();
            
        AB_UserPortalHomeController_v1.userPortalWrapper obj1 = new AB_UserPortalHomeController_v1.userPortalWrapper(newUsr,'Denver');
        obj.inContactAccess = true;
        obj.liveMsgAccess = true;
        obj.buildQuery();
        obj.getMyUsersWrapper();
        obj.doResetPassword();
        obj.End();
            
            
        }
    }
    
}