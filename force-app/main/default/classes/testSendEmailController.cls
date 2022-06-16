@isTest (SeeAllData=true)
public with sharing class testSendEmailController {

    static String emailAddress = 'selyavkosh2@gmail.com';
    static String subject = 'INV-000002';

    @isTest
    static void testGetEmailTemplate(){
        EmailTemplate emailtemp = [SELECT subject, body, id FROM EmailTemplate WHERE name =: 'EmailTemplate'];

        Test.startTest();
        System.assertEquals(SendEmailController.getEmailTemplate(), emailtemp);
        Test.stopTest();
    }

    @isTest
    static void testGetOpportunity(){
        Opportunity opp = [SELECT id, Invoice_number__c FROM Opportunity LIMIT 1];

        Test.startTest();
        System.assertEquals(SendEmailController.getOpportunity(opp.id), opp);
        Test.stopTest();
    }

    @isTest
    static void testGetContactName(){
        Opportunity opp = [SELECT id FROM Opportunity WHERE Invoice_number__c =: subject];
        OpportunityContactRole oppContactRole= [SELECT ContactId, Id FROM OpportunityContactRole WHERE OpportunityId =: opp.id AND  IsPrimary =: true LIMIT 1];
        Contact contacts = [SELECT Name, Email, Phone, Accountid FROM Contact WHERE id =: oppContactRole.ContactId];

        Test.startTest();
        System.assertEquals(SendEmailController.getContactName(opp.id), contacts);
        Test.stopTest();
    }

    @isTest
    static void testSendEmailToController(){
        Opportunity opp= [SELECT id, Invoice_number__c FROM Opportunity WHERE Invoice_number__c =: subject];
        Test.startTest();
        SendEmailController.sendEmailToController('test', emailAddress, 'test', opp.id, subject);
        Test.stopTest();
    }
}
