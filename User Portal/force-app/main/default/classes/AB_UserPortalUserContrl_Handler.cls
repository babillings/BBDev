/*
    Auhtor Name : Femi
    Date        : July 4th, 2017
    Description : create a user handler
*/
public class AB_UserPortalUserContrl_Handler {

    Public static Map<String,Profile> getProfiles(){
        Map<String, Profile> profiles = new Map<String, Profile>();
        for(Profile pr : [select Name, Id from Profile]){
            profiles.put(pr.Name, pr);
        }
        return profiles;
    }

    Public static Map<String,UserRole> getRoles(){
        Map<String, UserRole> userRoles = new Map<String, UserRole>();
        for (UserRole ur : [Select Name, Id from UserRole]){
            userRoles.put(ur.Name, ur);
        }
        return userRoles;
    }

    public static List<User> prefillUserFields(List<User> users, String whslrType) {
        if(users != null && !users.isEmpty()){
            Map<String, Profile> profiles = getProfiles();
            system.debug('***profiles: '+profiles);
            //String profile = '';
            
            for(User usr : users){
                //set the roleid and the profileid based on the account and the role
                String role = usr.Title ;
                system.debug('***'+role);
                system.debug('***whslrType: '+whslrType);
                /*iif (!String.isEmpty(role)){
                    if(profiles.containsKey(whslrType + ' '+role))
                        profile = String.valueOf(profiles.get(whslrType + ' '+role).id);
                    else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,'Profile is not available for the selected Role.'));
                        return null;
                    }
                    f(whslrType == 'IND') {
                    
                        if (role==Label.SalesRep) {
                            profile = String.valueOf(profiles.get(whslrType + ' Representative').id);
                        } else if (role==Label.SalesManager) {
                            profile = String.valueOf(profiles.get(whslrType + ' Management').id);
                        } else if (role==Label.EAM) {
                            profile = String.valueOf(profiles.get(whslrType + ' Management').id);
                        } else if (role==Label.SEC) {
                            profile = String.valueOf(profiles.get(whslrType + ' Management').id);
                        } else if (role==Label.TeamLead) {
                            profile = String.valueOf(profiles.get(whslrType + ' Lead').id);
                        } else if (role==Label.Merchandiser) {
                            profile = String.valueOf(profiles.get(whslrTYpe + ' Merchandiser').id);
                        } else {
                            profile='Unknown';
                        }
                         
                    }
                    else if(whslrType == 'WOD') {
                        if (role=='Lead') {
                            profile = String.valueOf(profiles.get(whslrType + ' Lead').id);
                        } else if (role=='Logistics Forecaster') {
                            profile = String.valueOf(profiles.get(whslrType + ' Logistics Forecaster').id);
                        } else if (role=='Management') {
                            profile = String.valueOf(profiles.get(whslrType + ' Management').id);
                        } else if (role=='Merchandiser') {
                            profile = String.valueOf(profiles.get(whslrType + ' Merchandiser').id);
                        } else if (role=='Sign Shop') {
                            profile = String.valueOf(profiles.get(whslrType + ' Sign Shop').id);
                        } else if (role=='Tech Logistics') {
                            profile = String.valueOf(profiles.get(whslrTYpe + ' Tech Logistics').id);
                        } else {
                            profile='Unknown';
                        }
                    }
                }*/
                //Setting other mandatory fields
                if(usr.Email != null) {
                    usr.FederationIdentifier = usr.Email.left(40);
                    usr.Alias = usr.Email.left(8);
                    usr.CommunityNickname = usr.Email.left(40);
                    usr.Username = usr.Email;
                    system.debug('***Username: '+usr.Username);
                }
                //usr.ProfileId = profile;
                usr.TimeZoneSidKey =  UserInfo.getTimeZone().getID();
                usr.LocaleSidKey = 'en_US';
                usr.EmailEncodingKey = 'ISO-8859-1';
                usr.DefaultDivision = [Select Id from Division where Name = 'USA' limit 1].id;
                usr.LanguageLocaleKey = 'en_US';
                usr.Send_To_Global__c = true;
            }
        }
        return users;
    }
}