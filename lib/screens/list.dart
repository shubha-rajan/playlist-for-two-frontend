import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';


class ListPage extends StatefulWidget {
  ListPage ({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListPageState createState() => _ListPageState();

}


class _ListPageState extends State<ListPage> {

  var _songData= {
    'top_songs':[],
    'saved_songs':[],
    'followed_artists':[],
    'top_artists':[]
  };

  Future<Map> getData() async {
    String token = await LoginHelper.getAuthToken();
    String userID = await LoginHelper.getLoggedInUser();
    
    var response = await http.get("${DotEnv().env['P42_API']}/listening-history?user_id=$userID", headers: {'authorization': token});
    return json.decode(response.body);
  }

  void setData() async {
    var data = await getData();
    setState(() {
      _songData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    setData();
    return DefaultTabController(
      length:2,
      child:Scaffold (
      appBar: AppBar(
        title: Text(widget.title),
        bottom:TabBar(
          tabs: [
                Tab(text: "Top Songs",),
                Tab(text: "Saved Songs"),
              ],
        )
      ),
      body:Flex(
        direction: Axis.vertical,
        children: [Expanded(
        child: TabBarView(
          children: [
             _myListView(context, _songData['top_songs']),
            _myListView(context, _songData['saved_songs'])
          ] ,
        )
      )
        ]
      )
      )
    );
  }
  Widget _myListView(BuildContext context, List data) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(data[index]['name']),
          );
        },
      );
  }
}