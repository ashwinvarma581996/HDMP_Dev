import { LightningElement } from 'lwc';

export default class SectionNavigation extends LightningElement {
    value = 'myProducts';

    get options() {
        return [
            { label: 'My Products', value: 'myProducts' },
            { label: 'My Dealers', value: 'myDealers' },
            { label: 'My Payments', value: 'myPayments' },
            { label: 'My Wishlist', value: 'wishlist' },
            { label: 'My Address Book', value: 'myAddressBook' },
            { label: 'Preferences', value: 'preference' },
            { label: 'Order History', value: 'Order History' },
            { label: 'Log Out', value: 'logout' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
    }
}