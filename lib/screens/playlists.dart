import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';

class PlaylistPage extends StatefulWidget {
  PlaylistPage ({Key key, this.friendID}) : super(key: key);
  final String friendID;

  @override
  _PlaylistPageState createState() => _PlaylistPageState();

}


class _PlaylistPageState extends State<PlaylistPage> {

  dynamic _playlists= [];

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
    setData();
    return DefaultTabController(
      length:2,
      child:Scaffold (
      appBar: AppBar(
        title: Text('Playlists'),

      ),
      body:Flex(
        direction: Axis.vertical,
        children: [Expanded(
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
          );
        },
      );
  }
}