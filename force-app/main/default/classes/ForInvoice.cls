public with sharing class ForInvoice {
    private final Opportunity opportunity;

    public ForInvoice(ApexPages.StandardController stdController){
        this.opportunity=(Opportunity)stdController.getRecord();
    }



    Contact contact = null;

    public Contact getContact(){
        if(contact==null){
            OpportunityContactRole opportunityContacrs=[SELECT contactid FROM OpportunityContactRole WHERE isprimary=:true AND opportunityid =: opportunity.id LIMIT 1];
            contact =[SELECT name, email, phone, accountid FROM contact WHERE id=:opportunityContacrs.contactid LIMIT 1][0];
        }
        return contact;
    }

    Account account = null;

    public Account getAccount(){
        if(account==null){
            if(contact == null) {
                contact = getContact();
            }
            account=[SELECT name FROM account WHERE id=:contact.accountid LIMIT 1][0];
        }
        return account;
    }

    List<OpportunityLineItem> products;

    public List<OpportunityLineItem> getProducts(){
        if(products==null){
            ids=opportunity.id;
            products = new List<OpportunityLineItem>();
            products.addAll([Select Product2.Name, Quantity, UnitPrice, TotalPrice from OpportunityLineItem where opportunityid =: opportunity.id]);
        }
        
        return products;
    }

    Double totalPrice = 0;

    public Double getTotalPrice() {
        if(products==null){ 
            products = getProducts();
        }
        for(OpportunityLineItem product : products) {
            totalPrice += product.TotalPrice;
        }
        return totalPrice; 
    }

    String ids;
    Opportunity opps;
    String str;

    public Opportunity getOpp(){
        opps=[select Invoice_Number__c, id, ownerId from Opportunity where id=:opportunity.id];
        ids=opportunity.id;
        return opps;
    }

    public PageReference createPDFFile() {
        PageReference pdfPage = Page.PDFGenerator;
        pdfPage.getParameters().put('id', opportunity.Id);
        opps = [SELECT Invoice_Number__c, id FROM Opportunity WHERE id =: opportunity.id];
        str = opps.Invoice_Number__c;
    
        Blob pdfBlob; 

        if (!Test.isRunningTest()) { 
            pdfBlob = pdfPage.getContentasPDF(); 
        } else { 
            pdfBlob = Blob.valueOf('Some Text');
        }

    
        
        List<ContentDocument> document=[SELECT id, title FROM ContentDocument WHERE title=:str limit 1];
        
        if(document.size() > 0){
            document[0].parentId = opportunity.id;
            ContentVersion version = new ContentVersion();
            version.versionData = pdfBlob;
            version.title = str;
            version.ContentLocation = 'S';
            version.PathOnClient = str + '.pdf';
            version.ContentDocumentId = document[0].id;
            insert version;
        
            delete [SELECT id FROM COntentDocumentLink WHERE LinkedEntityId =: opportunity.id];

            ContentDocumentLink link = new ContentDocumentLink();
            link.LinkedEntityId = opportunity.id;
            link.Visibility  = 'AllUsers';
            link.ShareType = 'V';
            link.ContentDocumentId = document[0].id;
            insert link;

        }  
        else{
            ContentVersion version = new ContentVersion();
            version.versionData = pdfBlob;
            version.title = str;
            version.ContentLocation = 'S';
            version.PathOnClient = str+'.pdf';
            insert version;
        }
        
        

        PageReference pageWhereWeWantToGo = Page.PDFGenerator;
        pageWhereWeWantToGo.getParameters().put('id',opportunity.Id); 
        pageWhereWeWantToGo.setRedirect(true);
        return pageWhereWeWantToGo;    
    }
}
