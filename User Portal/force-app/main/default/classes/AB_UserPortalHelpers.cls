/*
Author Name : Scott Meidroth/Slalom
Date        : April 12, 2017
Description : helper methods for AB_UserPortalHomeController and AB_UserPortalContactExtension
*/

/*Test class: AB_UserPortalTest*/

public with sharing class AB_UserPortalHelpers {

		/*//BB START
		public static string getProfileName(Id profileId)
		{
			List<Profile> myProfile;
			String myProfileName;
			myProfile = [select name from Profile where id=:profileID];
		}
		//BB END*/
		public static string getUserRoleName(Id roleId) {
      		List<UserRole> myRole;
      		String myRoleName;
      		myRole = [Select name from UserRole where id=:roleId];
      		if(!myRole.isEmpty()){
        		myRoleName = myRole[0].Name;
        		return myRoleName;
      		} else {
      			return null;
			}
		}
}