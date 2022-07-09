@isTest
public with sharing class testForInvoice {
    
    private static String Invoice_Number;
    private static Id Ids;
    public static ForInvoice getForInvoice(Opportunity opp) {
        PageReference testPage = page.PDFGenerator;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opp.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(opp);     
        return new ForInvoice(sc); 
    }

    @TestSetup
    public static void makeData(){

        Account account = new Account(name='ivan20');
        insert account;

        Opportunity opp = new Opportunity(name = 'ddd', AccountId=account.id, closedate=Date.today(), StageName='Prospecting');
        insert opp;
        Invoice_Number=[SELECT Invoice_Number__c FROM opportunity WHERE id=:opp.id][0].Invoice_Number__c;
 Product2 objProduct = new Product2();
        objProduct.Name = 'Test';
        objProduct.Description = 'Test';
        Insert objProduct;
        
        PricebookEntry objPBEntry = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id=objProduct.Id,UnitPrice=2,IsActive=true);
        Insert objPBEntry;


        OpportunityLineItem product = new OpportunityLineItem(PriceBookEntryId =objPBEntry.id, Quantity=4, UnitPrice=2,opportunityid=opp.id);
        insert product;


        Contact contact = new Contact(FirstName='12',
        LastName='234',email='123@gmail.com', phone='2233221122', accountid=account.id);
         insert contact;
        OpportunityContactRole oppcontact = new OpportunityContactRole(contactid=contact.id, opportunityid=opp.id, isprimary=true);
        
        insert oppcontact;
        
    }

	
    public static void setupInvoiceNumber() {
        Invoice_Number = [SELECT Invoice_Number__c FROM Opportunity][0].Invoice_Number__c;
    }
    
    @isTest
    public static void testGetContact() {
        setupInvoiceNumber();
        Opportunity opp = [SELECT id, Invoice_Number__c, name FROM Opportunity WHERE Invoice_Number__c =: Invoice_Number];

        OpportunityContactRole opportunityContacrs = [SELECT contactid FROM OpportunityContactRole WHERE isprimary=:true AND opportunityid =: opp.id LIMIT 1];
        Contact contact =[SELECT name, email, phone, accountid FROM contact WHERE id=:opportunityContacrs.contactid][0];
          
        ForInvoice ext = getForInvoice(opp); 

        System.assertEquals(ext.getContact(), contact);
    }

    @isTest
    public static void testGetAccount() {
        setupInvoiceNumber();
        Opportunity opp = [SELECT id, Invoice_Number__c, name FROM Opportunity WHERE Invoice_Number__c =: Invoice_Number];

        OpportunityContactRole opportunityContacrs=[SELECT contactid FROM OpportunityContactRole WHERE isprimary=:true AND opportunityid =: opp.id LIMIT 1];
        Contact contact =[SELECT name, email, phone, accountid FROM contact WHERE id=:opportunityContacrs.contactid LIMIT 1][0];
        Account account=[SELECT name FROM account WHERE id=:contact.accountid LIMIT 1][0];

        ForInvoice ext = getForInvoice(opp); 

        System.assertEquals(ext.getAccount(), account);
    }

    @isTest
    public static void testGetProducts() {
        setupInvoiceNumber();
        Opportunity opp = [SELECT id, Invoice_Number__c, name FROM Opportunity WHERE Invoice_Number__c =: Invoice_Number];
        List<OpportunityLineItem> products = [SELECT Product2.Name, Quantity, UnitPrice, TotalPrice FROM OpportunityLineItem WHERE opportunityid =: opp.id];
        
        ForInvoice ext = getForInvoice(opp); 

        System.assertEquals(ext.getProducts(), products);
    }

    @isTest
    public static void testTotalPrice(){
        setupInvoiceNumber();
        Opportunity opp = [SELECT id, Invoice_Number__c, name FROM Opportunity WHERE Invoice_Number__c =: Invoice_Number];
        List<OpportunityLineItem> products = [SELECT Product2.Name, Quantity, UnitPrice, TotalPrice FROM OpportunityLineItem WHERE opportunityid =: opp.id];
        
        Double totalPrice = 0;

        for(OpportunityLineItem product : products) {
            totalPrice += product.TotalPrice;
        }

        ForInvoice ext = getForInvoice(opp); 

        System.assertEquals(ext.getTotalPrice(), totalPrice);
    }

    @isTest
    public static void testGetOpp(){
        setupInvoiceNumber();
        Opportunity opp = [SELECT Invoice_Number__c, id, ownerId FROM Opportunity  WHERE Invoice_Number__c =: Invoice_Number];

        ForInvoice ext = getForInvoice(opp); 

        System.assertEquals(ext.getOpp(), opp);
    }

    @isTest
    public static void testCreatePDFFileWithDocument() {
        setupInvoiceNumber();
        System.debug(testForInvoice.Invoice_Number);
        Opportunity opp = [SELECT id, Invoice_Number__c, name FROM Opportunity WHERE Invoice_Number__c =: Invoice_Number];
        
        ContentVersion contentVersion_1 = new ContentVersion(
      		Title = Invoice_Number,
      		PathOnClient = 'Penguins.jpg',
      		VersionData = Blob.valueOf('Test Content'),
      		IsMajorVersion = true
    	);
    	insert contentVersion_1;
        
        ForInvoice ext = getForInvoice(opp); 

        System.debug(ext.getOpp()); 
        System.assertEquals(ext.createPDFFile().getUrl(), getPageWhereWeWantToGo(opp).getUrl());
    }

    @isTest
    public static void testCreatePDFFileWithoutDocument() {
        setupInvoiceNumber();
        System.debug(testForInvoice.Invoice_Number);
        Opportunity opp = [SELECT id, Invoice_Number__c, name FROM Opportunity WHERE Invoice_Number__c =: Invoice_Number];
        
        ForInvoice ext = getForInvoice(opp); 

        System.debug(ext.getOpp()); 
        System.assertEquals(ext.createPDFFile().getUrl(), getPageWhereWeWantToGo(opp).getUrl());
    }
    
    public static Pagereference getPageWhereWeWantToGo(Opportunity opp) {
        PageReference pageWhereWeWantToGo = Page.PDFGenerator;
        pageWhereWeWantToGo.getParameters().put('id', opp.Id); 
        pageWhereWeWantToGo.setRedirect(true);
        return pageWhereWeWantToGo;
    }
}