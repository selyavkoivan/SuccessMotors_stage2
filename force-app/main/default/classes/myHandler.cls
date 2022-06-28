global class myHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope envelop) {
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        Integer index = email.subject.indexOf('INV-');

        String attachmentName = email.subject.substring(index) + '.pdf';
        
        attachment atach = [SELECT name, id, parentid FROM attachment WHERE name =: attachmentName LIMIT 1];
        opportunity opp = [SELECT StageName,name FROM opportunity WHERE id=: atach.ParentId];
        
        Integer indexToApproved = -1;
        Integer indexToRejected = -1;
        
        if(opp.StageName != 'Closed Lost' && opp.StageName != 'Closed Won') {
            String emailBody = email.plainTextBody; 
            indexToApproved = emailBody.indexOf('Approved'); 
            indexToRejected = emailBody.indexOf('Rejected');
        } else return result;

        if(indexToApproved >= 0) {
            String objectName = 'Opportunity';
			String fieldName ='StageName';

			Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
			Schema.DescribeSObjectResult r = s.getDescribe();
			Map<String,Schema.SObjectField> fields = r.fields.getMap();
			Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
			List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();

        	for(Integer i = 0; i < picklist.size(); i++) {
                if(opp.StageName == picklist[i].getValue()) {
                    opp.StageName = picklist[i+1].getValue();
                    break;
                }
        	}
            try {
                update(opp);
            } 
            catch (Exception e) {
                System.debug(e);
            }
        }
        else if(indexToRejected >= 0) {
            opp.StageName = 'Closed Lost';
            try {
                update(opp);
            }
            catch (Exception e) {
                System.debug(e);
            }
        }     
		return result;
	}
}