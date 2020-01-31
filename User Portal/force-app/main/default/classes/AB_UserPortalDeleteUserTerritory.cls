public without sharing class AB_UserPortalDeleteUserTerritory implements Queueable{
    //@future
    public String userId;
    public AB_UserPortalDeleteUserTerritory(String userId)
    {
        this.userId = userId;
    }
    public void execute(QueueableContext context) {
        System.debug('User ID '+userId);
        //BRIANNA START
        //Query and check if User Territory exist
        List<FSL__User_Territory__c> list_UserTerr = new List<FSL__User_Territory__c>([SELECT Id,FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c =: userId]);
        //If there is an existing User Territory, start logic to delete it
        if(list_UserTerr != null && list_UserTerr.size() > 0)
        {
            delete list_UserTerr;
        }
            ///2nd DML operation
    }
}
