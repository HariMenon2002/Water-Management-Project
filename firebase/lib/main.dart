import 'package:firebaseproject/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//firebase

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
      title:'flutter demo',
      // theme:ThemeData(
      //   primarySwatch: Colors.purple,
      // ),
      home: SplashScreen(),
    );
  }
}



/*
1.First install nodejs and set as env variable
2.Go to  firebase and do the necessary steps
3.flutter fire configure ... command given is to be run here in the terminal
4.Go to pubspec yaml and add firebase_core
5.Import the firebase files(given in documentation)
6.Call the async initialize app fn as given above in main function

7.Go to android section in firebase website, and do the necessary steps ,add the necessary packages in settings.gradle
8.Get necessary pkgs from pub.dev and make sdk version in app\build.gradle as 21, you may also encounter multidex error, for that in terminal do flutter run --debug and enter y when prompted

9.Create ui an firebase_services folder
 */
