import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';

import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/home.dart';



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
    initUriListener();
  }

  getUser(code) async {
    var payload = {"code": "$code"};
    var response = await http.post('http://127.0.0.1:5000/login-user', body: payload);
    LoginHelper.setLoggedInUser(json.decode(response.body)['spotify_id']);
    LoginHelper.setUserName(json.decode(response.body)['name']);
    List<dynamic> imageLinks = json.decode(response.body)['image_links'];
    String url = (imageLinks.length > 0) ? imageLinks[0]['url'] : '';
    LoginHelper.setUserPhoto(url);
    Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(name: json.decode(response.body)['name'], imageUrl: url),
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

        title: Text('Log In'),
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
