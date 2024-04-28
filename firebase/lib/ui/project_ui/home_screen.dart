import 'package:firebaseproject/Contact/contactUs.dart';
import 'package:firebaseproject/Models/parametermodel.dart';
import 'package:firebaseproject/ui/auth/login_screen.dart';
import 'package:firebaseproject/ui/project_ui/home_screen2.dart';
import 'package:firebaseproject/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

import 'dart:convert';

//With Blessings from the Great Baba


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Parameters> postList=[];   //we have to do it as we dont have array name for api content of the website
   String id="";


  Future<List<Parameters>> getPostApi()async{
   // final response=await http.get(Uri.parse("https://mpde59432382a0fac6b1.free.beeceptor.com/data"));
    final response=await http.get(Uri.parse("https://mp026bb069719e51a543.free.beeceptor.com/data"));
    var data=jsonDecode(response.body.toString());
    if(response.statusCode==200){
      postList.clear();
      for(Map<String, dynamic>i in data){
        postList.add(Parameters.fromJson(i));
      }

      return postList;
    }
    else{

      return postList;
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
                Navigator.pop(context);
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
              //flex: 1,
                child: FutureBuilder(
                    future: getPostApi(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SizedBox(
                                width:MediaQuery.of(context).size.width,
                                child: SfCartesianChart(
                                  primaryXAxis:  CategoryAxis(),
                                  title: const ChartTitle(text: 'PH analysis'),
                                  series: <LineSeries<Parameters, int>>[
                                    LineSeries<Parameters, int>(
                                      dataSource: postList,
                                      xValueMapper: (Parameters sales, int index) => index,
                                      yValueMapper: (Parameters sales, _) => sales.ph,
                                    )
                                  ]
                                ),
                              ),
                              SizedBox(
                                width:MediaQuery.of(context).size.width,
                                child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    title: const ChartTitle(text: 'Hardness analysis'),
                                    series: <LineSeries<Parameters, int>>[
                                      LineSeries<Parameters, int>(
                                        dataSource: postList,
                                        xValueMapper: (Parameters sales, int index) => index,
                                        yValueMapper: (Parameters sales, _) => sales.hardness,
                                      )
                                    ]
                                ),
                              ),
                              SizedBox(
                                width:MediaQuery.of(context).size.width,
                                child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    title: const ChartTitle(text: 'Solids analysis'),
                                    series: <LineSeries<Parameters, int>>[
                                      LineSeries<Parameters, int>(
                                        dataSource: postList,
                                        xValueMapper: (Parameters para, int index) => index,
                                        yValueMapper: (Parameters para, _) => para.solids,
                                      )
                                    ]
                                ),
                              ),
                              SizedBox(
                                width:MediaQuery.of(context).size.width,
                                child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    title: const ChartTitle(text: 'Chloramines analysis'),
                                    series: <LineSeries<Parameters, int>>[
                                      LineSeries<Parameters, int>(
                                        dataSource: postList,
                                        xValueMapper: (Parameters sales, int index) => index,
                                        yValueMapper: (Parameters sales, _) => sales.chloramines,
                                      )
                                    ]
                                ),
                              ),
                              SizedBox(
                                width:MediaQuery.of(context).size.width,
                                child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    title: const ChartTitle(text: 'Conductivity analysis'),
                                    series: <LineSeries<Parameters, int>>[
                                      LineSeries<Parameters, int>(
                                        dataSource: postList,
                                        xValueMapper: (Parameters sales, int index) => index,
                                        yValueMapper: (Parameters sales, _) => sales.conductivity,
                                      )
                                    ]
                                ),
                              ),
                              SizedBox(
                                width:MediaQuery.of(context).size.width,
                                child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    title: const ChartTitle(text: 'Turbidity analysis'),
                                    series: <LineSeries<Parameters, int>>[
                                      LineSeries<Parameters, int>(
                                        dataSource: postList,
                                        xValueMapper: (Parameters sales, int index) => index,
                                        yValueMapper: (Parameters sales, _) => sales.turbidity,
                                      )
                                    ]
                                ),
                              ),
                            ]
                          ),
                        );
                      }
                      else{
                        return const CircularProgressIndicator();
                      }
                    }
                )
            ),
              Expanded(
                //flex: 2,
                child: SingleChildScrollView(
                  child: FutureBuilder(
                    future:getPostApi(),
                    builder: (context,snapshot){
                      if(!snapshot.hasData){return const Text("loading");}
                      else{
                        id="d";
                        return Column(
                          children: [
                            Row(
                                children: [
                                  Padding(padding:const EdgeInsets.only(left: 40,right:30,bottom: 40,top:20),child: Contain(message: postList[0].ph!.toStringAsFixed(2), color:HexColor('#90EE90'),title: "PH",max:post(postList,"ph").toStringAsFixed(2))),
                                  Padding(padding:const EdgeInsets.only(left: 40,right:30,bottom: 40,top:20),child: Contain(message: postList[0].hardness!.toStringAsFixed(2), color:HexColor('F4F82D'),title:"Hardness",max:post(postList,"hardness").toStringAsFixed(2))),
                                ],
                            ),
                            Row(
                              children: [

                                Padding(padding:const EdgeInsets.only(left: 40,right:30,bottom: 40),child: Contain(message: postList[0].solids!.toStringAsFixed(2), color:HexColor('ffdab9'),title: "Solids",max:post(postList,"solids").toStringAsFixed(2))),
                                Padding(padding:const EdgeInsets.only(left: 40,right:30,bottom: 40),child: Contain(message: postList[0].chloramines!.toStringAsFixed(2), color: HexColor('9FDAED'),title: "Chloramines",max:post(postList,"chloramines").toStringAsFixed(2))),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(padding:const EdgeInsets.only(left: 40,right:30,bottom:40),child: Contain(message: postList[0].conductivity!.toStringAsFixed(2), color:HexColor('974DF6'),title: "Conductivity",max:post(postList,"conductivity").toStringAsFixed(2))),
                                Padding(padding:const EdgeInsets.only(left: 40,right:30,bottom:40),child: Contain(message: postList[0].turbidity!.toStringAsFixed(2), color: HexColor('FB73CD'),title:"Turbidity",max:post(postList,"turbidity").toStringAsFixed(2))),
                              ],
                            ),
                          ]
                        );
                      }
                    }
                              ),
                ),
              ),
              FloatingActionButton(child:Icon(Icons.arrow_circle_right_outlined),onPressed: (){Navigator.push(context,MaterialPageRoute(builder: (context)=>HomeScreenTwo()));})
              

          ],
        ),
        
        
      )
    );
  }
}


double post(List<Parameters> list1,String index1){
  double max=0.0;


  for(int index=0;index<list1.length;index++){

      switch(index1) {
        case "ph":
          if (max < list1[index].ph!.toDouble()) {
            max = list1[index].ph!.toDouble();
          }
          break;
        case "hardness":
          if (max < list1[index].hardness!.toDouble()) {
            max = list1[index].hardness!.toDouble();
          }
          break;

        case "solids":
          if (max < list1[index].solids!.toDouble()) {
            max = list1[index].solids!.toDouble();
          }
          break;
        case "chloramines":
          if (max < list1[index].chloramines!.toDouble()) {
            max = list1[index].hardness!.toDouble();
          }
          break;
        case "conductivity":
          if (max < list1[index].conductivity!.toDouble()) {
            max = list1[index].conductivity!.toDouble();
          }
          break;
        case "turbidity":
          if (max < list1[index].turbidity!.toDouble()) {
            max = list1[index].turbidity!.toDouble();
          }
          break;
        default:
          break;
      }
    }

  return max;
}

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










