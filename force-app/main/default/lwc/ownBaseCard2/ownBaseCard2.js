/* eslint-disable no-unused-vars */
import { api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnBaseCard2 extends OwnBaseElement {
    @api brand;
    @api titlecolor;
    @api title;
    @api icon;
    @api bodytext;
    @api body;
    @api forwardiconname;
   

    get isDefault() { return this.brand === 'Default'; }; 
    get isHonda() { return this.brand === 'Honda Auto'; }; 
    get isAcura() { return this.brand === 'Acura Auto'; }; 
    get isPS() { return this.brand === 'Powersports'; }; 
    get isPE() { return this.brand === 'Power Equipment'; }; 
    get isMarine() { return this.brand === 'Marine'; }; 
    get isTitleRed() { return this.titlecolor === 'Honda Red'; }; 
    get isBody() { return this.body === 'body'; }; 
    get isAcuraHonda(){return this.brand === 'Acura Honda';};


    handleClick(event){
        this.dispatchEvent(new CustomEvent('click'));   
        }
}