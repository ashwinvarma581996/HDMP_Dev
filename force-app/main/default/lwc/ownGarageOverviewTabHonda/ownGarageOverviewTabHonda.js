import { LightningElement, track } from 'lwc';
import { ISGUEST } from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';
export default class OwnGarageOverviewTabHonda extends OwnBaseElement {
    @track isGuest = ISGUEST;
}