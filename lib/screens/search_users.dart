import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:playlist_for_two/helpers/login_helper.dart';


class SearchPage extends StatefulWidget {
  SearchPage ({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController editingController = TextEditingController();
  var _users = [];

  Future<List> getUsers() async {
    String token = await LoginHelper.getAuthToken();
    var response = await http.get("${DotEnv().env['P42_API']}/users", headers:{"authorization":token} );

    return json.decode(response.body);
  }

  void setUsers() async {
    var data = await getUsers();
    setState(() {
      _users= data;
    });
  }


  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Friends'),    
      ),
      body:Column(
        children: <Widget>[
              TextField(
                controller: editingController,
                decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0))
                  )
                ),
              ),
              _myListView(context, _users),
        ],
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