import 'package:flutter/material.dart';


class FriendsPage extends StatefulWidget {
  FriendsPage ({Key key, this.data, this.title}) : super(key: key);
  final dynamic data;
  final String title;

  

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  
  void _findFriends(){
    
  }

  Widget build(BuildContext context) {

    return DefaultTabController(
      length:3,
      child: Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          tabs: [
                Tab(text: "Incoming",),
                Tab(text: "Sent"),
                Tab(text: "Accepted"),
              ],
        )
        
      ),
      body: TabBarView(
          children: [
            _myListView(context, widget.data['incoming']),
            _myListView(context, widget.data['sent']),
            _myListView(context, widget.data['accepted']),
          ] ,
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: _findFriends,
        child: Icon(Icons.add), 
        backgroundColor: Colors.blueAccent
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