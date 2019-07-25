import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';


class ListPage extends StatefulWidget {
  ListPage ({Key key}) : super(key: key);

  @override
  _ListPageState createState() => _ListPageState();

}


class _ListPageState extends State<ListPage> {


   @override
   void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  dynamic _songData;
  dynamic _genres;

  Future<Map> getSongData() async {
    String token = await LoginHelper.getAuthToken();
    String userID = await LoginHelper.getLoggedInUser();
    
    var response = await http.get("${DotEnv().env['P42_API']}/listening-history?user_id=$userID", headers: {'authorization': token});
    return json.decode(response.body);
  }

  Future<dynamic> getGenres() async {
    String token = await LoginHelper.getAuthToken();
    String userID = await LoginHelper.getLoggedInUser();
    
    var response = await http.get("${DotEnv().env['P42_API']}/genres?user_id=$userID", headers: {'authorization': token});
    return json.decode(response.body);
  }

  void setSongData() async {
    var data = await getSongData();
    setState(() {
      _songData = data;
    });
  }

  void setGenres() async {
    var data = await getGenres();
    setState(() {
      _genres = data;
    });
  }

  @override
  void didChangeDependencies() {
    setSongData();
    setGenres();
    super.didChangeDependencies();
}

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length:3,
      child:Scaffold (
      appBar: AppBar(
        title: Text("My Listening Data"),
        bottom:TabBar(
          tabs: [
                Tab(text: "Top Songs",),
                Tab(text: "Top Artists"),
                Tab(text: "Top Genres")
              ],
        )
      ),
      body:Flex(
        direction: Axis.vertical,
        children: [Expanded(
        child: TabBarView(
          children: [
            (_songData!=null) ? _itemListView(context, _songData['top_songs']) : _loadingBar,
            (_songData!=null)  ? _itemListView(context, _songData['top_artists']) : 
            _loadingBar,
            (_genres!=null) ? _itemListView(context, _genres.keys.toList()) : 
            _loadingBar
          ] ,
        )
      )
        ]
      )
      )
    );
  }

  Widget _loadingBar = new Container(
              height: 20.0,
              child: new Center(child: new LinearProgressIndicator()),
            );

  Widget _itemListView(BuildContext context, List data) {
    
    return ListView.separated(
        separatorBuilder:(context, index) => Divider(
        color: Colors.blueGrey,
      ),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          String name = (data[index] is String) ? data[index] : data[index]['name'];
          return ListTile(
            title: Text("${index +1} .  ${name}"),
          );
        },
      );
  }

}