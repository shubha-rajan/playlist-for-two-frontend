import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/home.dart';
import 'package:playlist_for_two/helpers/navigation_helper.dart';





class AuthHelper {

  static void launchSpotifyLogin(String stateKey)  async {
    var clientId = DotEnv().env['SPOTIFY_CLIENT_ID'];
    var redirectUri = DotEnv().env['SPOTIFY_REDIRECT_URI'];
    var scopes = "user-library-read user-follow-read user-top-read playlist-read-collaborative playlist-modify-private";

    final url = Uri.encodeFull('https://accounts.spotify.com/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&state=$stateKey&scope=$scopes&show_dialog=true');

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
  }

  static initUriListener(stateKey) async {

    getUriLinksStream().listen((Uri uri) async {
      if (uri?.queryParameters['state'] == stateKey) {
        var code = uri?.queryParameters['code'];
        await getUser(code);
        closeWebView();
      }

    }, onError: (err) {
      print('got err: $err');
    });
  }

  static Future getUser(code) async {
    var payload = {"code": "$code"};
    var response = await http.post(DotEnv().env['P42_API'], body: payload);

    LoginHelper.setLoggedInUser(json.decode(response.body)['spotify_id']);
    LoginHelper.setUserName(json.decode(response.body)['name']);

    List<dynamic> imageLinks = json.decode(response.body)['image_links'];
    String url = (imageLinks.length > 0) ? imageLinks[0]['url'] : '';
    LoginHelper.setUserPhoto(url);
    
   locator<NavigationService>().navigateTo(
       MaterialPageRoute(
            builder: (context) => HomePage(name: json.decode(response.body)['name'], imageUrl: url),
          )
    );
  }
}