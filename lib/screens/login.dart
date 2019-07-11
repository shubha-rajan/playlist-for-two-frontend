import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

import 'package:playlist_for_two/helpers/auth_helper.dart';



var uuid = new Uuid(options: {
  'grng': UuidUtil.cryptoRNG
});

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  var stateKey = uuid.v4(options: {
  'rng': UuidUtil.cryptoRNG
  });


  initState() {
    super.initState();
    AuthHelper.initUriListener(stateKey);
  }

  _loginPressed(){
    AuthHelper.launchSpotifyLogin(stateKey);
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Log In'),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('graphics/logo-white.png', width:250),
            MaterialButton(
              onPressed: _loginPressed,
              child: Text('Log in with Spotify',
                style: TextStyle(fontSize: 20)
              ),
              shape: StadiumBorder(),
              textColor: Colors.white,
              color:Colors.green, 
              height: 50,
              minWidth:300
            ),
          ],
        ),
      ),
    );
  }
}
