import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/playlist_info.dart';
import 'package:playlist_for_two/screens/form.dart';
import 'package:playlist_for_two/screens/home.dart';
import 'package:playlist_for_two/components/user_card.dart';

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
    setFriends();
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
      _errorDialog('Could not generate playlist',
          'There was a problem creating your grab bag playlist. This can occur if either you or ${widget.name} have a limited listening history or if you do not have any common songs, artists, or genres. Try making a custom playlist to discover new music together and then try again!');
    }
  }

  Future<Map> getFriends() async {
    String authToken = await LoginHelper.getAuthToken();
    var response = await http.get("${DotEnv().env['P42_API']}/friends?user_id=${widget.userID}",
        headers: {'authorization': authToken});

    return json.decode(response.body);
  }

  Future<List> getPlaylists() async {
    String authToken = await LoginHelper.getAuthToken();
    String selfID = await LoginHelper.getLoggedInUser();
    dynamic response = await http.get(
        "${DotEnv().env['P42_API']}/playlists?user_id=$selfID&friend_id=${widget.userID}",
        headers: {'authorization': authToken});
    return json.decode(response.body);
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
      _errorDialog('An error occured', 'Could not remove friend. Please try again!');
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

  void setData() async {
    dynamic playlists = await getPlaylists();
    setState(() {
      _playlists = playlists;
    });
  }

  Future<void> _errorDialog(String titleText, String contentText) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleText),
          content: Text(contentText),
          actions: <Widget>[
            FlatButton(
              child: Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  Widget _playlistListView(BuildContext context, List data) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: Colors.blueGrey,
      ),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(data[index]['description']['name']),
            onTap: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PlaylistInfo(playlist: data[index])))
                  .whenComplete(setData);
            });
      },
    );
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

  Widget _friendListView(BuildContext context, List data) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: Colors.blueGrey,
      ),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(json.decode(data[index])['name']),
          onTap: () {
            _friendTapCallback(
                json.decode(data[index])['friend_id'], json.decode(data[index])['name']);
          },
        );
      },
    );
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
                  _actionButton(
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
                                      ? _playlistListView(context, _playlists)
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                              Icon(Icons.lock),
                                              SizedBox(height: 20),
                                              Text(
                                                  'Playlists are only visible to users who are friends')
                                            ]),
                                  (_friendStatus == 'accepted')
                                      ? _friendListView(context, _friends['accepted'])
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

Widget _actionButton(BuildContext context, String status, Function requestFriend,
    Function acceptFriend, Function removeFriend) {
  Widget button;
  switch (status) {
    case 'none':
      {
        button = MaterialButton(
          onPressed: requestFriend,
          child: Text('Add Friend', style: TextStyle(fontSize: 15)),
          textColor: Colors.white,
          color: Colors.blueAccent,
        );
      }
      break;
    case 'requested':
      {
        button = MaterialButton(
          onPressed: removeFriend,
          child: Text('Cancel Friend Request', style: TextStyle(fontSize: 15)),
        );
      }
      break;
    case 'accepted':
      {
        button = MaterialButton(
          onPressed: removeFriend,
          child: Text('Remove Friend', style: TextStyle(fontSize: 15)),
          textColor: Colors.white,
          color: Colors.red,
        );
      }
      break;
    case 'incoming':
      {
        button = MaterialButton(
          onPressed: acceptFriend,
          child: Text('Accept Friend Request', style: TextStyle(fontSize: 15)),
          textColor: Colors.white,
          color: Colors.blueAccent,
        );
      }
      break;
    default:
      {
        button = SizedBox();
      }
  }
  return (button);
}
