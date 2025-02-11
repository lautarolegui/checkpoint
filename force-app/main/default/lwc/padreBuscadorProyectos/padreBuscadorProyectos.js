import { LightningElement } from 'lwc';

export default class ComponentePadre extends LightningElement {
    selectedAccountId = '';

    handleAccountSelected(event) {
        this.selectedAccountId = event.detail.accountId;
    }
}
