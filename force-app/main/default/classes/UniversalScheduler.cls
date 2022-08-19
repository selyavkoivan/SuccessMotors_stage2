global with sharing class UniversalScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        CronTrigger ct = [SELECT CronJobDetail.Name FROM CronTrigger WHERE Id =: ctx.getTriggerId()];
        runBatch(ct.CronJobDetail.Name.split(',')[1]);
    }

    @AuraEnabled(cacheable=true)
    global static ID runBatch(String apexClass){     
        Type t = Type.forName(apexClass);
        if (t == null){
           throw new TWSException (apexClass + ' not found');
        }
        Object s = t.newInstance();
        ID batchprocessid = Database.executeBatch((Database.Batchable<sObject>)s);
    
        return batchprocessid;    
    }

    public class TWSException extends Exception{}
}
