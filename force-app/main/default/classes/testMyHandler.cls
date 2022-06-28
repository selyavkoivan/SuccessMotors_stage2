@isTest(SeeAllData=true)
public with sharing class testMyHandler {
    

    static String emailAddress = 'selyavkosh2@gmail.com';
    static String subject = 'INV-000002';

    @isTest
    static void testInboundEmailWithoutNormalPlainTextBody(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        email.plainTextBody = 'qwertyuiop';
        email.fromAddress = emailAddress;
        email.subject = subject;

        myHandler edr = new myHandler();
        edr.handleInboundEmail(email,env); 

        Test.startTest();
        Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env);
        System.assertEquals(result.success, true);
        Test.stopTest();
    }

    @isTest
    static void testInboundEmailWithApproved(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        email.plainTextBody = 'Approved';
        email.fromAddress = emailAddress;
        email.subject = subject;

        myHandler edr = new myHandler();
        edr.handleInboundEmail(email,env); 

        Test.startTest();
        Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env);
        System.assertEquals(result.success, true);
        Test.stopTest();
    }

    @isTest
    static void testInboundEmailWithRejected(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        email.plainTextBody = 'Rejected';
        email.fromAddress = emailAddress;
        email.subject = subject;

        myHandler edr = new myHandler();
        edr.handleInboundEmail(email,env); 

        Test.startTest();
        Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env);
        System.assertEquals(result.success, true);
        Test.stopTest();
    }
}
