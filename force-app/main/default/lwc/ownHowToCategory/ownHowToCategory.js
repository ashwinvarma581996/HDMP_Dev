import { LightningElement, track } from 'lwc';

export default class OwnHowToCategory extends LightningElement {
    @track categoryData;
    @track features =[];
    connectedCallback(){
        this.initialize();
    }

    initialize(){
        if(sessionStorage.getItem('howtoguides')){
           let content = JSON.parse(sessionStorage.getItem('howtoguides'));
           content.features.forEach(element => {
            //console.log('This is element : ', element);
            let existingFeature;
            let existingIndex;
            this.features.forEach( (ele, index) =>{
                if(ele.title == element.title && ( !ele.content || !element.content || ele.content == element.content)){
                    existingFeature = ele;
                    existingIndex = index;
                }
                
            })
            if(existingFeature){
                existingFeature.items.push(JSON.parse(JSON.stringify(element)));
                this.features.splice(existingIndex, 1, existingFeature);
            }else{
                let featureObj = {
                    title : element.title,
                    content: element.content,
                    items : [element]
                } 
                this.features.push(featureObj);        
            }
           });
           
             //console.log('features ====> ',this.features);
            this.categoryData = content;
        }
    }
}