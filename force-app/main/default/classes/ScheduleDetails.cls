global with sharing class ScheduleDetails {

    public static ID IdCronJobDetail(String NameCronJobDetail){
        return [SELECT Id  FROM CronJobDetail WHERE Name like: NameCronJobDetail + ',%' LIMIT 1].Id;
    }
    
    public static Boolean isCronJobDetail(String NameCronJobDetail){
        Boolean isCron = true;
        List<CronJobDetail> CronJobDetails = [SELECT Id, Name  FROM CronJobDetail WHERE Name like: NameCronJobDetail + ',%' LIMIT 1];
        if(CronJobDetails.size() == 0 ) {
            isCron=false;
        }
        return isCron;
    }

    @AuraEnabled(cacheable=true)
    public static String getCRON(String NameCronJobDetail){
        if (isCronJobDetail(NameCronJobDetail)){
            ID IdCJD = IdCronJobDetail(NameCronJobDetail);    
            return [SELECT CronExpression  FROM CronTrigger WHERE CronJobDetailId =: IdCJD LIMIT 1].CronExpression;
        } else {
            return '0 0 0 * * ?';
        }
    }
    
    /*@AuraEnabled(cacheable=true)
    public static String getStateCronTrigger(String NameCronJobDetail){
        if (isCronJobDetail(NameCronJobDetail)) {
            Id IdCJD = IdCronJobDetail(NameCronJobDetail);
            return [SELECT State  FROM CronTrigger WHERE CronJobDetailId =: IdCJD LIMIT 1].State;
        } else { 
            return null;
        }
    }*/
    
    @AuraEnabled(cacheable=true)
    public static Boolean isWorkedTrigger(String NameCronJobDetail){
        boolean isWork = false;
        if (isCronJobDetail(NameCronJobDetail)) {
            isWork = true;
        }
        return isWork;
    }
    
    @AuraEnabled()
    public static void stopSchedulable(String NameCronJobDetail){
        Id IdCronJobDetail = IdCronJobDetail(NameCronJobDetail);
        Id jobId = [SELECT Id FROM CronTrigger WHERE CronJobDetailId =: IdCronJobDetail LIMIT 1].Id;
        System.abortJob(jobId);  
    }

    @AuraEnabled(cacheable=true)
    public static void startSchedulable(String NameCronJobDetail, String CRONstr, String BatchName){
        try {
            Type newSchedulerType = Type.forName(NameCronJobDetail);
		    System.schedule(NameCronJobDetail + ',' + BatchName, CRONstr, (Schedulable)newSchedulerType.newInstance());
        } catch (Exception e) {
            System.debug('error: ' + e.getMessage());
        }
    }     
    
    @AuraEnabled(cacheable=true)
    public static ID runBatch(String apexClass){     
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
