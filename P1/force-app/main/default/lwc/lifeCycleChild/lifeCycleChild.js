import { LightningElement } from 'lwc';

export default class LifeCycleChild extends LightningElement {
     constructor(){
        super();
        console.log("Hello I am child Constructor");
    }

    connectedCallback(){
        console.log("Hello I am Child connectedCallback");
        throw new Error('Error Occured');
    }

    renderedCallback(){
        console.log("Hello I am Child renderedCallback");
    }

    disconnectedCallback(){ 
        console.log("Hello I am Child disconnectedCallback");
        alert('Hello I am Child disconnectedCallback');
    }
}