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
            account=[SELECT name FROM account WHERE id=:contact.accountid LIMIT 1][0];
        }
        return account;
    }

    List<OpportunityLineItem> products;

    public List<OpportunityLineItem> getProducts(){
        if(products==null){
            products=[Select Product2.Name, Quantity, UnitPrice, TotalPrice from OpportunityLineItem where opportunityid =: opportunity.id];
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

    public PageReference attachPDF() {
        PageReference pdfPage = Page.PDFGenerator;
        pdfPage.getParameters().put('id',opportunity.Id);
        opps=[select Invoice_Number__c, id from Opportunity where id =: opportunity.id];
        str=opps.Invoice_Number__c;
        Blob pdfBlob; 
        if (!Test.isRunningTest()) { 
            pdfBlob = pdfPage.getContentasPDF(); 
        } else { 
            pdfBlob = Blob.valueOf('Some Text');
        }
        attachment[] attchToDelete=[select  parentId, name, body from attachment where parentId=:opportunity.id and name=:str+'.pdf'];
        delete attchToDelete;
        
        Attachment attach = new Attachment(parentId = opportunity.Id, Name =str+'.pdf', body = pdfBlob);
        insert attach;
        
        List<ContentDocument> document=[select id, title from ContentDocument where title=:str limit 1];

        if(document.size() > 0){
        ContentVersion v = new ContentVersion();
        v.versionData=pdfBlob;
        v.title=str;
        v.ContentLocation='S';
        v.PathOnClient=str+'.pdf';
        v.ContentDocumentId=document[0].id;
        insert v;
        }  
        else{
            ContentVersion v = new ContentVersion();
            v.versionData=pdfBlob;
            v.title=str;
            v.ContentLocation='S';
            v.PathOnClient=str+'.pdf';
            insert v;
        }
        

        PageReference pageWhereWeWantToGo = Page.PDFGenerator;
        pageWhereWeWantToGo.getParameters().put('id',opportunity.Id); 
        pageWhereWeWantToGo.setRedirect(true);
        return pageWhereWeWantToGo;    
    }
}
