import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';


import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/list.dart';
import 'package:playlist_for_two/screens/friends.dart';



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

  void _getUserSongs() async {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => ListPage()
      )
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
                  child:Text('8 friends'), 
                  padding:EdgeInsets.only(right:5)),
                Padding(
                  child:Text('10 Playlists'), 
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
            
            SizedBox(height: 30),
            SizedBox(height: 30),
            DefaultTabController(
            length:2,
            child: Column(children: <Widget>[
              TabBar(
                tabs: [
                  Tab(text: "Friends"),
                  Tab(text: "Playlists")
                ]
                ),
                
            ],
            
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
    return ListView(
      
      children: <Widget>[
          Container(
            child:Image.asset('graphics/logo-white.png'),
            padding: EdgeInsets.all(50),
          ),
          ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Friend Requests'),
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
