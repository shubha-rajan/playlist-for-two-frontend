import 'package:flutter/material.dart';

Widget actionButton(BuildContext context, String status, Function requestFriend,
    Function acceptFriend, Function removeFriend) {
  Widget button;
  switch (status) {
    case 'none':
      {
        button = MaterialButton(
          onPressed: requestFriend,
          child: Text('Add Friend', style: TextStyle(fontSize: 15)),
          textColor: Colors.white,
          color: Colors.blueAccent,
        );
      }
      break;
    case 'requested':
      {
        button = MaterialButton(
          onPressed: removeFriend,
          child: Text('Cancel Request', style: TextStyle(fontSize: 15)),
        );
      }
      break;
    case 'accepted':
      {
        button = MaterialButton(
          onPressed: removeFriend,
          child: Text('Remove Friend', style: TextStyle(fontSize: 15)),
          textColor: Colors.white,
          color: Colors.red,
        );
      }
      break;
    case 'incoming':
      {
        button = MaterialButton(
          onPressed: acceptFriend,
          child: Text('Accept Request', style: TextStyle(fontSize: 15)),
          textColor: Colors.white,
          color: Colors.blueAccent,
        );
      }
      break;
    default:
      {
        button = SizedBox();
      }
  }
  return (button);
}
