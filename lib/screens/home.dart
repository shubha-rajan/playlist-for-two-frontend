import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:playlist_for_two/screens/top_music.dart';
import 'package:playlist_for_two/screens/user.dart';

import 'package:playlist_for_two/components/drawer_list_view.dart';
import 'package:playlist_for_two/components/friend_list_view.dart';
import 'package:playlist_for_two/components/playlist_view.dart';
import 'package:playlist_for_two/components/user_card.dart';
import 'package:playlist_for_two/components/error_dialog.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.name, this.imageUrl, this.authToken, this.userID}) : super(key: key);

  final String authToken;
  final String imageUrl;
  final String name;
  final String userID;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic _friends = {
    'accepted': [],
    'incoming': [],
    'sent': [],
  };
  bool _friendsLoaded = false;

  List<dynamic> _playlists = [];
  bool _playlistsLoaded = false;

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

  Future<Map> getFriends() async {
    String token = widget.authToken;
    String userID = widget.userID;

    var response = await http.get("${DotEnv().env['P42_API']}/friends?user_id=$userID",
        headers: {'authorization': token});

    if (response.statusCode == 200) {
      setState(() {
        _friendsLoaded = true;
      });
      return json.decode(response.body);
    } else {
      errorDialog(context, 'An error occurred',
          'There was a problem retrieving data from our servers. Check your network connection or try again later.');
      return _friends;
    }
  }

  Future<List> getPlaylists() async {
    String token = widget.authToken;
    String userID = widget.userID;

    var response = await http.get("${DotEnv().env['P42_API']}/playlists?user_id=$userID",
        headers: {'authorization': token});

    if (response.statusCode == 200) {
      setState(() {
        _playlistsLoaded = true;
      });
      return json.decode(response.body);
    } else {
      errorDialog(context, 'An error occurred',
          'There was a problem retrieving data from our servers. Check your network connection or try again later.');
      return _playlists;
    }
  }

  Future<void> setData() async {
    var friends = await getFriends();
    var playlists = await getPlaylists();
    setState(() {
      _friends = friends['friends'];
      _playlists = playlists;
    });
  }

  void _viewUser(userID, name) {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => UserPage(userID: userID, name: name)))
        .whenComplete(setData);
  }

  void _getUserSongs() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TopMusicPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Playlist for Two"),
        ),
        drawer: Drawer(
            child: DrawerListView(
          refreshCallback: setData,
        )),
        body: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Padding(
            child: userCard(
                widget.imageUrl,
                widget.name,
                _friends['accepted'].length,
                _playlists.length,
                MaterialButton(
                  onPressed: _getUserSongs,
                  child: Text('My Top Music', style: TextStyle(fontSize: 15)),
                  textColor: Colors.white,
                  color: Colors.blueAccent,
                )),
            padding: EdgeInsets.all(30),
          ),
          Expanded(
              child: DefaultTabController(
                  length: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: TabBar(tabs: [
                          Tab(text: "Friends"),
                          Tab(text: "Playlists"),
                        ]),
                        width: 400,
                      ),
                      Flexible(
                        child: TabBarView(
                          children: [
                            (_friendsLoaded)
                                ? friendListView(context, _friends['accepted'], _viewUser, setData)
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                        Center(child: CircularProgressIndicator()),
                                        SizedBox(height: 20),
                                        Text('Loading Friends...')
                                      ]),
                            (_playlistsLoaded)
                                ? playlistListView(context, _playlists, setData)
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                        Center(child: CircularProgressIndicator()),
                                        SizedBox(height: 20),
                                        Text('Loading Playlists...')
                                      ]),
                          ],
                        ),
                        fit: FlexFit.loose,
                      )
                    ],
                  ))),
        ])));
  }
}
