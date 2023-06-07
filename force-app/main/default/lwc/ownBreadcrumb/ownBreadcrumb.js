import { api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class ownBreadcrumb extends OwnBaseElement {
    @api label = 'Home';
    @api url = '/';
    @api goBack;
    @api customEvent;
    handleClick(){
        if(this.goBack){
            window.history.back();
        }else if(this.customEvent){
            const cusEvent = new CustomEvent('navigate',{detail : ''});
            this.dispatchEvent(cusEvent);
        }else{
            this.navigate(this.url, {});
        }
        
    }
}