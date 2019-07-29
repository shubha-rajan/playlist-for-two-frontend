import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/form.dart';
import 'package:playlist_for_two/screens/home.dart';
import 'package:playlist_for_two/components/user_card.dart';
import 'package:playlist_for_two/components/error_dialog.dart';
import 'package:playlist_for_two/components/playlist_view.dart';
import 'package:playlist_for_two/components/friend_list_view.dart';
import 'package:playlist_for_two/components/action_button.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key, this.name, this.userID}) : super(key: key);

  final String name;
  final String userID;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _filterExplicit = false;
  String _friendStatus = 'pending';
  String _imageUrl = "http://placekitten.com/300/300";
  dynamic _friends = {'accepted': [], 'requested': [], 'incoming': []};

  Widget _loadingBar = new Container(
    height: 20.0,
    child: new Center(child: new LinearProgressIndicator()),
  );

  dynamic _playlists = [];

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

  void _viewUser(userID, name) {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => UserPage(userID: userID, name: name)))
        .whenComplete(setData);
  }

  Future<void> _createPlaylist() async {
    String authToken = await LoginHelper.getAuthToken();
    String selfID = await LoginHelper.getLoggedInUser();
    dynamic response = await http.post(
        "${DotEnv().env['P42_API']}/new-playlist?user_id=$selfID&friend_id=${widget.userID}&filter_explicit=$_filterExplicit",
        headers: {'authorization': authToken});
    if (response.statusCode == 200) {
      setData();
    } else {
      errorDialog(context, 'Could not generate playlist',
          'There was a problem creating your grab bag playlist. This can occur if either you or ${widget.name} have a limited listening history or if you do not have any common songs, artists, or genres. Try making a custom playlist to discover new music together and then try again!');
    }
  }

  Future<String> getImageURL() async {
    String authToken = await LoginHelper.getAuthToken();
    var response = await http.get("${DotEnv().env['P42_API']}/user?user_id=${widget.userID}",
        headers: {'authorization': authToken});
    if (response.statusCode == 200) {
      dynamic imageLinks = json.decode(response.body)['image_links'];
      String url = (imageLinks.length > 0) ? imageLinks[0]['url'] : _imageUrl;
      return url;
    } else {
      return _imageUrl;
    }
  }

  Future<Map> getFriends() async {
    String authToken = await LoginHelper.getAuthToken();
    var response = await http.get("${DotEnv().env['P42_API']}/friends?user_id=${widget.userID}",
        headers: {'authorization': authToken});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      errorDialog(context, 'An error occurred',
          'There was a problem retrieving data from our servers. Check your network connection or try again later.');
      return _friends;
    }
  }

  Future<List> getPlaylists() async {
    String authToken = await LoginHelper.getAuthToken();
    String selfID = await LoginHelper.getLoggedInUser();
    dynamic response = await http.get(
        "${DotEnv().env['P42_API']}/playlists?user_id=$selfID&friend_id=${widget.userID}",
        headers: {'authorization': authToken});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      errorDialog(context, 'An error occurred',
          'There was a problem retrieving data from our servers. Check your network connection or try again later.');
      return _playlists;
    }
  }

  Future<void> _removeFriend() async {
    String authToken = await LoginHelper.getAuthToken();
    String selfID = await LoginHelper.getLoggedInUser();
    dynamic response = await http.post("${DotEnv().env['P42_API']}/remove-friend",
        headers: {'authorization': authToken},
        body: {'user_id': selfID, 'friend_id': widget.userID});
    if (response.statusCode == 200) {
      setState(() {
        _friendStatus = 'none';
      });
    } else {
      errorDialog(context, 'An error occured', 'Could not remove friend. Please try again!');
    }
  }

  void _requestFriend() async {
    String selfID = await LoginHelper.getLoggedInUser();
    String token = await LoginHelper.getAuthToken();
    var payload = {
      "user_id": selfID,
      "friend_id": widget.userID,
    };
    dynamic response = await http.post("${DotEnv().env['P42_API']}/request-friend",
        headers: {"authorization": token}, body: payload);

    if (response.statusCode == 200) {
      setState(() {
        _friendStatus = 'requested';
      });
    }
  }

  void _acceptFriend() async {
    String selfID = await LoginHelper.getLoggedInUser();
    String token = await LoginHelper.getAuthToken();
    var payload = {
      "user_id": selfID,
      "friend_id": widget.userID,
    };
    dynamic response = await http.post("${DotEnv().env['P42_API']}/accept-friend",
        headers: {"authorization": token}, body: payload);
    if (response.statusCode == 200) {
      setState(() {
        _friendStatus = 'accepted';
      });
    }
  }

  Future<void> setData() async {
    dynamic playlists = await getPlaylists();
    String imageUrl = await getImageURL();
    setFriends();
    setState(() {
      _playlists = playlists;
      _imageUrl = imageUrl;
    });
  }

  Future<void> _grabBagPlaylistDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Make a new playlist'),
          content: Container(
              height: 150,
              child: Column(children: <Widget>[
                Text(
                    'Generate a playlist based on randomly selected songs, artists, and genres that you and ${widget.name} have in common.'),
                SwitchListTile(
                    title: const Text('Filter Explicit Content?'),
                    value: _filterExplicit,
                    onChanged: (bool val) => setState(() => _filterExplicit = val)),
              ])),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Let's make a playlist!"),
              onPressed: () {
                _createPlaylist();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _customPlaylistForm() {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlaylistForm(userID: widget.userID, name: widget.name)))
        .whenComplete(setData);
  }

  void setFriends() async {
    String selfID = await LoginHelper.getLoggedInUser();

    var data = await getFriends();
    var friends = data['friends'];

    dynamic incoming = friends['incoming'].map((friend) => json.decode(friend)['friend_id']);
    dynamic requested = friends['sent'].map((friend) => json.decode(friend)['friend_id']);
    dynamic accepted = friends['accepted'].map((friend) => json.decode(friend)['friend_id']);

    if (incoming.contains(selfID)) {
      setState(() {
        _friendStatus = 'requested';
        _friends = friends;
      });
    } else if (requested.contains(selfID)) {
      setState(() {
        _friendStatus = 'incoming';
        _friends = friends;
      });
    } else if (accepted.contains(selfID)) {
      setState(() {
        _friendStatus = 'accepted';
        _friends = friends;
      });
    } else {
      setState(() {
        _friendStatus = 'none';
        _friends = friends;
      });
    }
  }

  Future<void> _friendTapCallback(friendID, friendName) async {
    String name = await LoginHelper.getUserName();
    String selfID = await LoginHelper.getLoggedInUser();
    String imageURL = await LoginHelper.getUserPhoto();
    String authToken = await LoginHelper.getAuthToken();
    if (friendID == selfID) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    name: name,
                    imageUrl: imageURL,
                    userID: selfID,
                    authToken: authToken,
                  ))).whenComplete(setData);
    } else {
      _viewUser(friendID, friendName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Playlist for Two"),
        ),
        body: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Padding(
              child: userCard(
                  _imageUrl,
                  widget.name,
                  _friends['accepted'].length,
                  _playlists.length,
                  actionButton(
                      context, _friendStatus, _requestFriend, _acceptFriend, _removeFriend)),
              padding: EdgeInsets.all(30)),
          (_friendStatus == 'accepted')
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: _customPlaylistForm,
                      child: Text('New Custom Playlist', style: TextStyle(fontSize: 15)),
                      textColor: Colors.white,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(height: 10),
                    MaterialButton(
                      onPressed: _grabBagPlaylistDialog,
                      child: Text('New Grab Bag Playlist', style: TextStyle(fontSize: 15)),
                      textColor: Colors.white,
                      color: Colors.blueAccent,
                    ),
                  ],
                )
              : SizedBox(height: 0),
          Expanded(
              child: DefaultTabController(
                  length: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: TabBar(tabs: [
                          Tab(text: "Shared Playlists"),
                          Tab(text: "${widget.name}'s Friends"),
                        ]),
                        width: 400,
                      ),
                      Flexible(
                        child: (_friendStatus == 'pending')
                            ? _loadingBar
                            : TabBarView(
                                children: [
                                  (_friendStatus == 'accepted')
                                      ? playlistListView(context, _playlists, setData)
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                              Icon(Icons.lock),
                                              SizedBox(height: 20),
                                              Text(
                                                  'Playlists are only visible to users who are friends')
                                            ]),
                                  (_friendStatus == 'accepted')
                                      ? friendListView(context, _friends['accepted'],
                                          _friendTapCallback, setData)
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                              Icon(Icons.lock),
                                              SizedBox(height: 20),
                                              Text(
                                                  'Friend lists are only visible to users who are friends')
                                            ]),
                                ],
                              ),
                        fit: FlexFit.loose,
                      )
                    ],
                  )))
        ])));
  }
}
