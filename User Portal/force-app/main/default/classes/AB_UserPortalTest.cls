/*
Author Name : Scott Meidroth/Slalom
Date        : April 5, 2017
Description : Test class controller extensions for AB_UserPortalContact and AB_UserPortalHome pages
*/


@isTest
private class AB_UserPortalTest {

    @testSetup static void testSetup() {
        List<UserRole> roles1 = new List<UserRole>();
        List<UserRole> roles2 = new List<UserRole>();
        List<UserRole> roles3 = new List<UserRole>();
        List<User> users = new List<User>();
        UserRole r = new UserRole(DeveloperName = 'IIND_1', Name = 'IND - GREY EAGLE DISTRIBUTORS 22438/21228 Leadership');
        roles1.add(r);
        insert roles1;

        UserRole r1 = new UserRole(parentroleId=r.id, DeveloperName = 'IIND_2', Name = 'IND - GREY EAGLE DISTRIBUTORS - 22438');
        roles2.add(r1);

        userRole r2 = new UserRole(parentroleId=r.id, DeveloperName = 'IIND_3', Name = 'IND - GREY EAGLE DISTRIBUTORS - 21228'); 
        roles2.add(r2);
        insert roles2;

        UserRole r11 = new UserRole(parentroleId=r1.id, DeveloperName = 'IIND_2_1', Name = 'IND - GREY EAGLE DISTRIBUTORS - 22438 Owner ');
        roles3.add(r11);

        userRole r21 = new UserRole(parentroleId=r2.id, DeveloperName = 'IIND_3_1', Name = 'IND - GREY EAGLE DISTRIBUTORS - 21228 Owner ');
        roles3.add(r21);
        insert roles3;

         User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'IND Management'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id
        );
        
        users.add(u);
        
        User u2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'IND Management'].Id,
            LastName = 'last',
            Email = 'puser001@amamama.com',
            Username = 'puser001@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r2.Id
        );
        users.add(u2);
        
        User u3 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'IND Representative'].Id,
            LastName = 'last',
            Email = 'puser002@amamama.com',
            Username = 'puser002@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r11.Id
        );
        users.add(u3);
        
        User u4 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'IND Representative'].Id,
            LastName = 'last',
            Email = 'puser003@amamama.com',
            Username = 'puser003@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r21.Id
        );
        users.add(u4);
        
        insert users;
        //Creating records for Role connectore Femi Onakoya Daugherty. 1/21/2018
        String ProfileId = [SELECT Id FROM Profile WHERE Name = 'IND Representative'].Id;
        List<Role_connector__c> rcList = new List<Role_connector__c>();
        integer i =0;
        for(user usr : users) {
            System.runAs(usr){         
                Role_connector__c rc = new Role_connector__c(
                                            Profile_ID__c = ProfileId,
                                            Profile_Name__c = 'IND Representative',
                                            Role_Name__c = 'Sales Rep');
                if(i == 2)
                rc.Role_Name__c = 'Team Lead';
                insert rc;
                i++;
        }

        }
}

    public static testmethod void testContactInsertUpdate() {
        List<Account> accounts = AB_TestDataFactory.createAccounts(1, 'Wholesaler', false) ;
        for(Account a: accounts){
            a.name='TEST GREY EAGLE DISTRIBUTORS';
            a.WSLR_NBR_US__c='22438';
            a.MH_WSLR_PARTY_ID_US__c='22438';
            a.EDWID_US__c='22438';
            a.WSLR_TYP_CD_US__c='WS';
            

        }
        insert accounts;

        //get the NAZ User record type
        Id nazUsrRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('NAZ User').getRecordTypeId();
    
        List<Contact> lstContacts = new List<Contact>();
        
        for (integer j=0;j<50;j++){
            Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'Test' + String.valueOf(j),
            Email='tcontact' + String.valueOf(j) + '@amamama.com',
            Role_Picklist__c = 'Sales Rep',
            RecordTypeId=nazUsrRecTypeId,
            Account=accounts[0]

            );
            lstContacts.add(c);
        }
        insert lstContacts;

        for (Contact c:lstContacts){
            c.SRI_Access__c = true;
        }
        update lstContacts;

        for (Contact c:lstContacts) {
            c.SRI_Access__c = false;
        }
        update lstContacts;
    }


    
    public static testMethod void testUserPortalHome() {
        User u = [SELECT Name, Id, Email from User where Email = 'puser000@amamama.com'];
        User u3 = [SELECT Name, Id, Email from User where Email = 'puser002@amamama.com'];
        User u4 = [SELECT Name, Id, Email from User where Email = 'puser003@amamama.com'];
        Test.startTest();
        system.runAs(u){
        
        List<Account> accounts = AB_TestDataFactory.createAccounts(1, 'Wholesaler', false) ;
        for(Account a: accounts){
            a.name='TEST GREY EAGLE DISTRIBUTORS';
            a.WSLR_NBR_US__c='22438';
            a.MH_WSLR_PARTY_ID_US__c='22438';
            a.EDWID_US__c='22438';
            a.WSLR_TYP_CD_US__c='WS';
            a.OwnerId = u3.id;

        }
        insert accounts;
        accounts = AB_TestDataFactory.createAccounts(1, 'Wholesaler', false) ;
        for(Account a: accounts){
            a.name='TEST GREY EAGLE DISTRIBUTORS';
            a.WSLR_NBR_US__c='21228';
            a.MH_WSLR_PARTY_ID_US__c='22438';
            a.EDWID_US__c='99999';
            a.WSLR_TYP_CD_US__c='WS';
            a.OwnerId = u4.id;

        }
        insert accounts;
      
        //get the NAZ User record type
        Id nazUsrRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('NAZ User').getRecordTypeId();
    
        List<Contact> lstContacts = new List<Contact>();
        
        for (integer j=0;j<50;j++){
            Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'Test' + String.valueOf(j),
            Email='tcontact' + String.valueOf(j) + '@amamama.com',
            Role_Picklist__c = 'Sales Rep',
            RecordTypeId=nazUsrRecTypeId,
            Account=accounts[0]

            );
            lstContacts.add(c);
        }
        insert lstContacts;
        PageReference pageRef = Page.AB_UserPortalHome;
        pageRef.getParameters().put('sf', 'Name');
        pageRef.getParameters().put('sd', 'asc');
        pageRef.getParameters().put('pn','0');
        Test.setCurrentPage(pageRef);            
        List<Contact> contacts = new List<Contact>();
        AB_UserPortalHomeController controller = new AB_UserPortalHomeController();
        //List<userPortalWrapper> myContacts = controller.getMyContactsWrapper();


        controller.getMyContactsWrapper();
        controller.processSelected();

        pageRef = controller.Beginning();
        pageRef = controller.End();
        pageRef = controller.Next();
        pageRef = controller.Previous();

        //pageRef = controller.processSelected();
        controller.sortField = 'Name';
        controller.sortDirection = 'asc';
        Boolean ret = controller.getDisablePrevious();
        ret = controller.getDisableNext();
        integer i = controller.getPageNumber();
        i = controller.getTotalPages();
        i = controller.getTotal_Size();
        controller.sortToggle();
        PageReference pageref2 = controller.doNewContact();
        System.assertEquals(pageref2.getUrl(), '/apex/AB_UserPortalContact?pn=0&sd=asc&sf=Name');
        pageref2 = controller.doLogout();
        System.assertEquals(pageref2.getUrl(), '/secur/logout.jsp');

        //test null condition of helper method
        String myRoleName;
        Id myRoleId = u.id;
        myRoleName = AB_UserPortalHelpers.getUserRoleName(myRoleId);
        System.assertEquals(myRoleName, null);
        Test.stopTest();
        }    
    }
    
    public static testMethod void testUserPortalContactExtension() {
        User u = [SELECT Name, Id, Email from User where Email = 'puser000@amamama.com'];
        User u2 = [SELECT Name, Id, Email from User where Email = 'puser001@amamama.com'];
        User u3 = [SELECT Name, Id, Email from User where Email = 'puser002@amamama.com'];
        User u4 = [SELECT Name, Id, Email from User where Email = 'puser003@amamama.com'];
        UserRole r = [SELECT Id, UserRole.Name FROM UserRole WHERE DeveloperName = 'IIND_1' LIMIT 1];
        UserRole r1 = [SELECT Id, UserRole.Name FROM UserRole WHERE DeveloperName = 'IIND_2' LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.AB_UserPortalContact;
        

        pageRef.getParameters().put('sf', 'Name');
        pageRef.getParameters().put('sd', 'asc');
        pageRef.getParameters().put('pn','0');

        Test.setCurrentPage(pageRef);

        system.runAs(u){
            List<Account> accounts = AB_TestDataFactory.createAccounts(1, 'Wholesaler', false) ;
            for(Account a: accounts){
                a.name='TEST GREY EAGLE DISTRIBUTORS';
                a.WSLR_NBR_US__c='22438';
                a.MH_WSLR_PARTY_ID_US__c='22438';
                a.EDWID_US__c='22438';
                a.WSLR_TYP_CD_US__c='WS';
                a.OwnerId = u3.id;

            }
            insert accounts;
            accounts = AB_TestDataFactory.createAccounts(1, 'Wholesaler', false) ;
            for(Account a: accounts){
                a.name='TEST GREY EAGLE DISTRIBUTORS';
                a.WSLR_NBR_US__c='21228';
                a.MH_WSLR_PARTY_ID_US__c='22438';
                a.EDWID_US__c='99999';
                a.WSLR_TYP_CD_US__c='WS';
                a.OwnerId = u4.id;
            }
            insert accounts;

            Contact c = new Contact(
                FirstName = 'Test',
                LastName = 'Test',
                Email='tcontact@amamama.com',
                Role_Picklist__c = 'Sales Rep'
            );

            Contact c1 = new Contact(
                FirstName = 'Test Find Me',
                LastName = 'Test Find Me',
                Email='tFindMe@amamama.com',
                Role_Picklist__c = 'Sales Rep'
            );
            insert c1;

            PageReference pageRef2 = Page.AB_UserPortalContact;
            pageRef2.getParameters().put('sf', 'Name');
            pageRef2.getParameters().put('sd', 'asc');
            pageRef2.getParameters().put('pn','0');

            Test.setCurrentPage(pageRef2);
            AB_UserPortalContactExtension controller = new AB_UserPortalContactExtension(new ApexPages.StandardController(c));
            controller.selectedRole = r.id;
        
            pageRef2 = controller.doSave();
            System.assertEquals(pageref2.getUrl(), '/apex/AB_UserPortalHome?pn=0&sd=asc&sf=Name');
            controller.doCancel();

            c.Email='tFindMe@amamama.com';
            pageRef2 = controller.doSave();

            c.Email = 'tDonotFindMe@amamama.com';
            pageRef2 = controller.doSave();

            Contact c2 = new Contact(
                FirstName = 'Test Find Me',
                LastName = 'Test Find Me',
                Email='tFindMe@amamama.com',
                Role_Picklist__c = 'Sales Rep'
            );

           controller = new AB_UserPortalContactExtension(new ApexPages.StandardController(c2));
           PageReference pageRef3 = controller.doSave();

        }
        system.RunAs(u){
            Contact c2 = new Contact(
                FirstName = 'Test2',
                LastName = 'Test2',
                Email='tcontact2@amamama.com',
                Role_Picklist__c = 'Team Lead',
                SRI_Access__c = true
            );

            PageReference pageRef2 = Page.AB_UserPortalContact;
            pageRef2.getParameters().put('sf', 'Name');
            pageRef2.getParameters().put('sd', 'asc');
            pageRef2.getParameters().put('pn','0');

            Test.setCurrentPage(pageRef2);

            AB_UserPortalContactExtension controller = new AB_UserPortalContactExtension(new ApexPages.StandardController(c2));
        
            controller.selectedRole = r1.id;
            controller.doSave();
            pageRef2 = controller.doCancel();
            System.assertEquals(pageref2.getUrl(), '/apex/AB_UserPortalHome?pn=0&sd=asc&sf=Name');

            
            
        }

        system.RunAs(u2){   
            Contact c2 = new Contact(
                FirstName = 'Test2',
                LastName = 'Test2',
                Email='tcontact2@amamama.com',
                Role_Picklist__c = 'Team Lead',
                SRI_Access__c = true
            );
            PageReference pageRef2 = Page.AB_UserPortalContact;
            pageRef2.getParameters().put('sf', 'Name');
            pageRef2.getParameters().put('sd', 'asc');
            pageRef2.getParameters().put('pn','0');
            Test.setCurrentPage(pageRef2);
            AB_UserPortalContactExtension controller = new AB_UserPortalContactExtension(new ApexPages.StandardController(c2));
            controller.selectedRole = r.id;
            controller.doSave();
            pageRef2 = controller.doCancel();
            System.assertEquals(pageref2.getUrl(), '/apex/AB_UserPortalHome?pn=0&sd=asc&sf=Name');
            
            c2 = [SELECT SRI_Access__c, Email from Contact where Email = 'tcontact2@amamama.com' Limit 1];
            c2.SRI_Access__c = false;
            update c2;

            c2.SRI_Access__c = true;
            update c2;


        }

        system.RunAs(u2){
            Contact c2 = new Contact(
                FirstName = 'Test2',
                LastName = 'Test2',
                Email='tcontact2@amamama.com',
                Role_Picklist__c = 'Team Lead'
            );
            insert c2;
            PageReference pageRef3 = Page.AB_UserPortalContact;
            pageRef3.getParameters().put('sf', 'Name');
            pageRef3.getParameters().put('sd', 'asc');
            pageRef3.getParameters().put('pn','0');
            pageRef3.getParameters().put('id', c2.id);
            Test.setCurrentPage(pageRef3);
            AB_UserPortalContactExtension controller = new AB_UserPortalContactExtension(new ApexPages.StandardController(c2));
            controller.selectedRole = r.id;
            controller.doSave();
            pageRef3 = controller.doCancel();
            System.assertEquals(pageref3.getUrl(), '/apex/AB_UserPortalHome?pn=0&sd=asc&sf=Name');
            controller.doRemoveUser();
        }
        Test.stopTest(); 
    }

}