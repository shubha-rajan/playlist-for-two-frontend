import 'package:flutter/material.dart';
import 'package:playlist_for_two/components/confirm_dialog.dart';

Widget actionButton(BuildContext context, String name, String status, Function requestFriend,
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
          onPressed: () {
            confirmDialog(
                context,
                "Are you sure you want to remove $name from your friends?",
                "You will no longer be able to create and share playlists. To connect with $name again, they will need to accept your friend request",
                removeFriend);
          },
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
