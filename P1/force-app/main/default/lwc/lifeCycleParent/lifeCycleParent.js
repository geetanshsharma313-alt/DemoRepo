import { LightningElement } from 'lwc';

export default class LifeCycleParent extends LightningElement {

    constructor(){
        super();
        console.log("Hello I am Parent Constructor");
    }

    connectedCallback(){
        console.log("Hello I am Parent connectedCallback");
    }

    renderedCallback(){
        console.log("Hello I am Parent renderedCallback");
    }

    isVisibleChild = false;
    handleClick(){
        this.isVisibleChild = !this.isVisibleChild;
    }
    
    errorCallback(error, stack){
        console.log(error.message);
        console.log(stack);
    }
}