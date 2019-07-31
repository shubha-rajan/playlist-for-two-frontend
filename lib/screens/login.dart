import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

import 'package:playlist_for_two/helpers/auth_helper.dart';

var uuid = new Uuid(options: {'grng': UuidUtil.cryptoRNG});

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var stateKey = uuid.v4(options: {'rng': UuidUtil.cryptoRNG});
  bool isLoading = false;
  Widget _loadingBar = new Container(
    height: 20.0,
    child: new Center(child: new LinearProgressIndicator()),
  );

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  initState() {
    super.initState();
    AuthHelper.initUriListener(stateKey, context, _setLoadingState);
  }

  _loginPressed() {
    AuthHelper.launchSpotifyLogin(stateKey, context);
  }

  void _setLoadingState() {
    setState(() {
      isLoading = true;
    });
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
            Image.asset('graphics/logo-white.png', width: 250),
            isLoading
                ? Column(children: <Widget>[
                    _loadingBar,
                    Text("Loading your listening data. This may take a while...")
                  ])
                : Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 20),
                    child: MaterialButton(
                        onPressed: _loginPressed,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                          Text('Log in with Spotify', style: TextStyle(fontSize: 20)),
                          Padding(
                              child: Image.asset(
                                'graphics/Spotify_Icon_RGB_White.png',
                                height: 40,
                                width: 40,
                              ),
                              padding: EdgeInsets.only(left: 10, right: 10))
                        ]),
                        shape: StadiumBorder(),
                        textColor: Colors.white,
                        color: Colors.green,
                        height: 50,
                        )),
          ],
        ),
      ),
    );
  }
}
