public with sharing class AccountDetailsController {

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOppoortunitiesForOneAccount(String ids){
        return [SELECT id,name,closedate, createddate, amount FROM Opportunity WHERE accountid =: ids AND isclosed =: true];
    }

    @AuraEnabled(cacheable=true)
    public static Integer searchCount(String accountName, Decimal price){
        if(!String.isBlank(accountName) && (price != 0 && price != null)) {
            return [SELECT COUNT() FROM account WHERE name LIKE :'%' + accountName  + '%'  AND Amount_Sum__c =: price];
        } else if(!String.isBlank(accountName)) {
            return [SELECT COUNT() FROM account WHERE name LIKE : '%' + accountName  + '%'];
        } else if (price != 0 && price != null) {
            return [SELECT COUNT() FROM account WHERE Amount_Sum__c =: price];
        } else return [SELECT COUNT() FROM account];
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getProducts(String ids){
        return [SELECT name, Quantity, UnitPrice, TotalPrice, id FROM OpportunityLineItem WHERE opportunityid =: ids];
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccountsWithOpportunities(Integer queryLimit, Integer offset, String accountName, Decimal price){
        if(!String.isBlank(accountName) && price != 0) {
            return [SELECT id, name, Amount_Sum__c,
            (SELECT id,name,closedate, createddate, amount
            FROM opportunities WHERE isclosed =: true)
            FROM account WHERE name LIKE :'%' + accountName  + '%'  AND Amount_Sum__c =: price LIMIT : queryLimit OFFSET : offset];
        } else if(!String.isBlank(accountName)) {
            return [SELECT id, name, Amount_Sum__c,
            (SELECT id,name,closedate, createddate, amount
            FROM opportunities WHERE isclosed =: true)
            FROM account WHERE name LIKE : '%' + accountName  + '%' LIMIT : queryLimit OFFSET : offset];
        } else if (price != 0) {
            return [SELECT id, name, Amount_Sum__c,
            (SELECT id,name,closedate, createddate, amount
            FROM opportunities WHERE isclosed =: true)
            FROM account WHERE Amount_Sum__c =: price LIMIT : queryLimit OFFSET : offset];
        } else return [SELECT id, name, Amount_Sum__c,
            (SELECT id,name,closedate, createddate, amount
            FROM opportunities WHERE isclosed =: true)
            FROM account LIMIT : queryLimit OFFSET : offset];
    }

}
