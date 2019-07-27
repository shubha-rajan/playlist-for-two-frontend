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
<<<<<<< Updated upstream
  List<dynamic> _selectedArtists = [];
  List<dynamic> _selectedSongs = [];
  List<dynamic> _selectedGenres = [];
  bool _filterExplicit = false;
=======
  List<String> _selectedArtists = [];
  List<String> _selectedGenres = [];
  List<String> _selectedSongs = [];
  dynamic _selfGenres = [];
  dynamic _userGenres = [];
  List<String> _selectedSelfGenres = [];
  List<String> _selectedUserGenres = [];


  @override
  void didChangeDependencies() {
    setData();
    super.didChangeDependencies();
  }
>>>>>>> Stashed changes

  Future<dynamic> getSeeds() async {
    String token = await LoginHelper.getAuthToken();
    String userID = await LoginHelper.getLoggedInUser();
    
    dynamic response = await http.get("${DotEnv().env['P42_API']}/intersection?user_id=$userID&friend_id=${widget.friendID}", headers: {'authorization': token});
    return json.decode(response.body);
  }

<<<<<<< Updated upstream
  
=======
  Future<dynamic> getGenres({userID}) async {
    String token = await LoginHelper.getAuthToken();
    String id=  userID ?? await LoginHelper.getLoggedInUser(); 
    var response = await http.get("${DotEnv().env['P42_API']}/genres?user_id=$id", headers: {'authorization': token});
    return json.decode(response.body);
  }


  Future<void> _createPlaylist() async{
    String authToken = await LoginHelper.getAuthToken();
    String selfID = await LoginHelper.getLoggedInUser();

    Map<String, List> seeds =  {
        "artists": _selectedArtists,
        "songs" : _selectedSongs,
        "genres" : _selectedGenres,
    };

    dynamic response = await http.post("${DotEnv().env['P42_API']}/new-playlist?user_id=$selfID&friend_id=${widget.userID}&filter_explicit=$_filterExplicit", 
    headers:{'authorization': authToken},
    body: {"seeds": json.encode(seeds), "features":json.encode(_features)});
    if (response.statusCode == 200) {
      Navigator.pushReplacement(context, 
        MaterialPageRoute(builder: (context) => UserPage(name: widget.name, userID: widget.userID, ))
      );
    } else{
      _errorDialog();
    }
  }
>>>>>>> Stashed changes


  void setData() async {
    dynamic seeds = await getSeeds();
    dynamic userGenres= await getGenres(userID:widget.userID);
    dynamic selfGenres= await getGenres();
    setState(() {
      _seeds = seeds;
      _userGenres = userGenres;
      _selfGenres = selfGenres;
    });
  }

  @override
  void didChangeDependencies() {
    setData();
    super.didChangeDependencies();
  }


<<<<<<< Updated upstream
  Widget _loadingBar = new Container(
              height: 20.0,
              child: new Center(child: new LinearProgressIndicator()),
            );
=======
  Widget buildMultiSelectLayout(title, fieldName, callback ) {
    return(
      Column(children: <Widget>[
      SizedBox(height: 20),
      Text(title,
      style: TextStyle(fontSize: 15)),
      (_seeds['common_$fieldName'].length == 0) ?
      Padding(child:Text("No common $fieldName... yet! :D",
      style: TextStyle(fontSize: 15)),
      padding: EdgeInsets.only(top:30, bottom:30),
      ) :
      Container(
        child:MultiSelect( _seeds['common_$fieldName'],
          (_selectedSongs.length + _selectedArtists.length + _selectedGenres.length),
          onSelectionChanged: (selectedList) {
            callback(selectedList);
            },
          ), 
        width:300),
      ],)
    );
  }
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
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
                Padding(child:Text("No common artists, yet!",
                style: TextStyle(fontSize: 20)),
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
                Padding(child:Text("No common genres, yet!",
                style: TextStyle(fontSize: 20)),
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
=======
            SizedBox(height: 40),
            Text("Your Musical Intersection",
              style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            
            (_seeds['common_songs'].length + _seeds['common_artists'].length + _seeds['common_genres'].length > 0) ? 
            Flex(
              direction: Axis.vertical,
              children:<Widget>[
                Container(
                    child:Text("Select up to 5 seeds from songs, artists, and genres that you and ${widget.name} have in common."),
                    width:350
                ),
                buildMultiSelectLayout("Common Songs", 'songs', updateSelectedSongs ),
                buildMultiSelectLayout("Common Artists", 'artists', updateSelectedArtists ),
                buildMultiSelectLayout("Common Genres", 'genres', updateSelectedGenres ),
                SizedBox(height:20),
              ]
            ) :
            Flex(
              direction: Axis.vertical,
              children:<Widget>[
                Container(
                    child:Text("It looks like you and ${widget.name} don't have any common songs, albums, or genres. Why not start a playlist by combining some of your top genres with ${widget.name}'s?"),
                    width:350
                ),
                Text('Your Top Genres', style: TextStyle(fontSize: 15)),
                Container(
                  child:MultiSelect( _selfGenres.keys.toList(), _selectedGenres.length,
                    onSelectionChanged: (selectedList) {
                      setState(() {
                        _selectedSelfGenres = selectedList;
                        _selectedGenres = _selectedSelfGenres + _selectedUserGenres;
                      });
                      },
                    ), 
                width:300),
                Text("${widget.name}'s Top Genres", style: TextStyle(fontSize: 15)),
                Container(
                  child:MultiSelect( _userGenres.keys.toList(), _selectedGenres.length,
                    onSelectionChanged: (selectedList) {
                      setState(() {
                        _selectedUserGenres = selectedList;
                        _selectedGenres = _selectedSelfGenres + _selectedUserGenres;
                      });
                      },
                    ), 
                width:300),
                SizedBox(height:20),
              ]
              ),

              Text("Fine-tune Your Playlist",
              style: TextStyle(fontSize: 20)),
              SizedBox(height:20),
              Text('Tempo'), 
              rangeSliderDisplayBuilder('tempo', 'The overall estimated tempo of a track in beats per minute (BPM). In musical terminology, tempo is the speed or pace of a given piece and derives directly from the average beat duration. Values range from 50BPM to 200BPM', 50.0, 200.0),
              Text('Loudness'), 
              rangeSliderDisplayBuilder('loudness', 'The overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Loudness is the quality of a sound that is the primary psychological correlate of physical strength (amplitude). Values range between -30 and 0 db.', -30.0, 0.0), 
              Text('Danceability'),
              rangeSliderDisplayBuilder('danceability', 'Danceability describes how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable.', 0.0, 1.0), 
              Text('Valence'),
              rangeSliderDisplayBuilder('valence', 'A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).', 0.0, 1.0),                 
              Text('Energy'),
              rangeSliderDisplayBuilder('energy', 'Energy is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale.', 0.0, 1.0), 
              Text('Acousticness'),
              rangeSliderDisplayBuilder('acousticness', 'A confidence measure from 0.0 to 1.0 of whether the track is acoustic. 1.0 represents high confidence the track is acoustic. Values range from 0.0 to 1.0. ', 0.0, 1.0),     
              Text('Speechiness'),
              rangeSliderDisplayBuilder('speechiness', 'Speechiness detects the presence of spoken words in a track. Values above 0.66 describe tracks that are probably made entirely of spoken words. Values between 0.33 and 0.66 describe tracks that may contain both music and speech, either in sections or layered, including such cases as rap music. Values below 0.33 most likely represent music and other non-speech-like tracks. Values range from 0.0 to 1.0. ', 0.0, 1.0), 
              Text('Instrumentalness'),
              rangeSliderDisplayBuilder('instrumentalness', 'Predicts whether a track contains no vocals. “Ooh” and “aah” sounds are treated as instrumental in this context. Rap or spoken word tracks are clearly “vocal”. The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content. Values above 0.5 are intended to represent instrumental tracks, but confidence is higher as the value approaches 1.0. Values range from 0.0 to 1.0. ', 0.0, 1.0), 
              
              Text('Liveness'),
              rangeSliderDisplayBuilder('liveness', 'Detects the presence of an audience in the recording. Higher liveness values represent an increased probability that the track was performed live. Values range from 0.0 to 1.0.', 0.0, 1.0), 
              SwitchListTile(
                    title: const Text('Filter Explicit Content?'),
                    value: _filterExplicit,
                    onChanged: (bool val) =>
                        setState(() => _filterExplicit = val)
              ),
                MaterialButton(
                  onPressed: _createPlaylist,
                  child: Text('Make a Playlist!',
                        style: TextStyle(fontSize: 15)
                      ),
                      textColor: Colors.white,
                      color:Colors.blueAccent, 
>>>>>>> Stashed changes
                ),
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
<<<<<<< Updated upstream
=======

  final List data;
>>>>>>> Stashed changes
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
