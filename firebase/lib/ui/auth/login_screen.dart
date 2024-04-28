import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseproject/ui/auth/signup_screen.dart';
import 'package:firebaseproject/ui/project_ui/home_screen.dart';
import 'package:firebaseproject/utils/utils.dart';
import 'package:firebaseproject/widgets/round_button.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey=GlobalKey<FormState>();        //works as a unique identifier for a form
  final emailController=TextEditingController();
  final passwordController=TextEditingController();

  final _auth=FirebaseAuth.instance;
  bool loading=false;


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();            //dispose when screen is not there
    passwordController.dispose();
  }

  void login(){
    setState(() {
      loading=true;
    });
    _auth.signInWithEmailAndPassword(email: emailController.text.toString(), password: passwordController.text.toString()).then((value) {
            Utils().toastMessage(value.user!.email.toString());  //to display if successful
            Navigator.push(context,MaterialPageRoute(builder: (context)=>HomeScreen()));
            setState(() {
              loading=false;
            });
    }).onError((error, stackTrace){

      debugPrint(error.toString());
      Utils().toastMessage(error.toString());
      setState(() {
        loading=false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,            //to remove back button
        backgroundColor: Colors.deepPurple,
        title: const Padding(padding:EdgeInsets.only(bottom:8),child: Center(child: Text("Login",style: TextStyle(color: Colors.white),))),
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

                    keyboardType: TextInputType.emailAddress,
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
                  const SizedBox(height:10),
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

             RoundButton(title: 'Login',loading:loading,onTap: (){
                            if(_formKey.currentState!.validate()){
                                      login();
                            }
                      },),
             const SizedBox(height: 30,),

             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Text("dont have an account?"),
                 TextButton(onPressed: (){
                        Navigator.push(context,MaterialPageRoute(builder: (context)=>SignUpScreen()));
                 },
                     child: const Text('Sign up')
                 ),
               ],
             ),
          ],
        ),
      )
    );
  }
}
