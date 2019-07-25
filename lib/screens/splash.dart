import 'dart:async';

import 'package:flutter/material.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/home.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => 
new _SplashPageState();
}
class _SplashPageState extends State<SplashPage> {
  getNextScreen() async {
     String user = await LoginHelper.getLoggedInUser();
      if (user == '') {
        return Navigator.pushReplacementNamed(context, '/login');
      } else {
        String username = await LoginHelper.getUserName();
        String url = await LoginHelper.getUserPhoto();
        String token = await LoginHelper.getAuthToken();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(name: username, imageUrl: url, authToken: token, userID:user)
          ),
    );
      }
      
  }
  startTimer() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, getNextScreen);
  }
  @override
    void initState() {
      super.initState();
      startTimer();
    }
  @override
  Widget build(BuildContext context) {
  
  return new Scaffold(
      body: new Center(
        child: new Image.asset('graphics/logo-white.png', width:250),
        
        ),
      );
  }
}
