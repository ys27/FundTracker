import 'package:flutter/material.dart';

Widget StatTitle({
  String title,
  MainAxisAlignment alignment = MainAxisAlignment.start,
  Widget appendWidget,
}) =>
    Row(
      mainAxisAlignment: alignment,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 30.0),
        ),
        appendWidget ?? Container(),
      ],
    );
