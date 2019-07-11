import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'package:playlist_for_two/screens/splash.dart';
import 'package:playlist_for_two/screens/login.dart';
import 'package:playlist_for_two/screens/home.dart';



Future main() async {
  await DotEnv().load('.env');
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
   @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  
  @override
  Widget build(BuildContext context) {
    
  
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.green,
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashPage(),
        '/login': (context) => LoginPage(),
        '/home':(context) => HomePage()
      }
    );
  }
}




