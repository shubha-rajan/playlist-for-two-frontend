import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/list.dart';
import 'package:playlist_for_two/screens/friends.dart';



class HomePage extends StatelessWidget {
  HomePage({Key key, this.name, this.imageUrl}) : super(key: key);
  final String name;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {

    void _logOutUser() {
      LoginHelper.clearLoggedInUser();
      Navigator.pushReplacementNamed(context, '/login');
  }
    void _getUserSongs() async {
      String userID = await LoginHelper.getLoggedInUser();
      
      var response = await http.get('${DotEnv().env['P42_API']}/listening-history?user_id=$userID');
      Navigator.push(
        context, 
        MaterialPageRoute(
            builder: (context) => ListPage(
              itemList: json.decode(response.body)['top_songs'], 
              title:'Top Songs',
          )
        )
      );
    }

    void _getFriendsList() async {

    Navigator.push(
        context, 
        MaterialPageRoute(
            builder: (context) => FriendsPage(
              title:'Friends',
          )
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
            CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => new CircularProgressIndicator(),
                errorWidget: (context, url, error) => new Icon(Icons.error),
            ),
            Text('Welcome, $name',
            style: TextStyle(fontSize: 50), textAlign: TextAlign.center,),
            SizedBox(height: 30),
            MaterialButton(
                  onPressed: _getUserSongs,
                  child: Text('My Top Songs',
                    style: TextStyle(fontSize: 20)
                  ),
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  color:Colors.blueAccent, 
                  height: 50,
                  minWidth:300
            ),
            SizedBox(height: 30),
            MaterialButton(
                  onPressed: _getFriendsList,
                  child: Text('My Friends',
                    style: TextStyle(fontSize: 20)
                  ),
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  color:Colors.blueAccent, 
                  height: 50,
                  minWidth:300
            ),
            SizedBox(height: 30),
            MaterialButton(
                  onPressed: _logOutUser,
                  child: Text('Log Out',
                    style: TextStyle(fontSize: 20)
                  ),
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  color:Colors.red, 
                  height: 50,
                  minWidth:300
            ),
          ]
        )
      )
    );
  }
}