global with sharing class MailingBatch implements Database.Batchable<sObject> {

    global database.querylocator start(Database.BatchableContext BC){
        Date today = system.today(); 
       
        String query = 'SELECT ID, Name, Email, Birthdate FROM Contact WHERE DAY_IN_MONTH(Birthdate) = ' + 
        today.day() +  ' AND CALENDAR_MONTH(Birthdate) = ' + today.month();

        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Contact> scope){
       
        for(Contact contact : scope) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
            String[] toAddresses = new String[] { contact.Email };
            mail.setToAddresses(toAddresses);
            mail.setUseSignature(false); 
            mail.setBccSender(false); 
            mail.setSaveAsActivity(false); 
            mail.setTargetObjectId(contact.Id);
            mail.setTemplateId([SELECT Id FROM EmailTemplate WHERE name =: 'birthday email template' LIMIT 1].Id);        
       
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
   
   global void finish(Database.BatchableContext BC){
   }
}
