@isTest
public with sharing class testAccountDetailsController {
    
    private static String ids;
    private static String accountWithoutCLosedOppIds;

    private static String oppIdWithProducts;
    private static String oppIdWithoutProducts;

    private static final String incorrectIds = '0123';
    private static final String partOFAccName = 'i';
    private static final Decimal totalAmount = 8;
    private static final Integer queryLimit = 10;
    private static final Integer offset = 10;


    @testSetup
    public static void createRecordsForTest() {
        
        
        Account acc = new Account(name='ivan');
        Account accWithoutOpp = new Account(name='ivan');

        insert acc;
        insert accWithoutOpp;

        Opportunity opp = new Opportunity(accountId=acc.id, name='opppp', closedate=Date.today(), StageName='Closed Won');
        insert opp;

        Opportunity oppWithoutProduct = new Opportunity(accountId=acc.id, name='opppp', closedate=Date.today(), StageName='Closed Won');
        insert oppWithoutProduct;

        Product2 objProduct = new Product2();
        objProduct.Name = 'Test';
        objProduct.Description = 'Test';
        Insert objProduct;
        
        PricebookEntry objPBEntry = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id=objProduct.Id,UnitPrice=2,IsActive=true);
        Insert objPBEntry;


        OpportunityLineItem product = new OpportunityLineItem(PriceBookEntryId =objPBEntry.id, Quantity=4, UnitPrice=2,opportunityid=opp.id);
        insert product;
    }   

    public static void setupIds() {
        oppIdWithProducts = [SELECT id FROM Opportunity WHERE Count_of_Products__c > 0].id;
		oppIdWithoutProducts = [SELECT id FROM Opportunity WHERE Count_of_Products__c = 0].id;
        ids = [SELECT accountid FROM Opportunity WHERE Count_of_Products__c > 0].accountid;
        accountWithoutCLosedOppIds = [SELECT id FROM Account WHERE id !=: ids][0].id;
        
        System.Debug(oppIdWithProducts);
        System.Debug(oppIdWithoutProducts);
        System.Debug(ids);
        System.Debug(accountWithoutCLosedOppIds);
    }
    
    @isTest
    public static void testGetOppoortunitiesForOneAccount() {
        setupIds();
        List<Opportunity> accountOpps = [SELECT id,name,closedate, createddate, amount FROM Opportunity WHERE accountid =: ids AND isclosed =: true AND IsWon=: true AND Count_of_Products__c > 0];
        System.assertEquals(accountOpps, AccountDetailsController.getOppoortunitiesForOneAccount(ids));
    }

    @isTest
    public static void testGetOppoortunitiesForOneAccountWithoutClosedOpps() {
                setupIds();
        List<Opportunity> accountOpps = [SELECT id,name,closedate, createddate, amount FROM Opportunity WHERE accountid =: accountWithoutCLosedOppIds AND isclosed =: true];
        System.assertEquals(accountOpps, AccountDetailsController.getOppoortunitiesForOneAccount(accountWithoutCLosedOppIds));
    }

    @isTest
    public static void testGetOppoortunitiesForIncorrectAccount() {
                setupIds();
        List<Opportunity> accountOpps = [SELECT id,name,closedate, createddate, amount FROM Opportunity WHERE accountid =: incorrectIds AND isclosed =: true];
        System.assertEquals(accountOpps, AccountDetailsController.getOppoortunitiesForOneAccount(incorrectIds));
    }

    @isTest
    public static void testSearchCountWithNameAndPrice() {
                setupIds();
        Integer count = [SELECT COUNT() FROM account WHERE name LIKE :'%' + partOFAccName  + '%'  AND Amount_Sum__c =: totalAmount
        AND id IN (SELECT AccountId
        FROM Opportunity WHERE isclosed =: true) AND
        Id NOT IN (SELECT AccountId FROM Opportunity WHERE IsWon=: false)];
        System.assertEquals(count, AccountDetailsController.searchCount(partOFAccName, totalAmount));
    }

    @isTest
    public static void testSearchCountWithName() {
        setupIds();
        Integer count = [SELECT COUNT() FROM account WHERE name LIKE :'%' + partOFAccName  + '%' AND id IN (SELECT AccountId
        FROM Opportunity WHERE isclosed =: true) AND
        Id NOT IN (SELECT AccountId FROM Opportunity WHERE IsWon=: false)];
        System.assertEquals(count, AccountDetailsController.searchCount(partOFAccName, 0));
    }

    @isTest
    public static void testSearchCountWithIncorrectName() {
        setupIds();
        String partOfIncorrectName = 'qwertyuiop';
        Integer count = [SELECT COUNT() FROM account WHERE name LIKE :'%' + partOfIncorrectName  + '%' AND id IN (SELECT AccountId
        FROM Opportunity WHERE isclosed =: true) AND
        Id NOT IN (SELECT AccountId FROM Opportunity WHERE IsWon=: false)];
        System.assertEquals(count, AccountDetailsController.searchCount(partOfIncorrectName, 0));
    }

    @isTest
    public static void testSearchCountWithPrice() {
        setupIds();
        Integer count = [SELECT COUNT() FROM account WHERE Amount_Sum__c =: totalAmount AND id IN (SELECT AccountId
        FROM Opportunity WHERE isclosed =: true) AND
        Id NOT IN (SELECT AccountId FROM Opportunity WHERE IsWon=: false)];
        System.assertEquals(count, AccountDetailsController.searchCount(null, totalAmount));
    }

    @isTest
    public static void testSearchCountWithIncorrectPrice() {
        setupIds();
        Integer count = [SELECT COUNT() FROM account WHERE Amount_Sum__c =: 12 AND id IN (SELECT AccountId
        FROM Opportunity WHERE isclosed =: true) AND
        Id NOT IN (SELECT AccountId FROM Opportunity WHERE IsWon=: false)];
        System.assertEquals(count, AccountDetailsController.searchCount(null, 12));
    }

    @isTest
    public static void testSearchCount() {
        setupIds();
        Integer count = [SELECT COUNT() FROM account WHERE id IN (SELECT AccountId
        FROM Opportunity WHERE isclosed =: true) AND
        Id NOT IN (SELECT AccountId FROM Opportunity WHERE IsWon=: false)];
        System.assertEquals(count, AccountDetailsController.searchCount(null, 0));
    }

    @isTest
    public static void testGetProducts(){
        setupIds();
        List<OpportunityLineItem> items = [SELECT name, Quantity, UnitPrice, TotalPrice, id FROM OpportunityLineItem WHERE opportunityid =: oppIdWithProducts];
        System.assertEquals(items, AccountDetailsController.getProducts(oppIdWithProducts));
    }

    @isTest
    public static void testGetProductsForOppWithoutProducts(){
        setupIds();
        List<OpportunityLineItem> items = [SELECT name, Quantity, UnitPrice, TotalPrice, id FROM OpportunityLineItem WHERE opportunityid =: oppIdWithoutProducts];
        System.assertEquals(items, AccountDetailsController.getProducts(oppIdWithoutProducts));
    }

    @isTest
    public static void testSearchAccountsWithOpportunities() {
        setupIds();
        List<Account> accs = [SELECT id, name, Amount_Sum__c,
        (SELECT id,name,closedate, createddate, amount
        FROM opportunities WHERE isclosed =: true)
        FROM account WHERE id IN (SELECT AccountId
        FROM Opportunity WHERE isclosed =: true) AND
        Id NOT IN (SELECT AccountId FROM Opportunity WHERE IsWon=: false) LIMIT : queryLimit OFFSET : offset];
        System.assertEquals(accs, AccountDetailsController.searchAccountsWithOpportunities(queryLimit, offset, null, 0));
    }

    @isTest
    public static void testSearchAccountsWithOpportunitiesWithNameAndPrice() {
        setupIds();
        List<Account> accs = [SELECT id, name, Amount_Sum__c,
        (SELECT id,name,closedate, createddate, amount
        FROM opportunities WHERE isclosed =: true)
        FROM account WHERE name LIKE :'%' + partOFAccName  + '%'  AND Amount_Sum__c =: totalAmount AND id IN (SELECT AccountId
        FROM Opportunity WHERE isclosed =: true) AND
        Id NOT IN (SELECT AccountId FROM Opportunity WHERE IsWon=: false) LIMIT : queryLimit OFFSET : offset];
        System.assertEquals(accs, AccountDetailsController.searchAccountsWithOpportunities(queryLimit, offset, partOFAccName, totalAmount));
    }

    @isTest
    public static void testSearchAccountsWithOpportunitiesWithName() {
        setupIds();
        List<Account> accs = [SELECT id, name, Amount_Sum__c,
        (SELECT id,name,closedate, createddate, amount
        FROM opportunities WHERE isclosed =: true)
        FROM account WHERE name LIKE :'%' + partOFAccName  + '%' AND id IN (SELECT AccountId
        FROM Opportunity WHERE isclosed =: true) AND
        Id NOT IN (SELECT AccountId FROM Opportunity WHERE IsWon=: false) LIMIT : queryLimit OFFSET : offset];
        System.assertEquals(accs, AccountDetailsController.searchAccountsWithOpportunities(queryLimit, offset, partOFAccName, 0));
    }

    @isTest
    public static void testSearchAccountsWithOpportunitiesWithPrice() {
        setupIds();
        List<Account> accs = [SELECT id, name, Amount_Sum__c,
        (SELECT id,name,closedate, createddate, amount
        FROM opportunities WHERE isclosed =: true)
        FROM account WHERE Amount_Sum__c =: totalAmount AND id IN (SELECT AccountId
        FROM Opportunity WHERE isclosed =: true) AND
        Id NOT IN (SELECT AccountId FROM Opportunity WHERE IsWon=: false) LIMIT : queryLimit OFFSET : offset];
        System.assertEquals(accs, AccountDetailsController.searchAccountsWithOpportunities(queryLimit, offset, null, totalAmount));
    }

}