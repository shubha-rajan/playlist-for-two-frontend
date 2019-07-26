import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/user.dart';

class SearchPage extends StatefulWidget {
  SearchPage ({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  dynamic _searchResults = [];
  dynamic _users = [];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_updateSearchTerm);
  }

   @override
   void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  void _updateSearchTerm() {
    String _searchTerm = searchController.text;
    List results = [];
    _users.forEach((user) {
      if ((_searchTerm.length > 0) && (user['name'].toLowerCase().contains(_searchTerm.toLowerCase()))) {
        results.add(user);
      } 
    });
    setState(() {
      _searchResults = results;
    });
  }

  Future<List> getUsers() async {
    String token = await LoginHelper.getAuthToken();
    var response = await http.get("${DotEnv().env['P42_API']}/users", headers:{"authorization":token} );

    return json.decode(response.body);
  }

  void setUsers() async {
    var userData = await getUsers();
    setState(() {
      _users= userData;
    });
  }

  void viewUser(userID, name) {
    Navigator.push(context,
    MaterialPageRoute(
      builder: (context) => UserPage(userID: userID, name:name)
    )
  );
  }

  Widget _searchListView(BuildContext context, List searchResults) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(searchResults[index]['name']),
            onTap: (){
              viewUser(searchResults[index]['spotify_id'], searchResults[index]['name']);
            },
          );
        },
      );
  }

  Widget build(BuildContext context) {
    setUsers();
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Friends'),    
      ),
      body:Column(
        children: <Widget>[
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0))
                  )
                ),
              ),
              Expanded(child: _searchListView(context, _searchResults),)
              ,
        ],
      ) 
    );
  }

  
}