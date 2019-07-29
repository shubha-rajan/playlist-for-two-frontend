import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:playlist_for_two/helpers/login_helper.dart';
import 'package:playlist_for_two/screens/user.dart';
import 'package:playlist_for_two/components/error_dialog.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  dynamic _searchResults = [];
  dynamic _users = [];
  bool _usersLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    searchController.addListener(_updateSearchTerm);
    setUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_updateSearchTerm);
    setUsers();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _updateSearchTerm() {
    String _searchTerm = searchController.text;
    List results = [];
    _users.forEach((user) {
      if ((_searchTerm.length > 0) &&
          (user['name'].toLowerCase().contains(_searchTerm.toLowerCase()))) {
        results.add(user);
      }
    });
    setState(() {
      _searchResults = results;
    });
  }

  Future<List> getUsers() async {
    setState(() {
      _usersLoaded = false;
    });
    String token = await LoginHelper.getAuthToken();
    var response =
        await http.get("${DotEnv().env['P42_API']}/users", headers: {"authorization": token});
    if (response.statusCode == 200) {
      setState(() {
        _usersLoaded = true;
      });
      return json.decode(response.body);
    } else {
      errorDialog(context, 'An error occurred',
          'There was a problem retrieving data from our servers. Check your network connection or try again later.');
      return _users;
    }
  }

  void setUsers() async {
    var userData = await getUsers();
    setState(() {
      _users = userData;
    });
  }

  void viewUser(userID, name) {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => UserPage(userID: userID, name: name)))
        .whenComplete(setUsers);
  }

  Widget _searchListView(BuildContext context, List searchResults) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index]['name']),
          onTap: () {
            viewUser(searchResults[index]['spotify_id'], searchResults[index]['name']);
          },
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Find Friends'),
        ),
        body: Column(
          children: <Widget>[
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
            Expanded(
              
              child: _usersLoaded ? _searchListView(context, _searchResults) :
              Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                        Center(child: CircularProgressIndicator()),
                                        SizedBox(height: 20),
                                        Text('Loading Users...')
                                      ]),
            ),
          ],
        ));
  }
}
