import { LightningElement,api } from 'lwc';

export default class PaymentAndBilling extends LightningElement {
    paymentValue;
    paymentTypeOptions = [
        { label: 'Credit Card', value: 'CreditCard' },
        { label: 'Debit Card', value: 'DebitCard' }
    ];
    cardExpValue;
    cardNum;
    cardCvv;
    @api cartId;
    handlePaymentTypeChange(event){

    }
}