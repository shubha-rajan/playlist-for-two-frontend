import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';


import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/list.dart';
import 'package:playlist_for_two/screens/friends.dart';
import 'package:playlist_for_two/screens/user.dart';
import 'package:playlist_for_two/screens/search_users.dart';
import 'package:playlist_for_two/screens/playlist_info.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key, this.name, this.imageUrl, this.authToken, this.userID}) : super(key: key);
  final String name;
  final String imageUrl;
  final String authToken;
  final String userID;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic _friends={
    'accepted':[],
    'incoming':[],
    'sent':[],
  };
  List<dynamic> _playlists = [];

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  Future<Map> getFriends() async {
    String token = widget.authToken;
    String userID = widget.userID;

    var response = await http.get("${DotEnv().env['P42_API']}/friends?user_id=$userID", headers: {'authorization': token});

  if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return _friends;
    }
  }

  Future<List> getPlaylists() async {
    String token = widget.authToken;
    String userID = widget.userID;

    var response = await http.get("${DotEnv().env['P42_API']}/playlists?user_id=$userID", headers: {'authorization': token});

  if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return _playlists;
    }
  }

  void setData() async {
    var friends = await getFriends();
    var playlists = await getPlaylists();
    setState(() {
      _friends= friends['friends'];
      _playlists= playlists;
    });
  }
  
  void _viewUser(userID, name) {
    Navigator.push(context,
    MaterialPageRoute(
      builder: (context) => UserPage(userID: userID, name:name)
    )
  );
  }

  @override
  void didChangeDependencies() {
    setData();
    super.didChangeDependencies();
  }


  void _getUserSongs() async {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => ListPage()
      )
    );
  }


  Widget _friendListView(BuildContext context, List data) {
    return ListView.separated(
      separatorBuilder:(context, index) => Divider(
        color: Colors.blueGrey,
      ),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(json.decode(data[index])['name']),
            onTap: (){
              _viewUser(json.decode(data[index])['friend_id'], json.decode(data[index])['name']);
            },
          );
        },
      );
  }
  Widget _playlistListView(BuildContext context, List data) {
    return ListView.separated(
        separatorBuilder:(context, index) => Divider(
        color: Colors.blueGrey,
      ), 
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(data[index]['description']['name']),
            trailing: Icon(Icons.arrow_forward),
            onTap:(){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistInfo(playlist: data[index])));
            }
          );
        },
      );
  }
  Widget _userCard() {
    return ( Row(
      children: <Widget>[
        Container(height: 100, width:100, 
          child: ClipRRect(
            borderRadius: new BorderRadius.circular(50.0),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              placeholder: (context, url) => new CircularProgressIndicator(),
              errorWidget: (context, url, error) => new Icon(Icons.error),
            )
          )
          ),
        Padding(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('${widget.name}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              SizedBox(height:10),
              Row(children: <Widget>[
                Padding(
                  child:Text('${_friends['accepted'].length} friends'), 
                  padding:EdgeInsets.only(right:5)),
                Padding(
                  child:Text('${_playlists.length} Playlists'), 
                  padding:EdgeInsets.only(left:5)),
              ]
              ),
              SizedBox(height:10),
              MaterialButton(
                
                onPressed: _getUserSongs,
                child: Text('My Song Data',
                  style: TextStyle(fontSize: 15)
                ),
                textColor: Colors.white,
                color:Colors.blueAccent, 
              ),
            ]
          ),
          padding: EdgeInsets.only(left:30),
        )
      ]
    )
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Playlist for Two"),
      ),
      drawer: Drawer(child:DrawerListView()),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
            child: _userCard(),
            padding: EdgeInsets.all(30),
            ),
            
            Expanded(
            child:  DefaultTabController(
              length:2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
              
                children: <Widget>[
              Container(
                child:TabBar(
                tabs: [
                  Tab(text: "Friends"),
                  Tab(text: "Playlists"),
                ]
                ),
              width: 400,),
              Flexible(
                child:TabBarView(
                children: [
                  _friendListView(context, _friends['accepted']),
                  _playlistListView(context, _playlists)
                ] ,
              ),
              fit: FlexFit.loose,)
            ],
            
            )
          )
          ), 
          ]
        )
      )
    );
  }
}

class DrawerListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _logOutUser() {
      LoginHelper.clearLoggedInUser();
      Navigator.pushReplacementNamed(context, '/login');
    }

    void _getFriendRequests() async {
    Navigator.push(context, 
        MaterialPageRoute(builder: (context) => FriendsPage())
      );

    }

    void _findFriends(){
    Navigator.push(context, 
      MaterialPageRoute(
            builder: (context) => SearchPage()
      )
    );
  }
    return ListView(
      
      children: <Widget>[
          Container(
            child:Image.asset('graphics/logo-white.png'),
            padding: EdgeInsets.all(50),
          ),
          ListTile(
              leading: Icon(Icons.search),
              title: Text('Find Friends'),
              onTap: () {
                   _findFriends();
              },
          ),
          ListTile(
              leading: Icon(Icons.person_add),
              title: Text('View Friend Requests'),
              onTap: () {
                   _getFriendRequests();
              },
          ),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log Out'),
              onTap: () {
                   _logOutUser();
              },
          )
      ],
    );
  }
}
