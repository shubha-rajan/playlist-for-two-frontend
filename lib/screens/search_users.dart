import 'package:flutter/material.dart';


class FriendsPage extends StatefulWidget {
  FriendsPage ({Key key}) : super(key: key);

  

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List _friends = [];

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Find Friends'),
        bottom: TabBar(
          tabs: [
                Tab(text: "Incoming",),
                Tab(text: "Sent"),
                Tab(text: "Accepted"),
              ],
        )
        
      ),
      body: _myListView(context, _friends),
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