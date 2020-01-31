trigger ServiceResourceTrigger on ServiceResource (before update) {

    switch on Trigger.operationType {

        when BEFORE_UPDATE { 

            //ServiceResourceHandler.DeactivateResource(trigger.newMap);
        }
    }
}