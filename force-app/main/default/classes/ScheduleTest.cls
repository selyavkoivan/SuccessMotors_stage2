@isTest
public with sharing class ScheduleTest {

    public static testmethod void testMailingBatchSchedule(){
            Test.startTest();
  
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            String jobId = System.schedule('MailingBatchScheduleTestJob', CRON_EXP, new MailingBatchSchedule());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 

            System.assertEquals(0, ct.TimesTriggered); 
            System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));   

            Test.stopTest();        
       }

       public static testmethod void testUniversalSchedule(){
            Test.startTest();

            String CRON_EXP = '0 0 0 3 9 ? 2022';
            String jobId = System.schedule('MailingBatchSchedule,MailingBatch', CRON_EXP, new UniversalScheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 

            System.assertEquals(0, ct.TimesTriggered); 
            System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));   

            Test.stopTest();        
   }
}
