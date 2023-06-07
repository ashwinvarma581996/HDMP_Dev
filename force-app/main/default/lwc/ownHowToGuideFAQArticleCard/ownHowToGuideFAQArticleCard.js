import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getKnowledgeArticles } from 'c/ownDataUtils';

export default class OwnHowToGuideFAQArticleCard extends OwnBaseElement {
    @api category;
    @api icon;
    @api title;
    @api titlecolor;
    @api actionbuttonlabel;
    @api description;
    @api maxResults = 4;
    @track results;

    get titleClass(){
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    connectedCallback(){
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.initialize();
    }

    initialize = async () => {
        try {
            this.results = await getKnowledgeArticles(this.category, this.maxResults);
            //console.log('this.results  :-  ',this.results);
        } catch (error) {
            //console.log('error  :-  ',error);
        }
       
    };
    
    handleButtonClick(){
        sessionStorage.setItem('frompage',document.title.toLowerCase());
        this.navigate('/how-to-guides', {});
    }

    handleArticleClick(event){
        let id = event.currentTarget.dataset.id;
        this.navigate('/article?id=' + id + '&' + 'brand=' + this.category, {});
    }
}