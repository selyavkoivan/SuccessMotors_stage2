@RestResource(urlMapping='/Payment/*')
global with sharing class PaymentManager {
    @HttpPost
    global static void createPayments(List<Pay> payments) {
        List<Payment__c> paymentList = new List<Payment__c>();

        for (Pay payment : payments) {
            Opportunity op = [SELECT Id FROM Opportunity WHERE Id = :payment.Opportunity];
            paymentList.add( new Payment__c(Opportunity__c = op.Id, Amount__c = payment.Amount, 
            FirstName__c = payment.FirstName, LastName__c = payment.LastName));
        } 

        insert paymentList;
    }

    global class Pay {global String Opportunity; global Decimal Amount; global String FirstName; global String LastName;}
}
