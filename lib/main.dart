import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:playlist_for_two/screens/splash.dart';
import 'package:playlist_for_two/screens/login.dart';
import 'package:playlist_for_two/screens/home.dart';
import 'package:playlist_for_two/helpers/navigation_helper.dart';



Future main() async {
  await DotEnv().load('.env');
  setupLocator();
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
        primaryColor: Colors.blueAccent,
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashPage(),
        '/login': (context) => LoginPage(),
        '/home':(context) => HomePage()
      },
      navigatorKey: locator<NavigationService>().navigatorKey,
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/home':
            return MaterialPageRoute(builder: (context) => HomePage());
          default: 
            return MaterialPageRoute(builder: (context) => LoginPage());
        }
      }
    );
  }
}




