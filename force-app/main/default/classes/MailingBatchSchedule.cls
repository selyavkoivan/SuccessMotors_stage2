global with sharing class MailingBatchSchedule implements Schedulable {

    global void execute(SchedulableContext ctx) {
        MailingBatch birthdayBatch = new MailingBatch();
        database.executebatch(birthdayBatch);
    }
}
