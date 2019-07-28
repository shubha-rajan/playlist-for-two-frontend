import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget userCard(imageUrl, name, numFriends, numPlaylists, button) {
  return (Row(children: <Widget>[
    Container(
        height: 100,
        width: 100,
        child: ClipRRect(
            borderRadius: new BorderRadius.circular(50.0),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => new CircularProgressIndicator(),
              errorWidget: (context, url, error) => new Icon(Icons.error),
            ))),
    Padding(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('$name',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            SizedBox(height: 10),
            Row(children: <Widget>[
              Padding(child: Text('$numFriends friends'), padding: EdgeInsets.only(right: 5)),
              Padding(child: Text('$numPlaylists Playlists'), padding: EdgeInsets.only(left: 5)),
            ]),
            SizedBox(height: 10),
            button
          ]),
      padding: EdgeInsets.only(left: 30),
    )
  ]));
}
