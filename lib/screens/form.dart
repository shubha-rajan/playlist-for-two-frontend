import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';

class PlaylistForm extends StatefulWidget {
  PlaylistForm({Key key, this.userID, this.name}) : super(key: key);
  final String userID;
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
  Map _features = {
    'valence': {
      'min': 0.0,
      'max' : 1.0
    },
    'danceability': {
      'min': 0.0,
      'max' : 1.0
    },
    'energy': {
      'min': 0.0,
      'max' : 1.0
    },
    'loudness': {
      'min': -30.0,
      'max' : 0.0
    },
    'speechiness': {
      'min': 0.0,
      'max' : 1.0
    },
    'acousticness': {
      'min': 0.0,
      'max' : 1.0
    },
    'liveness': {
      'min': 0.0,
      'max' : 1.0
    },
    'instrumentalness': {
      'min': 0.0,
      'max' : 1.0
    },
    'tempo' : {
      'min': 50.0,
      'max' : 200.0
    }
  };

  Future<dynamic> getSeeds() async {
    String token = await LoginHelper.getAuthToken();
    String userID = await LoginHelper.getLoggedInUser();
    
    dynamic response = await http.get("${DotEnv().env['P42_API']}/intersection?user_id=$userID&friend_id=${widget.userID}", headers: {'authorization': token});
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
                SizedBox(height:20),
                Text("Track Features",
                style: TextStyle(fontSize: 20)),
                SizedBox(height:20),
                Text('Tempo'), 
                Padding(
                  child:Text('The overall estimated tempo of a track in beats per minute (BPM). In musical terminology, tempo is the speed or pace of a given piece and derives directly from the average beat duration. Values range from 50BPM to 200BPM'), 
                  padding: EdgeInsets.all(20)), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center ,
                  children: <Widget>[
                    Text("min: ${_features['tempo']['min'].toStringAsFixed(2)}"),
                    SizedBox(width:10),
                    Text("max: ${_features['tempo']['max'].toStringAsFixed(2)}"),
                  ],
                ), 
                RangeSlider(
                  min: 50,
                  max:  200,
                  values: RangeValues(_features['tempo']['min'], _features['tempo']['max']),
                  onChanged: (RangeValues values) {
                      setState(() {
                        _features['tempo']['min'] = values.start;
                        _features['tempo']['max'] = values.end;
                      });
                    },
                ),
                SizedBox(height:20),
                Text('Loudness'),  
                Padding(
                  child:Text('The overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Loudness is the quality of a sound that is the primary psychological correlate of physical strength (amplitude). Values typically range between -60 and 0 db.'), 
                  padding: EdgeInsets.all(20)),  
                Row(
                  mainAxisAlignment: MainAxisAlignment.center ,
                  children: <Widget>[
                    Text("min: ${_features['loudness']['min'].toStringAsFixed(2)}"),
                    SizedBox(width:10),
                    Text("max: ${_features['loudness']['max'].toStringAsFixed(2)}"),
                  ],
                ),  
                RangeSlider(
                  values: RangeValues(_features['loudness']['min'], _features['loudness']['max']),
                  min:-30,
                  max: 0,
                  onChanged: (RangeValues values) {
                      setState(() {
                        _features['loudness']['min'] = values.start;
                        _features['loudness']['max'] = values.end;
                      });
                    },
                ),
                SizedBox(height:20),
                Text('Danceability'),
                Padding(
                  child:Text('Danceability describes how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable.'), 
                  padding: EdgeInsets.all(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center ,
                  children: <Widget>[
                    Text("min: ${_features['danceability']['min'].toStringAsFixed(2)}"),
                    SizedBox(width:10),
                    Text("max: ${_features['danceability']['max'].toStringAsFixed(2)}"),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(_features['danceability']['min'],_features['danceability']['max']),
                  onChanged: (RangeValues values) {
                      setState(() {
                        _features['danceability']['min'] = values.start;
                        _features['danceability']['max'] = values.end;
                      });
                    },
                ),
                
                 
                SizedBox(height:20),
                Text('Valence'),
                Padding(
                  child:Text('A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).'), 
                  padding: EdgeInsets.all(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center ,
                  children: <Widget>[
                    Text("min: ${_features['valence']['min'].toStringAsFixed(2)}"),
                    SizedBox(width:10),
                    Text("max: ${_features['valence']['max'].toStringAsFixed(2)}"),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(_features['valence']['min'],_features['valence']['max']),
                  onChanged: (RangeValues values) {
                      setState(() {
                        _features['valence']['min'] = values.start;
                        _features['valence']['max'] = values.end;
                      });
                    },
                ),
                Text('Energy'),
                Padding(
                  child:Text('Energy is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale.'), 
                  padding: EdgeInsets.all(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center ,
                  children: <Widget>[
                    Text("min: ${_features['energy']['min'].toStringAsFixed(2)}"),
                    SizedBox(width:10),
                    Text("max: ${_features['energy']['max'].toStringAsFixed(2)}"),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(_features['energy']['min'],_features['energy']['max']),
                  onChanged: (RangeValues values) {
                      setState(() {
                        _features['energy']['min'] = values.start;
                        _features['energy']['max'] = values.end;
                      });
                    },
                ),
                SizedBox(height:20),
                Text('Acousticness'),
                  Padding(
                  child:Text('A confidence measure from 0.0 to 1.0 of whether the track is acoustic. 1.0 represents high confidence the track is acoustic. Values range from 0.0 to 1.0. '), 
                  padding: EdgeInsets.all(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center ,
                  children: <Widget>[
                    Text("min: ${_features['acousticness']['min'].toStringAsFixed(2)}"),
                    SizedBox(width:10),
                    Text("max: ${_features['acousticness']['max'].toStringAsFixed(2)}"),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(_features['acousticness']['min'],_features['acousticness']['max']),
                  onChanged: (RangeValues values) {
                      setState(() {
                        _features['acousticness']['min'] = values.start;
                        _features['acousticness']['max'] = values.end;
                      });
                    },
                ),
                SizedBox(height:20),
                Text('Speechiness'),
                Padding(
                  child:Text('Speechiness detects the presence of spoken words in a track. Values above 0.66 describe tracks that are probably made entirely of spoken words. Values between 0.33 and 0.66 describe tracks that may contain both music and speech, either in sections or layered, including such cases as rap music. Values below 0.33 most likely represent music and other non-speech-like tracks. Values range from 0.0 to 1.0. '), 
                  padding: EdgeInsets.all(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center ,
                  children: <Widget>[
                    Text("min: ${_features['speechiness']['min'].toStringAsFixed(2)}"),
                    SizedBox(width:10),
                    Text("max: ${_features['speechiness']['max'].toStringAsFixed(2)}"),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(_features['speechiness']['min'],_features['speechiness']['max']),
                  onChanged: (RangeValues values) {
                      setState(() {
                        _features['speechiness']['min'] = values.start;
                        _features['speechiness']['max'] = values.end;
                      });
                    },
                ),
                SizedBox(height:20),
                Text('Instrumentalness'),
                Padding(
                  child:Text('Predicts whether a track contains no vocals. “Ooh” and “aah” sounds are treated as instrumental in this context. Rap or spoken word tracks are clearly “vocal”. The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content. Values above 0.5 are intended to represent instrumental tracks, but confidence is higher as the value approaches 1.0. Values range from 0.0 to 1.0.'), 
                  padding: EdgeInsets.all(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center ,
                  children: <Widget>[
                    Text("min: ${_features['instrumentalness']['min'].toStringAsFixed(2)}"),
                    SizedBox(width:10),
                    Text("max: ${_features['instrumentalness']['max'].toStringAsFixed(2)}"),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(_features['instrumentalness']['min'],_features['instrumentalness']['max']),
                  onChanged: (RangeValues values) {
                      setState(() {
                        _features['instrumentalness']['min'] = values.start;
                        _features['instrumentalness']['max'] = values.end;
                      });
                    },
                ),
                SizedBox(height:20),
                Text('Liveness'),
                 Padding(
                  child:Text('Detects the presence of an audience in the recording. Higher liveness values represent an increased probability that the track was performed live. Values range from 0.0 to 1.0.'), 
                  padding:EdgeInsets.all(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center ,
                  children: <Widget>[
                    Text("min: ${_features['liveness']['min'].toStringAsFixed(2)}"),
                    SizedBox(width:10),
                    Text("max: ${_features['liveness']['max'].toStringAsFixed(2)}"),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(_features['liveness']['min'],_features['liveness']['max']),
                  onChanged: (RangeValues values) {
                      setState(() {
                        _features['liveness']['min'] = values.start;
                        _features['liveness']['max'] = values.end;
                      });
                    },
                ),
                SizedBox(height:20),
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
// and https://medium.com/@KarthikPonnam/flutter-loadmore-in-listview-23820612907d 
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
