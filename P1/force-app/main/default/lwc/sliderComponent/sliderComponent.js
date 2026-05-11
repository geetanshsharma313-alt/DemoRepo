import { LightningElement , api} from 'lwc';

export default class SliderComponent extends LightningElement {
    val = 20
    handleClick(event){
        this.val = event.target.value
    }
    @api reset(){
        this.val= 50
    }
}