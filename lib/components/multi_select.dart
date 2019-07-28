import 'package:flutter/material.dart';

// Code for MultiSelect widget adapted from
// https://medium.com/@KarthikPonnam/flutter-multi-select-choicechip-244ea016b6fa
// and https://medium.com/@KarthikPonnam/flutter-loadmore-in-listview-23820612907d

class MultiSelect extends StatefulWidget {
  MultiSelect(this.data, this.totalSelected, {this.onSelectionChanged});

  final List<dynamic> data;
  final int totalSelected;

  @override
  _MultiSelectState createState() => _MultiSelectState();

  final Function(List<String>) onSelectionChanged;
}

class _MultiSelectState extends State<MultiSelect> {
  int perPage = 5;
  int present = 0;

  List<dynamic> _displayed = [];
  List<String> _selected = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      if ((present + perPage) > widget.data.length) {
        _displayed.addAll(widget.data.getRange(present, widget.data.length));
      } else {
        _displayed.addAll(widget.data.getRange(present, present + perPage));
      }
      present = present + perPage;
    });
  }

  Future<void> _seedLimitDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('More than 5 seeds selected'),
          content: Text(
              'You can choose a maximum of 5 seeds for your custom playlist. Please remove some of your selections before adding more.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _buildChoiceList() {
    List<Widget> choices = List();
    _displayed.forEach((item) {
      String name = (item is String) ? item : item['name'];
      String id = (item is String) ? item : item['id'];
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(name),
          selected: _selected.contains(id),
          onSelected: (selected) {
            if (_selected.contains(id)) {
              setState(() {
                _selected.remove(id);
              });
              widget.onSelectionChanged(_selected);
            } else if (widget.totalSelected >= 5) {
              _seedLimitDialog();
            } else {
              setState(() {
                _selected.add(id);
                widget.onSelectionChanged(_selected);
              });
            }
          },
        ),
      ));
    });
    if (present <= widget.data.length) {
      choices.add(FlatButton(
        child: Text(
          "Load More",
          style: TextStyle(color: Colors.lightBlue),
        ),
        onPressed: () {
          setState(() {
            if ((present + perPage) > widget.data.length) {
              _displayed.addAll(widget.data.getRange(present, widget.data.length));
            } else {
              _displayed.addAll(widget.data.getRange(present, present + perPage));
            }
            present = present + perPage;
          });
        },
      ));
    }

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
