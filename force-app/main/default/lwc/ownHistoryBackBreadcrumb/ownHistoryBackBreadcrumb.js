import { LightningElement,api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnHistoryBackBreadcrumb extends OwnBaseElement {

    @api title;

    handleBackLinkClick(){
        history.back();
    }
}