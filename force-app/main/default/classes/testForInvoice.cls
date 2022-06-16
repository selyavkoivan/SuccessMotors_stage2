@isTest(SeeAllData = true)
public with sharing class testForInvoice {
    
    static String Invoice_Number = 'INV-000002';

    static ForInvoice getForInvoice(Opportunity opp) {
        PageReference testPage = page.PDFGenerator;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opp.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(opp);     
        return new ForInvoice(sc); 
    }

    @isTest
    static void testGetContact() {
        Opportunity opp = [SELECT id, Invoice_Number__c, name FROM Opportunity WHERE Invoice_Number__c =: Invoice_Number];

        OpportunityContactRole opportunityContacrs = [SELECT contactid FROM OpportunityContactRole WHERE isprimary=:true AND opportunityid =: opp.id LIMIT 1];
        Contact contact =[SELECT name, email, phone, accountid FROM contact WHERE id=:opportunityContacrs.contactid][0];
          
        ForInvoice ext = getForInvoice(opp); 

        System.assertEquals(ext.getContact(), contact);
    }

    @isTest
    static void testGetAccount() {
        Opportunity opp = [SELECT id, Invoice_Number__c, name FROM Opportunity WHERE Invoice_Number__c =: Invoice_Number];

        OpportunityContactRole opportunityContacrs=[SELECT contactid FROM OpportunityContactRole WHERE isprimary=:true AND opportunityid =: opp.id LIMIT 1];
        Contact contact =[SELECT name, email, phone, accountid FROM contact WHERE id=:opportunityContacrs.contactid LIMIT 1][0];
        Account account=[SELECT name FROM account WHERE id=:contact.accountid LIMIT 1][0];

        ForInvoice ext = getForInvoice(opp); 

        System.assertEquals(ext.getAccount(), account);
    }

    @isTest
    static void testGetProducts() {
        Opportunity opp = [SELECT id, Invoice_Number__c, name FROM Opportunity WHERE Invoice_Number__c =: Invoice_Number];
        List<OpportunityLineItem> products = [SELECT Product2.Name, Quantity, UnitPrice, TotalPrice FROM OpportunityLineItem WHERE opportunityid =: opp.id];
        
        ForInvoice ext = getForInvoice(opp); 

        System.assertEquals(ext.getProducts(), products);
    }

    @isTest
    static void testTotalPrice(){
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
    static void testGetOpp(){
        Opportunity opp = [SELECT Invoice_Number__c, id, ownerId FROM Opportunity  WHERE Invoice_Number__c =: Invoice_Number];

        ForInvoice ext = getForInvoice(opp); 

        System.assertEquals(ext.getOpp(), opp);
    }

    @isTest
    static void testAttachPDF() {
        Opportunity opp = [SELECT id, Invoice_Number__c, name FROM Opportunity WHERE Invoice_Number__c =: Invoice_Number];
        
        ForInvoice ext = getForInvoice(opp); 

        System.debug(ext.getOpp()); 
        System.assertEquals(ext.attachPDF().getUrl(), getPageWhereWeWantToGo(opp).getUrl());
    }

    @isTest
    static void testAttachPDFWithoutAttachment() {
        Opportunity opp = [SELECT id, Invoice_Number__c, name FROM Opportunity WHERE Invoice_Number__c =: '' LIMIT 1];

        ForInvoice ext = getForInvoice(opp); 

        System.debug(ext.getOpp()); 
        System.assertEquals(ext.attachPDF().getUrl(), getPageWhereWeWantToGo(opp).getUrl());
    }

    static Pagereference getPageWhereWeWantToGo(Opportunity opp) {
        PageReference pageWhereWeWantToGo = Page.PDFGenerator;
        pageWhereWeWantToGo.getParameters().put('id', opp.Id); 
        pageWhereWeWantToGo.setRedirect(true);
        return pageWhereWeWantToGo;
    }
}
