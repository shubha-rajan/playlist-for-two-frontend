import 'package:flutter/material.dart';


class FriendsPage extends StatefulWidget {
  FriendsPage ({Key key}) : super(key: key);
  

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  dynamic data;
  String title;

  Widget build(BuildContext context) {

    return DefaultTabController(
      length:3,
      child: Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: TabBar(
          tabs: [
                Tab(text: "Incoming Requests",),
                Tab(text: "Sent Requests"),
                Tab(text: "Accepted Requests"),
              ],
        )
        
      ),
      body: TabBarView(
          children: [
            _myListView(context, data['incoming']),
            _myListView(context, data['sent']),
            _myListView(context, data['accepted']),
          ] ,
          
          
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