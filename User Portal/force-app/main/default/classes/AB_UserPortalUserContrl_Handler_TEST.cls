@isTest
public class AB_UserPortalUserContrl_Handler_TEST {
    
    public static User createUser() {
    User u = new User();
    u.username = 'usertest';
    u.alias = 'stduser';
    u.email = 'user@test.in';
    u.emailencodingkey = 'UTF-8';
    u.LastName = 'Test';
    system.debug('profile id is *****'+UserInfo.getProfileId());
    u.ProfileId = UserInfo.getProfileId();
    u.TimeZoneSidKey = 'America/New_York';
    return u;
  }
    
    public static User[] createUser(Integer n) {
    User[] users = new User[] {};
    for (Integer i = 0; i < n; i++) {
      users.add(createUser());
    }
        system.debug('users **************************************'+users);
    return users;
  }
    
    @isTest
    public static void userportalinfo()
    {
        Test.startTest(); 
        AB_UserPortalUserContrl_Handler ABUPUC = new AB_UserPortalUserContrl_Handler();
        AB_UserPortalUserContrl_Handler.getProfiles();
        AB_UserPortalUserContrl_Handler.getRoles();
        AB_UserPortalUserContrl_Handler.prefillUserFields(createUser(1), 'test');
        Test.stopTest();
    }
    

}