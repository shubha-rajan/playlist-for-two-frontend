import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



var uuid = new Uuid(options: {
  'grng': UuidUtil.cryptoRNG
});

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
        '/login': (context) => LoginPage(title:"Log In"),
        '/home':(context) => HomePage()
      }
    );
  }
}

class LoginHelper {

  static Future<String> getLoggedInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('UID') ?? '';
  }

  static Future<bool> setLoggedInUser(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('UID', id);
    
  }

  static Future<bool> clearLoggedInUser()  async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  var stateKey = uuid.v4(options: {
  'rng': UuidUtil.cryptoRNG
  });


  initState() {
    super.initState();
    initUriListener();
  }

  getUser(code) async {
    var payload = {"code": "$code"};
    var response = await http.post('http://127.0.0.1:5000/login-user', body: payload);
    LoginHelper.setLoggedInUser(json.decode(response.body)['spotify_id']);
    Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
    );
  }

  initUriListener() async {

    getUriLinksStream().listen((Uri uri) {
      if (uri?.queryParameters['state'] == stateKey) {
        var code = uri?.queryParameters['code'];
        getUser(code);
        closeWebView();
      }

    }, onError: (err) {
      print('got err: $err');
    });
  }

  void _launchSpotify()  async {
  var clientId = DotEnv().env['SPOTIFY_CLIENT_ID'];
  var redirectUri = DotEnv().env['SPOTIFY_REDIRECT_URI'];
  var scopes = "user-library-read user-read-recently-played user-top-read playlist-read-collaborative playlist-modify-private";

  final url = Uri.encodeFull('https://accounts.spotify.com/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&state=$stateKey&scope=$scopes&show_dialog=true');

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          
          children: <Widget>[
            Image.asset('graphics/logo-white.png', width:250),
            MaterialButton(
              onPressed: _launchSpotify,
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

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => 
new _SplashPageState();
}
class _SplashPageState extends State<SplashPage> {
  getNextScreen() async {
     String user = await LoginHelper.getLoggedInUser();
      print(user);
      String route = (user == '') ? '/login' : '/home';
      return Navigator.pushReplacementNamed(context, route);
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
        child: new Image.asset('graphics/splash.png', width:250),
        
        ),
      );
  }
}


class HomePage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    void _logOutUser() {
      LoginHelper.clearLoggedInUser();
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
                builder: (context) => LoginPage(title: 'Log In')
              )
      );
  }
    return Scaffold(
      appBar: AppBar(
        title: Text("Playlist for Two"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome'),
            MaterialButton(
                  onPressed: _logOutUser,
                  child: Text('Log Out',
                    style: TextStyle(fontSize: 20)
                  ),
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  color:Colors.green, 
                  height: 50,
                  minWidth:300
            ),
          ]
        )
      )
    );
  }
}