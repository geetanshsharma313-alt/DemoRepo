import { LightningElement , track} from 'lwc';

export default class HelloWorld extends LightningElement {
    
      
      Fullname = "Geetansh Sharma"
      title = "Software Engineer"
      
      changeHandler(event){
          this.title = event.target.value
      }

      @track address ={

          city : "Noida",
          state : "Uttar Pradesh",
          country : "India"
      }

      trackHandler(event){
          this.address.city = event.target.value
      }

      users = ['john','jane','jack','jill']
      get firstUser(){
          return this.users[0]
      }
      
      num1 = 10;
      num2 = 20;
      get sum(){
          return this.num1 + this.num2
      }




}