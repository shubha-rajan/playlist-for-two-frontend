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

  dynamic _playlists= [];

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

  Future<void> _createPlaylistDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Make a new playlist'),
        content:Text('Generate a playlist based on randomly selected songs, artists, and genres that you and ${widget.name} have in common.'),         
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

  void setData() async {
    dynamic data = await getPlaylists();
    setState(() {
      _playlists = data;
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
              onPressed: _createPlaylistDialog,
              child: Text('Create a new playlist!',
                    style: TextStyle(fontSize: 20)
                  ),
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  color:Colors.blueAccent, 
                  height: 50,
                  minWidth:300
            ),
          SizedBox(height:40),
          Expanded(
          child: _playlistListView(context, _playlists),
        )
        ]
      )
      )
    );
  }
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
}