import { LightningElement, track, wire, api } from 'lwc';
import getSymbols from '@salesforce/apex/CurrencyConvertor.getSymbols';
import convertAmount from '@salesforce/apex/CurrencyConvertor.convertAmount';
import getOppAmount from '@salesforce/apex/CurrencyConvertor.getOppAmount';

export default class CurrencyConvertor extends LightningElement {
    @api recordId
    source = 'INR';
    target = 'USD';
    @track amount = undefined;
    @track record = undefined;
    @track error = undefined;
    @track isLoading = false;
    @track convertedAmount = 0;
    @track options = [];


    @wire(getSymbols)
    getOptions({ error, data }) {
        console.log('Inside Wire');
        if (data) {
            console.log('inside data');
            console.log(data);
            this.record = data;
            this.error = undefined;
            this.mapToOptions(data.symbols);
        } else if (error) {
            this.data = undefined;
            this.error = error;
        }
        console.log(this.recordId);

    }

    connectedCallback() {
        console.log('Inside Connected Callback');

        if (this.recordId) {
            this.getOpportunityAmount();
        }
    }

    getOpportunityAmount() {
        getOppAmount({ recordId: this.recordId }).then((result) => {
            this.amount = result;
        }).catch((err) => {
            console.log("---error occured while converting amount = " + err);
        })
    }

    mapToOptions(symbols) {
        this.options = Object.entries(symbols).map((symbol) => {
            return { label: symbol[1], value: symbol[0] }
        });
        console.log(this.options);
    }

    onSourceChangeHandler(event) {
        this.source = event.detail.value;
        console.log(event.detail.value)

    }
    onTargetChangeHandler(event) {
        this.target = event.detail.value;
        console.log(event.detail.value)
    }
    onAmountChangeHandler(event) {
        this.amount = event.target.value;
    }
    onConvertAmountHandler() {
        console.log('Inside onConvertAmount handler');
        console.log(this.source, this.target, this.amount)
        this.isLoading = true;
        convertAmount({ source: this.source, amount: this.amount, target: this.target })
            .then((result) => {
                console.log(result);
                this.convertedAmount = result + '  ' + this.target;
                this.isLoading = false;
            }).catch((err) => {
                console.log("---error occured while converting amount = " + err);
            })
    }
}
