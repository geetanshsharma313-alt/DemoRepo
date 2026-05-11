import { LightningElement } from 'lwc';

export default class p2cParentComponent extends LightningElement {
    //   carouselData=[
    //     {
    //         src:"https://www.lightningdesignsystem.com/assets/images/carousel/carousel-01.jpg",
    //         header:"First Card",
    //         description:"First Description"
    //     },
    //     {
    //         src:"https://www.lightningdesignsystem.com/assets/images/carousel/carousel-02.jpg",
    //         header:"Second Card",
    //         description:"Second Description"
    //     },
    //     {
    //         src:"https://www.lightningdesignsystem.com/assets/images/carousel/carousel-03.jpg",
    //         header:"Third Card",
    //         description:"Third Description"
    //     }
    // ]

    percentage = 10
    handleClick(event){
        this.percentage = event.target.value
    }
    handleButton(){
            this.template.querySelector('c-slider-component').reset()
    }
}