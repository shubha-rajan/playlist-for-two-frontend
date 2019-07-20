import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/search_users.dart';
import 'package:playlist_for_two/screens/user.dart';



class FriendsPage extends StatefulWidget {
  FriendsPage ({Key key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
   @override
   void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }
  
  dynamic _friends={
    'incoming':[],
    'sent':[],
    'accepted':[]
  };

  void _findFriends(){
    Navigator.push(context, 
      MaterialPageRoute(
            builder: (context) => SearchPage()
      )
    );
  }

  Future<Map> getData() async {
    String token = await LoginHelper.getAuthToken();
    String userID = await LoginHelper.getLoggedInUser();

    var response = await http.get("${DotEnv().env['P42_API']}/friends?user_id=$userID", headers: {'authorization': token});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return _friends;
    }
      
  }

  void setData() async {
    var data = await getData();
    setState(() {
      _friends= data['friends'];
    });
  }
  
  void viewUser(userID, name) {
    Navigator.push(context,
    MaterialPageRoute(
      builder: (context) => UserPage(userID: userID, name:name)
    )
  );
  }

  @override
  void didChangeDependencies() {
    setData();
    super.didChangeDependencies();
  }

  Widget build(BuildContext context) {
    
    return DefaultTabController(
      length:3,
      child: Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
        bottom: TabBar(
          tabs: [
                Tab(text: "Incoming",),
                Tab(text: "Sent"),
                Tab(text: "Accepted"),
              ],
        )
        
      ),
      body: TabBarView(
          children: [
            _myListView(context, _friends['incoming']),
            _myListView(context, _friends['sent']),
            _myListView(context, _friends['accepted']),
          ] ,
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: _findFriends,
        child: Icon(Icons.add), 
        backgroundColor: Colors.blueAccent
      )
      )
    );
  }
  Widget _myListView(BuildContext context, List data) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(json.decode(data[index])['name']),
            onTap: (){
              viewUser(json.decode(data[index])['friend_id'], json.decode(data[index])['name']);
            },
          );
        },
      );
  }
}