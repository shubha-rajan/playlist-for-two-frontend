import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/components/error_dialog.dart';

class TopMusicPage extends StatefulWidget {
  TopMusicPage({Key key}) : super(key: key);

  @override
  _TopMusicPageState createState() => _TopMusicPageState();
}

class _TopMusicPageState extends State<TopMusicPage> {
  dynamic _genres = [];
  Widget _loadingBar = new Container(
    height: 20.0,
    child: new Center(child: new LinearProgressIndicator()),
  );

  dynamic _songData = {'top_songs': [], 'top_artists': []};

  @override
  void didChangeDependencies() {
    setSongData();
    setGenres();
    super.didChangeDependencies();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<Map> getSongData() async {
    String token = await LoginHelper.getAuthToken();
    String userID = await LoginHelper.getLoggedInUser();

    var response = await http.get("${DotEnv().env['P42_API']}/listening-history?user_id=$userID",
        headers: {'authorization': token});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      errorDialog(context, 'An error occurred',
          'There was a problem retrieving data from our servers. Check your network connection or try again later.');
      return _songData;
    }
  }

  Future<dynamic> getGenres() async {
    String token = await LoginHelper.getAuthToken();
    String userID = await LoginHelper.getLoggedInUser();

    var response = await http.get("${DotEnv().env['P42_API']}/genres?user_id=$userID",
        headers: {'authorization': token});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      errorDialog(context, 'An error occurred',
          'There was a problem retrieving data from our servers. Check your network connection or try again later.');
      return _songData;
    }
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

  Widget _itemListView(BuildContext context, List data) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: Colors.blueGrey,
      ),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        String name = (data[index] is String) ? data[index] : data[index]['name'];
        return ListTile(
          title: Text("${index + 1} .  $name"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
                title: Text("My Top Music"),
                bottom: TabBar(
                  tabs: [
                    Tab(
                      text: "Top Songs",
                    ),
                    Tab(text: "Top Artists"),
                    Tab(text: "Top Genres")
                  ],
                )),
            body: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: (_songData == null) || (_genres == null)
                          ? _loadingBar
                          : TabBarView(
                              children: [
                                _itemListView(context, _songData['top_songs']),
                                _itemListView(context, _songData['top_artists']),
                                _itemListView(context, _genres.keys.toList())
                              ],
                            ))
                ])));
  }
}
