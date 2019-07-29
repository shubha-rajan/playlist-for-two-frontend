import 'dart:convert';
import 'package:flutter/material.dart';

Widget friendListView(
    BuildContext context, List data, Function tapCallback, Function refreshCallback) {
  return RefreshIndicator(
      onRefresh: refreshCallback,
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.blueGrey,
        ),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(json.decode(data[index])['name']),
            onTap: () {
              tapCallback(json.decode(data[index])['friend_id'], json.decode(data[index])['name']);
            },
          );
        },
      ));
}
