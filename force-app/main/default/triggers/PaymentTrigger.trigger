trigger PaymentTrigger on Payment__c (after insert, after update) {

    List<Opportunity> oppsToUpdate = new List<Opportunity>();
    List<Task> taskToInsert = new List<Task>();

    for(Payment__c p : Trigger.New) {
        
        Decimal SummPaymet = 0.00;
        Decimal AmountOpportunity = [SELECT Amount FROM Opportunity WHERE Id =: p.Opportunity__c LIMIT 1].Amount;

        for(Payment__c pp : [SELECT Amount__c FROM Payment__c WHERE Opportunity__c =: p.Opportunity__c]){
            SummPaymet += pp.Amount__c;
        }
        
        if (SummPaymet > 0 && SummPaymet < AmountOpportunity) {
            Opportunity op = [SELECT Id, Name, ContactId FROM Opportunity WHERE Id =: p.Opportunity__c]; 
            op.StageName = 'Partially Paid';
            oppsToUpdate.add(op);       

        } else {

            Opportunity op = [SELECT Id, Name, OwnerId FROM Opportunity WHERE Id = :p.Opportunity__c]; 
            op.StageName = 'Fully Paid';
            oppsToUpdate.add(op);   

            Task tsk = new Task();
            	tsk.OwnerId = op.OwnerId; 
                tsk.Priority = 'High'; 
                tsk.Status = 'Not Started'; 
                tsk.Subject = 'Delivery of goods'; 
                tsk.IsReminderSet = true;
            	tsk.ReminderDateTime = Datetime.newInstanceGmt( Date.today().addDays(2),Time.newInstance(17, 0, 0, 0));
				tsk.WhatId = op.Id; 
                taskToInsert.add(tsk);
               
	        }
           
    }
    update oppsToUpdate;
    insert taskToInsert; 
    
}