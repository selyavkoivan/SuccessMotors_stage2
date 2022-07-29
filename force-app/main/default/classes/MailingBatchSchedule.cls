public with sharing class MailingBatchSchedule implements Schedulable {

    public void execute(SchedulableContext ctx) {
        MailingBatch birthdayBatch = new MailingBatch();
        database.executebatch(birthdayBatch);
    }
}
