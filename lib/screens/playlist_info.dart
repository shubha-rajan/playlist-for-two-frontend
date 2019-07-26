
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:url_launcher/url_launcher.dart';


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
  dynamic _tracks= [];

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
    if(mounted){
      super.setState(fn);
    }
  }

  void _updateDescription(){
    setState((){
      _newDescription = descriptionController.text;
    });
  }

    void _updateTitle(){
    setState((){
      _newTitle = titleController.text;
    });
  }

  void _setTitleDescription(){
    setState(() {
      _title = widget.playlist['description']['name'];
      _description= widget.playlist['description']['description'];
    });
  }

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

  Future<void> _updateTitleDescription() async {
    
    setState(() {
      _title = _newTitle;
      _description = _newDescription;
    });
  }

  Future<void> _editDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Playlist Details'),
        content:Container(
          height:400,
          child: Column(children: <Widget>[
            Flex(
              mainAxisSize: MainAxisSize.min,
              direction: Axis.vertical,
              children:<Widget>[
                Flexible(
                  fit:FlexFit.loose,
                  child:TextField(
                  controller: titleController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueGrey,
                        width: 1
                      )
                    )
                  )
                  )
                ),
              ]
            ),
            
            SizedBox(height:20),
            Flex(
            mainAxisSize: MainAxisSize.min,
            direction: Axis.vertical,
            children:<Widget>[
              Flexible(
              fit: FlexFit.loose,
              child:TextField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blueGrey,
                    width: 1
                  )
                ),
              ),
            )
            )
            ],
            
            )
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
            child: Text('Save'),
            onPressed: () {
              _updateTitleDescription();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }
  );
  }

  void _openPlaylistInSpotify() async{
    String playlistID = widget.playlist['uri'].substring(17);
    String url = 'https://open.spotify.com/user/${DotEnv().env['SPOTIFY_USER_ID']}/playlist/$playlistID';
    if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url }';
      }

  }

  void _openTrackInSpotify(trackID) async{
    
    String url = 'https://open.spotify.com/track/$trackID';
    if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url ';
      }
  }

  Widget _playlistTrackView(BuildContext context, List data) {
    return ListView.separated(
        separatorBuilder:(context, index) => Divider(
        color: Colors.blueGrey,
      ),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("${data[index]['name']} - ${data[index]['artists'][0]}"),
            onTap: (){
              _openTrackInSpotify(data[index]['id']);
            },
          );
        },
      );
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
              Text(_title ?? widget.playlist['description']['title'], 
              style: TextStyle(fontSize: 20)),
              SizedBox(height:40),
              Text(_description ?? widget.playlist['description']['description'],
              style: TextStyle(fontSize: 15)),
              SizedBox(height:40),
              Row (
                mainAxisAlignment:MainAxisAlignment.center,
                children:<Widget>[
                  MaterialButton(
                    child: Text('Edit Playlist Details'),
                    onPressed: _editDialog,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  MaterialButton(
                    child: Text('Open in Spotify'),
                    onPressed: _openPlaylistInSpotify,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    color:Colors.green,
                  )
              ])
              
            ],
            ),
            margin: EdgeInsets.only(left: 20.0, right: 20.0),
          ),
          Expanded(
            child:  DefaultTabController(
              length:1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
              
                children: <Widget>[
              Container(
                child:TabBar(
                tabs: [
                  Tab(child:Text("Tracks",
                    style: TextStyle(fontSize: 20),
                  )),
                ]
                ),
              width: 400,),
              Flexible(
                child:TabBarView(
                children: [
                  _playlistTrackView(context, _tracks),
                ] ,
              ),
              fit: FlexFit.loose,)
            ],
            
            )
          )
          
        )
        ]
      )
      )
    );
  }
}
