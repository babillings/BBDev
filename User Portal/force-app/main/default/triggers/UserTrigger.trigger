trigger UserTrigger on User (before insert,before update,after insert,after update) {

    //trigger events on User
    if(Trigger.isbefore && Trigger.isInsert)
    {
        UserTriggerHandler.beforeInsert(trigger.new);
        
        //Femi: This will link Manager id for new creating Merchandiser user with Dispather user who has same wholesaler number
        UserTriggerHandler.populateManagerIdForMerchandiser(trigger.new,null); 
    }  

    if(Trigger.isbefore && Trigger.isUpdate)
    {
        UserTriggerHandler.beforeUpdate(trigger.new,trigger.oldMap);
        
        //Femi: This will delink Manager id for existing Merchandiser user on update Dispather user who has same wholesaler number 
        //and becoming inactive or on profile change from Dispather to other
        UserTriggerHandler.DelinkMerchandisersToDisManagers(trigger.new,Trigger.OldMap); 
        
        //Femi: This will link Manager id for updated Merchandiser users with Dispather user who has same wholesaler number
        UserTriggerHandler.populateManagerIdForMerchandiser(trigger.new,Trigger.OldMap); 
    }  


    if(trigger.isAfter && trigger.isInsert)
    {   
        UserTriggerHandler.afterInsert(trigger.new);
        
        //Femi: This will link Manager id for existing Merchandiser user on creation Dispather user who has same wholesaler number 
        UserTriggerHandler.linkMerchandisersToDisManagers(trigger.new,null);
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {   
        UserTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
        
        //Femi: This will link Manager id for existing Merchandiser user on updating Dispather user who has same wholesaler number
        //and becoming Active or Profile getting changed to Dispather 
        UserTriggerHandler.linkMerchandisersToDisManagers(trigger.new,trigger.oldMap);
    }
}