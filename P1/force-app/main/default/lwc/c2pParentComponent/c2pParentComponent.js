import { LightningElement } from 'lwc';

export default class C2pParentComponent extends LightningElement {
    showModal = false;
    msg
    handleClick(){
        this.showModal = true;
    }
    handleClose(event){
        this.msg = event.detail
        this.showModal = false;
    }

}