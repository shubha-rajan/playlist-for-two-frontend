import 'package:flutter/material.dart';


class UserPage extends StatelessWidget {
  UserPage({Key key, this.name, this.userID}) : super(key: key);
  final String name;
  final String userID;

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text("Playlist for Two"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(name,
            style: TextStyle(fontSize: 50), textAlign: TextAlign.center,),
            SizedBox(height: 30),
          ]
        )
      )
    );
  }
}