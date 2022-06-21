@isTest (SeeAllData=true)
public with sharing class testAccountDetailsController {
    
    private static final String ids = '0015i000007xBqhAAE';
    private static final String accountWithoutCLosedOppIds = '0015i000002qe48AAA';

    private static final String oppIdWithProducts = '0065i000002KhzYAAS';
    private static final String oppIdWithoutProducts = '0065i000002KhzZAAS';

    private static final String incorrectIds = '0123';
    private static final String partOFAccName = 'd';
    private static final Decimal totalAmount = 501460200;
    private static final Integer queryLimit = 10;
    private static final Integer offset = 10;


    @isTest
    public static void testGetOppoortunitiesForOneAccount() {
        List<Opportunity> accountOpps = [SELECT id,name,closedate, createddate, amount FROM Opportunity WHERE accountid =: ids AND isclosed =: true];
        System.assertEquals(accountOpps, AccountDetailsController.getOppoortunitiesForOneAccount(ids));
    }

    @isTest
    public static void testGetOppoortunitiesForOneAccountWithoutClosedOpps() {
        List<Opportunity> accountOpps = [SELECT id,name,closedate, createddate, amount FROM Opportunity WHERE accountid =: accountWithoutCLosedOppIds AND isclosed =: true];
        System.assertEquals(accountOpps, AccountDetailsController.getOppoortunitiesForOneAccount(accountWithoutCLosedOppIds));
    }

    @isTest
    public static void testGetOppoortunitiesForIncorrectAccount() {
        List<Opportunity> accountOpps = [SELECT id,name,closedate, createddate, amount FROM Opportunity WHERE accountid =: incorrectIds AND isclosed =: true];
        System.assertEquals(accountOpps, AccountDetailsController.getOppoortunitiesForOneAccount(incorrectIds));
    }

    @isTest
    public static void testSearchCountWithNameAndPrice() {
        Integer count = [SELECT COUNT() FROM account WHERE name LIKE :'%' + partOFAccName  + '%'  AND Amount_Sum__c =: totalAmount];
        System.assertEquals(count, AccountDetailsController.searchCount(partOFAccName, totalAmount));
    }

    @isTest
    public static void testSearchCountWithName() {
        Integer count = [SELECT COUNT() FROM account WHERE name LIKE :'%' + partOFAccName  + '%'];
        System.assertEquals(count, AccountDetailsController.searchCount(partOFAccName, 0));
    }

    @isTest
    public static void testSearchCountWithIncorrectName() {
        String partOfIncorrectName = 'qwertyuiop';
        Integer count = [SELECT COUNT() FROM account WHERE name LIKE :'%' + partOfIncorrectName  + '%'];
        System.assertEquals(count, AccountDetailsController.searchCount(partOfIncorrectName, 0));
    }

    @isTest
    public static void testSearchCountWithPrice() {
        Integer count = [SELECT COUNT() FROM account WHERE Amount_Sum__c =: totalAmount];
        System.assertEquals(count, AccountDetailsController.searchCount(null, totalAmount));
    }

    @isTest
    public static void testSearchCountWithIncorrectPrice() {
        Integer count = [SELECT COUNT() FROM account WHERE Amount_Sum__c =: 12];
        System.assertEquals(count, AccountDetailsController.searchCount(null, 12));
    }

    @isTest
    public static void testSearchCount() {
        Integer count = [SELECT COUNT() FROM account];
        System.assertEquals(count, AccountDetailsController.searchCount(null, 0));
    }

    @isTest
    public static void testGetProducts(){
        List<OpportunityLineItem> items = [SELECT name, Quantity, UnitPrice, TotalPrice, id FROM OpportunityLineItem WHERE opportunityid =: oppIdWithProducts];
        System.assertEquals(items, AccountDetailsController.getProducts(oppIdWithProducts));
    }

    @isTest
    public static void testGetProductsForOppWithoutProducts(){
        List<OpportunityLineItem> items = [SELECT name, Quantity, UnitPrice, TotalPrice, id FROM OpportunityLineItem WHERE opportunityid =: oppIdWithoutProducts];
        System.assertEquals(items, AccountDetailsController.getProducts(oppIdWithoutProducts));
    }

    @isTest
    public static void testSearchAccountsWithOpportunities() {
        List<Account> accs = [SELECT id, name, Amount_Sum__c,
        (SELECT id,name,closedate, createddate, amount
        FROM opportunities WHERE isclosed =: true)
        FROM account LIMIT : queryLimit OFFSET : offset];
        System.assertEquals(accs, AccountDetailsController.searchAccountsWithOpportunities(queryLimit, offset, null, 0));
    }

    @isTest
    public static void testSearchAccountsWithOpportunitiesWithNameAndPrice() {
        List<Account> accs = [SELECT id, name, Amount_Sum__c,
        (SELECT id,name,closedate, createddate, amount
        FROM opportunities WHERE isclosed =: true)
        FROM account WHERE name LIKE :'%' + partOFAccName  + '%'  AND Amount_Sum__c =: totalAmount LIMIT : queryLimit OFFSET : offset];
        System.assertEquals(accs, AccountDetailsController.searchAccountsWithOpportunities(queryLimit, offset, partOFAccName, totalAmount));
    }

    @isTest
    public static void testSearchAccountsWithOpportunitiesWithName() {
        List<Account> accs = [SELECT id, name, Amount_Sum__c,
        (SELECT id,name,closedate, createddate, amount
        FROM opportunities WHERE isclosed =: true)
        FROM account WHERE name LIKE :'%' + partOFAccName  + '%' LIMIT : queryLimit OFFSET : offset];
        System.assertEquals(accs, AccountDetailsController.searchAccountsWithOpportunities(queryLimit, offset, partOFAccName, 0));
    }

    @isTest
    public static void testSearchAccountsWithOpportunitiesWithPrice() {
        List<Account> accs = [SELECT id, name, Amount_Sum__c,
        (SELECT id,name,closedate, createddate, amount
        FROM opportunities WHERE isclosed =: true)
        FROM account WHERE Amount_Sum__c =: totalAmount LIMIT : queryLimit OFFSET : offset];
        System.assertEquals(accs, AccountDetailsController.searchAccountsWithOpportunities(queryLimit, offset, null, totalAmount));
    }

}