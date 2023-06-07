import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import {
    getOrigin,
    getGarage
} from 'c/ownDataUtils';


const progressAutos = [
    { label: 'Get to know your Honda', value: 'Get_to_know_your_Honda', isActive: true },
    { label: 'Connect your Smartphone', value: 'Connect_your_Smartphone', isActive: false },
    { label: 'Personalize your Honda', value: 'Personalize_your_Honda', isActive: false },
    { label: 'Explore Payment Options', value: 'Explore_Payment_Options', isActive: false }
]


const progressMarine = [
    { label: 'Get to Know Your Motor', value: 'Get_to_Know_Your_Motor', isActive: true },
    { label: 'Taking Care of Your Motor', value: 'Taking_Care_of_Your_Motor', isActive: false },
    { label: 'Fueling Your Motor', value: 'Fueling_Your_Motor', isActive: false }
]

export default class OwnQuickStartGuideOverview extends OwnBaseElement {

    @track progressList;
    @track selectedSection = 'Get_to_know_your_Honda';
    @api contentId1;
    @api contentId2;
    @api contentId3;
    @api brand;
    @track videoIcon = 'play.svg';
    @track showGuide = false;
    @track garage;

    connectedCallback() {
        if(this.brand == 'Marine'){
            this.progressList = progressMarine;
            this.selectedSection = 'Get_to_Know_Your_Motor';
        }else{
            this.progressList = progressAutos;
        }
        
        this.intialize();
    }  
    
    intialize = async () => {
        this.garage = await getGarage('');
        if(this.garage && this.garage.products && this.garage.products.length == 1){
            this.showGuide = true;
        }
    }

    get isGet_to_know_your_Honda(){
        return this.selectedSection == 'Get_to_know_your_Honda';
    }
    get isConnect_your_Smartphone(){
        return this.selectedSection == 'Connect_your_Smartphone';
    }
    get isGet_To_Know_Your_Motor(){
        return this.selectedSection == 'Get_to_Know_Your_Motor';
    }

    handleActive(event) {
        //console.log('This is handleActive : ',event.currentTarget.dataset.value);
        let indicaterName = event.currentTarget.dataset.value;
        this.containerBodyName = event.currentTarget.dataset.value;
        let progress = [];
        this.progressList.forEach(element => {
            if(element.value == indicaterName) {
                 element.isActive = true;
                 this.selectedSection = element.value;
            }else{
                element.isActive = false;
            }     
            progress.push(element);
        });
        this.progressList = progress;
    }

    handleAccourdion(event) {
        //console.log('test1  :-  ', event.currentTarget.dataset.value);
        let indicaterName = event.currentTarget.dataset.value;
        this.containerBodyName = event.currentTarget.dataset.value;
        let progress = [];
        this.progressList.forEach(element => {
            if(element.value == indicaterName) {
                element.isActive = true;
                this.selectedSection = element.value;
           }else{
               element.isActive = false;
           }   
            progress.push(element);
        });
        // this.progressList = progress;
        // setTimeout((self) => {
        //     let child = this.template.querySelector(`c-own-quick-start-guide-steps[data-value=${this.containerBodyName}]`);
        //     console.log('test2  :-  ', child);
        //     child.setContainerBody(this.containerBodyName);
        // }, 1000).bind(this);
        
    }

    closeGuide(){
        this.showGuide = false;
    }

    navigateToPage(){
        this.navigate('/quick-start-guide',{});
    }

}