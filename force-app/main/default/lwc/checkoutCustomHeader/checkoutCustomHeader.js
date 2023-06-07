import { LightningElement, wire, track } from 'lwc';
import imageResourcePath from '@salesforce/resourceUrl/honda_images';

export default class CheckoutCustomHeader extends LightningElement {
    dreamShopLogoURL = imageResourcePath + '/dreamshop.png';
    hondaLogoURL = imageResourcePath + '/honda.png';
    communityBaseURL = window.location.origin;

}