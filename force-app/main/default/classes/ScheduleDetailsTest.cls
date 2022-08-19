@isTest
public with sharing class ScheduleDetailsTest {
    
    static String NameCronJobDetail = 'MailingBatchSchedule';
    static String CRONstr = '0 12 12 12 12 ? 2022';
    static String BatchName = 'MailingBatch';

    @testSetup
    static void makeData() {
        ScheduleDetails.startSchedulable(NameCronJobDetail, CRONstr, BatchName);
    }

    static testMethod void testCronJobDetail() {
        System.assertEquals(ScheduleDetails.isCronJobDetail(NameCronJobDetail), true);
    } 

    static testMethod void testNotExistCronJobDetail() {
        ScheduleDetails.stopSchedulable(NameCronJobDetail);
        System.assertEquals(ScheduleDetails.isCronJobDetail(NameCronJobDetail), false);
    } 
    

    static testMethod void testGetCRON() {
        System.assertEquals(ScheduleDetails.getCRON(NameCronJobDetail), CRONstr);
    } 

    static testMethod void testGetNotExistCRON() {
        ScheduleDetails.stopSchedulable(NameCronJobDetail);
        System.assertEquals(ScheduleDetails.getCRON(NameCronJobDetail), '0 0 0 * * ?');
    } 

    static testMethod void testIsWorkedTrigger() {
        System.assertEquals(ScheduleDetails.isWorkedTrigger(NameCronJobDetail), true);
    } 

    static testMethod void testRunBatch() {
        System.assertEquals(ScheduleDetails.runBatch(BatchName) == null, false);
    } 

}
