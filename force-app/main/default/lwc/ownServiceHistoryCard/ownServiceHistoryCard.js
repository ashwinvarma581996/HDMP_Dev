import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getPopularKnowledgeArticles } from 'c/ownDataUtils';

export default class OwnHelpFAQArticleCard extends OwnBaseElement {
    @api category;
    @api icon;
    @api title;
    @api titlecolor;
    @api actionbuttonlabel;
    @api description;
    @track maxResults = 3;
    @track results;
    @api isguest;

    get titleClass(){
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    connectedCallback(){
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.initialize();
    }

    initialize = async () => {
        this.results = await getPopularKnowledgeArticles(this.category, this.maxResults);
    };
    
    handleClickAction(){
        this.navigate('/help-center-' + this.brand, {});
    }

    handleArticleClick(event){
        let id = event.currentTarget.dataset.id;
        this.navigate('/article?id=' + id + '&' + 'brand=' + this.category, {});
    }
}