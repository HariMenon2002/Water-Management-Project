import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebaseproject/ui/auth/login_screen.dart';
import 'package:firebaseproject/widgets/round_button.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  bool loading=false;

  final _formKey=GlobalKey<FormState>();        //works as a unique identifier for a form
  final emailController=TextEditingController();
  final passwordController=TextEditingController();

  FirebaseAuth _auth  =FirebaseAuth.instance;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();            //dispose when screen is not there
    passwordController.dispose();
  }

  void signup(){
    setState(() {
      loading=true;
    });
    _auth.createUserWithEmailAndPassword(
        email: emailController.text.toString(),
        password: passwordController.text.toString()).then((value){

      setState(() {
        loading=false;
      });
    }).onError((error, stackTrace) {
      Utils().toastMessage(error.toString());               //this is to display the error message
      setState(() {
        loading=false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          backgroundColor: Colors.deepPurple,
          title: Padding(padding:EdgeInsets.only(bottom:8),child: Center(child: Text("Sign Up",style: TextStyle(color: Colors.white),))),
        ),
        body:Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                  key:_formKey,
                  child:Column(
                    children: [
                      TextFormField(

                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          // helperText: 'Enter email e.g.jon@gmail.com',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),

                        validator: (value){
                          if(value!.isEmpty) return 'Enter email';
                          return null;
                        },   //if user has not entered anything and is trying to login
                      ),
                      SizedBox(height:10),
                      TextFormField(

                        controller: passwordController,
                        obscureText: true,             //to hide the password
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          // helperText: 'Enter email e.g.jon@gmail.com',
                          prefixIcon: Icon(Icons.lock_open),
                        ),

                        validator: (value){
                          if(value!.isEmpty) return 'Enter password';
                          return null;
                        },
                      ),


                    ],
                  )
              ),
              const SizedBox(height: 50,),

              RoundButton(title: 'Sign Up',loading:loading,onTap: (){
                if(_formKey.currentState!.validate()){

                      signup();
                      
                  }
              },),
              const SizedBox(height: 30,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(onPressed: (){
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginScreen()));
                      },
                      child: Text('Login'))
                ],
              ),
            ],
          ),
        )
    );
  }
}




/*
1.Go to firebase and go to your project app. Click on build and then on authentication in the left side
2.In sign in method, click on email/password
3.Disable only the email link option in the bottom
4.In the app, enter email and password in sign up section,login  and check user console in firebase

5.We use flutter toast to handle errors(eg when my password is only 4 charac it gives error), create a directory named utils in lib file
6.Create utils.dart file and a class and in that paste the code which you can copy from readme section of flutter toast and modify it.


 */