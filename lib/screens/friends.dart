import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/search_users.dart';
import 'package:playlist_for_two/screens/user.dart';
import 'package:playlist_for_two/components/error_dialog.dart';

class FriendsPage extends StatefulWidget {
  FriendsPage({Key key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  dynamic _friends = {
    'accepted': [],
    'incoming': [],
    'sent': [],
  };

  @override
  void didChangeDependencies() {
    setData();
    super.didChangeDependencies();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _findFriends() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()))
        .whenComplete(setData);
  }

  Future<Map> getData() async {
    String token = await LoginHelper.getAuthToken();
    String userID = await LoginHelper.getLoggedInUser();

    var response = await http.get("${DotEnv().env['P42_API']}/friends?user_id=$userID",
        headers: {'authorization': token});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      errorDialog(context, 'An error occurred',
          'There was a problem retrieving data from our servers. Check your network connection or try again later.');
      return _friends;
    }
  }

  void setData() async {
    var data = await getData();
    setState(() {
      _friends = data['friends'];
    });
  }

  void _viewUser(userID, name) {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => UserPage(userID: userID, name: name)))
        .whenComplete(setData);
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
                title: Text('Friend Requests'),
                bottom: TabBar(
                  tabs: [
                    Tab(
                      text: "New Requests",
                    ),
                    Tab(text: "Sent Requests"),
                  ],
                )),
            body: TabBarView(
              children: [
                _friendListView(context, _friends['incoming']),
                _friendListView(context, _friends['sent']),
              ],
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: _findFriends,
                child: Icon(Icons.add),
                backgroundColor: Colors.blueAccent)));
  }

  Widget _friendListView(BuildContext context, List data) {
    return RefreshIndicator(
        onRefresh: setData,
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: data.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(json.decode(data[index])['name']),
              onTap: () {
                _viewUser(json.decode(data[index])['friend_id'], json.decode(data[index])['name']);
              },
            );
          },
        ));
  }
}
