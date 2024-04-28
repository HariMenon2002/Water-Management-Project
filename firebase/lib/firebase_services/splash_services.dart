import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseproject/ui/auth/login_screen.dart';
import 'package:firebaseproject/ui/firestore/firestore_list_screen.dart';
import 'package:firebaseproject/ui/project_ui/home_screen.dart';
import 'package:flutter/material.dart';



import '../ui/posts/post_screen.dart';

class SplashServices{
  void isLogin(BuildContext context){

     final auth=FirebaseAuth.instance;
     final  user=auth.currentUser;  //gives details of current user

     if(user!=null) {
       Timer(const Duration(seconds: 3), () =>
           Navigator.push(
               context, MaterialPageRoute(builder: (context) => HomeScreen()))
       );
     }
     else {
       Timer(const Duration(seconds: 3), () =>
           Navigator.push(
               context, MaterialPageRoute(builder: (context) => LoginScreen()))
       );
     }
  }
}