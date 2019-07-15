import 'package:flutter/material.dart';


class ListPage extends StatelessWidget {
  ListPage ({Key key, this.itemList, this.title}) : super(key: key);
  final List itemList;
  final String title;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Expanded(
            child: _myListView(context, itemList),
          )]
            ),
          
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