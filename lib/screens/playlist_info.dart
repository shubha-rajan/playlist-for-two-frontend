
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';


class PlaylistInfo extends StatefulWidget {
  PlaylistInfo({Key key, this.playlist}) : super(key: key);
  final dynamic playlist;


  @override
  _PlaylistInfoState createState() => _PlaylistInfoState();

}


class _PlaylistInfoState extends State<PlaylistInfo> {
   @override
   void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  dynamic _tracks= [];

  Future<dynamic> _getTracks() async{
    String token = await LoginHelper.getAuthToken();

    String playlistID = widget.playlist['uri'].substring(17);
    dynamic response = await http.get("${DotEnv().env['P42_API']}/playlist?playlist_id=$playlistID",
    headers:{'authorization': token});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
  }

  Future<void> _setTracks() async {
    var data = await _getTracks();
    setState(() {
      _tracks = data;
    });
  }

  @override
    void didChangeDependencies() {
      _setTracks();
      super.didChangeDependencies();
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
          Container(child: 
           Column(children: <Widget>[
              Text(widget.playlist['description']['name'], 
              style: TextStyle(fontSize: 20)),
              SizedBox(height:40),
              Text(widget.playlist['description']['description'],
              style: TextStyle(fontSize: 15)),
              SizedBox(height:40),
              Text("Track list:", 
              style: TextStyle(fontSize: 20)),
            ],
            ),
            margin: EdgeInsets.only(left: 20.0, right: 20.0),
          ),
          
          Expanded(
          child: _playlistTrackView(context, _tracks),
        )
        ]
      )
      )
    );
  }
  Widget _playlistTrackView(BuildContext context, List data) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("${data[index]['name']} - ${data[index]['artists'][0]}"),
          );
        },
      );
  }
}