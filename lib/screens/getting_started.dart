import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Getting Started")),
        body: SingleChildScrollView(
            child: Center(
                child: Padding(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                      Container(
                        child: Image.asset('graphics/logo-white.png'),
                        padding: EdgeInsets.all(60),
                      ),
                      Text("Welcome to Playlist for Two!", style: TextStyle(fontSize: 20)),
                      SizedBox(height: 20),
                      Text(
                          "Playlist for Two is all about finding common ground and discovering music together. It is built on top of Spotify's powerful recommendation engine, and uses your listening history to find out what music you have in common with your friends.",
                          style: TextStyle(fontSize: 15)),
                      SizedBox(height: 20),
                      Text(
                          "To get started, find a friend and request to connect with them. Once they accept your friend request, you can start generating playlists!",
                          style: TextStyle(fontSize: 15)),
                      SizedBox(height: 20),
                      Text(
                          "You can either generate a customized playlist by choosing specific seeds from things you have in common, or make a grab bag playlist, where up to 5 random seeds are selected by the app. Once you generate a playlist, it will be visible to both you and your friend!",
                          style: TextStyle(fontSize: 15))
                    ]),
                    padding: EdgeInsets.all(30)))));
  }
}
