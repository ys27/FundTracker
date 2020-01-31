import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class StatTitle extends StatelessWidget {
  final String title;
  final MainAxisAlignment alignment;
  final Widget appendWidget;

  StatTitle({
    this.title,
    this.alignment = MainAxisAlignment.start,
    this.appendWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 30.0),
        ),
        appendWidget ?? Container(),
      ],
    );
  }
}

class Alert extends StatelessWidget {
  final String content;

  Alert(this.content);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Are you sure?"),
      content: Text(content),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: Text("Confirm"),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Theme.of(context).primaryColor,
      child: Center(
        child: SpinKitPulse(
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}
