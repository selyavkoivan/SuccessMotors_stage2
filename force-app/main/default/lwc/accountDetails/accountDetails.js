import { LightningElement, api, wire, track} from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

import Amount from '@salesforce/schema/Opportunity.Amount';
import Name from '@salesforce/schema/Opportunity.Name';
import CloseDate from '@salesforce/schema/Opportunity.CloseDate';
import CreatedDate from '@salesforce/schema/Opportunity.CreatedDate';
import getOppoortunitiesForOneAccount from '@salesforce/apex/AccountDetailsController.getOppoortunitiesForOneAccount';
import searchAccountsWithOpportunities from '@salesforce/apex/AccountDetailsController.searchAccountsWithOpportunities';
import getProducts from '@salesforce/apex/AccountDetailsController.getProducts';
import searchCount from '@salesforce/apex/AccountDetailsController.searchCount';

import prName from '@salesforce/schema/OpportunityLineItem.Name';
import Quantity from '@salesforce/schema/OpportunityLineItem.Quantity';
import UnitPrice from '@salesforce/schema/OpportunityLineItem.UnitPrice';
import TotalPrice from '@salesforce/schema/OpportunityLineItem.TotalPrice';

const actions = [
    { label: 'Open', name: 'open' },
];

const columns=[
    { label: 'Name', fieldName: Name.fieldApiName, type: 'text'},
    { label: 'Amount', fieldName: Amount.fieldApiName, type: 'currency',
    typeAttributes: { maximumFractionDigits: '2' }},
    { label: 'CloseDate', fieldName: CloseDate.fieldApiName, type: 'date' },
    { label: 'CreatedDate', fieldName: CreatedDate.fieldApiName, type: 'date' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    }
]

const productColumns=[
    { label: 'Name', fieldName: prName.fieldApiName, type: 'text'},
    { label: 'Quantity', fieldName: Quantity.fieldApiName, type: 'text'},
    { label: 'Unit Price', fieldName: UnitPrice.fieldApiName, type: 'currency',
    typeAttributes: { maximumFractionDigits: '2' }},
    { label: 'Total Price', fieldName: TotalPrice.fieldApiName, type: 'currency',
    typeAttributes: { maximumFractionDigits: '2' }}
]

export default class AccountDetails extends NavigationMixin(LightningElement)   {
    columns = columns;

    productColumns = productColumns;


    @api recordId;

    @track isRendered = false;
    @track searchAcc = '';
    @track searchSum = 0;
    @track countOnPage = 10; 
    @track offset = 0; 
    @track dataForRecord;
    @track record;
    @track Accs;
    @track pageNumber = 1;
    @track openModal = false;
    @track isPrev = true;
    @track isNext;
    @track totalCount;
    @track Products
    
    @wire(getOppoortunitiesForOneAccount,{ids :'$recordId'}) handleGetOpportunitiesForOneAccountResult(result){
        if(result.data){
            if(result.data.length >= 1){
                this.dataForRecord = result.data;
            }
            else{
                console.log('error with one account');
            }
        }
    }

    @wire(searchAccountsWithOpportunities,{queryLimit :'$countOnPage', offset : '$offset', 
    accountName : '$searchAcc', price : '$searchSum'}) handleSearchAccountsWithOpportunitiesResult(result) {
        this.Accs = result;
        this.isRendered = false;
        this.editButtonsStatus();
    };

    @wire(searchCount,{accountName : '$searchAcc', price : '$searchSum'}) handleSearchCountResult(result){
        this.totalCount = result.data;
        this.offset = 0;
        this.editButtonsStatus();
    }  

    editButtonsStatus() {

        this.isNext = typeof this.totalCount == 'undefined' || this.offset >= this.totalCount - this.countOnPage || this.totalCount == 0;
        this.isPrev = this.offset < this.countOnPage;
    }

    handleNext(){
        this.offset = this.offset + this.countOnPage;
    }
 
    handlePrev(){
        this.offset = this.offset - this.countOnPage;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'open':
                this.openModalWindow(row);
                break;
            default:
        }
    }

    openModalWindow(row) {
        this.openModal = true;
        this.record=row;
        getProducts({ids : this.record.Id})
        .then(result =>{
            
            if(result.length >= 1){
                this.Products=result;
            }
            else{
                this.Products=null;
            }
        })
        .catch(error => {
            console.log('open modal wndow error');
        });
    }

    closeModal() {
        this.openModal = false;
    }

    changeHandlerSum(event) {
        this.searchSum = event.target.value;
    }

    changeHandlerAcc(event) {
        this.searchAcc = event.target.value;
    }

    renderedCallback() {

        let sections = this.template.querySelectorAll('lightning-accordion-section')
        
        if(sections.length != 0 && !this.isRendered) {
            this.isRendered = true;

            sections.forEach((currentValue, index, array) => {
                currentValue.label =  currentValue.name + " " + currentValue.label + "$"
            })
            
        }
    }
}