import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/playlist_info.dart';
class PlaylistPage extends StatefulWidget {
  PlaylistPage ({Key key, this.friendID, this.name}) : super(key: key);
  final String friendID;
  final String name;

  @override
  _PlaylistPageState createState() => _PlaylistPageState();

}


class _PlaylistPageState extends State<PlaylistPage> {
   @override
   void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  dynamic _playlists;
  bool _filterExplicit = false;
  dynamic _seeds;
  dynamic _selected =[];

  Future<void> _createPlaylist() async{
    String userID = await LoginHelper.getLoggedInUser();
    String token = await LoginHelper.getAuthToken();
    dynamic response = await http.post("${DotEnv().env['P42_API']}/new-playlist?user_id=$userID&friend_id=${widget.friendID}", 
    headers:{'authorization': token});
    if (response.statusCode == 200) {
      setData();
    }
  }

@override
  void didChangeDependencies() {
    setData();
    super.didChangeDependencies();
}

  Future<void> _grabBagPlaylistDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Make a new playlist'),
        content:Container(
            height: 150,
            child:Column(
            children:<Widget>[
              Text('Generate a playlist based on randomly selected songs, artists, and genres that you and ${widget.name} have in common.'),
              SwitchListTile(
                    title: const Text('Filter Explicit Content?'),
                    value: _filterExplicit,
                    onChanged: (bool val) =>
                        setState(() => _filterExplicit = val)
              ),
            ]
          )
        ),
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

  Future<void> _customPlaylistDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Make a new playlist'),
        content:Flex(
          direction: Axis.vertical,
          children:<Widget>[
          Expanded(
          child:SingleChildScrollView(
          child:Column(
            children:<Widget>[
              Text("Select up to 5 seeds from songs, artists, and genres that you and ${widget.name} have in common."),
              SizedBox(height: 20),
              Text("Common Songs",
              style: TextStyle(fontSize: 20)),
              Container(child:_optionSongArtistListView(context, _seeds['common_songs']), height: 400, width:300),
              Text("Common Artists",
              style: TextStyle(fontSize: 20)),
              Container(child:_optionSongArtistListView(context, _seeds['common_artists']), height: 400, width:300),
              Text("Common Genres",
              style: TextStyle(fontSize: 20)),
              Container(child:_optionGenreListView(context, _seeds['common_genres']), height: 400, width:300),
              SwitchListTile(
                    title: const Text('Filter Explicit Content?'),
                    value: _filterExplicit,
                    onChanged: (bool val) =>
                        setState(() => _filterExplicit = val)
              ),
            ]
          )
          )
          )
          ]
          ),
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

  Future<List> getPlaylists() async {
    String token = await LoginHelper.getAuthToken();
    String userID = await LoginHelper.getLoggedInUser();
    
    dynamic response = await http.get("${DotEnv().env['P42_API']}/playlists?user_id=$userID&friend_id=${widget.friendID}", headers: {'authorization': token});
    return json.decode(response.body);
  }

  Future<dynamic> getSeeds() async {
    String token = await LoginHelper.getAuthToken();
    String userID = await LoginHelper.getLoggedInUser();
    
    dynamic response = await http.get("${DotEnv().env['P42_API']}/intersection?user_id=$userID&friend_id=${widget.friendID}", headers: {'authorization': token});
    return json.decode(response.body);
  }
  void setData() async {
    dynamic playlists = await getPlaylists();
    dynamic seeds = await getSeeds();
    setState(() {
      _playlists = playlists;
      _seeds = seeds;
    });
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length:2,
      child:Scaffold (
      appBar: AppBar(
        title: Text('Playlists'),

      ),
      body:Flex(
        direction: Axis.vertical,
        children: [
          SizedBox(height:40),
          MaterialButton(
              onPressed: _customPlaylistDialog,
              child: Text('New Custom Playlist',
                    style: TextStyle(fontSize: 15)
                  ),
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  color:Colors.blueAccent, 
                  height: 50,
                  minWidth:200
            ),
          SizedBox(height:40),
          MaterialButton(
              onPressed: _grabBagPlaylistDialog,
              child: Text('New Grab Bag Playlist',
                    style: TextStyle(fontSize: 15)
                  ),
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  color:Colors.blueAccent, 
                  height: 50,
                  minWidth:200
            ),
          
          SizedBox(height:40),
          (_playlists != null) ?
          Expanded(child: _playlistListView(context, _playlists),) :
          _loadingBar
        ]
      )
      )
    );
  }

  Widget _loadingBar = new Container(
              height: 20.0,
              child: new Center(child: new LinearProgressIndicator()),
            );

  Widget _playlistListView(BuildContext context, List data) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(data[index]['description']['name']),
            trailing: Icon(Icons.arrow_forward),
            onTap:(){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistInfo(playlist: data[index])));
            }
          );
        },
      );
  }


Widget _optionSongArtistListView(BuildContext context, List data) {
  return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(json.decode(data[index])['name']),
            value: false,
            onChanged: (val) {
              if (val) {
                setState(() {
                  _selected = _selected.add(json.decode(data[index]['id']));
                });
              }
              
            }
          );
        },
      );
  }

  Widget _optionGenreListView(BuildContext context, List data) {
  return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(data[index]),
            value: false,
            onChanged: (val) {
              if (val) {
                setState(() {
                  _selected = _selected.add(json.decode(data[index]));
                });
              }
              
            }
          );
        },
      );
  }
}