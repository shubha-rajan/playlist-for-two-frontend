import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';




class UserPage extends StatefulWidget {
  UserPage({Key key, this.name, this.userID}) : super(key: key);
  final String name;
  final String userID;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  String _friendStatus;


  Future<Map> getFriends() async {
    String token = await LoginHelper.getAuthToken();
    String userID = await LoginHelper.getLoggedInUser();

    var response = await http.get("${DotEnv().env['P42_API']}/friends?user_id=$userID", headers: {'authorization': token});

    return json.decode(response.body);
  }


  void setFriendStatus(id) async{
    var data = await getFriends();
    var _friends= data['friends'];
    print(_friends);
    dynamic incoming = _friends['incoming'].map((friend) => json.decode(friend)['friend_id']);
    dynamic requested = _friends['sent'].map((friend) => json.decode(friend)['friend_id']);
    dynamic accepted = _friends['accepted'].map((friend) => json.decode(friend)['friend_id']);

    if (incoming.contains(id)) {
      setState(() {
      _friendStatus= 'incoming';
    });
    } else if (requested.contains(id)) {
      setState(() {
      _friendStatus= 'requested';
    });
    } else if (accepted.contains(id)) {
      setState(() {
      _friendStatus= 'accepted';
    });
    } else {
      setState(() {
      _friendStatus= 'none';
    });
    }
  }

  initState() {
    super.initState();
    setFriendStatus(widget.userID);
  }

  void _requestFriend() async {
        String currentUser = await LoginHelper.getLoggedInUser();
        String token = await LoginHelper.getAuthToken();
        var payload = {
          "user_id": currentUser,
          "friend_id": widget.userID,
        };
        dynamic response = await http.post("${DotEnv().env['P42_API']}/request-friend", headers:{"authorization":token}, body:payload);

        if (response.status == 200) {
          setState(() {
            _friendStatus ='requested';
          });
        }

  }

  void _acceptFriend() async {
    String currentUser = await LoginHelper.getLoggedInUser();
    String token = await LoginHelper.getAuthToken();
    var payload = {
          "user_id": currentUser,
          "friend_id": widget.userID,
        };
    dynamic response = await http.post("${DotEnv().env['P42_API']}/accept-friend", headers:{"authorization":token}, body:payload);

    if (response.status == 200) {
          setState(() {
            _friendStatus ='accepted';
          });
        }
  }

  void _viewPlaylists() async {
    print('TODO: Write me!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Playlist for Two"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.name,
            style: TextStyle(fontSize: 50), textAlign: TextAlign.center,),
            SizedBox(height: 30),
            _actionButton(context, _friendStatus, _requestFriend, _acceptFriend, _viewPlaylists)
          ]
        )
      )
    );
  }
}
Widget _actionButton(BuildContext context, String status, Function requestFriend, Function acceptFriend, Function viewPlaylist) {

  Widget button;
  switch(status) {
    case 'none': {
      button = MaterialButton(
              onPressed: requestFriend,
              child: Text('Send a Friend Request',
                    style: TextStyle(fontSize: 20)
                  ),
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  color:Colors.blueAccent, 
                  height: 50,
                  minWidth:300
            );
    }
    break;
    case 'requested': {
      button = MaterialButton(
              onPressed: null,
              child: Text('Friend Request Sent',
                    style: TextStyle(fontSize: 20)
                  ),
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  color:Colors.blueAccent, 
                  height: 50,
                  minWidth:300
            );
    }
    break;
    case 'accepted': {
      button = MaterialButton(
              onPressed: viewPlaylist,
              child: Text('Show Playlist',
                    style: TextStyle(fontSize: 20)
                  ),
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  color:Colors.blueAccent, 
                  height: 50,
                  minWidth:300
            );
    }
    break;
    case 'incoming': {
      button = MaterialButton(
              onPressed: acceptFriend,
              child: Text('Accept Friend Request',
                    style: TextStyle(fontSize: 20)
                  ),
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  color:Colors.blueAccent, 
                  height: 50,
                  minWidth:300
            );
    }
    break;
  }
  return(button);
}