//import 'dart:html';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseproject/Contact/contactUs.dart';
import 'package:firebaseproject/ui/auth/login_screen.dart';
import 'package:firebaseproject/ui/project_ui/home_screen.dart';
import 'package:firebaseproject/widgets/round_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import 'dart:convert';

//With Blessings from the Great Baba


class HomeScreenTwo extends StatefulWidget {
  const HomeScreenTwo({super.key});

  @override
  State<HomeScreenTwo> createState() => _HomeScreenTwoState();
}

class _HomeScreenTwoState extends State<HomeScreenTwo> {

  
  String prediction3="dd";
  final ref=FirebaseDatabase.instance.ref("UsersData/readings");


  void _showDialog(String problem){
    showDialog(context: context, builder: (context){
            return CupertinoAlertDialog(
              title: Text(problem),
              content:const Text("Please go to Contacts Section to solve the problem"),
              actions: [
                MaterialButton(onPressed: (){Navigator.pop(context);},child:Text('Go Back')),
                MaterialButton(onPressed: (){Navigator.push(context,MaterialPageRoute(builder: (context)=>Contact()));},child:Text('Go to Contacts')),
              ],
            );
    });
  }



  Future<String> predictWaterPotability(Map<dynamic, dynamic> data) async {
    final response = await http.post(
      Uri.parse('https://8b01-42-108-125-60.ngrok-free.app/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    print(response.statusCode);
    print("dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, return the prediction
      return jsonDecode(response.body)['prediction'];
    } else {
      // If the server returns an error response, throw an exception
      throw Exception('Failed to predict water potability.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:const Text("Water parameters",style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.deepPurple,
        ),

        drawer: Drawer(

          child:ListView(
            padding: const EdgeInsets.only(top:0),
            children: [
              const UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color:Color(0xff764abc),
                  ),
                  accountName: Text('Hari Menon'),
                  accountEmail: Text('dkfjs@gmail.com')
              ),




              ListTile(
                leading:const Icon(Icons.home),
                title:const Text('Home'),
                onTap: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>HomeScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title:const Text('Logout'),
                onTap: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginScreen()));
                },
              ),
              ListTile(
                leading:const Icon(Icons.call),
                title:const Text('Contact'),
                onTap: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>Contact()));
                },
              ),
            ],
          ),
        ),

        body: SafeArea(
          child:Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Expanded(
                //flex: 2,
                child: SingleChildScrollView(
                  child: StreamBuilder(
                      stream:ref.onValue,
                      builder: (context,snapshot){
                        if(!snapshot.hasData){return const Text("loading");}
                        else{
                          Map<dynamic,dynamic> map=snapshot.data!.snapshot.value as dynamic;
                          List<dynamic> list=[];
                          list.clear();
                          list=map.values.toList();
                          list.sort((a, b) {
                            // Ensure both objects have a 'timestamp' key
                            if (a.containsKey('timestamp') && b.containsKey('timestamp')) {
                              // Compare timestamps
                              return a['timestamp'].compareTo(b['timestamp']);
                            } else {
                              // If one of the objects doesn't have a 'timestamp' key, keep it at the end
                              return 1;
                            }
                          });

                          int length1=snapshot.data!.snapshot.children.length;






                          double pH=double.parse(list[length1-1]?['pH']);
                          double conductivity=double.parse(list[length1-1]?['conductivity']);
                          double turbidity=double.parse(list[length1-1]?['turbidity']);
                          double tds=double.parse(list[length1-1]?['ppm']);






                          void trial() async{
                            //String prediction = await predictWaterPotability(list[length1-1]);
                            String prediction2=await predictWaterPotability(
                              {

                                "ph":double.parse(list[length1-1]?["pH"]),
                                "Hardness": 150.0,
                                "Solids":double.parse(list[length1-1]?["ppm"]),
                                "Chloramines":7.3,
                                "Sulfate":368.5,
                                "Conductivity":double.parse(list[length1-1]?["conductivity"]),
                                "Organic_carbon":10.379,
                                "Trihalomethanes":86.99,
                                "Turbidity":double.parse(list[length1-1]?["turbidity"]),
                              }
                            );
                             print(prediction2);
                             prediction3=prediction2;
                          }
                          trial();

                           if(prediction3=="Potable") return Center(child: Container(child: Center(child: Text("Water is portable",)),color: Colors.greenAccent,height: 200,width:100));





                          if(pH>16.0 || pH<2.0) {
                            return CupertinoAlertDialog(
                              title: Text("PH out of range: $pH"),
                              content: const Text("Threshold: 5-7"),
                              actions: [
                                MaterialButton(onPressed: () {
                                  Navigator.pop(context);
                                }, child: const Text("Go Back")),
                                MaterialButton(onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => Contact()));
                                }, child: const Text("Contact"),)
                              ],
                            );
                          }
                          if(turbidity>150.0 || turbidity<0.0) {
                            return CupertinoAlertDialog(
                              title: Text("Turbidity out of range: $turbidity"),
                              content: const Text("Threshold: 0-5"),
                              actions: [
                                MaterialButton(onPressed: () {
                                  Navigator.pop(context);
                                }, child: const Text("Go Back")),
                                MaterialButton(onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => Contact()));
                                }, child: const Text("Contact"),)
                              ],
                            );
                          }
                          if(conductivity>100.0 || conductivity<0.0) {
                            return CupertinoAlertDialog(
                              title: Text("Conductivity out of range: $conductivity"),
                              content: const Text("Threshold: 1-5"),
                              actions: [
                                MaterialButton(onPressed: () {
                                  Navigator.pop(context);
                                }, child: const Text("Go Back")),
                                MaterialButton(onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => Contact()));
                                }, child: const Text("Contact"),)
                              ],
                            );
                          }
                          if(tds>150.0 || tds<0.0) {
                            return CupertinoAlertDialog(
                              title:  Text("TDS out of range: $tds"),
                              content: const Text("Threshold: 0-150"),
                              actions: [
                                MaterialButton(onPressed: () {
                                  Navigator.pop(context);
                                }, child: const Text("Go Back")),
                                MaterialButton(onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => Contact()));
                                }, child: const Text("Contact"),)
                              ],
                            );
                          }
                          return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 100),
                                Row(
                                  children: [
                                    Padding(padding:const EdgeInsets.only(left: 40,right:30,bottom: 40,top:20),child: Contain(message:list[length1-1]['humidity'] , color:HexColor('#90EE90'),title: "Humidity",max:list[length1-1]['max humidity'])),
                                    Padding(padding:const EdgeInsets.only(left: 40,right:30,bottom: 40,top:20),child: Contain(message: list[length1-1]['temperature'], color:HexColor('F4F82D'),title:"Temperature",max:list[length1-1]['max temperature'])),
                                  ],
                                ),
                                Row(
                                  children: [

                                    Padding(padding:const EdgeInsets.only(left: 40,right:30,bottom: 40),child: Contain(message:list[length1-1]['pH'] , color:HexColor('ffdab9'),title: "PH",max:list[length1-1]['max pH'])),
                                    Padding(padding:const EdgeInsets.only(left: 40,right:30,bottom: 40),child: Contain(message:list[length1-1]['turbidity'] , color:HexColor('9FDAED'),title: "Turbidity",max:list[length1-1]['max turbidity'])),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(padding:const EdgeInsets.only(left: 40,right:30,bottom:40),child: Contain(message:list[length1-1]['conductivity'] , color:HexColor('974DF6'),title: "Conductivity",max:list[length1-1]['max conductivity'])),
                                    Padding(padding:const EdgeInsets.only(left: 40,right:30,bottom:40),child: Contain(message:list[length1-1]['ppm'] , color:HexColor('FB73CD'),title: "TDS")),
                                  ],
                                ),

                              ]
                          );
                        }
                      }
                  ),
                ),
              ),


            ],
          ),
        )
    );
  }
}


    //to be removed

// Convert hex color to Color object
class HexColor extends Color {
  HexColor(final String hexColor) : super(_parseColor(hexColor));

  static int _parseColor(String color) {
    var hex = color.toUpperCase().replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return int.parse(hex, radix: 16);
  }
}












