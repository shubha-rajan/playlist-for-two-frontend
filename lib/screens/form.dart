import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';

class PlaylistForm extends StatefulWidget {
  PlaylistForm({Key key, this.friendID, this.name}) : super(key: key);
  final String friendID;
  final String name;

  @override
  _PlaylistFormState createState() => _PlaylistFormState();

}

class _PlaylistFormState extends State<PlaylistForm>{
  dynamic _seeds;
  List<dynamic> _selectedArtists = [];
  List<dynamic> _selectedSongs = [];
  List<dynamic> _selectedGenres = [];
  bool _filterExplicit = false;

  Future<dynamic> getSeeds() async {
    String token = await LoginHelper.getAuthToken();
    String userID = await LoginHelper.getLoggedInUser();
    
    dynamic response = await http.get("${DotEnv().env['P42_API']}/intersection?user_id=$userID&friend_id=${widget.friendID}", headers: {'authorization': token});
    return json.decode(response.body);
  }

  void setData() async {
    dynamic seeds = await getSeeds();
    setState(() {
      _seeds = seeds;
    });
  }

  @override
  void didChangeDependencies() {
    setData();
    super.didChangeDependencies();
  }


  Widget _loadingBar = new Container(
              height: 20.0,
              child: new Center(child: new LinearProgressIndicator()),
            );

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text('Make a Playlist'),
      ),
      body:(_seeds!=null) ?
        SingleChildScrollView(child:
        Column(
          mainAxisSize: MainAxisSize.min,
          children:<Widget>[
            SizedBox(height: 20),
            Container(
              child:Text("Select up to 5 seeds from songs, artists, and genres that you and ${widget.name} have in common.",
              style: TextStyle(fontSize: 20)),
              width:300
            ),
            Flex(
              direction: Axis.vertical,
              children:<Widget>[
                SizedBox(height: 20),
                Text("Common Songs",
                style: TextStyle(fontSize: 20)),
                Container(child:MultiSelect( _seeds['common_songs'],
                onSelectionChanged: (selectedList) {
                  setState(() {
                        _selectedSongs = selectedList;
                  });
    },), width:300),
                Text("Common Artists",
                style: TextStyle(fontSize: 20)),
                Container(child:MultiSelect( _seeds['common_artists'],
                onSelectionChanged: (selectedList) {
                  setState(() {
                        _selectedArtists = selectedList;
                  });
                }), width:300),
                Text("Common Genres",
                style: TextStyle(fontSize: 20)),
                Container(child:MultiSelect(_seeds['common_genres'],
                onSelectionChanged: (selectedList) {
                  setState(() {
                        _selectedGenres = selectedList;
                  });
                })
                ,  width:300),
                SwitchListTile(
                      title: const Text('Filter Explicit Content?'),
                      value: _filterExplicit,
                      onChanged: (bool val) =>
                          setState(() => _filterExplicit = val)
                ),
              ]
            )
          ]
          )
         ) :
        _loadingBar
    );
  }

}


// Code for MultiSelect widget adapted from 
// https://medium.com/@KarthikPonnam/flutter-multi-select-choicechip-244ea016b6fa
class MultiSelect extends StatefulWidget {
  MultiSelect(this.data,{this.onSelectionChanged});

  final List<dynamic> data;
  final Function(List<String>) onSelectionChanged;
  
  @override
  _MultiSelectState createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  List<String> _selected = List();
  
    _buildChoiceList() {
    
    List<Widget> choices = List();
    widget.data.forEach((item) {
      String name = (item is String) ? item : item['name'];
      String id = (item is String) ? item : item['name'];
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(name),
          selected: _selected.contains(id),
          onSelected: (selected) {
            if (_selected.contains(id)) {
              setState(() {
              _selected.remove(id);
              });
            } else {
              setState(() {
              _selected.add(id);
              });
            }
          },
        ),
      ));
    });
    return choices;
  }
   @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
