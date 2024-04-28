import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebaseproject/ui/auth/login_screen.dart';
import 'package:firebaseproject/ui/posts/add_posts.dart';
import 'package:firebaseproject/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  final auth=FirebaseAuth.instance;
  final ref=FirebaseDatabase.instance.ref('Post');
  final searchFilter=TextEditingController();
  final editController=TextEditingController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // ref.onValue.listen((event) { });           you can also do this
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
                  IconButton(color:Colors.white,onPressed: (){
                    auth.signOut().then((value) {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginScreen()));
                    }).onError((error, stackTrace) {
                      Utils().toastMessage(error.toString());
                    });
                  }, icon:Icon(Icons.logout_outlined)),
                  SizedBox(width:10,)
        ],
        backgroundColor:Colors.deepPurple,
        title: Center(child: Text('Post',style: TextStyle(color: Colors.white),)),
      ),

      body:Column(
        children:[
          const SizedBox(height:10),
          Padding(
            padding:const EdgeInsets.symmetric(horizontal: 20),
            child: TextFormField(             //for filtering list
              controller:searchFilter,
              decoration:const InputDecoration(
                hintText: "Search",
                border:OutlineInputBorder(),
              ),

              onChanged: (String value){
                  setState(() {

                  });
              },

            ),
          ),
          Expanded(
            child:FirebaseAnimatedList(
                query:ref,
                defaultChild:Text("loading"),
                itemBuilder:(context,snapshot,animation,index){

                  final title=snapshot.child("title").value.toString();

                  if(searchFilter.text.isEmpty){
                    return ListTile(
                      title:Text(snapshot.child('title').value.toString()), //title attribute of a child,snapshot symbolises post
                      subtitle:Text(snapshot.child('id').value.toString()),
                      trailing: PopupMenuButton(
                        icon:Icon(Icons.more_vert),
                        itemBuilder: (context)=>[
                             PopupMenuItem(
                                value:1,
                                 child:ListTile(
                                   onTap: (){
                                     Navigator.pop(context);
                                     showMyDialog(title,snapshot.child('id').value.toString());
                                   },
                                   leading:Icon(Icons.edit),
                                   title:Text("edit"),
                                 )
                             ),
                             PopupMenuItem(
                              value:1,
                              child:ListTile(
                                onTap: (){
                                  Navigator.pop(context);
                                  ref.child(snapshot.child('id').value.toString()).remove();
                                },
                                leading:Icon(Icons.delete_outline),
                                title:Text("delete"),
                              )
                          ),
                      ],
                      ),
                    );
                  }
                  else if(title.toLowerCase().contains(searchFilter.text.toLowerCase().toString())){
                    return ListTile(
                      title:Text(snapshot.child('title').value.toString()), //title attribute of a child,snapshot symbolises post
                      subtitle:Text(snapshot.child('id').value.toString()),
                    );
                  }

                  else{
                    return Container();
                  }
                }
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
           Navigator.push(context,MaterialPageRoute(builder: (context)=>AddPostScreen()));

        },
        child:Icon(Icons.add),
      ),
    );
  }


  Future<void> showMyDialog(String title,String id )async{
    editController.text=title;
    return showDialog(
        context:context,
        builder:(BuildContext context){
          return AlertDialog(
            title:Text("update"),
            content:Container(
              child:TextField(
                controller:editController,
                decoration: InputDecoration(
                  hintText: 'edit',

                ),
              ),
            ),
            actions:[
              TextButton(onPressed: (){Navigator.pop(context);}, child: Text("cancel")),
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                    ref.child(id).update({
                      'title':editController.text.toLowerCase(),
                    }).then((value){
                      Utils().toastMessage("post updated");

                    }).onError((error, stackTrace) {
                      Utils().toastMessage(error.toString());
                    });




                    },

                  child: Text("update")),
            ],
          );
        }
    );
  }
}


/*
1.Now we are trying to update and delete from the list, I have added pop up to each list item
 */
