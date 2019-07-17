import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playlist_for_two/helpers/login_helper.dart';




class UserPage extends StatelessWidget {
  UserPage({Key key, this.name, this.userID}) : super(key: key);
  final String name;
  final String userID;

  @override
  Widget build(BuildContext context) {

    void _requestFriend() async {
        String currentUser = await LoginHelper.getLoggedInUser();
        String token = await LoginHelper.getAuthToken();
        var payload = {
          "user_id": currentUser,
          "friend_id": userID,
        };
        dynamic response = await http.post("${DotEnv().env['P42_API']}/request-friend", headers:{"authorization":token}, body:payload);

        print(response.body);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Playlist for Two"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(name,
            style: TextStyle(fontSize: 50), textAlign: TextAlign.center,),
            SizedBox(height: 30),
            MaterialButton(
              onPressed: _requestFriend,
              child: Text('Send a Friend Request',
                    style: TextStyle(fontSize: 20)
                  ),
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  color:Colors.blueAccent, 
                  height: 50,
                  minWidth:300
            )
          ]
        )
      )
    );
  }
}