@isTest
public with sharing class PaymentManagerTest {

    @TestSetup
    public static void makeData(){
        Opportunity opp = new Opportunity();
        opp.CloseDate=date.today().addMonths(2);
        opp.Name='test opp';
        opp.StageName='IsWon';
        opp.Amount = 6000;
        insert opp;

        Opportunity opp2 = new Opportunity();
        opp2.CloseDate=date.today().addMonths(2);
        opp2.Name='test opp 2';
        opp2.StageName='IsWon';
        opp2.Amount = 6000;
        insert opp2;
    }

    @isTest
    static void testHttpPost() {
    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Payment/'; 
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;

        PaymentManager.Pay pay = new PaymentManager.Pay();
        pay.Amount = 8888;
        pay.FirstName = 'Ivan';
        pay.LastName = 'Sialiauka';
        pay.Opportunity = [SELECT Id FROM Opportunity WHERE Name =: 'test opp' LIMIT 1].Id;

        PaymentManager.Pay pay2 = new PaymentManager.Pay();
        pay2.Amount = 2000;
        pay2.FirstName = 'Ivan1';
        pay2.LastName = 'Sialiauka1';
        pay2.Opportunity = [SELECT Id FROM Opportunity WHERE Name =: 'test opp 2' LIMIT 1].Id;

        List<PaymentManager.Pay> pays = new List<PaymentManager.Pay> {pay, pay2};
        Test.startTest();
        PaymentManager.createPayments(pays);
        Test.stopTest();



        System.assertEquals([SELECT COUNT() FROM Payment__c], 2);
    }
}
