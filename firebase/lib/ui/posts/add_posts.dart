import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseproject/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:firebaseproject/utils/utils.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {

  final postController=TextEditingController();
  bool loading=false;
  final databaseRef=FirebaseDatabase.instance.ref('Post');  //creates a table(also called node) in firebase,post acts as a table
        //suppose i change this name to eg. test, another table of test will be created with below children(refresh the console to see)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Center(child: Text("Add post",style: TextStyle(color: Colors.white),)),
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
                      // databaseRef.child('1').set({        //ie post will have a child whose id is 1 and it has 2 children title and id
                      //                    suppose i change id to 2 , it will create another child with title and id
                      //  'title':postController.text.toString(),
                      //   'id': 12
                      // });
                      //if i keep changing data to same child id, it will get updated


                      // databaseRef.child('2').set({        //ie post will have a child whose id is 1 and it has 2 children title and id
                      //
                      //   'title':postController.text.toString(),
                      //   'id': 12
                      // }).then((value){
                      //   Utils().toastMessage('Post added');
                      //   setState((){
                      //     loading=false;
                      //   });
                      //
                      // }).onError((error,stackTrace){
                      //   Utils().toastMessage(error.toString());
                      //   setState((){
                      //     loading=false;
                      //   });
                      //
                      // });




                    String id=DateTime.now().millisecondsSinceEpoch.toString();

                    databaseRef.child(id).set({   //this is best method as we can have new child for each time instead of updating the content
                              //if i do .child('comment') to the above code i will get a sub child named comment

                              'title':postController.text.toString(),
                              'id': id,
                    }).then((value){
                          Utils().toastMessage('Post added');
                          setState((){
                              loading=false;
                          });

                      }).onError((error,stackTrace){
                          Utils().toastMessage(error.toString());
                          setState((){
                              loading=false;
                          });

                        });


                  })
        ],
        ),
      ),
    );
  }


}

/*
1.Go to realtime data base in build section
2.Choose location and start in test mode option
3.if i have problem in region, do flutterfire configure --project=testing-cli-44c7c and my firebase_options.dart gets updated.Also downloaded updated google services json and put it here

 */