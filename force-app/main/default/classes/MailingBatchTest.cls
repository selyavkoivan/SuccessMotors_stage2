@isTest
public with sharing class MailingBatchTest {
    @isTest
    static void testMailingBatch() 
    {
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < 5;i++)
        {
            Contact contact = new Contact();
            contact.FirstName = 'Name' + i;
            contact.LastName = 'Name' + i;
            contact.Email = 'email' + i + '@gmail.com';
            contact.Birthdate = System.today();
            contacts.add(contact);
        }
        insert contacts;
        
        Test.startTest();

        MailingBatch obj = new MailingBatch();
        DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}
