import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import communityId from '@salesforce/community/Id';
import getCategoryTree from '@salesforce/apex/B2BCategoryNavigation.getCategoryTree';

export default class B2bCategoryAccordion extends NavigationMixin(LightningElement) {

    fullNavigationList;
    @track navigationList;

    indexStack = [];
    currentParent;

    connectedCallback() {
        this.getNavigation();
    }

    getNavigation(){
        getCategoryTree({
            communityId: communityId
        }).then((result) => {
            var tempResult = JSON.parse(JSON.stringify(result));
            if(sessionStorage.getItem('dealer')){
                let dealer = JSON.parse(sessionStorage.getItem('dealer'));
                if (dealer && dealer.brand && dealer.brand.length) {
                    let dealerBrand = dealer.brand.toLowerCase();
                    let newArray = tempResult.filter(item => item.hasOwnProperty('categoryName') && item.categoryName.toLowerCase().includes(dealerBrand));
                    tempResult = newArray;
                }
            }
            tempResult.forEach(item1 => {
                item1.hasChild = item1.childs.length > 0;
                item1.childs.forEach(item2 => {
                    item2.hasChild = item2.childs.length > 0;
                    item2.childs.forEach(item3 => {
                        item3.hasChild = item3.childs.length > 0;
                        item3.childs.forEach(item4 => {
                            item4.hasChild = item4.childs.length > 0;
                            item4.childs.forEach(item5 => {
                                item5.hasChild = item5.childs.length > 0;
                            });
                        });
                    });
                });
            });
            this.fullNavigationList = tempResult;
            this.navigationList = tempResult;
        })
        .catch((error) => {
            console.log(error);
        });
    }

    handleIconClick(event){
        let index = event.target.dataset.index;
        this.currentParent = this.navigationList[index].categoryName;
        this.navigationList = this.navigationList[index].childs;
        this.indexStack.push(index);
    }

    handleBack(event){
        this.indexStack.pop();
        this.setCurrentNavigation();
    }

    setCurrentNavigation(){
        var currentNav;
        if(this.indexStack[4]){
            currentNav = this.fullNavigationList[this.indexStack[0]].childs[this.indexStack[1]].childs[this.indexStack[2]].childs[this.indexStack[3]].childs[this.indexStack[4]];
            this.currentParent = currentNav.categoryName;
            this.navigationList = currentNav.childs;
        }else if(this.indexStack[3]){
            currentNav = this.fullNavigationList[this.indexStack[0]].childs[this.indexStack[1]].childs[this.indexStack[2]].childs[this.indexStack[3]];
            this.currentParent = currentNav.categoryName;
            this.navigationList = currentNav.childs;
        }else if(this.indexStack[2]){
            currentNav = this.fullNavigationList[this.indexStack[0]].childs[this.indexStack[1]].childs[this.indexStack[2]];
            this.currentParent = currentNav.categoryName;
            this.navigationList = currentNav.childs;
        }else if(this.indexStack[1]){
            currentNav = this.fullNavigationList[this.indexStack[0]].childs[this.indexStack[1]];
            this.currentParent = currentNav.categoryName;
            this.navigationList = currentNav.childs;
        }else if(this.indexStack[0]){
            currentNav = this.fullNavigationList[this.indexStack[0]];
            this.currentParent = currentNav.categoryName;
            this.navigationList = currentNav.childs;
        }else{
            this.currentParent = '';
            this.navigationList = this.fullNavigationList;
        }
        return currentNav;
    }

    navigateToHome(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/'
            }
        });
    }
}