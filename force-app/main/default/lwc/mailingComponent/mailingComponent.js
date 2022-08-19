import { LightningElement, api, track, wire } from 'lwc';

import runBatch from'@salesforce/apex/ScheduleDetails.runBatch';
import getCRON from '@salesforce/apex/ScheduleDetails.getCRON';
import isWorkedTrigger from '@salesforce/apex/ScheduleDetails.isWorkedTrigger';
import stopSchedulable from'@salesforce/apex/ScheduleDetails.stopSchedulable';
import startSchedulable from'@salesforce/apex/ScheduleDetails.startSchedulable';

export default class LwcSchedule extends LightningElement {
  @api BatchName;
  @api ScheduleName;

  @track valueCRON;
  @track State;
  @track isWork;
  @track BatchBody;

 
  @wire(getCRON, {NameCronJobDetail: "$ScheduleName"}) valueCRON;  
  @wire(isWorkedTrigger, {NameCronJobDetail: "$ScheduleName"}) isWork; 

  onBatch(){
    runBatch({ apexClass: this.BatchName});        
  }

  onSchedulable(){
    startSchedulable({NameCronJobDetail: this.ScheduleName, CRONstr:this.valueCRON.data, BatchName: this.BatchName});
    window.location.reload();
  }
 
  offSchedulable(){
    stopSchedulable({NameCronJobDetail: this.ScheduleName});
    window.location.reload(); 
  }  

  changevalueCRON(event){
    this.valueCRON.data = event.target.value;
  }
}