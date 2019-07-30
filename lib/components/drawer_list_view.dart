import 'package:flutter/material.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/friend_requests.dart';
import 'package:playlist_for_two/screens/search_users.dart';
import 'package:playlist_for_two/screens/getting_started.dart';

class DrawerListView extends StatefulWidget {
  DrawerListView({Key key, this.refreshCallback}) : super(key: key);

  final Function refreshCallback;

  @override
  _DrawerListViewState createState() => _DrawerListViewState();
}

class _DrawerListViewState extends State<DrawerListView> {
  @override
  Widget build(BuildContext context) {
    void _logOutUser() {
      LoginHelper.clearLoggedInUser();
      Navigator.pushReplacementNamed(context, '/login');
    }

    void _getFriendRequests() async {
      Navigator.push(context, MaterialPageRoute(builder: (context) => FriendRequestsPage()))
          .whenComplete(widget.refreshCallback);
    }

    void _findFriends() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()))
          .whenComplete(widget.refreshCallback);
    }

    void _getHelp() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage()))
          .whenComplete(widget.refreshCallback);
    }

    return ListView(
      children: <Widget>[
        Container(
          child: Image.asset('graphics/logo-white.png'),
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
            leading: Icon(Icons.info_outline),
            title: Text('Getting Started'),
            onTap: () {
              _getHelp();
            }),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Log Out'),
          onTap: () {
            _logOutUser();
          },
        ),
      ],
    );
  }
}
