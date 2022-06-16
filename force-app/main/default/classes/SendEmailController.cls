public with sharing class SendEmailController {

    @AuraEnabled(cacheable=true)
    public static EmailTemplate getEmailTemplate(){
        EmailTemplate emailtemp = [SELECT subject, body, id FROM EmailTemplate WHERE name =: 'EmailTemplate'];
        return emailtemp;
    }

    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunity(String ids){
        return [SELECT Invoice_number__c, Id FROM Opportunity WHERE id =: ids];
    }

    @AuraEnabled(cacheable=true)
    public static Contact getContactName(String ids){
        OpportunityContactRole opp = [SELECT ContactId, Id FROM OpportunityContactRole WHERE OpportunityId =: ids AND IsPrimary =: true];
        Contact contacts = [SELECT Name, Email, Phone, Accountid FROM Contact WHERE id =: opp.ContactId];
        return contacts;
    }

    @AuraEnabled(cacheable=true)
    public static ContentVersion retriveFiles(String title){
        ContentDocument doc = [SELECT id FROM ContentDocument WHERE title =: title];
        return [SELECT Id, Title, FileExtension, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: doc.id AND isLatest=:true];
    }

    @AuraEnabled(cacheable=true)
    public static void sendEmailToController(String body, String toSend, String subject, String opportunityId, String invoiceNumber){
        
        try {
            PageReference pdfPage = Page.PDFGenerator; 
            pdfPage.getParameters().put('id', opportunityId);
            Blob pdfBlob;

            if(Test.isRunningTest()) { 
                pdfBlob = blob.valueOf('Unit.Test');
            } else {
                pdfBlob = pdfPage.getContentAsPDF();
            }

            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setBody(pdfBlob);
            attach.setFileName(invoiceNumber + '.pdf');

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
            String[] toAddresses = new String[] { toSend };

            mail.setToAddresses(toAddresses);
            mail.setSubject(subject);
            mail.setreplyto('emailtemplate@2o297326jgp238lk39vz7q9tol1p8g6089qw9b9puqk5cv25uh.5i-kmybeag.ap26.apex.salesforce.com');
            mail.setHtmlBody('<h1>' + body + '</h1>');
            messaging.Email[] emails = new messaging.Email[] { mail };
            Messaging.sendEmail(emails);
            
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
}