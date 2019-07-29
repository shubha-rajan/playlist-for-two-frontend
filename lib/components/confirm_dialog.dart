import 'package:flutter/material.dart';

Future<void> confirmDialog(
    BuildContext context, String titleText, String contentText, Function actionCallback) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titleText),
        content: Text(contentText),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Confirm'),
            onPressed: () {
              Navigator.of(context).pop();
              actionCallback();
            },
          ),
        ],
      );
    },
  );
}
