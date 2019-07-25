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
            SizedBox(height: 40),
            Container(
              child:Text("Select up to 5 seeds from songs, artists, and genres that you and ${widget.name} have in common.",
              style: TextStyle(fontSize: 20)),
              width:350
            ),
            Flex(
              direction: Axis.vertical,
              children:<Widget>[
                SizedBox(height: 20),
                Text("Common Songs",
                style: TextStyle(fontSize: 20)),
                (_seeds['common_songs'].length == 0) ?
                Padding(child:Text("No common songs... yet! :D",
                style: TextStyle(fontSize: 15)),
                padding: EdgeInsets.only(top:30, bottom:30),
                ) :
                Container(child:MultiSelect( _seeds['common_songs'],
                (_selectedSongs.length + _selectedArtists.length + _selectedGenres.length),
                onSelectionChanged: (selectedList) {
                  setState(() {
                        _selectedSongs = selectedList;
                  });
    },), width:300),
                Text("Common Artists",
                style: TextStyle(fontSize: 20)),
                (_seeds['common_artists'].length == 0) ?
                Padding(child:Text("No common artists... yet! :D",
                style: TextStyle(fontSize: 15)),
                padding: EdgeInsets.only(top:30, bottom:30),
                ) :
                Container(child:MultiSelect( _seeds['common_artists'],
                (_selectedSongs.length + _selectedArtists.length + _selectedGenres.length),
                onSelectionChanged: (selectedList) {
                  setState(() {
                        _selectedArtists = selectedList;
                  });
                }), width:300),
                Text("Common Genres",
                style: TextStyle(fontSize: 20)),
                (_seeds['common_genres'].length == 0) ?
                Padding(child:Text("No common genres... yet! :D",
                style: TextStyle(fontSize: 15)),
                padding: EdgeInsets.only(top:30, bottom:30),
                ) :
                Container(child:MultiSelect(_seeds['common_genres'],
                (_selectedSongs.length + _selectedArtists.length + _selectedGenres.length),
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
  MultiSelect(this.data, this.totalSelected, {this.onSelectionChanged});
  final int totalSelected;
  final List<dynamic> data;
  final Function(List<String>) onSelectionChanged;
  
  @override
  _MultiSelectState createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  
  List<String> _selected = [];
  List <dynamic> _displayed = [];
  int present = 0;
  int perPage = 5;

  @override
  void initState() {
    super.initState();
    setState(() {
      if((present + perPage )> widget.data.length) {
                    _displayed.addAll(
                        widget.data.getRange(present, widget.data.length));
                  } else {
                    _displayed.addAll(
                        widget.data.getRange(present, present + perPage));
                  }
                  present = present + perPage;
    });
  }

  Future<void> _seedLimitDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('More than 5 seeds selected'),
        content:Text('You can choose a maximum of 5 seeds for your custom playlist. Please remove some of your selections before adding more.'),
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

    _buildChoiceList() {
    List<Widget> choices = List();
    _displayed.forEach((item) {
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
              widget.onSelectionChanged(_selected);
            } else if (widget.totalSelected >=5) {
                _seedLimitDialog();
              } else {
              setState(() {
              _selected.add(id);
              widget.onSelectionChanged(_selected);
              });
            }
          },
        ),
      ));
    });
    if (present <= widget.data.length){
      choices.add(FlatButton(
              child: Text("Load More",
              style: TextStyle(color: Colors.lightBlue),),
              onPressed: () {
                setState(() {
                  if((present + perPage )> widget.data.length) {
                    _displayed.addAll(
                        widget.data.getRange(present, widget.data.length));
                  } else {
                    _displayed.addAll(
                        widget.data.getRange(present, present + perPage));
                  }
                  present = present + perPage;
                });
              },
            )
          );
    }
    
    return choices;
  }
   @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
