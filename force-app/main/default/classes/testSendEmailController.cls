@isTest
public with sharing class testSendEmailController {

    static String emailAddress = 'selyavkosh2@gmail.com';
    static String subject = 'INV-000002';

    @testSetup
    static void setupData() {
        Account acc = new Account(name='ivan');
        insert acc;
        
        Opportunity opp = new Opportunity(name='opppp', closedate=Date.today(), StageName='Closed Won');
        insert opp;

        Product2 objProduct = new Product2();
        objProduct.Name = 'Test';
        objProduct.Description = 'Test';
        Insert objProduct;
        
        PricebookEntry objPBEntry = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id=objProduct.Id,UnitPrice=2,IsActive=true);
        Insert objPBEntry;

        OpportunityLineItem product = new OpportunityLineItem(PriceBookEntryId =objPBEntry.id, Quantity=4, UnitPrice=2,opportunityid=opp.id);
        insert product;
        
        Contact contact = new Contact(FirstName='12',
        LastName='234',email='123@gmail.com', phone='2233221122', accountid=acc.id);
        insert contact;
        
        OpportunityContactRole oppcontact = new OpportunityContactRole(contactid=contact.id, opportunityid=opp.id, isprimary=true);
        insert oppcontact;

    }
    
    public static void setupIds() {
        subject = [SELECT Invoice_number__c FROM Opportunity LIMIT 1].Invoice_number__c;
    }
    
    @isTest
    static void testGetEmailTemplate(){
        EmailTemplate emailtemp = [SELECT subject, body, id FROM EmailTemplate WHERE name =: 'EmailTemplate'];
		system.debug(emailtemp.body);
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
        setupIds();
        
        Opportunity opp = [SELECT id FROM Opportunity WHERE Invoice_number__c =: subject];
        OpportunityContactRole oppContactRole= [SELECT ContactId, Id FROM OpportunityContactRole WHERE OpportunityId =: opp.id AND  IsPrimary =: true LIMIT 1];
        Contact contacts = [SELECT Name, Email, Phone, Accountid FROM Contact WHERE id =: oppContactRole.ContactId];

        Test.startTest();
        System.assertEquals(SendEmailController.getContactName(opp.id), contacts);
        Test.stopTest();
    }

    @isTest
    static void testSendEmailToController(){
        setupIds();
        Opportunity opp= [SELECT id, Invoice_number__c FROM Opportunity WHERE Invoice_number__c =: subject];
        Test.startTest();
        SendEmailController.sendEmailToController('test', emailAddress, 'test', opp.id, subject);
        Test.stopTest();
    }

    @isTest
    static void testSendEmailToControllerException(){
        setupIds();
        Opportunity opp= [SELECT id, Invoice_number__c FROM Opportunity WHERE Invoice_number__c =: subject];
        Test.startTest();
        SendEmailController.sendEmailToController(null, null,null, null, null);
        Test.stopTest();
    }

    @isTest
    static void testRetriveFiles(){
        ContentVersion newFile = new ContentVersion();
        newFile.PathOnClient = 'TestFile';
        newFile.Title = subject;
        newFile.VersionData = Blob.valueOf('sample content');
        insert newFile;
        
        //Create a new product
        Product2 testProduct = new Product2(Name='Test Product');
        insert testProduct;
        
        //Query the contentDocumentId
        ContentVersion insertedFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:newFile.Id];
        
        //Link the file with the product
        ContentDocumentLink linkedFile = new ContentDocumentLink(LinkedEntityId=testProduct.Id, ContentDocumentId=insertedFile.ContentDocumentId);
        insert linkedFile;
        
        ContentDocument doc = [SELECT id FROM ContentDocument WHERE title =: subject];
        ContentVersion version = [SELECT Id, Title, FileExtension, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: doc.id AND isLatest=:true];
        System.assertEquals(version, SendEmailController.retriveFiles(subject));
    }
}