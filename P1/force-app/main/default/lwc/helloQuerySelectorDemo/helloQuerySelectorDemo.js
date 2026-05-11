import { LightningElement } from 'lwc';

export default class HelloQuerySelectorDemo extends LightningElement {
    users=['Rahul','Raj','Ravi','Rajesh']
    handleClick(){
        const elem = this.template.querySelector('H1')
        const userList = this.template.querySelectorAll('.name')
        Array.from(userList).forEach(user => {
            console.log(user.innerText)
            user.setAttribute("title", user.innerText)
        })
        
        console.log(elem.innerText)
    const childElement = this.template.querySelector('.child')
    childElement.innerHTML = '<p>i am just a Child Element</p>'
    }
    
}