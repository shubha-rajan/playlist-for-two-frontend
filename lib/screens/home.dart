import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/songs_list.dart';


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
      
      var response = await http.get('http://play-for-two.herokuapp.com/listening-history?user_id=$userID');
      Navigator.push(
        context, 
        MaterialPageRoute(
            builder: (context) => SongsListPage(songsList: json.decode(response.body)['top_songs'],
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
                  child: Text('My Summary',
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