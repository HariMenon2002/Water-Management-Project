import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseproject/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:firebaseproject/utils/utils.dart';

class AddFirestoreDataScreen extends StatefulWidget {
  const AddFirestoreDataScreen({super.key});

  @override
  State<AddFirestoreDataScreen> createState() => _AddFirestoreDataScreenState();
}

class _AddFirestoreDataScreenState extends State<AddFirestoreDataScreen> {

  final postController=TextEditingController();
  bool loading=false;
  final fireStore=FirebaseFirestore.instance.collection('users');   //if i change the name here, another collection therefore will be created


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Center(child: Text("Add firestore data",style: TextStyle(color: Colors.white),)),
      ),
      body:Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height:30,
            ),
            TextFormField(
              maxLines: 4,
              controller:postController,
              decoration:InputDecoration(
                  hintText: 'What is in your mind?',
                  border:OutlineInputBorder()
              ),
            ),
            SizedBox(
              height:30,
            ),
            RoundButton(title: 'add', loading:loading,onTap: (){

              setState((){
                loading=true;
              });



              String id=DateTime.now().microsecondsSinceEpoch.toString();
              fireStore.doc(id).set({                            //my document will have this id and the below data
                   'title':postController.text.toString(),
                   'id': id
              }).then((value){
                setState((){
                  loading=false;
                });
                Utils().toastMessage('post added');
              }).onError((error, stackTrace) {
                setState((){
                  loading=false;
                });
                 Utils().toastMessage(error.toString());
              });
            })
          ],
        ),
      ),
    );
  }


}

/*
1.Now we will be playing with firestore
2.Go to firebase.console and in your project build section in left, click on firestore database
3.Create a collection here named users
4.A collection will have documents which will have an id(we have assigned it as datetime..)
 */