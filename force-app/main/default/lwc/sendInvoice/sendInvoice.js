import { LightningElement,api,track,wire } from 'lwc';
import getEmailTemplate from '@salesforce/apex/SendEmailController.getEmailTemplate';
import getContactName from '@salesforce/apex/SendEmailController.getContactName';
import retriveFiles from '@salesforce/apex/SendEmailController.retriveFiles';
import getOpportunity from '@salesforce/apex/SendEmailController.getOpportunity';
import sendEmailToController from '@salesforce/apex/SendEmailController.sendEmailToController';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class sendInv extends NavigationMixin(LightningElement) {
    @api recordId;
    @wire (getEmailTemplate) emailTemplates;
    @api error;
    @wire(getContactName,{ids:'$recordId'}) contactName;
    @wire(getOpportunity,{ids:'$recordId'}) opp;
    @wire(retriveFiles,{title:'$opp.data.Invoice_Number__c'}) files;
    @track body='Какой то случайный текст';

    handleChangeBody(event){
        this.body=event.target.value;
    }
    handleCLick(){
      
        console.log(this.body);
this[NavigationMixin.Navigate]({
    type: 'standard__namedPage',
    attributes: {
        pageName: 'filePreview'
    },
    state : {
        recordIds:this.files.data.ContentDocumentId,
        selectedRecordId:this.files.data.ContentDocumentId
    }
  });
    }
  sendEmailAfterEvent(){
      if(this.body == '... нужно придумать текст письма клиенту') {
          this.body = this.emailTemplates.data.Body;
      }
      let subjects=this.opp.data.Invoice_Number__c;
    const recordInput = {body: this.body, toSend: this.contactName.data.Email,subject: subjects, opportunityId: this.opp.data.Id, invoiceNumber: this.opp.data.Invoice_Number__c};//You can send parameters
    sendEmailToController(recordInput)
    .then( () => {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Your email send',
            variant: 'success',
        });
        this.dispatchEvent(evt);    
        this.dispatchEvent(new CloseActionScreenEvent());
    }).catch( error => {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Your email dont send',
            variant: 'error',
        });
        console.log(error);
        this.dispatchEvent(evt);
    })
}
}