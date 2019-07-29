import 'package:flutter/material.dart';
import 'package:playlist_for_two/screens/playlist_info.dart';

Widget playlistListView(BuildContext context, List data, Function refreshCallback) {
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
              title: Text(data[index]['description']['name']),
              onTap: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PlaylistInfo(playlist: data[index])))
                    .whenComplete(refreshCallback);
              });
        },
      ));
}
