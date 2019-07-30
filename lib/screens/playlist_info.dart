import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:playlist_for_two/components/error_dialog.dart';

class PlaylistInfo extends StatefulWidget {
  PlaylistInfo({Key key, this.playlist}) : super(key: key);

  final dynamic playlist;

  @override
  _PlaylistInfoState createState() => _PlaylistInfoState();
}

class _PlaylistInfoState extends State<PlaylistInfo> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  String _description;
  String _newDescription;
  String _newTitle;
  String _title;
  dynamic _tracks = [];

  @override
  void didChangeDependencies() {
    _setTracks();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _setTitleDescription();
    titleController.addListener(_updateTitle);
    descriptionController.addListener(_updateDescription);
    titleController.text = widget.playlist['description']['name'];
    descriptionController.text = widget.playlist['description']['description'];
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<String> getFriendID() async {
    String selfID = await LoginHelper.getLoggedInUser();
    List<dynamic> playlistOwners = widget.playlist['owners'];
    String friendID = playlistOwners.firstWhere((item) {
      return (item != selfID);
    });
    return friendID;
  }

  void _changePlaylistDetails() async {
    String token = await LoginHelper.getAuthToken();
    String friendID = await getFriendID();

    dynamic payload = {
      'description': _newDescription,
      'name': _newTitle,
      'friend_id': friendID,
      'playlist_uri': widget.playlist['uri']
    };
    dynamic response = await http.post("${DotEnv().env['P42_API']}/edit-playlist",
        headers: {'authorization': token}, body: payload);
    if (response.statusCode != 200) {
      errorDialog(context, 'An error occured',
          'There was a problem updating your playlist details. Please try again');
    }
  }

  void _deletePlaylist() async {
    String token = await LoginHelper.getAuthToken();
    dynamic response = await http.post("${DotEnv().env['P42_API']}/delete-playlist",
        headers: {'authorization': token}, body: {'playlist_uri': widget.playlist['uri']});
    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      errorDialog(context, 'An error occured',
          'There was a problem deleting your playlist. Please try again');
    }
  }

  void _updateDescription() {
    setState(() {
      _newDescription = descriptionController.text;
    });
  }

  void _updateTitle() {
    setState(() {
      _newTitle = titleController.text;
    });
  }

  void _setTitleDescription() {
    setState(() {
      _title = widget.playlist['description']['name'];
      _description = widget.playlist['description']['description'];
    });
  }

  Future<dynamic> _getTracks() async {
    String token = await LoginHelper.getAuthToken();

    String playlistID = widget.playlist['uri'].substring(17);
    dynamic response = await http.get("${DotEnv().env['P42_API']}/playlist?playlist_id=$playlistID",
        headers: {'authorization': token});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      errorDialog(context, 'An error occurred',
          'There was a problem retrieving data from our servers. Check your network connection or try again later.');
      return _tracks;
    }
  }

  Future<void> _setTracks() async {
    var data = await _getTracks();
    setState(() {
      _tracks = data;
    });
  }

  Future<void> _updateTitleDescription() async {
    setState(() {
      _title = _newTitle;
      _description = _newDescription;
    });
  }

  Future<void> _deleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete this playlist?"),
          content: Container(
              child: Flex(direction: Axis.vertical, children: <Widget>[
                Text("Are you sure you want to delete this playlist? This is a permanent action."),
                SizedBox(height: 15),
                Text(
                    "Deleting this playlist will remove it from your profile. If you have followed the playlist on Spotify, deleting will not unfollow the playlist. Deleting this playlist on your profile will not remove it from your friend's profile"),
              ]),
              height: 300),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Delete'),
              onPressed: () {
                _deletePlaylist();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Playlist Details'),
            content:
                Flex(direction: Axis.vertical, mainAxisSize: MainAxisSize.min, children: <Widget>[
              TextField(
                controller: titleController,
              ),
              SizedBox(height: 20),
              Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      reverse: true,
                      child: TextField(
                        controller: descriptionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ))),
            ]),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  setState(() {
                    _newTitle = _title;
                    _newDescription = _description;
                  });
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Save'),
                onPressed: () {
                  _updateTitleDescription();
                  _changePlaylistDetails();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _openPlaylistInSpotify() async {
    String playlistID = widget.playlist['uri'].substring(17);
    String url =
        'https://open.spotify.com/user/${DotEnv().env['SPOTIFY_USER_ID']}/playlist/$playlistID';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      errorDialog(
          context, 'An error occurred', 'Unable to launch Spotify app or browser on this device');
    }
  }

  void _openTrackInSpotify(trackID) async {
    String url = 'https://open.spotify.com/track/$trackID';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      errorDialog(
          context, 'An error occurred', 'Unable to launch Spotify app or browser on this device');
    }
  }

  Widget _playlistTrackView(BuildContext context, List data) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: Colors.blueGrey,
      ),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text("${data[index]['name']} - ${data[index]['artists'][0]}"),
          onTap: () {
            _openTrackInSpotify(data[index]['id']);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Playlists'),
        ),
        body: Column(children: [
          SizedBox(height: 20),
          Padding(
              child: Text(_title ?? widget.playlist['description']['title'],
                  style: TextStyle(fontSize: 20)),
              padding: EdgeInsets.all(20)),
          Flexible(
              fit: FlexFit.loose,
              flex: 2,
              child: SingleChildScrollView(
                child: Padding(
                    child: Text(_description ?? widget.playlist['description']['description'],
                        style: TextStyle(fontSize: 15)),
                    padding: EdgeInsets.all(20)),
              )),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            MaterialButton(
              child: Icon(Icons.delete),
              onPressed: _deleteDialog,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            MaterialButton(
              child: Icon(Icons.edit),
              onPressed: _editDialog,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            MaterialButton(
              child: Image.asset('graphics/Spotify_Icon_RGB_Black.png', height: 30),
              onPressed: _openPlaylistInSpotify,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              textColor: Colors.white,
              color: Colors.green,
            ),
          ]),
          Flexible(
              flex: 5,
              fit: FlexFit.tight,
              child: DefaultTabController(
                  length: 1,
                  child: Flex(
                    direction: Axis.vertical,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: TabBar(tabs: [
                          Tab(
                              child: Text(
                            "Tracks",
                            style: TextStyle(fontSize: 20),
                          )),
                        ]),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _playlistTrackView(context, _tracks),
                          ],
                        ),
                      )
                    ],
                  )))
        ]));
  }
}
