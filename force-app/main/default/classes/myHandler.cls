global class myHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope envelop){
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String str = email.subject;
        Integer indexFirst = str.indexOf('INV-');
        str=str.substring(indexFirst);
        String nameAttachment = str+'.pdf';
        attachment atach=[select name, id, parentid from attachment where name =: nameAttachment limit 1];
        opportunity opp = [select StageName,name from opportunity where id=: atach.ParentId];
        Integer indexToApproved = -1;
        Integer indexToRejected = -1;
        if(opp.StageName != 'Closed Lost' || opp.StageName != 'Closed Won')
        {String textBox=email.plainTextBody; indexToApproved=textBox.indexOf('Approved'); indexToRejected = textBox.indexOf('Rejected');}
        if(indexToApproved>=0){
            String objectName = 'Opportunity';
			String fieldName ='StageName';
			Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
            System.debug(s);
			Schema.DescribeSObjectResult r = s.getDescribe() ;
            System.debug(r);
			Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
            System.debug(fields);
			Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            System.debug(fieldResult);
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        	for(Integer i=0; i<ple.size();i++){
              if(opp.StageName == ple[i].getValue()){
                opp.StageName = ple[i+1].getValue();
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
        else if(indexToRejected>=0){
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